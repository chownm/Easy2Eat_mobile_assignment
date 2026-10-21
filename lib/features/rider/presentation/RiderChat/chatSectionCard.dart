import 'package:flutter/material.dart';

class ChatSectionCard extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const ChatSectionCard({
    super.key,
    this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8, top: 12),
            child: Text(
              title!.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
        Column(
          children: children,
        ),
      ],
    );
  }
}
