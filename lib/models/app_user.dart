import 'package:firebase_auth/firebase_auth.dart';

class AppUser {
  String email;
  String photoURL;
  String displayName;

  Map toMap(User user) {
    var data = Map<String, dynamic>();
    data['email'] = user.email;
    data['displayName'] = user.displayName;
    data['photoURL'] = user.photoURL;
    return data;
  }

  AppUser.fromMap(User user) {
    this.email = user.email;
    this.displayName = user.displayName;
    this.photoURL = user.photoURL;
  }
}
