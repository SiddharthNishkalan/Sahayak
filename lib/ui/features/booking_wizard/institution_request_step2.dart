import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../app_view_model.dart';
import '../booking_status/institution_allocation_status_screen.dart';

class InstitutionRequestStep2Screen extends StatefulWidget {
  final AppViewModel viewModel;

  const InstitutionRequestStep2Screen({
    super.key,
    required this.viewModel,
  });

  @override
  State<InstitutionRequestStep2Screen> createState() => _InstitutionRequestStep2ScreenState();
}

class _InstitutionRequestStep2ScreenState extends State<InstitutionRequestStep2Screen> {
  final List<String> _dateOptions = [
    'Tomorrow\n6 Sep',
    'Friday\n7 Sep',
    'Saturday\n8 Sep',
    'Sunday\n9 Sep',
    'Monday\n10 Sep',
  ];

  final List<Map<String, String>> _shiftOptions = [
    {
      'slot': '9:00 AM – 1:00 PM (Morning Shift)',
      'desc': 'Optimal for facility maintenance & cleaning crews',
    },
    {
      'slot': '1:00 PM – 5:00 PM (Afternoon Shift)',
      'desc': 'Optimal for post-lunch inspections & repairs',
    },
    {
      'slot': '9:00 AM – 5:00 PM (Full Day Shift)',
      'desc': 'Standard 8-hour shift for extensive multi-trade work',
    },
    {
      'slot': '6:00 PM – 10:00 PM (After-Hours Shift)',
      'desc': 'Zero-disruption evening maintenance',
    },
  ];

  void _submitWorkforceRequest() {
    HapticFeedback.heavyImpact();
    final booking = widget.viewModel.createInstitutionWorkforceBooking();

    Navigator.pushAndRemoveUntil(
      context,
      CupertinoPageRoute(
        builder: (_) => InstitutionAllocationStatusScreen(
          viewModel: widget.viewModel,
          booking: booking,
        ),
      ),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedDateIndex = widget.viewModel.institutionSelectedDateIndex;
    final selectedSlot = widget.viewModel.institutionSelectedTimeSlot;
    final domainCounts = widget.viewModel.institutionDomainWorkerCounts;
    final totalWorkers = widget.viewModel.institutionTotalWorkers;
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
          'Deployment Timing',
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
                'Step 2 of 2',
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
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                        // Scheduled Deployment Notice (No Emergency Shortcut)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: SahayakColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: SahayakColors.borderSubtle),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: SahayakColors.secondaryFixed.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.calendar_month_rounded, color: SahayakColors.secondary, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Scheduled Workforce Allocation',
                                      style: SahayakTypography.labelMd().copyWith(fontWeight: FontWeight.w700),
                                    ),
                                    Text(
                                      'Cooperative guild roster coordinates worker assignments in advance.',
                                      style: SahayakTypography.caption(color: SahayakColors.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // 1. Date Selection
                        Text(
                          '1. Select Service Date',
                          style: SahayakTypography.labelLg().copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 64,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _dateOptions.length,
                            separatorBuilder: (_, _) => const SizedBox(width: 8),
                            itemBuilder: (context, idx) {
                              final isSelected = selectedDateIndex == idx;
                              return InkWell(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  widget.viewModel.setInstitutionDateIndex(idx);
                                },
                                borderRadius: BorderRadius.circular(14),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  width: 84,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? SahayakColors.secondary : SahayakColors.surfaceContainerLowest,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSelected ? SahayakColors.secondary : SahayakColors.borderSubtle,
                                      width: isSelected ? 1.5 : 1.0,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: SahayakColors.secondary.withValues(alpha: 0.2),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    _dateOptions[idx],
                                    textAlign: TextAlign.center,
                                    style: SahayakTypography.labelSm(
                                      color: isSelected ? Colors.white : SahayakColors.onSurface,
                                    ).copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 18),

                        // 2. Shift / Time Slot Selection
                        Text(
                          '2. Select Shift Window',
                          style: SahayakTypography.labelLg().copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 10),
                        ..._shiftOptions.map((opt) {
                          final slot = opt['slot']!;
                          final isSelected = selectedSlot == slot;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? SahayakColors.secondaryFixed.withValues(alpha: 0.15)
                                  : SahayakColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? SahayakColors.secondary : SahayakColors.borderSubtle,
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                              child: ListTile(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  widget.viewModel.setInstitutionTimeSlot(slot);
                                },
                                leading: Icon(
                                  Icons.access_time_rounded,
                                  color: isSelected ? SahayakColors.secondary : SahayakColors.onSurfaceVariant,
                                ),
                                title: Text(
                                  slot,
                                  style: SahayakTypography.labelMd().copyWith(
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(
                                  opt['desc']!,
                                  style: SahayakTypography.caption(),
                                ),
                                trailing: Icon(
                                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                  color: isSelected ? SahayakColors.secondary : SahayakColors.outline,
                                ),
                              ),
                            ),
                          );
                        }),

                        const SizedBox(height: 18),

                        // 3. Workforce Allocation Summary
                        Text(
                          '3. Workforce Allocation Summary',
                          style: SahayakTypography.labelLg().copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(16),
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
                                    child: Text(
                                      'Facility Site:',
                                      style: SahayakTypography.caption(color: SahayakColors.onSurfaceVariant),
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      selectedSite.label,
                                      textAlign: TextAlign.end,
                                      style: SahayakTypography.labelSm().copyWith(fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Headcount Breakdown:',
                                      style: SahayakTypography.caption(color: SahayakColors.onSurfaceVariant),
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      domainCounts.entries
                                          .map((e) => '${e.value} ${e.key[0].toUpperCase()}${e.key.substring(1)}')
                                          .join(', '),
                                      textAlign: TextAlign.end,
                                      style: SahayakTypography.labelSm().copyWith(fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Total Headcount:',
                                      style: SahayakTypography.caption(color: SahayakColors.onSurfaceVariant),
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      '$totalWorkers Cooperative Workers',
                                      textAlign: TextAlign.end,
                                      overflow: TextOverflow.ellipsis,
                                      style: SahayakTypography.labelSm(color: SahayakColors.primary).copyWith(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
                                '$totalWorkers Specialists Requested',
                                style: SahayakTypography.labelLg(color: SahayakColors.secondary).copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'Zero upfront fee · Invoice upon completion',
                                style: SahayakTypography.caption(),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _submitWorkforceRequest,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: SahayakColors.secondary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Row(
                              children: [
                                Text('Submit Request'),
                                SizedBox(width: 6),
                                Icon(Icons.check_circle_rounded, size: 18),
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
