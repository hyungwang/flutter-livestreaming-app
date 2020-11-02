import 'package:agora_livestream/models/app_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseRepo {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future<User> getCurrentUser() async {
    return _auth.currentUser;
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    return await _auth.signInWithCredential(credential);
  }

  Future<bool> findUser(User user) async {
    QuerySnapshot result = await firestore
        .collection('users')
        .where('email', isEqualTo: user.email)
        .get();
    return result.docs.length > 0;
  }

  Future<bool> authenticateUser(User user) async {
    if (await findUser(user)) {
      return true;
    } else {
      await firestore
          .collection('users')
          .add(AppUser.fromMap(user).toMap(user));
      return true;
    }
  }

  Future<void> signOut() async {
    await GoogleSignIn()
      ..disconnect()
      ..signOut();
    return _auth.signOut();
  }
}
