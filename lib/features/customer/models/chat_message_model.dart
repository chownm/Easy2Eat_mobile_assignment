import 'package:flutter/material.dart';

enum MessageSenderRole {
  customer,
  rider,
}

class ChatMessageItem {
  final String id;
  final String senderName;
  final MessageSenderRole senderRole;
  final String text;
  final String? translatedText;
  final String timeString;
  final bool isDelivered;

  const ChatMessageItem({
    required this.id,
    required this.senderName,
    required this.senderRole,
    required this.text,
    this.translatedText,
    required this.timeString,
    this.isDelivered = true,
  });
}

/// Central in-memory repository shared between Customer and Rider roles.
class ActiveChatRepository {
  // Singleton pattern for cross-screen data linkage
  static final ActiveChatRepository _instance = ActiveChatRepository._internal();
  factory ActiveChatRepository() => _instance;
  ActiveChatRepository._internal();

  /// Shared active conversation with Muhammad Harith
  static final List<ChatMessageItem> messagesWithRider = <ChatMessageItem>[
    const ChatMessageItem(
      id: 'm1',
      senderName: 'Muhammad Harith',
      senderRole: MessageSenderRole.rider,
      text: 'Salam, saya sudah sampai di kedai Bai Wei. Sedang tunggu pesanan siap dibungkus.',
      translatedText: 'Hi, I have arrived at Bai Wei store. Waiting for the order packaging to finish.',
      timeString: '12:36 PM',
    ),
    const ChatMessageItem(
      id: 'm2',
      senderName: 'You (Customer)',
      senderRole: MessageSenderRole.customer,
      text: 'Thanks! Please leave it on Gate Pillar 2 drop table when you reach.',
      translatedText: 'Terima kasih! Sila letakkan di atas meja drop Gate Pillar 2 bila sampai.',
      timeString: '12:37 PM',
    ),
    const ChatMessageItem(
      id: 'm3',
      senderName: 'Muhammad Harith',
      senderRole: MessageSenderRole.rider,
      text: 'Baik, saya dalam perjalanan sekarang melalui C180 corridor.',
      translatedText: 'Alright, I am on the way now through C180 corridor.',
      timeString: '12:39 PM',
    ),
  ];

  static void addMessage({
    required String text,
    required MessageSenderRole role,
    required String senderName,
    String? translation,
  }) {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour >= 12 ? 'PM' : 'AM';

    messagesWithRider.add(
      ChatMessageItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderName: senderName,
        senderRole: role,
        text: text,
        translatedText: translation,
        timeString: '$hour:$minute $ampm',
      ),
    );
  }
}