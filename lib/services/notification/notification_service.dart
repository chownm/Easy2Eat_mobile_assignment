import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Top-level function for background FCM handling
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling background FCM message: ${message.messageId}");
}

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'easy2eat_orders', // id
    'Order Tracking Updates', // title
    description: 'Notifications regarding kitchen progress, dispatch, and arrival.',
    importance: Importance.max,
    playSound: true,
  );

  static Future<void> initialize() async {
    // 1. Request OS Permission (Required for iOS and Android 13+)
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      debugPrint('User declined notification permissions');
      return;
    }

    // 2. Initialize local notifications for foreground presentation
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();

    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    // Create Android High-Priority Channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // 3. Register Background Handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 4. Foreground Message Listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        showLocalNotification(
          title: notification.title ?? 'Order Update',
          body: notification.body ?? '',
        );
      }
    });

    // 5. Store FCM Token to Firestore
    await syncDeviceToken();
  }

  /// Saves or updates the device FCM token under users/{uid}/fcmToken
  static Future<void> syncDeviceToken() async {
    try {
      // ignore: deprecated_member_use
      final token = await _messaging.getToken();
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (token != null && uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set(
          {'fcmToken': token},
          SetOptions(merge: true),
        );
      }
    } catch (e) {
      debugPrint('Error syncing FCM token: $e');
    }
  }

  /// Displays an immediate Heads-Up notification banner
  static Future<void> showLocalNotification({
    required String title,
    required String body,
  }) async {
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }
}