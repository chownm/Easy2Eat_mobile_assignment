import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy2eat/core/constants/user_session.dart';

Future<void> saveProfile_FireStore(
    String name, String email, String phone, String carPlate) async {
  final String? uid = UserSession.currentUid;
  if (uid != null) {
    // SetOptions(merge: true) merges new fields WITHOUT overwriting existing fields (password, role, etc.)
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'phone': phone,
      'carPlate': carPlate,
    }, SetOptions(merge: true));
  }
}
