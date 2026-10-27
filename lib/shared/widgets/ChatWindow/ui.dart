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
  final List<ChatMessageModel> _messages = [
    ChatMessageModel(
      message: 'Saya dah sampai depan guard house lobby, abang.',
      isSender: true,
      time: '12:42 PM',
      status: 'Read',
    ),
    ChatMessageModel(
      message: "Okay I'm coming down now! Thanks!",
      translation: 'Translation: "Saya dah sampai depan guard house lobby, abang."',
      isSender: false,
      time: '12:45 PM',
    ),
  ];

  void _sendMessage(String text) {
    if (text.trim().isNotEmpty) {
      final now = TimeOfDay.now();
      final formattedTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
      
      setState(() {
        _messages.add(
          ChatMessageModel(
            message: text.trim(),
            isSender: true,
            time: formattedTime,
            status: 'Sent',
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      resizeToAvoidBottomInset: true,
      appBar: ChatAppBar(title: widget.title),
      body: Column(
        children: [
          Expanded(
            child: ChatWindowBody(messages: _messages),
          ),
          ChatWindowBottomBar(onSend: _sendMessage),
        ],
      ),
    );
  }
}
