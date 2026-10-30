import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:translator/translator.dart';
import 'package:easy2eat/core/constants/user_session.dart';
import 'package:easy2eat/core/theme/theme.dart';
import 'package:easy2eat/shared/widgets/ChatWindow/ChatAppBar.dart';
import 'package:easy2eat/shared/widgets/ChatWindow/ChatWindowBottomBar.dart';
import 'ChatWindowBody.dart';

class ChatWindow extends StatefulWidget {
  final String title;
  final String subtitle;

  const ChatWindow({
    super.key,
    this.title = 'Customer',
    this.subtitle = 'Active Order • On Delivery',
  });

  @override
  State<ChatWindow> createState() => _ChatWindowState();
}

class _ChatWindowState extends State<ChatWindow> {
  final String activeUid = UserSession.currentUid ?? '';
  final GoogleTranslator _translator = GoogleTranslator();
  String _targetLanguage = 'en';

  String get _currentTimeString => DateFormat('hh:mm a').format(DateTime.now());

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final currentTime = _currentTimeString;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(activeUid)
          .collection('chats')
          .doc(widget.title)
          .collection('messages')
          .add({
        'message': text.trim(),
        'isSender': true,
        'time': currentTime,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  Future<String?> _translate(String text) async {
    try {
      final res = await _translator.translate(text, to: _targetLanguage);
      return res.text;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: ChatAppBar(title: widget.title, subtitle: widget.subtitle),
      body: Column(
        children: [
          // Language selector bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: Colors.white,
            child: Row(
              children: [
                const Icon(Icons.g_translate, size: 16, color: ThemesColors.brandOrange),
                const SizedBox(width: 6),
                const Text('Translate to:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const Spacer(),
                _langButton('en', '🇬🇧 EN'),
                const SizedBox(width: 6),
                _langButton('ms', '🇲🇾 BM'),
                const SizedBox(width: 6),
                _langButton('zh-cn', '🇨🇳 中文'),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),

          // Real-time messages list from Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(activeUid)
                  .collection('chats')
                  .doc(widget.title)
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                final docs = snapshot.data?.docs ?? [];
                final rawMessages = docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return ChatMessageModel(
                    message: data['message'] ?? '',
                    isSender: data['isSender'] ?? true,
                    time: data['time'] ?? '',
                  );
                }).toList();

                return FutureBuilder<List<ChatMessageModel>>(
                  future: Future.wait(rawMessages.map((msg) async {
                    final trans = await _translate(msg.message);
                    return ChatMessageModel(
                      message: msg.message,
                      isSender: msg.isSender,
                      time: msg.time,
                      translation: trans,
                    );
                  })),
                  builder: (context, transSnapshot) {
                    final messages = transSnapshot.data ?? rawMessages;
                    return ChatWindowBody(messages: messages);
                  },
                );
              },
            ),
          ),

          // Input field
          ChatWindowBottomBar(onSend: _sendMessage),
        ],
      ),
    );
  }

  Widget _langButton(String code, String label) {
    final bool isSelected = _targetLanguage == code;
    return InkWell(
      onTap: () => setState(() => _targetLanguage = code),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? ThemesColors.brandOrange : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
