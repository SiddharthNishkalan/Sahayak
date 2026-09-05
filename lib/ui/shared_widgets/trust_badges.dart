import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';

class VerifiedShieldBadge extends StatelessWidget {
  final String label;
  final bool isSmall;

  const VerifiedShieldBadge({
    super.key,
    this.label = 'Verified',
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 10,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: SahayakColors.secondaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(
          color: SahayakColors.secondaryContainer,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_rounded,
            size: isSmall ? 12 : 14,
            color: SahayakColors.onSecondaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: isSmall
                ? SahayakTypography.caption(color: SahayakColors.onSecondaryContainer).copyWith(fontWeight: FontWeight.w700)
                : SahayakTypography.labelSm(color: SahayakColors.onSecondaryContainer),
          ),
        ],
      ),
    );
  }
}

class CoOpProtectedBadge extends StatelessWidget {
  const CoOpProtectedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: SahayakColors.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.verified_user_rounded,
            size: 14,
            color: SahayakColors.secondary,
          ),
          const SizedBox(width: 4),
          Text(
            'Co-op Protected',
            style: SahayakTypography.caption(color: SahayakColors.secondary).copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class FairMatchBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;

  const FairMatchBadge({
    super.key,
    required this.label,
    required this.icon,
    this.backgroundColor = SahayakColors.primaryFixed,
    this.foregroundColor = SahayakColors.onPrimaryFixed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foregroundColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: SahayakTypography.labelSm(color: foregroundColor),
          ),
        ],
      ),
    );
  }
}
