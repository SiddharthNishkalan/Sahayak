import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../app_view_model.dart';

import 'package:flutter/services.dart';

class CooperativeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppViewModel viewModel;
  final bool showBackButton;
  final String? customTitle;
  final String? customSubtitle;

  const CooperativeAppBar({
    super.key,
    required this.viewModel,
    this.showBackButton = false,
    this.customTitle,
    this.customSubtitle,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  void _showWardPicker(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: SahayakColors.surfaceContainerLowest,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final wards = [
          viewModel.strings.get('current_location_label'),
          'Home (Sector 4)',
          'Office (Commercial Hub)',
          'Residence (Greenwood)',
          'Branch Hub (North Zone)',
        ];

        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    viewModel.strings.get('service_location_title'),
                    style: SahayakTypography.headlineSm(),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cooperative network guarantees rapid emergency response from the nearest local hub.',
                    style: SahayakTypography.bodySm(),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    tileColor: SahayakColors.primaryFixed.withValues(alpha: 0.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    leading: const Icon(Icons.my_location_rounded, color: SahayakColors.primary),
                    title: Text(viewModel.strings.get('detect_live_gps'), style: SahayakTypography.labelMd(color: SahayakColors.primary)),
                    subtitle: Text(viewModel.strings.get('detect_live_gps_sub')),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Navigator.pop(ctx);
                      viewModel.detectCurrentDeviceLocation();
                    },
                  ),
                  const SizedBox(height: 8),
                  ...wards.map((ward) {
                    final isSelected = viewModel.currentWard == ward;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      leading: Icon(
                        Icons.location_on_rounded,
                        color: isSelected ? SahayakColors.primary : SahayakColors.outline,
                      ),
                      title: Text(
                        ward,
                        style: SahayakTypography.labelMd(
                          color: isSelected ? SahayakColors.primary : SahayakColors.onSurface,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: SahayakColors.primary)
                          : null,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        viewModel.updateWard(ward);
                        Navigator.pop(ctx);
                      },
                    );
                  }),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Drill-down compact bar: just back chevron + title
    if (showBackButton) {
      return AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.maybePop(context);
          },
        ),
        title: customTitle != null
            ? Text(customTitle!, style: SahayakTypography.labelLg())
            : null,
        centerTitle: false,
        toolbarHeight: 56,
      );
    }

    // Home brand bar with ward picker and profile avatar
    return Container(
      decoration: const BoxDecoration(
        color: SahayakColors.surface,
        border: Border(
          bottom: BorderSide(color: SahayakColors.borderSubtle, width: 0.5),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Brand Emblem
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: SahayakColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: SahayakColors.borderSubtle, width: 0.5),
                ),
                padding: const EdgeInsets.all(4),
                child: Image.asset(
                  'assets/images/logo_mark.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.home_work_rounded,
                    color: SahayakColors.primary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Title / Ward Dropdown
              Expanded(
                child: customTitle != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customTitle!,
                            style: SahayakTypography.labelLg(),
                          ),
                          if (customSubtitle != null)
                            Text(
                              customSubtitle!,
                              style: SahayakTypography.caption(color: SahayakColors.primary),
                            ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            viewModel.strings.get('coop_union'),
                            style: SahayakTypography.caption(color: SahayakColors.onSurfaceVariant),
                          ),
                          InkWell(
                            onTap: () => _showWardPicker(context),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    '📍 ${viewModel.currentWard}',
                                    style: SahayakTypography.labelMd(color: SahayakColors.primary),
                                  ),
                                ),
                                const Icon(
                                  Icons.expand_more_rounded,
                                  size: 16,
                                  color: SahayakColors.primary,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),

              // Profile Avatar Trigger
              InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  viewModel.switchTab(ShellTab.profile);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: SahayakColors.primary.withValues(alpha: 0.3), width: 1.5),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/images/user_avatar.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: SahayakColors.primaryContainer,
                      child: const Icon(Icons.person, color: SahayakColors.onPrimary, size: 18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

