import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class chat_page extends StatefulWidget {
  final docs;
  const chat_page({Key? key, this.docs}) : super(key: key);

  @override
  _chat_pageState createState() => _chat_pageState();
}

class _chat_pageState extends State<chat_page> {
  String groupChatId = '';
  String? userID;

  TextEditingController textEditingController = TextEditingController();

  ScrollController scrollController = ScrollController();
  @override
  void initState() {
    // TODO: implement initState
    getcommonid();
    super.initState();
  }

  getcommonid() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    userID = sharedPreferences.getString('id');
    String otherid = widget.docs['id'];
    if (userID!.compareTo(otherid) > 0) {
      groupChatId = '$userID - $otherid';
    } else {
      groupChatId = '$otherid - $userID';
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat page!'),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('messages')
              .doc(groupChatId)
              .collection(groupChatId)
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return Column(
                children: <Widget>[
                  Expanded(
                      child: ListView.builder(
                    itemBuilder: (listContext, index) =>
                        buildItem(snapshot.data!.docs[index]),
                    itemCount: snapshot.data!.docs.length,
                    controller: scrollController,
                    reverse: true,
                  )),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: textEditingController,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () => sendmsg(),
                      ),
                    ],
                  ),
                ],
              );
            } else {
              return const Center(
                  child: SizedBox(
                height: 36,
                width: 36,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ));
            }
          }),
    );
  }

  sendmsg() {
    String msg = textEditingController.text.trim();
    if (msg.isNotEmpty) {
      var ref = FirebaseFirestore.instance
          .collection('messages')
          .doc(groupChatId)
          .collection(groupChatId)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      FirebaseFirestore.instance.runTransaction((transaction) async {
        await transaction.set(ref, {
          "senderId": userID,
          "anotherUserId": widget.docs['id'],
          "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
          'content': msg,
          "type": 'text',
        });
      });
      scrollController.animateTo(0.0,
          duration: Duration(milliseconds: 100), curve: Curves.bounceInOut);
    } else {
      print('Please enter some text to send');
    }
  }

  buildItem(doc) {
    return Padding(
      padding: EdgeInsets.only(
          top: 8.0,
          left: ((doc['senderId'] == userID) ? 64 : 0),
          right: ((doc['senderId'] == userID) ? 0 : 64)),
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
            color: ((doc['senderId'] == userID)
                ? Colors.grey
                : Colors.greenAccent),
            borderRadius: BorderRadius.circular(8.0)),
        child: (doc['type'] == 'text')
            ? Text('${doc['content']}')
            : Image.network(doc['content']),
      ),
    );
  }
}
