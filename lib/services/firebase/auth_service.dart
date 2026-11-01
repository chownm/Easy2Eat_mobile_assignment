import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/constants/user_session.dart';

class AuthService {
  Future<String?> signup({required String email, required String password}) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      String? uid = userCredential.user?.uid;
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

  static Future<bool> googleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return false;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final uid = userCredential.user?.uid;
      if (uid != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (!doc.exists) {
          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'name': userCredential.user?.displayName ?? 'User',
            'email': userCredential.user?.email ?? '',
            'role': 'customer',
          }, SetOptions(merge: true));
          UserSession.setRole('customer');
        } else {
          final role = doc.data()?['role'] as String? ?? '';
          UserSession.setRole(role);
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Signs out from both Google Sign-In and Firebase Auth
  static Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    try {
      UserSession.logout();
    } catch (_) {}

  }
}
