import 'package:flutter/material.dart';
import 'package:easy2eat/core/theme/theme.dart';

class CustomerProximityBeaconBanner extends StatelessWidget {
  final String residenceLabel;
  final String dropOffLandmark;
  final VoidCallback? onTap;

  const CustomerProximityBeaconBanner({
    super.key,
    required this.residenceLabel,
    required this.dropOffLandmark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFDF2EE),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: ThemesColors.brandOrange.withValues(alpha: 0.5),
              width: 1.2,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: ThemesColors.brandOrange.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              // Proximity notification bell icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: ThemesColors.brandOrange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: ThemesColors.appSurface,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),

              // Banner Content Block
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const Text(
                          '100M PROXIMITY BEACON',
                          style: TextStyle(
                            color: ThemesColors.brandOrange,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Flexible container prevents right-edge overflow on long location labels
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: ThemesColors.darkCharcoal.withValues(
                                alpha: 0.08,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              residenceLabel.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: ThemesColors.darkCharcoal.withValues(
                                  alpha: 0.75,
                                ),
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: ThemesColors.darkCharcoal.withValues(
                            alpha: 0.85,
                          ),
                          fontSize: 11.5,
                          height: 1.3,
                          fontWeight: FontWeight.w500,
                        ),
                        children: <TextSpan>[
                          const TextSpan(text: 'Rider is within 100m! Head downstairs to '),
                          TextSpan(
                            text: dropOffLandmark,
                            style: const TextStyle(
                              color: ThemesColors.darkCharcoal,
                              fontWeight: FontWeight.w800,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const TextSpan(text: ' for pickup.'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}