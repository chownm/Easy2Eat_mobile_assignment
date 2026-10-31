import 'package:firebase_auth/firebase_auth.dart';

class UserSession {
  /// Automatically retrieves the active user's UID from Firebase Auth
  static String? get currentUid => FirebaseAuth.instance.currentUser?.uid;


  static String? _cachedRole;
  static String? get role => _cachedRole;

  static void setRole(String? userRole) {
    _cachedRole = userRole;
  }

  static Future<void> logout() async {
    _cachedRole = null;
    await FirebaseAuth.instance.signOut();
  }

  static bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;
}
