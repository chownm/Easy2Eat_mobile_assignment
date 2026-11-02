import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String messageId;
  final String senderId;
  final String senderName;
  final String messageText;
  final Timestamp? timestamp;
  final bool isVendor;

  ChatMessage({
    required this.messageId,
    required this.senderId,
    required this.senderName,
    required this.messageText,
    required this.timestamp,
    required this.isVendor,
  });

  /// Factory constructor to parse Firestore document into ChatMessage
  factory ChatMessage.fromJson(Map<String, dynamic> json, String id) {
    return ChatMessage(
      messageId: id,
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? 'User',
      messageText: json['messageText'] ?? '',
      timestamp: json['timestamp'] as Timestamp?,
      isVendor: json['isVendor'] ?? false,
    );
  }

  /// Convert ChatMessage to JSON for Firestore storage
  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'messageText': messageText,
      'timestamp': timestamp ?? FieldValue.serverTimestamp(),
      'isVendor': isVendor,
    };
  }
}