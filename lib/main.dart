import 'package:easy2eat/features/rider/presentation/RiderChat/ui.dart';
import 'package:easy2eat/features/rider/presentation/RiderHomePage/ui.dart';
import 'package:easy2eat/features/settings/presentation/ui.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RiderChat(),
    );
  }
}
