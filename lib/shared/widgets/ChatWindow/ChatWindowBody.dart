import 'package:flutter/material.dart';

class ChatWindowBody extends StatefulWidget {
  final int itemCount;
  const ChatWindowBody({super.key, this.itemCount = 1});

  @override
  State<ChatWindowBody> createState() => _ChatWindowBodyState();
}

class _ChatWindowBodyState extends State<ChatWindowBody> {
  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: ListView.builder(
        itemCount: widget.itemCount,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        itemBuilder: (context, index) {
          return const Column(
            children: [
              ChatTextBubble(
                isSender: true,
                message: 'Saya dah sampai depan guard house lobby, abang.',
                time: '12:42 PM',
                status: 'Read',
              ),
              SizedBox(height: 12),
              ChatTextBubble(
                isSender: false,
                message: "Okay I'm coming down now! Thanks!",
                translation:
                'Translation: "Saya dah sampai depan guard house lobby, abang."',
                time: '12:45 PM',
              ),
            ],
          );
        },
      ),
    );
  }
}

class ChatTextBubble extends StatelessWidget {
  final bool isSender;
  final String message;
  final String? translation;
  final String time;
  final String? status;

  const ChatTextBubble({
    super.key,
    required this.isSender,
    required this.message,
    this.translation,
    required this.time,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78,
            ),
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: isSender ? const Color(0xFF1C1A19) : Colors.grey.shade200,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16.0),
                topRight: const Radius.circular(16.0),
                bottomLeft: Radius.circular(isSender ? 16.0 : 4.0),
                bottomRight: Radius.circular(isSender ? 4.0 : 16.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    color: isSender ? Colors.white : const Color(0xFF1C1A19),
                    fontSize: 15.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (translation != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Divider(
                      height: 1,
                      color: isSender ? Colors.grey.shade800 : Colors.grey.shade300,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.g_translate,
                        size: 14,
                        color: isSender ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          translation!,
                          style: TextStyle(
                            color: isSender ? const Color(0xFFE5A88B) : Colors.grey.shade700,
                            fontSize: 13.0,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Timestamp and Status
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                time,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              if (isSender && status != null) ...[
                const Text(' • ', style: TextStyle(fontSize: 11, color: Colors.grey)),
                Text(
                  status!,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.done_all,
                  size: 14,
                  color: status == 'Read' ? const Color(0xFFD1533B) : Colors.grey,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
