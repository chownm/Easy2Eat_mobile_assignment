import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy2eat/core/constants/user_session.dart';
import 'package:easy2eat/shared/widgets/ChatWindow/ChatAppBar.dart';
import 'package:easy2eat/shared/widgets/ChatWindow/ChatWindowBottomBar.dart';
import 'package:flutter/material.dart';

import 'ChatWindowBody.dart';

class ChatWindow extends StatefulWidget {
  final String title;

  const ChatWindow({
    super.key,
    this.title = 'Alex',
  });

  @override
  State<ChatWindow> createState() => _ChatWindowState();
}

class _ChatWindowState extends State<ChatWindow> {
  final String? uid = UserSession.currentUid;

  Future<void> _sendMessage(String text) async {
    if (text.trim().isNotEmpty) {
      final now = TimeOfDay.now();
      final formattedTime =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

      try {
        final activeUid = uid ?? 'guest_rider';
        // Store message in Firestore: users/{uid}/chats/{chatTitle}/messages
        await FirebaseFirestore.instance
            .collection('users')
            .doc(activeUid)
            .collection('chats')
            .doc(widget.title)
            .collection('messages')
            .add({
          'message': text.trim(),
          'isSender': true,
          'time': formattedTime,
          'status': 'Sent',
          'timestamp': FieldValue.serverTimestamp(),
        });
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeUid = uid ?? 'guest_rider';

    // Stream messages from Firestore subcollection: users/{uid}/chats/{chatTitle}/messages
    final messagesStream = FirebaseFirestore.instance
        .collection('users')
        .doc(activeUid)
        .collection('chats')
        .doc(widget.title)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      resizeToAvoidBottomInset: true,
      appBar: ChatAppBar(title: widget.title),
      body: StreamBuilder<QuerySnapshot>(
        stream: messagesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          final List<ChatMessageModel> messages = docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return ChatMessageModel(
              message: data['message'] ?? '',
              isSender: data['isSender'] ?? true,
              time: data['time'] ?? '12:00 PM',
              status: data['status'] ?? 'Sent',
            );
          }).toList();

          return Column(
            children: [
              Expanded(
                child: ChatWindowBody(messages: messages),
              ),
              ChatWindowBottomBar(onSend: _sendMessage),
            ],
          );
        },
      ),
    );
  }
}
