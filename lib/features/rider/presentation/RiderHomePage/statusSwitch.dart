import 'package:flutter/material.dart';
import 'package:easy2eat/core/theme/theme.dart';

class RiderStatus extends StatefulWidget {
  const RiderStatus({super.key});

  @override
  State<RiderStatus> createState() => _RiderStatusState();
}

class _RiderStatusState extends State<RiderStatus> {
  int _selectedToggleIndex = 0; // 0 for Button 1, 1 for Button 2

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side: Bullet point + Text
          const Row(
            children: [
              Icon(Icons.circle, size: 10, color: Colors.black),
              SizedBox(width: 8),
              Text(
                "Rider Status",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ThemesColors.darkCharcoal,
                ),
              ),
            ],
          ),

          // Right side: Pill toggle buttons
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F7),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                // Button 1
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedToggleIndex = 0;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedToggleIndex == 0
                          ? ThemesColors.darkCharcoal
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Online",
                      style: TextStyle(
                        color: _selectedToggleIndex == 0
                            ? Colors.white
                            : Colors.grey[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),

                // Button 2
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedToggleIndex = 1;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedToggleIndex == 1
                          ? ThemesColors.darkCharcoal
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Offline",
                      style: TextStyle(
                        color: _selectedToggleIndex == 1
                            ? Colors.white
                            : Colors.grey[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Alias for backwards compatibility
typedef riderStatus = RiderStatus;
