import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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
  final bool? isCustomerView; // true when opened by Customer, false when by Rider

  const ChatWindow({
    super.key,
    this.title = 'Muhammad Harith',
    this.subtitle = 'BQK 4812 • On Delivery',
    this.chatRoomId, // Shared room linking Customer & Rider
    this.isCustomerView,
  });

  @override
  State<ChatWindow> createState() => _ChatWindowState();
}

class _ChatWindowState extends State<ChatWindow> {
  final String? uid = UserSession.currentUid;
  final GoogleTranslator _translator = GoogleTranslator();

  // Active translation target language: 'ms' (Malay), 'zh-cn' (Chinese), 'en' (English)
  late String _targetLanguage;

  /// 1. AUTO-DETECT ROLE:
  bool get _isCustomer {
    if (widget.isCustomerView != null) return widget.isCustomerView!;
    if (widget.title.toLowerCase().contains('customer')) return false; // Viewing customer -> You are rider!
    return true; // Default to customer
  }

  /// 2. UNIQUE CHAT ROOM PER ORDER:
  String get _effectiveRoomId {
    if (widget.chatRoomId != null && widget.chatRoomId!.isNotEmpty) {
      return widget.chatRoomId!;
    }
    // Clean the title into a safe Firestore ID (e.g., 'Customer ORD-4568' -> 'order_Customer_ORD-4568')
    final cleanId = widget.title.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    return 'room_$cleanId';
  }

  // Cache to store live translations so we don't re-fetch repeatedly
  final Map<String, String> _translationCache = {};

  @override
  void initState() {
    super.initState();
    // Default reading language: Chinese for Customer, Malay for Rider
    _targetLanguage = _isCustomer ? 'zh-cn' : 'ms';
  }

  // Safe local messages so the screen NEVER crashes if Firebase is offline/uninitialized
  final List<ChatMessageModel> _localMessages = [
    ChatMessageModel(
      message: 'Salam, saya sudah ambil pesanan di Bai Wei. Sekarang menuju ke lokasi anda.',
      isSender: false, // from Rider (appears on left for Customer)
      time: '12:38 PM',
      status: 'Read',
    ),
    ChatMessageModel(
      message: 'Thanks! Please leave it on Gate Pillar 2 drop table.',
      isSender: true, // from Customer (appears on right for Customer)
      time: '12:39 PM',
      status: 'Read',
    ),
  ];

  /// Safe check: returns true only if Firebase.initializeApp() was called in main.dart
  bool get _isFirebaseReady {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Tri-lingual Offline Fallback for Malaysian food delivery keywords
  /// Covers: English ('en'), Bahasa Melayu ('ms'), and Chinese ('zh-cn')
  String? _offlineFallback(String text, String targetLang) {
    final lower = text.toLowerCase();

    // 1. Target: Simplified Chinese ('zh-cn')
    if (targetLang == 'zh-cn') {
      if (lower.contains('downstairs') || lower.contains('turun') || lower.contains('bawah')) {
        return '我正在下楼拿餐！';
      }
      if (lower.contains('gate') || lower.contains('pillar') || lower.contains('meja') || lower.contains('table')) {
        return '请放在 2 号门柱的放置桌上。';
      }
      if (lower.contains('arrived') || lower.contains('here') || lower.contains('sampai')) {
        return '我已经到达大门口了。';
      }
      if (lower.contains('otw') || lower.contains('way') || lower.contains('perjalanan')) {
        return '我正在路上，很快就到。';
      }
      return '已翻译: $text';
    }

    // 2. Target: Bahasa Melayu ('ms')
    if (targetLang == 'ms') {
      if (lower.contains('downstairs') || lower.contains('下楼')) {
        return 'Saya sedang turun ke bawah sekarang!';
      }
      if (lower.contains('gate') || lower.contains('pillar') || lower.contains('table') || lower.contains('门柱') || lower.contains('桌子')) {
        return 'Sila tinggalkan di atas meja drop Gate Pillar 2.';
      }
      if (lower.contains('arrived') || lower.contains('here') || lower.contains('到了') || lower.contains('到达')) {
        return 'Saya sudah sampai di pintu pagar.';
      }
      if (lower.contains('otw') || lower.contains('way') || lower.contains('在路上') || lower.contains('路上')) {
        return 'Saya dalam perjalanan sekarang.';
      }
      return 'Diterjemahkan: $text';
    }

    // 3. Target: English ('en')
    if (lower.contains('turun') || lower.contains('下楼')) {
      return "I'm heading downstairs now!";
    }
    if (lower.contains('meja') || lower.contains('pagar') || lower.contains('门柱') || lower.contains('桌子')) {
      return 'Please leave it on the Gate Pillar 2 drop table.';
    }
    if (lower.contains('sampai') || lower.contains('到了') || lower.contains('到达')) {
      return 'I have arrived at the gate.';
    }
    if (lower.contains('perjalanan') || lower.contains('在路上')) {
      return 'I am on the way now.';
    }
    return 'Translated: $text';
  }

  /// Translates text reactively for display
  Future<String?> _getTranslationFor(String text) async {
    final cacheKey = '${text}_$_targetLanguage';
    if (_translationCache.containsKey(cacheKey)) {
      return _translationCache[cacheKey];
    }

    try {
      final res = await _translator.translate(text, to: _targetLanguage);
      _translationCache[cacheKey] = res.text;
      return res.text;
    } catch (_) {
      final fallback = _offlineFallback(text, _targetLanguage);
      if (fallback != null) _translationCache[cacheKey] = fallback;
      return fallback;
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final now = TimeOfDay.now();
    final formattedTime =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    final myRole = _isCustomer ? 'customer' : 'rider';

    // 1. Try sending to Firebase if initialized
    if (_isFirebaseReady) {
      try {
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(_effectiveRoomId)
            .collection('messages')
            .add({
          'message': text.trim(),
          'senderRole': myRole,
          'senderName': _isCustomer ? 'Customer' : 'Rider',
          'senderUid': uid ?? (_isCustomer ? 'customer_uid' : 'rider_uid'),
          'time': formattedTime,
          'status': 'Sent',
          'timestamp': FieldValue.serverTimestamp(),
        });
        return;
      } catch (_) {}
    }

    // 2. Safe local update (works even when Firebase is offline or uninitialized)
    setState(() {
      _localMessages.add(
        ChatMessageModel(
          message: text.trim(),
          isSender: true,
          time: formattedTime,
          status: 'Sent',
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final myRole = _isCustomer ? 'customer' : 'rider';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      resizeToAvoidBottomInset: true,
      appBar: ChatAppBar(
        title: widget.title,
        subtitle: widget.subtitle,
      ),
      body: Column(
        children: [
          // Multi-Language Selector Bar [ BM | 中文 | EN ]
          _buildLanguageSelectorBar(),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

          // Messages View (Firebase Stream if ready, otherwise Safe Local Messages)
          Expanded(
            child: _isFirebaseReady
                ? StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(_effectiveRoomId)
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                List<ChatMessageModel> rawMessages = [];
                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  rawMessages = snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final senderRole = data['senderRole'] ?? '';
                    final bool isSender = senderRole.isNotEmpty
                        ? (senderRole == myRole)
                        : (data['isSender'] ?? true);

                    return ChatMessageModel(
                      message: data['message'] ?? '',
                      isSender: isSender,
                      time: data['time'] ?? '12:00 PM',
                      status: data['status'] ?? 'Delivered',
                    );
                  }).toList();
                } else {
                  rawMessages = _localMessages;
                }

                return _buildTranslatedMessageList(rawMessages);
              },
            )
                : _buildTranslatedMessageList(_localMessages),
          ),

          // Bottom Input Bar
          ChatWindowBottomBar(onSend: _sendMessage),
        ],
      ),
    );
  }

  /// Builds the message list where translations update whenever _targetLanguage changes
  Widget _buildTranslatedMessageList(List<ChatMessageModel> rawMessages) {
    return FutureBuilder<List<ChatMessageModel>>(
      future: Future.wait(rawMessages.map((msg) async {
        final translated = await _getTranslationFor(msg.message);
        return ChatMessageModel(
          message: msg.message,
          isSender: msg.isSender,
          time: msg.time,
          status: msg.status,
          translation: translated,
        );
      })),
      builder: (context, snapshot) {
        final messages = snapshot.data ?? rawMessages;
        return ChatWindowBody(messages: messages);
      },
    );
  }

  Widget _buildLanguageSelectorBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      color: Colors.white,
      child: Row(
        children: [
          const Icon(
            Icons.g_translate,
            size: 16,
            color: ThemesColors.brandOrange,
          ),
          const SizedBox(width: 8),
          const Text(
            'Translate to:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: ThemesColors.darkCharcoal,
            ),
          ),
          const Spacer(),
          _langChip(code: 'ms', label: '🇲🇾 BM'),
          const SizedBox(width: 6),
          _langChip(code: 'zh-cn', label: '🇨🇳 中文'),
          const SizedBox(width: 6),
          _langChip(code: 'en', label: '🇬🇧 EN'),
        ],
      ),
    );
  }

  Widget _langChip({required String code, required String label}) {
    final bool isSelected = _targetLanguage == code;
    return InkWell(
      onTap: () {
        setState(() {
          _targetLanguage = code; // Instantly triggers re-translation of all messages on screen!
        });
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected
              ? ThemesColors.brandOrange
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? ThemesColors.brandOrange
                : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
            color: isSelected ? Colors.white : ThemesColors.darkCharcoal,
          ),
        ),
      ),
    );
  }
}