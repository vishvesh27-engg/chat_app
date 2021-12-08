import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'homepage.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool pageinitialised = false;
  final auth = FirebaseAuth.instance;

  void initState() {
    // TODO: implement initState
    isuserloggedin();
    super.initState();
  }

  isuserloggedin() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool userloggedin = (sharedPreferences.getString('id') ?? '').isNotEmpty;
    if (userloggedin) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => homepage()));
    } else {
      setState(() {
        pageinitialised = true;
      });
    }
  }

  handleSignIn() async {
    final res = await GoogleSignIn().signIn();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final aut = await res!.authentication;
    final creds = GoogleAuthProvider.credential(
        idToken: aut.idToken, accessToken: aut.accessToken);
    final firebaseuser = (await auth.signInWithCredential(creds)).user;
    if (firebaseuser != null) {
      final result = (await FirebaseFirestore.instance
              .collection('users')
              .where('id', isEqualTo: firebaseuser.uid)
              .get())
          .docs;
      if (result.isEmpty) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseuser.uid)
            .set({
          "id": firebaseuser.uid,
          "name": firebaseuser.displayName,
          "profile_pic": firebaseuser.photoURL,
          "created_at": DateTime.now().millisecondsSinceEpoch,
        });
        sharedPreferences.setString("id", firebaseuser.uid);
        sharedPreferences.setString("name", firebaseuser.displayName ?? '');
        sharedPreferences.setString("profile_pic", firebaseuser.photoURL ?? '');

        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => homepage()));
      } else {
        sharedPreferences.setString("id", result[0]["id"]);
        sharedPreferences.setString("name", result[0]["name"]);
        sharedPreferences.setString("profile_pic", result[0]["profile_pic"]);

        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => homepage()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (pageinitialised)
          ? Center(
              child: ElevatedButton(
                child: const Text('Sign in'),
                onPressed: handleSignIn,
              ),
            )
          : const Center(
              child: SizedBox(
                height: 36,
                width: 36,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
            ),
    );
  }
}
