import 'package:easy2eat/core/routing/RiderRouting.dart';
import 'package:easy2eat/features/rider/presentation/RiderHomePage/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: "lib/core/constants/.env"); // Loads .env

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', ''),
        Locale('ms', ''),
        Locale('zh', ''),
        Locale('ta', ''),
        Locale('es', ''),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', ''),
      child: const ProviderScope(child: MyApp()),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: const RiderHomePage(),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
