import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy2eat/core/constants/user_session.dart';

class TopHeaderWidget extends StatelessWidget {
  const TopHeaderWidget({super.key});

  /// Updates the store's opening status directly in the Firestore 'users' collection.
  Future<void> _toggleStoreStatus(BuildContext context, String activeUid, bool newIsOpen) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(activeUid)
          .set({
        'isOpen': newIsOpen,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve the active user UID from session or FirebaseAuth
    final activeUid = UserSession.currentUid ?? FirebaseAuth.instance.currentUser?.uid;

    // Handle unauthenticated state gracefully
    if (activeUid == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Text('No active user session', style: TextStyle(color: Colors.grey)),
      );
    }

    // Stream live data from the 'users' collection for this specific vendor UID
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(activeUid)
          .snapshots(),
      builder: (context, snapshot) {
        // Fallback to empty map if data is still loading or missing
        final userData = (snapshot.data?.data() as Map<String, dynamic>?) ?? {};

        // Extract fields with safe fallbacks
        final String storeName = userData['fullName'] ?? userData['name'] ?? 'Kitchen Central';
        final bool isOpen = userData['isOpen'] ?? true;

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'M',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              storeName, // 👈 Dynamic store name from Firestore
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.circle, size: 8, color: Colors.black),
                          ],
                        ),
                        const Text(
                          'Live Dashboard',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.black12,
                  child: Icon(Icons.person, color: Colors.black54),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.black26,
                        child: Icon(Icons.store, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                storeName, // 👈 Dynamic store name
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.verified, size: 16, color: Colors.black),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Live Kitchen Sync',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        isOpen ? 'OPEN' : 'CLOSED', // 👈 Dynamic status label
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: isOpen ? Colors.black : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Switch(
                        value: isOpen, // 👈 Dynamic switch value from Firestore
                        activeColor: Colors.white,
                        activeTrackColor: Colors.black,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.grey.shade400,
                        onChanged: (bool value) {
                          // Sync change directly to Firestore database
                          _toggleStoreStatus(context, activeUid, value);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.access_time, size: 18, color: Colors.black87),
                      SizedBox(width: 8),
                      Text(
                        'Est. Prep Window: ',
                        style: TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                      Text(
                        '18 min',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'OPTIMAL FLOW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}