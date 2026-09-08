import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../app_view_model.dart';
import 'institution_request_step2.dart';

class InstitutionRequestStep1Screen extends StatefulWidget {
  final AppViewModel viewModel;

  const InstitutionRequestStep1Screen({
    super.key,
    required this.viewModel,
  });

  @override
  State<InstitutionRequestStep1Screen> createState() => _InstitutionRequestStep1ScreenState();
}

class _InstitutionRequestStep1ScreenState extends State<InstitutionRequestStep1Screen> {
  late TextEditingController _notesController;

  final List<Map<String, dynamic>> _tradeDomains = [
    {
      'id': 'electrical',
      'name': 'Electricians & Power',
      'desc': 'Panels, wiring, load testing, generators, distribution boards',
      'icon': Icons.bolt_rounded,
      'color': Color(0xFFEAB308),
    },
    {
      'id': 'cleaner',
      'name': 'Deep Cleaning & Sanitation',
      'desc': 'Hall cleaning, floor buffing, restrooms, waste management',
      'icon': Icons.cleaning_services_rounded,
      'color': Color(0xFF06B6D4),
    },
    {
      'id': 'plumbing',
      'name': 'Plumbing & Water Systems',
      'desc': 'Commercial pipes, tank valves, drainage, sanitary fixtures',
      'icon': Icons.plumbing_rounded,
      'color': Color(0xFF3B82F6),
    },
    {
      'id': 'carpentry',
      'name': 'Carpentry & Fittings',
      'desc': 'Classroom furniture, partitions, hinges, heavy woodwork',
      'icon': Icons.carpenter_rounded,
      'color': Color(0xFFF97316),
    },
    {
      'id': 'appliance',
      'name': 'HVAC & Facility Machinery',
      'desc': 'Commercial AC units, water chillers, exhaust blowers, pumps',
      'icon': Icons.home_repair_service_rounded,
      'color': Color(0xFF8B5CF6),
    },
    {
      'id': 'painting',
      'name': 'Painting & Waterproofing',
      'desc': 'Exterior coatings, wall primers, moisture barriers, sealing',
      'icon': Icons.format_paint_rounded,
      'color': Color(0xFF10B981),
    },
  ];

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.viewModel.institutionTaskNotes);
    if (widget.viewModel.institutionDomainWorkerCounts.isEmpty) {
      widget.viewModel.updateInstitutionWorkerCount('electrical', 2);
      widget.viewModel.updateInstitutionWorkerCount('cleaner', 2);
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _goToStep2() {
    if (widget.viewModel.institutionTotalWorkers <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one trade domain and specify the worker count.'),
          backgroundColor: SahayakColors.error,
        ),
      );
      return;
    }

    widget.viewModel.setInstitutionTaskNotes(_notesController.text.trim());
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => InstitutionRequestStep2Screen(
          viewModel: widget.viewModel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedDomains = widget.viewModel.institutionDomainWorkerCounts;
    final totalWorkers = widget.viewModel.institutionTotalWorkers;
    final savedSites = widget.viewModel.repository.addresses;
    final selectedSite = widget.viewModel.institutionSelectedSite;

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
        title: Text(
          'Workforce Request',
          style: SahayakTypography.titleMedium().copyWith(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: SahayakColors.secondaryFixed.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Step 1 of 2',
                style: SahayakTypography.caption(color: SahayakColors.secondary).copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                        // Section 1: Trades and Multi-Worker Counts
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '1. Required Trades & Headcount',
                                style: SahayakTypography.labelLg().copyWith(fontWeight: FontWeight.w800),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: SahayakColors.primaryFixed,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '$totalWorkers Total Workers',
                                style: SahayakTypography.caption(color: SahayakColors.primary).copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Select one or multiple skills required for your facility and adjust headcount per trade.',
                          style: SahayakTypography.caption(color: SahayakColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 10),

                        // Multi-Trade In-Context Explanatory Banner
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: SahayakColors.secondaryContainer.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: SahayakColors.secondary.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.hub_rounded, size: 20, color: SahayakColors.secondary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Multi-Trade Request',
                                      style: SahayakTypography.labelMd().copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: SahayakColors.secondary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Multi-trade: combine multiple services like electrical and cleaning into a single request with domain-specific coordinator assignment and consolidated invoicing.',
                                      style: SahayakTypography.caption(color: SahayakColors.onSurfaceVariant).copyWith(
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Trade Domain Cards with Headcount Stepper
                        ..._tradeDomains.map((trade) {
                          final domainId = trade['id'] as String;
                          final isSelected = selectedDomains.containsKey(domainId);
                          final count = selectedDomains[domainId] ?? 0;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? SahayakColors.surfaceContainerLowest
                                  : SahayakColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? SahayakColors.secondary : SahayakColors.borderSubtle,
                                width: isSelected ? 1.8 : 1.0,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: SahayakColors.secondary.withValues(alpha: 0.06),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      widget.viewModel.toggleInstitutionDomain(domainId);
                                    },
                                    borderRadius: BorderRadius.circular(10),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: (trade['color'] as Color).withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Icon(
                                            trade['icon'] as IconData,
                                            color: trade['color'] as Color,
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                trade['name'] as String,
                                                style: SahayakTypography.labelMd().copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  color: isSelected ? SahayakColors.onSurface : SahayakColors.onSurfaceVariant,
                                                ),
                                              ),
                                              Text(
                                                trade['desc'] as String,
                                                style: SahayakTypography.caption(),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Checkbox(
                                          value: isSelected,
                                          activeColor: SahayakColors.secondary,
                                          onChanged: (_) {
                                            HapticFeedback.selectionClick();
                                            widget.viewModel.toggleInstitutionDomain(domainId);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),

                                  // If selected, show Headcount Stepper
                                  if (isSelected) ...[
                                    const Divider(height: 16, color: SahayakColors.borderSubtle),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Workers needed for this trade:',
                                            style: SahayakTypography.caption(color: SahayakColors.onSurface).copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            // Decrement Button
                                            IconButton(
                                              icon: const Icon(Icons.remove_circle_outline_rounded, size: 22),
                                              color: count > 1 ? SahayakColors.primary : SahayakColors.outline,
                                              onPressed: count > 1
                                                  ? () {
                                                      HapticFeedback.selectionClick();
                                                      widget.viewModel.updateInstitutionWorkerCount(domainId, count - 1);
                                                    }
                                                  : () {
                                                      HapticFeedback.selectionClick();
                                                      widget.viewModel.toggleInstitutionDomain(domainId);
                                                    },
                                              visualDensity: VisualDensity.compact,
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: SahayakColors.surfaceContainerHigh,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '$count',
                                                style: SahayakTypography.labelMd().copyWith(
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                            // Increment Button
                                            IconButton(
                                              icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
                                              color: count < 20 ? SahayakColors.secondary : SahayakColors.outline,
                                              onPressed: count < 20
                                                  ? () {
                                                      HapticFeedback.selectionClick();
                                                      widget.viewModel.updateInstitutionWorkerCount(domainId, count + 1);
                                                    }
                                                  : null,
                                              visualDensity: VisualDensity.compact,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }),

                        const SizedBox(height: 18),

                        // Section 2: Deployment Site / Facility Location (Single Registered Facility Site)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '2. Deployment Site',
                                style: SahayakTypography.labelLg().copyWith(fontWeight: FontWeight.w800),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: SahayakColors.secondaryFixed.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Primary Facility',
                                style: SahayakTypography.caption(color: SahayakColors.secondary).copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Single Registered Site Card (All other addresses excluded)
                        Builder(
                          builder: (context) {
                            final site = savedSites.isNotEmpty ? savedSites.first : selectedSite;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: SahayakColors.secondaryFixed.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: SahayakColors.secondary,
                                  width: 1.5,
                                ),
                              ),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.business_rounded,
                                  color: SahayakColors.secondary,
                                ),
                                title: Text(
                                  site.label,
                                  style: SahayakTypography.labelMd().copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                subtitle: Text(
                                  site.fullAddress,
                                  style: SahayakTypography.caption(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: const Icon(
                                  Icons.verified_rounded,
                                  color: SahayakColors.secondary,
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 18),

                        // Section 3: Facility Notes / Specific Work Scope
                        Text(
                          '3. Work Scope & Security / Entry Notes (Optional)',
                          style: SahayakTypography.labelLg().copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _notesController,
                          maxLines: 3,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            hintText: 'e.g. Workers must sign in at Gate 2 security desk. High-voltage safety gear required.',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: SahayakColors.borderSubtle),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: SahayakColors.borderSubtle),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: SahayakColors.secondary, width: 1.5),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Bottom Action Bar
                SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: SahayakColors.surfaceContainerLowest,
                      border: const Border(top: BorderSide(color: SahayakColors.borderSubtle)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 6,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$totalWorkers Workers Requested',
                                style: SahayakTypography.labelMd().copyWith(fontWeight: FontWeight.w800),
                              ),
                              Text(
                                'Across ${selectedDomains.length} trades',
                                style: SahayakTypography.caption(color: SahayakColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: totalWorkers > 0 ? _goToStep2 : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: SahayakColors.secondary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            child: const Row(
                              children: [
                                Text('Set Timing'),
                                SizedBox(width: 6),
                                Icon(Icons.arrow_forward_rounded, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
