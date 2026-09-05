import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../data/models/service.dart';
import '../../../app_view_model.dart';
import '../booking_wizard/step1_problem_details.dart';

class MarketplaceHomeScreen extends StatefulWidget {
  final AppViewModel viewModel;

  const MarketplaceHomeScreen({
    super.key,
    required this.viewModel,
  });

  @override
  State<MarketplaceHomeScreen> createState() => _MarketplaceHomeScreenState();
}

class _MarketplaceHomeScreenState extends State<MarketplaceHomeScreen> {
  bool? _selectedModeIsEmergency; // null = initial view, true = emergency, false = standard

  void _selectMode(bool isEmergency) {
    setState(() {
      _selectedModeIsEmergency = isEmergency;
    });
  }

  void _openBookingWizard(ServiceItem service, bool isEmergency) {
    widget.viewModel.setTimingMode(isEmergency: isEmergency);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Step1ProblemDetailsScreen(
          viewModel: widget.viewModel,
          service: service,
        ),
      ),
    );
  }

  void _showDomainBottomSheet(BuildContext context, bool isEmergency) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: SahayakColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final services = widget.viewModel.repository.services;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: SahayakColors.outlineVariant,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isEmergency ? Icons.bolt_rounded : Icons.calendar_today_rounded,
                                color: isEmergency ? SahayakColors.error : SahayakColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  isEmergency ? widget.viewModel.strings.get('emergency_request') : widget.viewModel.strings.get('book_service'),
                                  style: SahayakTypography.headlineSm(),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isEmergency ? 'Rapid · SOS · Nearest Pro' : 'Standard · Scheduled · Fair Rate',
                            style: SahayakTypography.caption(
                              color: isEmergency ? SahayakColors.error : SahayakColors.secondary,
                            ).copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.6,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: services.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, idx) {
                      final item = services[idx];
                      return Material(
                        color: SahayakColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(ctx);
                            _openBookingWizard(item, isEmergency);
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: isEmergency
                                        ? SahayakColors.errorContainer
                                        : SahayakColors.primaryFixed,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    item.icon,
                                    color: isEmergency
                                        ? SahayakColors.onErrorContainer
                                        : SahayakColors.primary,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: SahayakTypography.labelLg().copyWith(fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item.description,
                                        style: SahayakTypography.bodySm(),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: isEmergency
                                        ? SahayakColors.errorContainer.withValues(alpha: 0.5)
                                        : SahayakColors.primaryFixed.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    widget.viewModel.strings.get('worker_quote'),
                                    style: SahayakTypography.caption(
                                      color: isEmergency ? SahayakColors.error : SahayakColors.primary,
                                    ).copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.chevron_right_rounded, color: SahayakColors.outline),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    final userName = viewModel.currentUser?.name.split(' ').first ?? 'Citizen';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Live Location & Greeting Bar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: SahayakColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: SahayakColors.borderSubtle),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: SahayakColors.primaryFixed,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_rounded, color: SahayakColors.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${viewModel.strings.get('hello')}, $userName 👋',
                            style: SahayakTypography.labelLg().copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.my_location_rounded, size: 12, color: SahayakColors.secondary),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  viewModel.currentWard,
                                  style: SahayakTypography.caption(color: SahayakColors.secondary).copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: viewModel.strings.get('detect_live_gps'),
                      icon: viewModel.isDetectingLocation
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.gps_fixed_rounded, color: SahayakColors.primary),
                      onPressed: viewModel.isDetectingLocation
                          ? null
                          : () => viewModel.detectCurrentDeviceLocation(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Title Section: Short, punchy
              Text(
                viewModel.strings.get('choose_mode'),
                style: SahayakTypography.headlineMd().copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                viewModel.strings.get('choose_mode_sub'),
                style: SahayakTypography.bodySm(color: SahayakColors.onSurfaceVariant),
              ),

              const SizedBox(height: 16),

              // OPTION 1: Emergency Request
              _buildOptionCard(
                title: viewModel.strings.get('emergency_request'),
                subtitle: viewModel.strings.get('emergency_sub_short'),
                badges: const ['Rapid', 'SOS', '<15 Mins', '24/7'],
                icon: Icons.bolt_rounded,
                accentColor: SahayakColors.error,
                containerColor: const Color(0xFFFDF2F2),
                borderColor: SahayakColors.error.withValues(alpha: 0.3),
                isSelected: _selectedModeIsEmergency == true,
                onTap: () {
                  _selectMode(true);
                  _showDomainBottomSheet(context, true);
                },
              ),

              const SizedBox(height: 16),

              // OPTION 2: Book a Service
              _buildOptionCard(
                title: viewModel.strings.get('book_service'),
                subtitle: viewModel.strings.get('book_sub_short'),
                badges: const ['Scheduled', 'Verified', 'Transparent', 'Fair Rates'],
                icon: Icons.calendar_month_rounded,
                accentColor: SahayakColors.primary,
                containerColor: SahayakColors.surfaceContainerLowest,
                borderColor: SahayakColors.primary.withValues(alpha: 0.3),
                isSelected: _selectedModeIsEmergency == false,
                onTap: () {
                  _selectMode(false);
                  _showDomainBottomSheet(context, false);
                },
              ),

              // If an option was selected, list domains inline as well
              if (_selectedModeIsEmergency != null) ...[
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        _selectedModeIsEmergency! ? viewModel.strings.get('emergency_domains') : viewModel.strings.get('service_domains'),
                        style: SahayakTypography.headlineSm(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showDomainBottomSheet(context, _selectedModeIsEmergency!),
                      icon: const Icon(Icons.tune_rounded, size: 16),
                      label: Text(viewModel.strings.get('view_all')),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildInlineDomainGrid(context, _selectedModeIsEmergency!),
              ],

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required List<String> badges,
    required IconData icon,
    required Color accentColor,
    required Color containerColor,
    required Color borderColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: containerColor,
      borderRadius: BorderRadius.circular(20),
      elevation: isSelected ? 3 : 1,
      shadowColor: accentColor.withValues(alpha: 0.15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? accentColor : borderColor,
              width: isSelected ? 2 : 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row with Icon and Arrow
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: accentColor, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: SahayakTypography.headlineSm().copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: SahayakTypography.bodySm(color: SahayakColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // One-Worder Chips Row
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: badges.map((badge) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: accentColor.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      badge,
                      style: SahayakTypography.caption(color: accentColor).copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInlineDomainGrid(BuildContext context, bool isEmergency) {
    final services = widget.viewModel.repository.services;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.45,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final item = services[index];
        return Material(
          color: SahayakColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: () => _openBookingWizard(item, isEmergency),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: SahayakColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: isEmergency
                              ? SahayakColors.errorContainer
                              : SahayakColors.primaryFixed,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          item.icon,
                          color: isEmergency ? SahayakColors.onErrorContainer : SahayakColors.primary,
                          size: 18,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isEmergency
                              ? SahayakColors.errorContainer.withValues(alpha: 0.6)
                              : SahayakColors.primaryFixed.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.viewModel.strings.get('worker_quote'),
                          style: SahayakTypography.caption(
                            color: isEmergency ? SahayakColors.error : SahayakColors.primary,
                          ).copyWith(fontWeight: FontWeight.w700, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: SahayakTypography.labelMd().copyWith(fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        item.description,
                        style: SahayakTypography.caption(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
