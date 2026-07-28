import 'package:firebase_auth/firebase_auth.dart';

class AuthGuard {
  static bool isLoggedIn() {
    return FirebaseAuth.instance.currentUser != null;
  }
}
