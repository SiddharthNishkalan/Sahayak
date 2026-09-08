import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../data/models/service.dart';
import '../../../app_view_model.dart';
import 'step2_time_location.dart';

class Step1ProblemDetailsScreen extends StatefulWidget {
  final AppViewModel viewModel;
  final ServiceItem service;

  const Step1ProblemDetailsScreen({
    super.key,
    required this.viewModel,
    required this.service,
  });

  @override
  State<Step1ProblemDetailsScreen> createState() => _Step1ProblemDetailsScreenState();
}

class _Step1ProblemDetailsScreenState extends State<Step1ProblemDetailsScreen> {
  late TextEditingController _descController;
  bool _descriptionError = false;
  int _selectedIntentTab = 0; // 0 = All, 1 = Repair, 2 = Installation, 3 = Inspection

  final List<String> _intentTabs = ['All', 'Repair', 'Installation', 'Inspection'];

  final List<Map<String, dynamic>> _tradeDomains = [
    {'id': 'plumbing', 'name': 'Plumbing & Water', 'desc': 'Pipes, taps, leakages, drains', 'icon': Icons.plumbing_rounded},
    {'id': 'electrical', 'name': 'Electrical & Power', 'desc': 'Wiring, switches, tripping, shorts', 'icon': Icons.bolt_rounded},
    {'id': 'appliance', 'name': 'Appliances & Motors', 'desc': 'Water heaters, pumps, motors', 'icon': Icons.home_repair_service_rounded},
    {'id': 'carpentry', 'name': 'Carpentry & Fittings', 'desc': 'Cabinets, hinges, woodwork', 'icon': Icons.carpenter_rounded},
    {'id': 'painting', 'name': 'Painting & Sealing', 'desc': 'Waterproofing, moisture spots', 'icon': Icons.format_paint_rounded},
    {'id': 'cleaner', 'name': 'Deep Cleaning', 'desc': 'Sanitation, drain clearance', 'icon': Icons.cleaning_services_rounded},
  ];

  final Map<int, bool> _faqExpanded = {0: false, 1: false, 2: false};

  @override
  void initState() {
    super.initState();
    widget.viewModel.setService(widget.service);
    _descController = TextEditingController(text: widget.viewModel.wizardProblemDescription);
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  void _goToStep2() {
    final text = _descController.text.trim();
    if (text.isEmpty) {
      setState(() => _descriptionError = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Problem description is mandatory (*). Please describe what needs fixing.'),
          backgroundColor: SahayakColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _descriptionError = false);
    widget.viewModel.setProblemDescription(text);
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => Step2TimeLocationScreen(
          viewModel: widget.viewModel,
          service: widget.service,
        ),
      ),
    );
  }

  List<ServiceSubcategory> _getFilteredSubcategories() {
    final subcategories = widget.viewModel.repository.getSubcategoriesForService(widget.service.id);
    if (_selectedIntentTab == 0) return subcategories;
    if (_selectedIntentTab == 1) {
      final matches = subcategories.where((s) =>
        s.title.toLowerCase().contains('repair') ||
        s.title.toLowerCase().contains('fix') ||
        s.title.toLowerCase().contains('leak') ||
        s.title.toLowerCase().contains('socket') ||
        s.title.toLowerCase().contains('mcb') ||
        s.title.toLowerCase().contains('care') ||
        s.title.toLowerCase().contains('clean') ||
        s.title.toLowerCase().contains('mow') ||
        s.title.toLowerCase().contains('hour') ||
        s.description.toLowerCase().contains('repair') ||
        s.description.toLowerCase().contains('fix')
      ).toList();
      return matches.isNotEmpty ? matches : subcategories;
    }
    if (_selectedIntentTab == 2) {
      final matches = subcategories.where((s) =>
        s.title.toLowerCase().contains('install') ||
        s.title.toLowerCase().contains('setup') ||
        s.title.toLowerCase().contains('fitting') ||
        s.title.toLowerCase().contains('assembly') ||
        s.title.toLowerCase().contains('commute') ||
        s.title.toLowerCase().contains('assist') ||
        s.title.toLowerCase().contains('move-in') ||
        s.description.toLowerCase().contains('install') ||
        s.description.toLowerCase().contains('setup') ||
        s.description.toLowerCase().contains('fitting')
      ).toList();
      return matches.isNotEmpty ? matches : subcategories;
    }
    if (_selectedIntentTab == 3) {
      final matches = subcategories.where((s) =>
        s.title.toLowerCase().contains('service') ||
        s.title.toLowerCase().contains('diagnos') ||
        s.title.toLowerCase().contains('check') ||
        s.title.toLowerCase().contains('inspect') ||
        s.title.toLowerCase().contains('track') ||
        s.title.toLowerCase().contains('touch-up') ||
        s.description.toLowerCase().contains('service') ||
        s.description.toLowerCase().contains('diagnos') ||
        s.description.toLowerCase().contains('check')
      ).toList();
      return matches.isNotEmpty ? matches : subcategories;
    }
    return subcategories;
  }

  String _getHintTextForService(String serviceId) {
    switch (serviceId.toLowerCase().trim()) {
      case 'plumber':
      case 'plumbing':
        return 'e.g., kitchen sink mixer tap is dripping continuously, need washer or spindle replaced...';
      case 'electrician':
      case 'electrical':
        return 'e.g., ceiling fan regulator sparking or power tripping on main switchboard socket...';
      case 'cleaner':
      case 'cleaning':
        return 'e.g., deep cleaning required for 2BHK flat, including kitchen tiles & bathroom descaling...';
      case 'carpenter':
      case 'carpentry':
        return 'e.g., wardrobe door hinges loose or bed frame needs realignment & polishing...';
      case 'caregiver':
      case 'caregiving':
        return 'e.g., daily mobility assistance, morning routine support and vital tracking for senior...';
      case 'driver':
      case 'driving':
        return 'e.g., experienced chauffeur needed for outstation trip or daily city office commute...';
      case 'gardener':
      case 'gardening':
        return 'e.g., lawn mowing, shrub pruning, and organic soil fertilizing for balcony garden...';
      case 'appliance':
      case 'appliances':
        return 'e.g., split AC cooling issue, low airflow or washing machine drain pump noise...';
      default:
        return 'e.g., describe what needs inspection, fixing or replacement...';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredSubcategories = _getFilteredSubcategories();
    final selectedSubId = widget.viewModel.wizardSelectedSubcategoryId;
    final photos = widget.viewModel.wizardUploadedPhotos;
    final videos = widget.viewModel.wizardUploadedVideos;
    final isMultiDomain = widget.viewModel.wizardIsMultiDomain;
    final selectedDomains = widget.viewModel.wizardSelectedDomains;

    return Scaffold(
      backgroundColor: SahayakColors.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          splashRadius: 24,
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.maybePop(context);
          },
        ),
        title: Text(widget.service.title, style: SahayakTypography.titleMedium().copyWith(fontWeight: FontWeight.w700)),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: SahayakColors.primary, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: SahayakColors.outlineVariant, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: SahayakColors.outlineVariant, shape: BoxShape.circle)),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                        // 1. Offer / Assurance Strip
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: SahayakColors.primaryFixed.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: SahayakColors.primary.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.verified_user_rounded, color: SahayakColors.primary, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Cooperative Certified • Worker Quoted Pricing • 0% Broker Markup',
                                  style: SahayakTypography.caption(color: SahayakColors.primary).copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // 2. Hero Trade Banner Card
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: SahayakColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: SahayakColors.borderSubtle),
                            boxShadow: [
                              BoxShadow(
                                color: SahayakColors.onSurface.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: SahayakColors.primaryFixed,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(widget.service.icon, color: SahayakColors.primary, size: 26),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            widget.service.title,
                                            style: SahayakTypography.headlineSm().copyWith(fontWeight: FontWeight.w800),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: SahayakColors.secondaryFixed,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'Verified',
                                            style: SahayakTypography.caption(color: SahayakColors.onSecondaryFixed)
                                                .copyWith(fontSize: 10, fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      widget.service.description,
                                      style: SahayakTypography.bodySm(),
                                    ),
                                    const SizedBox(height: 4),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Worker Quoted Pricing',
                                            style: SahayakTypography.labelSm(color: SahayakColors.primary).copyWith(fontWeight: FontWeight.w700),
                                          ),
                                          TextSpan(
                                            text: ' · Direct pro quotes',
                                            style: SahayakTypography.caption(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        if (!isMultiDomain) ...[
                          // 3. Segmented Intent Tab Row
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: SahayakColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: List.generate(_intentTabs.length, (idx) {
                                final isSel = _selectedIntentTab == idx;
                                return Expanded(
                                  child: InkWell(
                                    onTap: () => setState(() => _selectedIntentTab = idx),
                                    borderRadius: BorderRadius.circular(10),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      curve: Curves.easeInOut,
                                      padding: const EdgeInsets.symmetric(vertical: 9),
                                      decoration: BoxDecoration(
                                        color: isSel ? SahayakColors.surfaceContainerLowest : Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: isSel
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.04),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 1),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        _intentTabs[idx],
                                        style: SahayakTypography.caption(
                                          color: isSel ? SahayakColors.primary : SahayakColors.onSurfaceVariant,
                                        ).copyWith(fontWeight: isSel ? FontWeight.w800 : FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // 4. Service Subcategories Grid (Single Trade)
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: SahayakColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: SahayakColors.borderSubtle),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        'Service Subcategories',
                                        style: SahayakTypography.labelLg().copyWith(fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: SahayakColors.primaryFixed,
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        '${filteredSubcategories.length} Options',
                                        style: SahayakTypography.caption(
                                          color: SahayakColors.primary,
                                        ).copyWith(fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Service Variant Grid with Individual Pricing
                                GridView.count(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  childAspectRatio: 1.14,
                                  children: filteredSubcategories.map((sub) {
                                    final isSel = sub.id == selectedSubId;
                                    return InkWell(
                                      onTap: () {
                                        HapticFeedback.selectionClick();
                                        setState(() {
                                          widget.viewModel.setSubcategory(sub.id);
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(14),
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: isSel
                                              ? SahayakColors.surfaceContainerHigh
                                              : SahayakColors.surfaceContainerLow,
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(
                                            color: isSel ? SahayakColors.primary : SahayakColors.borderSubtle,
                                            width: isSel ? 2 : 1,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  width: 30,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    color: isSel ? SahayakColors.primary : SahayakColors.surfaceContainerHighest,
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Icon(
                                                    sub.icon,
                                                    size: 16,
                                                    color: isSel ? Colors.white : SahayakColors.onSurface,
                                                  ),
                                                ),
                                                Icon(
                                                  isSel ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                                                  size: 18,
                                                  color: isSel ? SahayakColors.primary : SahayakColors.outline,
                                                ),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  sub.title,
                                                  style: SahayakTypography.labelSm().copyWith(fontWeight: FontWeight.w700),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 2),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        'Worker Quote',
                                                        style: SahayakTypography.caption(color: SahayakColors.primary)
                                                            .copyWith(fontWeight: FontWeight.w700),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text('~45m', style: SahayakTypography.caption().copyWith(fontSize: 10)),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          // Multi-Trade Request Scope Card
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: SahayakColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: SahayakColors.borderSubtle),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          const Icon(Icons.hub_rounded, size: 20, color: SahayakColors.secondary),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Multi-Trade Request Scope',
                                              style: SahayakTypography.labelLg().copyWith(fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: SahayakColors.secondaryFixed,
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        '${selectedDomains.length} Trades Active',
                                        style: SahayakTypography.caption(
                                          color: SahayakColors.onSecondaryFixed,
                                        ).copyWith(fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Your request combines multiple trade domains. Nearby certified cooperative technicians capable of cross-trade diagnostics will be notified.',
                                  style: SahayakTypography.bodySm(color: SahayakColors.onSurfaceVariant),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: selectedDomains.map((d) {
                                    final trade = _tradeDomains.firstWhere(
                                      (t) => t['id'] == d,
                                      orElse: () => {
                                        'name': d[0].toUpperCase() + d.substring(1),
                                        'icon': Icons.handyman_rounded
                                      },
                                    );
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: SahayakColors.surfaceContainerHigh,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: SahayakColors.secondary.withValues(alpha: 0.4)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(trade['icon'] as IconData, size: 16, color: SahayakColors.secondary),
                                          const SizedBox(width: 6),
                                          Text(
                                            trade['name'] as String,
                                            style: SahayakTypography.labelSm(color: SahayakColors.onSurface)
                                                .copyWith(fontWeight: FontWeight.w700),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 14),

                        // 6. Mandatory Problem Description (*)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: SahayakColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _descriptionError ? SahayakColors.error : SahayakColors.borderSubtle,
                              width: _descriptionError ? 1.5 : 1.0,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Describe the issue ',
                                            style: SahayakTypography.labelMd(color: SahayakColors.onSurface),
                                          ),
                                          TextSpan(
                                            text: '*',
                                            style: SahayakTypography.labelMd(color: SahayakColors.error)
                                                .copyWith(fontWeight: FontWeight.w800),
                                          ),
                                          TextSpan(
                                            text: ' (Mandatory)',
                                            style: SahayakTypography.caption(color: SahayakColors.error),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_descController.text.length}/300',
                                    style: SahayakTypography.caption(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _descController,
                                maxLines: 4,
                                maxLength: 300,
                                keyboardType: TextInputType.multiline,
                                textCapitalization: TextCapitalization.sentences,
                                onChanged: (val) {
                                  setState(() {
                                    if (_descriptionError && val.trim().isNotEmpty) {
                                      _descriptionError = false;
                                    }
                                  });
                                },
                                decoration: InputDecoration(
                                  counterText: '',
                                  hintText: _getHintTextForService(widget.service.id),
                                  fillColor: SahayakColors.surfaceContainerLow,
                                  errorText: _descriptionError ? 'Description is required so workers bring correct fittings' : null,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // 7. Photos & 15s Video Attachment
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: SahayakColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: SahayakColors.borderSubtle),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Attach Photos & Video (Optional)',
                                      style: SahayakTypography.labelMd(),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('${photos.length + videos.length} files attached', style: SahayakTypography.caption()),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'A quick photo or 15s video allows cooperative pros to accurately evaluate replacement spares.',
                                style: SahayakTypography.caption(),
                              ),
                              const SizedBox(height: 10),

                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    ...photos.asMap().entries.map((entry) {
                                      final idx = entry.key;
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: Stack(
                                          children: [
                                            Container(
                                              width: 72,
                                              height: 72,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                                color: SahayakColors.surfaceContainer,
                                                border: Border.all(color: SahayakColors.borderSubtle),
                                              ),
                                              clipBehavior: Clip.antiAlias,
                                              child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
                                            ),
                                            Positioned(
                                              top: 2,
                                              right: 2,
                                              child: InkWell(
                                                onTap: () {
                                                  HapticFeedback.selectionClick();
                                                  setState(() => widget.viewModel.removeWizardPhoto(idx));
                                                },
                                                borderRadius: BorderRadius.circular(999),
                                                child: Container(
                                                  width: 26,
                                                  height: 26,
                                                  alignment: Alignment.center,
                                                  child: Container(
                                                    padding: const EdgeInsets.all(3),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black.withValues(alpha: 0.65),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(Icons.close, size: 12, color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                    if (photos.length < 3)
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: InkWell(
                                          onTap: () {
                                            HapticFeedback.lightImpact();
                                            setState(() => widget.viewModel.addWizardPhoto('assets/images/logo.png'));
                                          },
                                          borderRadius: BorderRadius.circular(12),
                                          child: Container(
                                            width: 72,
                                            height: 72,
                                            decoration: BoxDecoration(
                                              color: SahayakColors.surfaceContainerLow,
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: SahayakColors.borderSubtle),
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.add_a_photo_outlined, size: 20, color: SahayakColors.primary),
                                                const SizedBox(height: 2),
                                                Text('+ Photo', style: SahayakTypography.caption(color: SahayakColors.primary).copyWith(fontSize: 10, fontWeight: FontWeight.w700)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (videos.length < 2)
                                      InkWell(
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          setState(() => widget.viewModel.addWizardVideo('sample_video_clip.mp4'));
                                        },
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          width: 72,
                                          height: 72,
                                          decoration: BoxDecoration(
                                            color: SahayakColors.surfaceContainerLow,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: SahayakColors.borderSubtle),
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.videocam_outlined, size: 22, color: SahayakColors.secondary),
                                              const SizedBox(height: 2),
                                              Text('+ Video', style: SahayakTypography.caption(color: SahayakColors.secondary).copyWith(fontSize: 10, fontWeight: FontWeight.w700)),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // 8. Numbered Process Steps (Reference Pattern)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: SahayakColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: SahayakColors.borderSubtle),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('How Service Works', style: SahayakTypography.labelLg().copyWith(fontWeight: FontWeight.w800)),
                              const SizedBox(height: 12),
                              _buildNumberedStep(1, 'Formulate Request', 'Detail the problem and select your preferred timeslot.'),
                              _buildNumberedStep(2, 'Local Worker Match', 'Nearby background-verified cooperative members bid or accept.'),
                              _buildNumberedStep(3, 'Doorstep OTP Verification', 'Pro verifies your 4-digit code at arrival before starting.'),
                              _buildNumberedStep(4, 'Fair Transparent Settlement', 'Pay standardized labour rates with zero hidden markups.'),
                            ],
                          ),
                        ),



                        const SizedBox(height: 14),

                        // 10. FAQ Accordion (Reference Pattern)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: SahayakColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: SahayakColors.borderSubtle),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Frequently Asked Questions', style: SahayakTypography.labelLg().copyWith(fontWeight: FontWeight.w800)),
                              const SizedBox(height: 8),
                              _buildFaqItem(
                                0,
                                'How does cooperative fair pricing work?',
                                'Our rates are standardized by local worker guild councils. 100% of standard labour fees go directly to the worker with zero surge pricing during peak hours.',
                              ),
                              _buildFaqItem(
                                1,
                                'Can I cancel if my schedule changes?',
                                'Yes. You can cancel free of charge up to 1 hour prior to the scheduled slot under our Fair-Work Community Policy.',
                              ),
                              _buildFaqItem(
                                2,
                                'What is the Doorstep Verification OTP?',
                                'A unique 4-digit code is generated upon booking confirmation. Share it with your technician upon arrival to authorize the job start.',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Sticky Bottom Bar
                SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: SahayakColors.surfaceContainerLowest,
                      border: const Border(top: BorderSide(color: SahayakColors.borderSubtle)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _goToStep2,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                'Continue to Time & Location',
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildNumberedStep(int number, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: SahayakColors.primaryFixed,
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: SahayakTypography.caption(color: SahayakColors.primary).copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: SahayakTypography.labelSm().copyWith(fontWeight: FontWeight.w700)),
                Text(desc, style: SahayakTypography.caption()),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildFaqItem(int index, String question, String answer) {
    final isExpanded = _faqExpanded[index] ?? false;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _faqExpanded[index] = !isExpanded);
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    question,
                    style: SahayakTypography.labelSm().copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: SahayakColors.outline,
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  answer,
                  style: SahayakTypography.caption(),
                ),
              ),
              crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }
}
