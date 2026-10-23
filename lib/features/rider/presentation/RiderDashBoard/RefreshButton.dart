import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class RefreshButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;

  const RefreshButton({
    super.key,
    this.onPressed,
    this.label = "Refresh",
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed ?? () {},
      icon: const Icon(
        Icons.refresh,
        size: 18,
        color: ThemesColors.darkCharcoal,
      ),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: ThemesColors.darkCharcoal,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: ThemesColors.darkCharcoal,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),
    );
  }
}
