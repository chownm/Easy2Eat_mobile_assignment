import 'package:easy2eat/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy2eat/features/vendor/presentation/InventoryDetails/inventory-management.dart';

class StockManagementPage extends StatefulWidget {
  const StockManagementPage({super.key});

  @override
  State<StockManagementPage> createState() => _StockManagementPageState();
}

class _StockManagementPageState extends State<StockManagementPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemesColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: ThemesColors.appSurface,
        elevation: 0,
        title: const Text(
          'Inventory Management',
          style: TextStyle(
            color: ThemesColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),

      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: InventoryManagementPage(),
    ),
    );
  }
}
