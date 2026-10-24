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
  final List<String> _messages = [
    "Hello! I am on my way to deliver your order.",
  ];

  void _sendMessage(String text) {
    if (text.isNotEmpty) {
      setState(() {
        _messages.add(text);
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
          const Expanded(
            child: ChatWindowBody(),
          ),
          ChatWindowBottomBar(onSend: _sendMessage),
        ],
      ),
    );
  }
}
