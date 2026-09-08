import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../data/models/service.dart';
import '../../../app_view_model.dart';
import '../../shared_widgets/cooperative_app_bar.dart';
import '../booking_wizard/step1_problem_details.dart';
import 'institution_home_view.dart';

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
  late TextEditingController _searchController;
  late PageController _bannerPageController;
  Timer? _bannerTimer;
  int _currentBannerIndex = 0;
  bool? _selectedModeIsEmergency; // null = all, true = emergency, false = standard

  final List<Map<String, dynamic>> _promoBanners = [
    {
      'title': 'Cooperative Fair-Wage Guarantee',
      'subtitle': 'Zero surge pricing. 100% of standard labour fees go directly to verified workers.',
      'badge': 'Cooperative Charter',
      'icon': Icons.verified_user_rounded,
      'color': SahayakColors.primary,
      'bg': Color(0xFFEFF4FE),
    },
    {
      'title': 'Monsoon Drainage & Pipe Check',
      'subtitle': 'Pre-monsoon roof inspection and concealed drain clearance by verified pros.',
      'badge': 'Seasonal Shield',
      'icon': Icons.water_damage_rounded,
      'color': SahayakColors.secondary,
      'bg': Color(0xFFEBFBF3),
    },
    {
      'title': 'Emergency SOS Doorstep Dispatch',
      'subtitle': 'Burst pipe or power outage? Nearest cooperative pro dispatched under 20 mins.',
      'badge': '24/7 Rapid SOS',
      'icon': Icons.bolt_rounded,
      'color': SahayakColors.error,
      'bg': Color(0xFFFEF2F2),
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.viewModel.serviceSearchQuery);
    _bannerPageController = PageController();
    _startBannerAutoScroll();
  }

  void _startBannerAutoScroll() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      if (_bannerPageController.hasClients) {
        _currentBannerIndex = (_currentBannerIndex + 1) % _promoBanners.length;
        _bannerPageController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerPageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _selectMode(bool isEmergency) {
    setState(() {
      _selectedModeIsEmergency = isEmergency;
    });
  }

  void _openBookingWizard(ServiceItem service, bool isEmergency) {
    HapticFeedback.mediumImpact();
    widget.viewModel.setTimingMode(isEmergency: isEmergency);
    widget.viewModel.setService(service);
    Navigator.push(
      context,
      CupertinoPageRoute(
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
      showDragHandle: true,
      useSafeArea: true,
      backgroundColor: SahayakColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final services = widget.viewModel.repository.services;
        bool isMultiTradeMode = false;
        final Set<String> selectedMultiDomains = {'plumbing', 'electrical'};

        final tradeOptions = [
          {'id': 'plumbing', 'name': 'Plumbing & Water', 'desc': 'Pipes, taps, leakages, drains', 'icon': Icons.plumbing_rounded},
          {'id': 'electrical', 'name': 'Electrical & Power', 'desc': 'Wiring, switches, tripping, shorts', 'icon': Icons.bolt_rounded},
          {'id': 'appliance', 'name': 'Appliances & Motors', 'desc': 'Water heaters, pumps, motors', 'icon': Icons.home_repair_service_rounded},
          {'id': 'carpentry', 'name': 'Carpentry & Fittings', 'desc': 'Cabinets, hinges, woodwork', 'icon': Icons.carpenter_rounded},
          {'id': 'cleaner', 'name': 'Deep Cleaning', 'desc': 'Sanitation, drain clearance', 'icon': Icons.cleaning_services_rounded},
          {'id': 'painting', 'name': 'Painting & Sealing', 'desc': 'Waterproofing, moisture spots', 'icon': Icons.format_paint_rounded},
        ];

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: SingleChildScrollView(
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
                                      isEmergency
                                          ? widget.viewModel.strings.get('emergency_request')
                                          : widget.viewModel.strings.get('book_service'),
                                      style: SahayakTypography.headlineSm(),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isMultiTradeMode
                                    ? 'Cross-Trade Combined Diagnostic'
                                    : (isEmergency ? 'Rapid · SOS · Nearest Pro' : 'Standard · Scheduled · Fair Rate'),
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
                    const SizedBox(height: 12),

                    // Choice Tabs: Single Domain vs Multi-Trade
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: SahayakColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => setSheetState(() => isMultiTradeMode = false),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: !isMultiTradeMode ? SahayakColors.surfaceContainerLowest : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: !isMultiTradeMode
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.05),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          ),
                                        ]
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.handyman_rounded,
                                      size: 15,
                                      color: !isMultiTradeMode ? SahayakColors.primary : SahayakColors.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        'Single Trade',
                                        style: SahayakTypography.labelSm(
                                          color: !isMultiTradeMode ? SahayakColors.primary : SahayakColors.onSurfaceVariant,
                                        ).copyWith(fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () => setSheetState(() => isMultiTradeMode = true),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: isMultiTradeMode ? SahayakColors.surfaceContainerLowest : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: isMultiTradeMode
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.05),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          ),
                                        ]
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.hub_rounded, size: 15, color: SahayakColors.secondary),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        'Multi-Trade',
                                        style: SahayakTypography.labelSm(
                                          color: isMultiTradeMode ? SahayakColors.secondary : SahayakColors.onSurfaceVariant,
                                        ).copyWith(fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: SahayakColors.secondaryFixed,
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: const Text(
                                        'Combo',
                                        style: TextStyle(
                                          color: SahayakColors.onSecondaryFixed,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (!isMultiTradeMode) ...[
                      // Shortcut Card to Multi-Trade
                      InkWell(
                        onTap: () => setSheetState(() => isMultiTradeMode = true),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: SahayakColors.secondaryFixed.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: SahayakColors.secondary.withValues(alpha: 0.25)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.hub_rounded, color: SahayakColors.secondary, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Need multiple trades together? (e.g. Plumber + Electrician)',
                                      style: SahayakTypography.caption(color: SahayakColors.onSurface)
                                          .copyWith(fontWeight: FontWeight.w700),
                                    ),
                                    Text(
                                      'Combine trades into one cooperative diagnostic booking →',
                                      style: SahayakTypography.caption(color: SahayakColors.secondary)
                                          .copyWith(fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: SahayakColors.secondary),
                            ],
                          ),
                        ),
                      ),

                      // Single Trade List
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.45,
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
                                  widget.viewModel.toggleMultiDomain(false);
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
                    ] else ...[
                      // Multi-Trade Info Note
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: SahayakColors.secondaryFixed.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline_rounded, size: 16, color: SahayakColors.secondary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Select 2 or more trade domains below. Cooperative specialists qualified across all selected trades will be alerted.',
                                style: SahayakTypography.caption(color: SahayakColors.onSurface),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Multi-Trade Checkbox List
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.38,
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: tradeOptions.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 6),
                          itemBuilder: (context, idx) {
                            final trade = tradeOptions[idx];
                            final id = trade['id'] as String;
                            final isSelected = selectedMultiDomains.contains(id);

                            return InkWell(
                              onTap: () {
                                setSheetState(() {
                                  if (isSelected) {
                                    if (selectedMultiDomains.length > 1) {
                                      selectedMultiDomains.remove(id);
                                    }
                                  } else {
                                    selectedMultiDomains.add(id);
                                  }
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? SahayakColors.surfaceContainerHigh
                                      : SahayakColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected ? SahayakColors.secondary : Colors.transparent,
                                    width: isSelected ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      trade['icon'] as IconData,
                                      size: 22,
                                      color: isSelected ? SahayakColors.secondary : SahayakColors.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            trade['name'] as String,
                                            style: SahayakTypography.labelSm().copyWith(fontWeight: FontWeight.w700),
                                          ),
                                          Text(
                                            trade['desc'] as String,
                                            style: SahayakTypography.caption(),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                                      color: isSelected ? SahayakColors.secondary : SahayakColors.outline,
                                      size: 22,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Multi-Trade Summary & Continue Action
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: selectedMultiDomains.length >= 2
                              ? SahayakColors.secondaryFixed.withValues(alpha: 0.3)
                              : SahayakColors.errorContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedMultiDomains.length >= 2
                                  ? '${selectedMultiDomains.length} Trades Selected'
                                  : 'Select at least 2 trades',
                              style: SahayakTypography.caption(
                                color: selectedMultiDomains.length >= 2
                                    ? SahayakColors.secondary
                                    : SahayakColors.error,
                              ).copyWith(fontWeight: FontWeight.w700),
                            ),
                            Icon(
                              selectedMultiDomains.length >= 2
                                  ? Icons.check_circle_rounded
                                  : Icons.info_outline_rounded,
                              size: 16,
                              color: selectedMultiDomains.length >= 2
                                  ? SahayakColors.secondary
                                  : SahayakColors.error,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: selectedMultiDomains.length >= 2
                              ? () {
                                  widget.viewModel.setMultiTradeDomains(selectedMultiDomains);
                                  widget.viewModel.setTimingMode(isEmergency: isEmergency);
                                  Navigator.pop(ctx);
                                  final comboNames = selectedMultiDomains
                                      .map((d) => d[0].toUpperCase() + d.substring(1))
                                      .join(' + ');
                                  final multiService = ServiceItem(
                                    id: 'multi_trade',
                                    title: 'Multi-Trade ($comboNames)',
                                    description:
                                        'Combined multi-domain diagnostic across ${selectedMultiDomains.join(', ')}',
                                    basePrice: 0,
                                    priceUnit: 'quote',
                                    nearCount: 18,
                                    icon: Icons.hub_rounded,
                                  );
                                  _openBookingWizard(multiService, isEmergency);
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SahayakColors.secondary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: SahayakColors.surfaceContainerHigh,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.hub_rounded, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                selectedMultiDomains.length >= 2
                                    ? 'Continue with ${selectedMultiDomains.length} Trades'
                                    : 'Select 2+ Trades to Continue',
                                style: SahayakTypography.labelMd(color: Colors.white)
                                    .copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.arrow_forward_rounded, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;

    // Institution accounts receive the dedicated institution home view with no emergency shortcut
    if (viewModel.currentUser?.isInstitution == true) {
      return Column(
        children: [
          CooperativeAppBar(viewModel: viewModel),
          Expanded(
            child: InstitutionHomeView(viewModel: viewModel),
          ),
        ],
      );
    }

    final userName = viewModel.currentUser?.name.split(' ').first ?? 'Citizen';
    final filteredServices = viewModel.filteredServices;
    final isSearching = _searchController.text.trim().isNotEmpty;

    return Column(
      children: [
        CooperativeAppBar(viewModel: viewModel),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              HapticFeedback.lightImpact();
              await Future.delayed(const Duration(milliseconds: 500));
            },
            color: SahayakColors.primary,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: SahayakColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: SahayakColors.borderSubtle),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: SahayakColors.primaryFixed,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_rounded, color: SahayakColors.primary, size: 20),
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

              const SizedBox(height: 14),

              // 2. Search Bar (Search-First Pattern)
              Container(
                decoration: BoxDecoration(
                  color: SahayakColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSearching ? SahayakColors.primary : SahayakColors.borderSubtle,
                    width: isSearching ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: SahayakColors.onSurface.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      viewModel.setSearchQuery(val);
                    });
                  },
                  decoration: InputDecoration(
                    hintText: viewModel.strings.get('search_placeholder'),
                    hintStyle: SahayakTypography.bodySm(color: SahayakColors.outline),
                    prefixIcon: const Icon(Icons.search_rounded, color: SahayakColors.primary),
                    suffixIcon: isSearching
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18, color: SahayakColors.outline),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                viewModel.setSearchQuery('');
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // IF SEARCHING: Show flat search discovery list
              if (isSearching) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Matching Services (${filteredServices.length})',
                      style: SahayakTypography.labelLg().copyWith(fontWeight: FontWeight.w700),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          viewModel.setSearchQuery('');
                        });
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (filteredServices.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: SahayakColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: SahayakColors.borderSubtle),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.search_off_rounded, size: 40, color: SahayakColors.outline),
                        const SizedBox(height: 8),
                        Text('No services found matching "${_searchController.text}"',
                            style: SahayakTypography.bodySm(), textAlign: TextAlign.center),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredServices.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, idx) {
                      final item = filteredServices[idx];
                      return Material(
                        color: SahayakColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          onTap: () => _openBookingWizard(item, false),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: SahayakColors.borderSubtle),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: SahayakColors.primaryFixed,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(item.icon, color: SahayakColors.primary, size: 24),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: SahayakTypography.labelMd().copyWith(fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item.description,
                                        style: SahayakTypography.caption(),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('Worker Quoted',
                                        style: SahayakTypography.labelSm(color: SahayakColors.primary)
                                            .copyWith(fontWeight: FontWeight.w700)),
                                    Text('4.9 ★ (${item.nearCount}+)', style: SahayakTypography.caption()),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.chevron_right_rounded, color: SahayakColors.outline),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 20),
              ] else ...[
                // 3. Category Icon Grid (2 Rows x 4 Columns)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'All Services',
                        style: SahayakTypography.labelLg().copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '8 Cooperative Trades',
                        style: SahayakTypography.caption(color: SahayakColors.primary).copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildCategoryIconGrid(context),

                const SizedBox(height: 20),

                // 4. Auto-Rotating Promo Banner Carousel
                _buildPromoCarousel(context),

                const SizedBox(height: 20),

                // 5. Emergency vs Scheduled Mode Cards (Preserved)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        viewModel.strings.get('choose_mode'),
                        style: SahayakTypography.labelLg().copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        viewModel.strings.get('choose_mode_sub'),
                        style: SahayakTypography.caption(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Emergency Card
                    Expanded(
                      child: _buildQuickModeTile(
                        title: viewModel.strings.get('emergency_request'),
                        subtitle: '< 20 Mins SOS',
                        icon: Icons.bolt_rounded,
                        accentColor: SahayakColors.error,
                        bgColor: SahayakColors.errorContainer.withValues(alpha: 0.35),
                        isSelected: _selectedModeIsEmergency == true,
                        onTap: () {
                          _selectMode(true);
                          _showDomainBottomSheet(context, true);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Standard Book Card
                    Expanded(
                      child: _buildQuickModeTile(
                        title: viewModel.strings.get('book_service'),
                        subtitle: 'Scheduled · Fair Rate',
                        icon: Icons.calendar_month_rounded,
                        accentColor: SahayakColors.primary,
                        bgColor: SahayakColors.surfaceContainerLowest,
                        isSelected: _selectedModeIsEmergency == false,
                        onTap: () {
                          _selectMode(false);
                          _showDomainBottomSheet(context, false);
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 6. Horizontally-Scrolling "Popular Services" Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Popular Services',
                        style: SahayakTypography.labelLg().copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showDomainBottomSheet(context, false),
                      child: const Text('See All'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildHorizontalServicesRow(context, false),

                const SizedBox(height: 20),

                // 7. Horizontally-Scrolling "Emergency Ready (SOS)" Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.flash_on_rounded, color: SahayakColors.error, size: 18),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Rapid Emergency (SOS)',
                              style: SahayakTypography.labelLg().copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showDomainBottomSheet(context, true),
                      child: const Text('See All'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildHorizontalServicesRow(context, true),

                const SizedBox(height: 20),

                // 8. Trust & Guarantee Strip
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: SahayakColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: SahayakColors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: SahayakColors.secondaryFixed,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.verified_user_rounded, color: SahayakColors.secondary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Work Solute Cooperative Trust Charter',
                              style: SahayakTypography.labelSm().copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'Verified local technicians • 0% Broker markups • 30-Day Workmanship Warranty',
                              style: SahayakTypography.caption(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    ),
  ],
);
}

  // 8-Category Icon Grid (2 rows x 4 columns)
  Widget _buildCategoryIconGrid(BuildContext context) {
    final services = widget.viewModel.repository.services;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.78,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, idx) {
        final service = services[idx];
        return InkWell(
          onTap: () => _openBookingWizard(service, false),
          borderRadius: BorderRadius.circular(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: SahayakColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: SahayakColors.borderSubtle),
                  boxShadow: [
                    BoxShadow(
                      color: SahayakColors.onSurface.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(service.icon, color: SahayakColors.primary, size: 24),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                service.title,
                style: SahayakTypography.caption().copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        );
      },
    );
  }

  // Auto-Rotating Promo Banner Carousel
  Widget _buildPromoCarousel(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 148,
          child: PageView.builder(
            controller: _bannerPageController,
            itemCount: _promoBanners.length,
            onPageChanged: (idx) {
              setState(() => _currentBannerIndex = idx);
            },
            itemBuilder: (context, idx) {
              final banner = _promoBanners[idx];
              final color = banner['color'] as Color;
              final bg = banner['bg'] as Color;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              banner['badge'] as String,
                              style: SahayakTypography.caption(color: color).copyWith(fontWeight: FontWeight.w800, fontSize: 10),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            banner['title'] as String,
                            style: SahayakTypography.labelMd().copyWith(fontWeight: FontWeight.w800),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            banner['subtitle'] as String,
                            style: SahayakTypography.caption(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(banner['icon'] as IconData, color: color, size: 24),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // Dots Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_promoBanners.length, (i) {
            final isSel = i == _currentBannerIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isSel ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isSel ? SahayakColors.primary : SahayakColors.outlineVariant,
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }),
        ),
      ],
    );
  }

  // Quick Mode Tile (Emergency vs Standard)
  Widget _buildQuickModeTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required Color bgColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(14),
      elevation: isSelected ? 2 : 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? accentColor : SahayakColors.borderSubtle,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: SahayakTypography.labelSm().copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: SahayakTypography.caption(color: accentColor).copyWith(fontWeight: FontWeight.w700, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Horizontally-Scrolling Service Cards Row
  Widget _buildHorizontalServicesRow(BuildContext context, bool isEmergency) {
    final services = widget.viewModel.repository.services;

    return SizedBox(
      height: 192,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: services.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, idx) {
          final service = services[idx];
          return Container(
            width: 154,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: SahayakColors.surfaceContainerLowest,
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
                        color: isEmergency ? SahayakColors.errorContainer : SahayakColors.primaryFixed,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        service.icon,
                        color: isEmergency ? SahayakColors.onErrorContainer : SahayakColors.primary,
                        size: 18,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: SahayakColors.tertiary),
                        Text('4.9', style: SahayakTypography.caption().copyWith(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.title,
                      style: SahayakTypography.labelSm().copyWith(fontWeight: FontWeight.w700),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '~45 mins',
                      style: SahayakTypography.caption(),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Worker Quote',
                        style: SahayakTypography.caption(color: SahayakColors.primary).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () => _openBookingWizard(service, isEmergency),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        constraints: const BoxConstraints(minHeight: 30),
                        decoration: BoxDecoration(
                          color: isEmergency ? SahayakColors.error : SahayakColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isEmergency ? 'SOS' : 'Book',
                          style: SahayakTypography.caption(color: Colors.white).copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
