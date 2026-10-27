import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  Future<String?> signup({required String email, required String password}) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      String? uid = userCredential.user?.uid;
      print("Successfully registered with UID: $uid");

      return uid;
    } on FirebaseAuthException catch (e) {
      String message = 'Registration failed: ${e.message ?? e.code}';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is invalid format.';
      }
      throw message;
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }
}
