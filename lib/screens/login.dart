import 'package:agora_livestream/repositories/firebase_repository.dart';
import 'package:agora_livestream/screens/livestreams.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key key}) : super(key: key);
  FirebaseRepo _firebaseRepo = FirebaseRepo();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign In')),
      body: Center(
        child: RaisedButton(
          color: Theme.of(context).primaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
          child: Text(
            'SIGN IN WITH GOOGLE',
            style: Theme.of(context)
                .textTheme
                .bodyText1
                .copyWith(color: Colors.white),
          ),
          onPressed: () {
            _firebaseRepo.signInWithGoogle().then((UserCredential value) async {
              if (value?.user != null) {
                await _firebaseRepo.authenticateUser(value.user);
              } else {
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text('An error occured. Try again'),
                  backgroundColor: Colors.red,
                ));
              }
            });
          },
        ),
      ),
    );
  }
}
