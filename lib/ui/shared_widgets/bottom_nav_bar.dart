import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../app_view_model.dart';

import 'package:flutter/services.dart';

class CooperativeBottomNavBar extends StatelessWidget {
  final AppViewModel viewModel;

  const CooperativeBottomNavBar({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SahayakColors.surface.withValues(alpha: 0.96),
        border: const Border(
          top: BorderSide(color: SahayakColors.borderSubtle, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: SahayakColors.onSurface.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_rounded,
                label: viewModel.strings.get('home_nav'),
                isSelected: viewModel.currentTab == ShellTab.home,
                onTap: () {
                  HapticFeedback.selectionClick();
                  viewModel.switchTab(ShellTab.home);
                },
              ),
              _buildNavItem(
                icon: Icons.event_note_rounded,
                label: viewModel.strings.get('bookings_nav'),
                isSelected: viewModel.currentTab == ShellTab.bookings,
                badgeCount: 1,
                onTap: () {
                  HapticFeedback.selectionClick();
                  viewModel.switchTab(ShellTab.bookings);
                },
              ),
              _buildNavItem(
                icon: Icons.person_rounded,
                label: viewModel.strings.get('profile_nav'),
                isSelected: viewModel.currentTab == ShellTab.profile,
                onTap: () {
                  HapticFeedback.selectionClick();
                  viewModel.switchTab(ShellTab.profile);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    int? badgeCount,
    required VoidCallback onTap,
  }) {
    final color = isSelected ? SahayakColors.primary : SahayakColors.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        constraints: const BoxConstraints(minWidth: 64, minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: color, size: 24),
                if (badgeCount != null && badgeCount > 0)
                  Positioned(
                    top: -2,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: SahayakColors.primary,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                      child: Text(
                        '$badgeCount',
                        style: SahayakTypography.caption(color: SahayakColors.onPrimary).copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: SahayakTypography.caption(color: color).copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
