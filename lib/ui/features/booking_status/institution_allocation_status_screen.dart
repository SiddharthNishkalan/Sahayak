import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../data/models/booking.dart';
import '../../../data/models/worker.dart';
import '../../../data/repositories/app_repository.dart';
import '../../../app_view_model.dart';
import '../profile/tax_invoice_dialog.dart';

class InstitutionAllocationStatusScreen extends StatefulWidget {
  final AppViewModel? viewModel;
  final AppRepository? activeRepository;
  final Booking booking;

  const InstitutionAllocationStatusScreen({
    super.key,
    this.viewModel,
    this.activeRepository,
    required this.booking,
  });

  @override
  State<InstitutionAllocationStatusScreen> createState() => _InstitutionAllocationStatusScreenState();
}

class _InstitutionAllocationStatusScreenState extends State<InstitutionAllocationStatusScreen> {
  late Booking _currentBooking;

  @override
  void initState() {
    super.initState();
    _currentBooking = widget.booking;
  }

  void _contactSocietyDesk() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: SahayakColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: SahayakColors.secondaryFixed.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.support_agent_rounded, color: SahayakColors.secondary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Society Dispatch Desk',
                      style: SahayakTypography.titleMedium().copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Work Solute Cooperative Central Allocation Office (Peelamedu Cluster):',
                style: SahayakTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Coordinator: V. Chandran (Guild Allocation Secretary)',
                style: SahayakTypography.bodyMedium(),
              ),
              const SizedBox(height: 4),
              Text(
                'Helpline: +91 422 249 0881',
                style: SahayakTypography.bodyMedium().copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: SahayakColors.secondaryFixed.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: SahayakColors.secondaryFixed),
                ),
                child: Text(
                  'Request ID: ${_currentBooking.id}\nSite: ${_currentBooking.address.label}',
                  style: SahayakTypography.caption(color: SahayakColors.onSurface),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          Navigator.pop(ctx);
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Close'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Connecting to Work Solute Central Dispatch Desk...'),
                              backgroundColor: SahayakColors.secondary,
                            ),
                          );
                        },
                        icon: const Icon(Icons.call_rounded, size: 18),
                        label: const Text('Call Dispatch'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SahayakColors.secondary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
  }

  void _showConsolidatedInvoice() {
    HapticFeedback.lightImpact();
    TaxInvoiceDialog.show(
      context,
      invoice: _currentBooking.invoice,
    );
  }

  void _rateWorkforceRequest() {
    HapticFeedback.lightImpact();
    int selectedRating = 5;
    final feedbackController = TextEditingController(
      text: 'Prompt arrival and certified cooperative execution across all domains.',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: SahayakColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              4,
              20,
              MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 28),
                    const SizedBox(width: 8),
                    Text(
                      'Rate Workforce Request',
                      style: SahayakTypography.titleMedium().copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Please provide feedback for this institutional workforce deployment:',
                  style: SahayakTypography.bodyMedium(color: SahayakColors.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      final starValue = index + 1;
                      return IconButton(
                        iconSize: 36,
                        icon: Icon(
                          starValue <= selectedRating ? Icons.star_rounded : Icons.star_border_rounded,
                          color: const Color(0xFFF59E0B),
                        ),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          setModalState(() => selectedRating = starValue);
                        },
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: feedbackController,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Workforce performance comments...',
                    filled: true,
                    fillColor: SahayakColors.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: SahayakColors.borderSubtle),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: SahayakColors.borderSubtle),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(ctx);
                      if (widget.viewModel != null) {
                        widget.viewModel!.submitReview(
                          bookingId: _currentBooking.id,
                          rating: selectedRating,
                          feedback: feedbackController.text.trim(),
                        );
                      } else if (widget.activeRepository != null) {
                        widget.activeRepository!.submitBookingReview(
                          bookingId: _currentBooking.id,
                          rating: selectedRating.toDouble(),
                          reviewText: feedbackController.text.trim(),
                        );
                      }
                      setState(() {
                        _currentBooking = _currentBooking.copyWith(
                          rating: selectedRating,
                          reviewText: feedbackController.text.trim(),
                        );
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Thank you! Workforce feedback submitted to Cooperative Guild.'),
                          backgroundColor: SahayakColors.secondary,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SahayakColors.secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Submit Rating'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  }

  @override
  Widget build(BuildContext context) {
    final b = _currentBooking;
    final totalRequested = b.totalWorkersRequested;
    final totalAllocated = b.totalWorkersAllocated;
    final isFullyAllocated = b.isFullyAllocated;
    final remainingCount = b.remainingPositionsCount;
    final requiredByDomain = b.requiredWorkersPerDomain;
    final allocatedByDomain = b.allocatedWorkersPerDomain;

    return Scaffold(
      backgroundColor: SahayakColors.surface,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          tooltip: 'Back',
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).maybePop();
          },
        ),
        title: Text(
          'Allocation Status',
          style: SahayakTypography.headlineSm(),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.support_agent_rounded),
            tooltip: 'Contact Society Desk',
            onPressed: _contactSocietyDesk,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                  // 1. Request Top Overview Card
                  Container(
                    width: double.infinity,
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
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: SahayakColors.primaryFixed,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                b.id,
                                style: SahayakTypography.caption(color: SahayakColors.primary).copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isFullyAllocated
                                    ? SahayakColors.secondaryFixed.withValues(alpha: 0.4)
                                    : const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isFullyAllocated ? 'FULLY ALLOCATED' : 'ALLOCATING ROSTER',
                                style: SahayakTypography.caption(
                                  color: isFullyAllocated ? SahayakColors.secondary : const Color(0xFFD97706),
                                ).copyWith(fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          b.serviceName,
                          style: SahayakTypography.headlineSm(),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: SahayakColors.outline),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                b.address.label,
                                style: SahayakTypography.bodySm(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.schedule_rounded, size: 14, color: SahayakColors.outline),
                            const SizedBox(width: 4),
                            Text(
                              b.scheduledSlot,
                              style: SahayakTypography.caption(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 2. Aggregate Progress Indicator Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: SahayakColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: SahayakColors.borderSubtle),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Workforce Fulfillment',
                                style: SahayakTypography.labelLg().copyWith(fontWeight: FontWeight.w800),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$totalAllocated/$totalRequested',
                              style: SahayakTypography.labelMd(
                                color: isFullyAllocated ? SahayakColors.secondary : SahayakColors.primary,
                              ).copyWith(fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: b.allocationProgressRatio,
                            backgroundColor: SahayakColors.surfaceContainerHigh,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isFullyAllocated ? SahayakColors.secondary : SahayakColors.primary,
                            ),
                            minHeight: 10,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          isFullyAllocated
                              ? 'All requested workforce positions are confirmed by cooperative guild members.'
                              : 'Cooperative dispatch desk is matching remaining verified professionals.',
                          style: SahayakTypography.caption(color: SahayakColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),

                  // 3. Escalation Banner if Understaffed
                  if (remainingCount > 0) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$remainingCount position(s) still being filled',
                                  style: SahayakTypography.labelMd(color: const Color(0xFF92400E)).copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Primary cluster is coordinating with adjacent ward guilds. Need priority support?',
                                  style: SahayakTypography.caption(color: const Color(0xFFB45309)),
                                ),
                                const SizedBox(height: 8),
                                OutlinedButton.icon(
                                  onPressed: _contactSocietyDesk,
                                  icon: const Icon(Icons.support_agent_rounded, size: 16),
                                  label: const Text('Contact Society Desk'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF92400E),
                                    side: const BorderSide(color: Color(0xFFD97706)),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    visualDensity: VisualDensity.compact,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 18),

                  // 4. Per-Domain Breakdown & Worker Cards
                  Text(
                    'Trade Allocation Breakdown',
                    style: SahayakTypography.labelLg().copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),

                  if (requiredByDomain.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: SahayakColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: SahayakColors.borderSubtle),
                      ),
                      child: _buildCompactWorkerCard(b.worker, 'Primary Technician'),
                    )
                  else
                    ...requiredByDomain.entries.map((entry) {
                      final domain = entry.key;
                      final requiredCount = entry.value;
                      final confirmedList = allocatedByDomain[domain] ?? [];
                      final isTradeFull = confirmedList.length >= requiredCount;
                      final domainName = domain[0].toUpperCase() + domain.substring(1);
                      final coordinator = widget.viewModel?.getCoordinatorForDomain(domain) ??
                          widget.activeRepository?.getCoordinatorForDomain(domain);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
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
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: SahayakColors.secondaryFixed.withValues(alpha: 0.3),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          domain == 'electrical'
                                              ? Icons.bolt_rounded
                                              : (domain == 'cleaner' ? Icons.cleaning_services_rounded : Icons.handyman_rounded),
                                          size: 16,
                                          color: SahayakColors.secondary,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          domainName,
                                          style: SahayakTypography.labelMd().copyWith(fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isTradeFull
                                        ? SahayakColors.secondaryFixed.withValues(alpha: 0.3)
                                        : SahayakColors.surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${confirmedList.length}/$requiredCount confirmed',
                                    style: SahayakTypography.caption(
                                      color: isTradeFull ? SahayakColors.secondary : SahayakColors.onSurfaceVariant,
                                    ).copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                            if (coordinator != null) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: SahayakColors.secondaryFixed.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: SahayakColors.secondaryFixed.withValues(alpha: 0.35)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.person_pin_rounded, size: 16, color: SahayakColors.secondary),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Site Coordinator: ${coordinator.name} (${coordinator.phone})',
                                        style: SahayakTypography.caption(color: SahayakColors.onSurface).copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),

                            // Confirmed workers list (Compact cards - No Best Match badge UI)
                            if (confirmedList.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Text(
                                  'Cooperative dispatch in progress...',
                                  style: SahayakTypography.caption(color: SahayakColors.outline),
                                ),
                              )
                            else
                              ...confirmedList.map((w) {
                                return _buildCompactWorkerCard(w, domainName);
                              }),
                          ],
                        ),
                      );
                    }),

                  const SizedBox(height: 16),

                  // Actions: Invoice / Rating if completed or return
                  if (b.invoice != null) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: _showConsolidatedInvoice,
                        icon: const Icon(Icons.receipt_long_rounded, size: 18),
                        label: const Text('View Consolidated Tax Invoice'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: SahayakColors.secondary),
                          foregroundColor: SahayakColors.secondary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  if (b.rating == 0 && b.tab == BookingTab.completed) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _rateWorkforceRequest,
                        icon: const Icon(Icons.star_rounded, size: 18),
                        label: const Text('Rate Workforce Performance'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF59E0B),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        widget.viewModel?.switchTab(ShellTab.bookings);
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SahayakColors.secondary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Go to My Bookings'),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      }

  Widget _buildCompactWorkerCard(Worker worker, String tradeLabel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: SahayakColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SahayakColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: SahayakColors.surfaceContainerLowest,
              shape: BoxShape.circle,
              border: Border.all(color: SahayakColors.borderSubtle),
            ),
            alignment: Alignment.center,
            child: Text(
              worker.name.isNotEmpty ? worker.name[0] : 'W',
              style: SahayakTypography.labelMd().copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        worker.name,
                        style: SahayakTypography.labelSm().copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.verified_rounded, size: 14, color: SahayakColors.secondary),
                  ],
                ),
                Text(
                  '${worker.guildId} • $tradeLabel',
                  style: SahayakTypography.caption(),
                ),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 15, color: Color(0xFFF59E0B)),
              const SizedBox(width: 2),
              Text(
                '${worker.rating}',
                style: SahayakTypography.caption().copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
