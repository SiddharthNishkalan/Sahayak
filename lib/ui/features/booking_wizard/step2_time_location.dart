import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../data/models/service.dart';
import '../../../app_view_model.dart';
import '../../shared_widgets/custom_vector_map.dart';
import 'step3_worker_matching.dart';

class Step2TimeLocationScreen extends StatefulWidget {
  final AppViewModel viewModel;
  final ServiceItem service;

  const Step2TimeLocationScreen({
    super.key,
    required this.viewModel,
    required this.service,
  });

  @override
  State<Step2TimeLocationScreen> createState() => _Step2TimeLocationScreenState();
}

class _Step2TimeLocationScreenState extends State<Step2TimeLocationScreen> {
  late TextEditingController _notesController;

  final List<String> _dateOptions = ['Today\n5 Sep', 'Tomorrow\n6 Sep', 'Friday\n7 Sep', 'Saturday\n8 Sep'];
  final List<Map<String, dynamic>> _slotOptions = [
    {'slot': '9:00 AM – 11:00 AM', 'sub': 'Morning shift', 'disabled': false},
    {'slot': '11:00 AM – 1:00 PM', 'sub': '2 society workers free', 'disabled': false},
    {'slot': '2:00 PM – 4:00 PM', 'sub': 'Optimal match window', 'disabled': false},
    {'slot': '4:00 PM – 6:00 PM', 'sub': '3 society workers free', 'disabled': false},
    {'slot': '6:00 PM – 8:00 PM', 'sub': 'Evening co-op crew', 'disabled': false},
  ];

  final List<Map<String, String>> _emergencyTags = [
    {'id': 'BURST_PIPE', 'label': 'Burst Pipe / Flooding', 'icon': '💧'},
    {'id': 'POWER_OUTAGE', 'label': 'Power Failure / Short Circuit', 'icon': '⚡'},
    {'id': 'SEWAGE_BLOCK', 'label': 'Sewage / Main Drain Overflow', 'icon': '⚠️'},
    {'id': 'HEATER_FAILURE', 'label': 'Water Heater / Motor Spark', 'icon': '🔥'},
  ];

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(
      text: widget.viewModel.wizardSelectedAddress.notes.isNotEmpty
          ? widget.viewModel.wizardSelectedAddress.notes
          : 'Flat 302, Green Meadows Apt, near Water Tank',
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _goToStep3() {
    widget.viewModel.broadcastJobRequest();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Step3WorkerMatchingScreen(
          viewModel: widget.viewModel,
          service: widget.service,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEmergency = widget.viewModel.wizardIsEmergency;
    final selectedEmergencyTag = widget.viewModel.wizardEmergencyTag ?? _emergencyTags.first['id'];
    final selectedDate = widget.viewModel.wizardSelectedDateIndex;
    final selectedSlot = widget.viewModel.wizardSelectedTimeSlot;
    final selectedAddr = widget.viewModel.wizardSelectedAddress;

    return Scaffold(
      backgroundColor: SahayakColors.surface,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: SahayakColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: SahayakColors.borderSubtle),
              ),
              padding: const EdgeInsets.all(2),
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(Icons.build, size: 16),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Booking Wizard · Step 2', style: SahayakTypography.labelLg()),
                  Text(
                    'Sahayak Co-op • Schedule & Society Dispatch',
                    style: SahayakTypography.caption(color: SahayakColors.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: SahayakColors.primary, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: SahayakColors.primary, shape: BoxShape.circle)),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Progress Tracker Banner
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: SahayakColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(16),
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
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: const BoxDecoration(
                                            color: SahayakColors.primary,
                                            shape: BoxShape.circle,
                                          ),
                                          alignment: Alignment.center,
                                          child: const Text(
                                            '2',
                                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Time & Location',
                                          style: SahayakTypography.headlineSm(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '100% Ready',
                                    style: SahayakTypography.caption(color: SahayakColors.primary).copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                isEmergency
                                    ? 'Emergency job: Geolocation and tag will be transmitted to nearest society workers immediately.'
                                    : 'Pick your preferred date and time slot for a scheduled cooperative home visit.',
                                style: SahayakTypography.bodySm(),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: SahayakColors.primary,
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Container(
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: SahayakColors.primary,
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Section 1: Timing Mode: Scheduled vs Emergency
                        const SizedBox(height: 16),
                        Text('Service Urgency & Schedule', style: SahayakTypography.headlineSm()),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // Scheduled Option
                            Expanded(
                              child: InkWell(
                                onTap: () => widget.viewModel.setTimingMode(isEmergency: false),
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: !isEmergency ? SahayakColors.primaryFixed.withValues(alpha: 0.25) : SahayakColors.surfaceContainerLowest,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: !isEmergency ? SahayakColors.primary : SahayakColors.borderSubtle,
                                      width: !isEmergency ? 2 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Icon(Icons.calendar_month_rounded, color: SahayakColors.primary, size: 24),
                                          Icon(
                                            !isEmergency ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                                            size: 18,
                                            color: !isEmergency ? SahayakColors.primary : SahayakColors.outline,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text('Scheduled Visit', style: SahayakTypography.labelMd()),
                                      const SizedBox(height: 2),
                                      Text('Book in advance', style: SahayakTypography.caption(color: SahayakColors.secondary).copyWith(fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Emergency Option
                            Expanded(
                              child: InkWell(
                                onTap: () => widget.viewModel.setTimingMode(
                                  isEmergency: true,
                                  emergencyTag: selectedEmergencyTag,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isEmergency ? SahayakColors.errorContainer.withValues(alpha: 0.35) : SahayakColors.surfaceContainerLowest,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isEmergency ? SahayakColors.error : SahayakColors.borderSubtle,
                                      width: isEmergency ? 2 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Icon(Icons.bolt_rounded, color: SahayakColors.error, size: 24),
                                          Icon(
                                            isEmergency ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                                            size: 18,
                                            color: isEmergency ? SahayakColors.error : SahayakColors.outline,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text('⚡ Emergency', style: SahayakTypography.labelMd().copyWith(color: isEmergency ? SahayakColors.error : SahayakColors.onSurface)),
                                      const SizedBox(height: 2),
                                      Text('< 20 min rapid dispatch', style: SahayakTypography.caption(color: SahayakColors.error).copyWith(fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Emergency Tag & Geolocation Section (if Emergency)
                        if (isEmergency) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: SahayakColors.errorContainer.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: SahayakColors.error.withValues(alpha: 0.4)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.emergency_rounded, color: SahayakColors.error, size: 20),
                                    const SizedBox(width: 8),
                                    Text('Emergency Priority Tag *', style: SahayakTypography.labelMd().copyWith(color: SahayakColors.error)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Select the critical tag so nearest workers bring emergency equipment (pipe clamps, high-power isolation tools):',
                                  style: SahayakTypography.caption(),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _emergencyTags.map((tag) {
                                    final isTagSel = (widget.viewModel.wizardEmergencyTag ?? _emergencyTags.first['id']) == tag['id'];
                                    return ChoiceChip(
                                      selected: isTagSel,
                                      avatar: Text(tag['icon']!),
                                      label: Text(tag['label']!),
                                      selectedColor: SahayakColors.error,
                                      backgroundColor: SahayakColors.surfaceContainerLowest,
                                      labelStyle: TextStyle(
                                        color: isTagSel ? Colors.white : SahayakColors.onSurface,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                      onSelected: (val) {
                                        if (val) {
                                          widget.viewModel.setTimingMode(
                                            isEmergency: true,
                                            emergencyTag: tag['id'],
                                          );
                                        }
                                      },
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 12),
                                // Geolocation telemetry card
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: SahayakColors.surfaceContainerLowest,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: SahayakColors.borderSubtle),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.my_location_rounded, size: 18, color: SahayakColors.error),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Live GPS Geolocation Activated',
                                              style: SahayakTypography.labelSm().copyWith(fontWeight: FontWeight.w700),
                                            ),
                                            Text(
                                              '11.0168° N, 76.9558° E · ${selectedAddr.society.isNotEmpty ? selectedAddr.society : widget.viewModel.currentSociety}',
                                              style: SahayakTypography.caption(color: SahayakColors.onSurfaceVariant),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: SahayakColors.error,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text('PRIORITY', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Section 2: Date & Slot (Shown if not Emergency)
                        if (!isEmergency) ...[
                          const SizedBox(height: 16),
                          Text('Select Date', style: SahayakTypography.headlineSm()),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 62,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _dateOptions.length,
                              itemBuilder: (context, index) {
                                final isSel = selectedDate == index;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: InkWell(
                                    onTap: () => widget.viewModel.setDateIndex(index),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      width: 84,
                                      decoration: BoxDecoration(
                                        color: isSel ? SahayakColors.primaryContainer : SahayakColors.surfaceContainerLowest,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSel ? SahayakColors.primary : SahayakColors.borderSubtle,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        _dateOptions[index],
                                        textAlign: TextAlign.center,
                                        style: SahayakTypography.labelSm(
                                          color: isSel ? SahayakColors.onPrimary : SahayakColors.onSurface,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 14),
                          Text('Available Slots', style: SahayakTypography.headlineSm()),
                          const SizedBox(height: 8),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _slotOptions.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 2.0,
                            ),
                            itemBuilder: (context, index) {
                              final item = _slotOptions[index];
                              final slotText = item['slot'] as String;
                              final subText = item['sub'] as String;
                              final disabled = item['disabled'] as bool;
                              final isSel = selectedSlot == slotText;

                              return InkWell(
                                onTap: disabled ? null : () => widget.viewModel.setTimeSlot(slotText),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: disabled
                                        ? SahayakColors.surfaceContainer.withValues(alpha: 0.5)
                                        : isSel
                                            ? SahayakColors.surfaceContainerHigh
                                            : SahayakColors.surfaceContainerLowest,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSel ? SahayakColors.primary : SahayakColors.borderSubtle,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        slotText,
                                        style: SahayakTypography.labelSm(
                                          color: disabled ? SahayakColors.outline : SahayakColors.onSurface,
                                        ).copyWith(
                                          decoration: disabled ? TextDecoration.lineThrough : null,
                                          fontWeight: isSel ? FontWeight.w700 : FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        subText,
                                        style: SahayakTypography.caption(
                                          color: disabled
                                              ? SahayakColors.outline
                                              : isSel
                                                  ? SahayakColors.secondary
                                                  : SahayakColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],

                        // Section 3: Nearest Society Service Location
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'Service Location',
                                style: SahayakTypography.headlineSm(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: SahayakColors.secondaryContainer.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.people_alt_rounded, size: 12, color: SahayakColors.secondary),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        '${selectedAddr.society.isNotEmpty ? selectedAddr.society : widget.viewModel.currentSociety} Cluster',
                                        style: SahayakTypography.caption(color: SahayakColors.secondary).copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Mini Vector Map Preview
                        CustomVectorMap(height: 140, showControls: false),
                        const SizedBox(height: 10),

                        // Address card
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: SahayakColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: SahayakColors.borderSubtle),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: SahayakColors.primaryFixed,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.location_on_rounded, color: SahayakColors.primary),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(selectedAddr.label, style: SahayakTypography.labelMd()),
                                        Text(
                                          '${selectedAddr.streetAddress} (${selectedAddr.society})',
                                          style: SahayakTypography.bodySm(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Detect Device GPS',
                                    icon: const Icon(Icons.my_location_rounded, color: SahayakColors.primary, size: 20),
                                    onPressed: () => widget.viewModel.detectCurrentDeviceLocation(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Saved addresses pills using Wrap to prevent overflow
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: widget.viewModel.repository.addresses.map((addr) {
                                  final isSel = addr.id == selectedAddr.id;
                                  return InkWell(
                                    onTap: () => widget.viewModel.setWizardAddress(addr),
                                    borderRadius: BorderRadius.circular(999),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isSel ? SahayakColors.primary : SahayakColors.surfaceContainerLow,
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            addr.type == 'Home' ? Icons.home_rounded : Icons.apartment_rounded,
                                            size: 14,
                                            color: isSel ? SahayakColors.onPrimary : SahayakColors.onSurface,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${addr.type} · ${addr.society}',
                                            style: SahayakTypography.caption(
                                              color: isSel ? SahayakColors.onPrimary : SahayakColors.onSurface,
                                            ).copyWith(fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 12),
                              // Door landmark input
                              TextField(
                                controller: _notesController,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.door_front_door_outlined, color: SahayakColors.outline),
                                  hintText: 'House/Apartment & Landmark instructions',
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Nearest Society Dispatch Banner
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: SahayakColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.share_location_rounded, size: 20, color: SahayakColors.secondary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Broadcast to Nearest Society Workers', style: SahayakTypography.labelMd()),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Requests are broadcasted directly to certified workers in ${selectedAddr.society.isNotEmpty ? selectedAddr.society : widget.viewModel.currentSociety}. Workers evaluate and respond with competitive quotes.',
                                      style: SahayakTypography.bodySm(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Sticky Bottom CTA
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    color: SahayakColors.surfaceContainerLowest,
                    border: Border(top: BorderSide(color: SahayakColors.borderSubtle)),
                  ),
                  child: ElevatedButton(
                    onPressed: _goToStep3,
                    style: isEmergency
                        ? ElevatedButton.styleFrom(backgroundColor: SahayakColors.error)
                        : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            isEmergency
                                ? '⚡ Broadcast Emergency Dispatch'
                                : 'Broadcast to Nearest Society Workers',
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
