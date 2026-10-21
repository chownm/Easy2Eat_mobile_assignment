import 'package:flutter/material.dart';

class ChatSectionCard extends StatelessWidget {
  final String? title;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double? height;

  const ChatSectionCard({
    super.key,
    this.title,
    required this.itemCount,
    required this.itemBuilder,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
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
        SizedBox(
          height: height ?? 450,
          child: Scrollbar(
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(right: 4, bottom: 12),
              itemCount: itemCount,
              itemBuilder: itemBuilder,
            ),
          ),
        ),
      ],
    );
  }
}
