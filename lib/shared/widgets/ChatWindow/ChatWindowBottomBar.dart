import 'package:flutter/material.dart';
import 'package:easy2eat/core/theme/theme.dart';

class ChatWindowBottomBar extends StatefulWidget {
  final ValueChanged<String>? onSend;

  const ChatWindowBottomBar({
    super.key,
    this.onSend,
  });

  @override
  State<ChatWindowBottomBar> createState() => _ChatWindowBottomBarState();
}

class _ChatWindowBottomBarState extends State<ChatWindowBottomBar> {
  final TextEditingController _textController = TextEditingController();
  bool _isTyping = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      if (widget.onSend != null) {
        widget.onSend!(text);
      }
      _textController.clear();
      setState(() {
        _isTyping = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: ThemesColors.cardBackground,
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Attachment Buttons
            const BuildIconButton(
              icon: Icon(Icons.add_outlined, color: ThemesColors.darkCharcoal),
            ),
            const BuildIconButton(
              icon: Icon(Icons.camera_alt_outlined, color: ThemesColors.darkCharcoal),
            ),
            const BuildIconButton(
              icon: Icon(Icons.mic_none_outlined, color: ThemesColors.darkCharcoal),
            ),

            // Message Input Box
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(24.0),
                ),
                child: TextField(
                  controller: _textController,
                  style: const TextStyle(fontSize: 15, color: ThemesColors.darkCharcoal),
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: (text) {
                    setState(() {
                      _isTyping = text.trim().isNotEmpty;
                    });
                  },
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
            ),

            const SizedBox(width: 4),

            // Send Button
            IconButton(
              icon: Icon(
                Icons.arrow_forward_rounded,
                color: _isTyping ? ThemesColors.brandOrange : Colors.grey,
              ),
              onPressed: _isTyping ? _handleSend : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper Icon Button Widget (Stateless)
class BuildIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onPressed;

  const BuildIconButton({
    super.key,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: icon,
      onPressed: onPressed ?? () {},
      iconSize: 22,
      padding: const EdgeInsets.all(6),
      constraints: const BoxConstraints(),
    );
  }
}
