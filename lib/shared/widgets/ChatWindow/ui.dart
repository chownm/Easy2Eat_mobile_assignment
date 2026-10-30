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
  final String? chatRoomId;

  const ChatWindow({
    super.key,
    this.title = 'Customer',
    this.subtitle = 'Active Order • On Delivery',
    this.chatRoomId,
  });

  @override
  State<ChatWindow> createState() => _ChatWindowState();
}

class _ChatWindowState extends State<ChatWindow> {
  final String activeUid = UserSession.currentUid ?? '';
  final String activeRole = (UserSession.role ?? 'rider').toLowerCase();
  final GoogleTranslator _translator = GoogleTranslator();
  String _targetLanguage = 'en';

  /// Determines collection name: 'vendor_chats' or 'customer_chats'
  String get _collectionName {
    if (widget.title.toLowerCase().contains('vendor')) {
      return 'vendor_chats';
    }
    return 'customer_chats';
  }

  /// Extracts clean Order ID document (e.g., "ORD-1234") without prefix fluff
  String get _orderDocumentId {
    if (widget.chatRoomId != null && widget.chatRoomId!.isNotEmpty) {
      return widget.chatRoomId!;
    }
    final regex = RegExp(r'(ORD[-_]?\d+)|\b\d+\b');
    final match = regex.firstMatch(widget.title);
    if (match != null) {
      return match.group(0)!;
    }
    return widget.title;
  }

  String get _currentTimeString => DateFormat('hh:mm a').format(DateTime.now());

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final currentTime = _currentTimeString;

    try {
      // Write directly to vendor_chats/{orderId}/messages or customer_chats/{orderId}/messages
      await FirebaseFirestore.instance
          .collection(_collectionName)
          .doc(_orderDocumentId)
          .collection('messages')
          .add({
        'message': text.trim(),
        'senderUid': activeUid,
        'senderRole': activeRole,
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

          // Real-time messages stream from vendor_chats or customer_chats
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(_collectionName)
                  .doc(_orderDocumentId)
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                final docs = snapshot.data?.docs ?? [];
                final rawMessages = docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final String senderUid = data['senderUid'] ?? '';
                  final String senderRole = (data['senderRole'] ?? '').toString().toLowerCase();

                  final bool isSender = (activeUid.isNotEmpty && senderUid == activeUid) ||
                      (senderRole.isNotEmpty && senderRole == activeRole) ||
                      (data['isSender'] ?? true);

                  return ChatMessageModel(
                    message: data['message'] ?? '',
                    isSender: isSender,
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
