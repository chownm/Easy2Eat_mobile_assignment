import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/user_session.dart';

Future<void> saveNewUser(String uid, String name, String role, String email, String password) async {
  await FirebaseFirestore.instance.collection('users').doc(uid).set({
    'name': name,
    'email': email,
    'role': role,
    'password' : password,
  });
  UserSession.setRole(role);
}

Future<String?> getUserRole(String email, String password) async {
  UserCredential userCredential = await FirebaseAuth.instance
      .signInWithEmailAndPassword(email: email, password: password);

  String? uid = userCredential.user?.uid;

  DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();

  if(snapshot.exists){
    String role = snapshot.get('role');
    UserSession.setRole(role);
    return role;
  }
  return null;
}
