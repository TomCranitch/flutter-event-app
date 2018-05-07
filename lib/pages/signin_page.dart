import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = new GoogleSignIn();



class SignInPage extends StatelessWidget {

  ///Logs in the current user and then navigates to the home page when successful
  Future<Null> _ensureLoggedInWithGoogle(BuildContext context) async {
    GoogleSignInAccount googleUser = _googleSignIn.currentUser;

    googleUser = await _googleSignIn.signIn();

    if(googleUser == null)
      googleUser = await _googleSignIn.signInSilently();
    if(googleUser == null) {
      googleUser = await _googleSignIn.signIn();
      //TODO: Add analytics
    }

    if (await _auth.currentUser() == null) {
      GoogleSignInAuthentication googleAuth = await _googleSignIn.currentUser.authentication;
      final FirebaseUser user = await _auth.signInWithGoogle(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken
      );
    }

    if (await _auth.currentUser() != null)
      Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new HomePage()));
  }

  Future<Null> _signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return new Material(
      child: new Column(
        children: <Widget>[
          new Expanded(
            child: new MaterialButton(
              onPressed: () => _ensureLoggedInWithGoogle(context),
              child: new Text("Sign in"),
            ),
          ),
          new Expanded(
            child: new MaterialButton(
              onPressed: () => _signOut,
              child: new Text("Sign Out"),
            ),
          )
        ],
      )
    );
  }

}
