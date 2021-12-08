import 'package:chat_app/chatpage.dart';
import 'package:chat_app/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class homepage extends StatefulWidget {
  const homepage({Key? key}) : super(key: key);

  @override
  _homepageState createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  String? userid;
  @override
  void initState() {
    // TODO: implement initState
    getuserid();
    super.initState();
  }

  getuserid() async {
    SharedPreferences sharedpreferences = await SharedPreferences.getInstance();
    userid = sharedpreferences.getString('id');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            ElevatedButton(
                onPressed: () async {
                  await GoogleSignIn().signOut();
                  SharedPreferences sharedPrefs =
                      await SharedPreferences.getInstance();
                  sharedPrefs.setString('id', '');
                  Navigator.of(context).pop();
                },
                child: Text('Logout'))
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) => ListView.builder(
                  itemBuilder: (listContext, index) =>
                      buildItem(snapshot.data!.docs[index]),
                  itemCount: snapshot.data!.docs.length,
                )));
  }

  buildItem(doc) {
    return (doc['id'] != userid)
        ? GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => chat_page(docs: doc)));
            },
            child: Card(
              color: Colors.lightBlue,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: Center(
                    child: Text(doc['name']),
                  ),
                ),
              ),
            ))
        : Container();
  }
}
