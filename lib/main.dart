import 'package:agora_livestream/repositories/firebase_repository.dart';
import 'package:agora_livestream/screens/livestreams.dart';
import 'package:agora_livestream/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp _initialization = await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  FirebaseRepo firebaseRepo = FirebaseRepo();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Livestream',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
          print(snapshot.hasData);
          if (snapshot.hasData) {
            return LiveStreamsScreen();
          } else {
            return LoginScreen();
          }
        },
      ),
    );
  }
}
