import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class LoginButton {
  LoginButton._();

  /// Reusable button builder for any social or auth provider.
  static Widget socialButton({
    required String label,
    String? iconPath,
    String? iconName,
    IconData? icon,
    VoidCallback? onPressed,
    Color backgroundColor = Colors.white,
    Color textColor = ThemesColors.darkCharcoal,
    Color borderColor = const Color(0xFFD0D0D0),
  }) {
    final String? resolvedIconPath = iconPath ??
        (iconName != null ? 'lib/assets/images/${iconName}Icon.png' : null);

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed ?? () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          side: BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          children: [
            if (resolvedIconPath != null)
              Image.asset(
                resolvedIconPath,
                height: 22.0,
                width: 22.0,
                errorBuilder: (context, error, stackTrace) => Icon(
                  icon ?? Icons.login,
                  size: 22.0,
                  color: textColor,
                ),
              )
            else if (icon != null)
              Icon(icon, size: 22.0, color: textColor),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 22),
          ],
        ),
      ),
    );
  }

  /// Shortcut for Google Login
  static Widget google({VoidCallback? onPressed, String label = "Continue with Google"}) {
    return socialButton(
      label: label,
      iconName: "google",
      onPressed: onPressed,
      backgroundColor: Colors.white,
      textColor: ThemesColors.darkCharcoal,
      borderColor: const Color(0xFFD0D0D0),
    );
  }

  /// Shortcut for Email Login
  static Widget email({VoidCallback? onPressed, String label = "Continue with Email"}) {
    return socialButton(
      label: label,
      icon: Icons.email_outlined,
      onPressed: onPressed,
      backgroundColor: Colors.white,
      textColor: ThemesColors.darkCharcoal,
      borderColor: const Color(0xFFD0D0D0),
    );
  }
}
