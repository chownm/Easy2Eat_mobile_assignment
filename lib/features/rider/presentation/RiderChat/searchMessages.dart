import 'package:flutter/material.dart';

class SearchMessages extends StatefulWidget {
  final ValueChanged<String>? onChanged;

  const SearchMessages({super.key, this.onChanged});

  @override
  State<SearchMessages> createState() => _SearchMessagesState();
}

class _SearchMessagesState extends State<SearchMessages> {
  String _inputText = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search,
            color: Colors.grey,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              style: const TextStyle(fontSize: 15, color: Colors.black87),
              decoration: const InputDecoration(
                hintText: 'Search Messages...',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) {
                setState(() {
                  _inputText = value;
                  print("_inputText: $_inputText");
                });
                if (widget.onChanged != null) {
                  widget.onChanged!(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
