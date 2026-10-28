import 'package:flutter/material.dart';
import '../../../../../core/theme/theme.dart';

class EmptyOrdersView extends StatelessWidget {
  final VoidCallback onRefresh;

  const EmptyOrdersView({
    super.key,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            "No incoming orders",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text("Refresh Orders"),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemesColors.darkCharcoal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
