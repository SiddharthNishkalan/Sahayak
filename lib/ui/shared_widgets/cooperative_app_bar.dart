import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../app_view_model.dart';

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
  Size get preferredSize => const Size.fromHeight(64);

  void _showWardPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: SahayakColors.surfaceContainerLowest,
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          viewModel.strings.get('service_location_title'),
                          style: SahayakTypography.headlineSm(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cooperative network guarantees rapid emergency response from the nearest local hub.',
                    style: SahayakTypography.bodySm(),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    tileColor: SahayakColors.primaryFixed.withValues(alpha: 0.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    leading: const Icon(Icons.my_location_rounded, color: SahayakColors.primary),
                    title: Text(viewModel.strings.get('detect_live_gps'), style: SahayakTypography.labelMd(color: SahayakColors.primary)),
                    subtitle: Text(viewModel.strings.get('detect_live_gps_sub')),
                    onTap: () {
                      Navigator.pop(ctx);
                      viewModel.detectCurrentDeviceLocation();
                    },
                  ),
                  const SizedBox(height: 10),
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
                        viewModel.updateWard(ward);
                        Navigator.pop(ctx);
                      },
                    );
                  }),
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
    return Container(
      decoration: BoxDecoration(
        color: SahayakColors.surface.withValues(alpha: 0.9),
        border: const Border(
          bottom: BorderSide(color: SahayakColors.borderSubtle, width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              if (showBackButton)
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: SahayakColors.onSurface),
                  onPressed: () => Navigator.maybePop(context),
                ),
              // Brand Emblem
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: SahayakColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: SahayakColors.borderSubtle),
                ),
                padding: const EdgeInsets.all(4),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.home_work_rounded,
                    color: SahayakColors.primary,
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
                            style: SahayakTypography.headlineSm(),
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
                            style: SahayakTypography.labelSm(color: SahayakColors.onSurfaceVariant),
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
                onTap: () => viewModel.switchTab(ShellTab.profile),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 36,
                  height: 36,
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
                      child: const Icon(Icons.person, color: SahayakColors.onPrimary, size: 20),
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
