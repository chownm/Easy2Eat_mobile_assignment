import 'package:easy2eat/core/routing/RiderRouting.dart';
import 'package:easy2eat/features/auth/presentation/login_screen.dart';
import 'package:easy2eat/features/rider/presentation/RiderHomePage/ui.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Push Notifications & request permission
  try {
    final notificationSettings = await FirebaseMessaging.instance.requestPermission(provisional: true);
    print("Notification permission status: ${notificationSettings.authorizationStatus}");

    final fcmToken = await FirebaseMessaging.instance.getToken();
    print("FCM Token: $fcmToken");

    final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    if (apnsToken != null) {
      print("APNS Token: $apnsToken");
    }
  } catch (e) {
    print("Notification initialization error: $e");
  }

  await dotenv.load(fileName: "lib/core/constants/.env"); // Loads .env

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
