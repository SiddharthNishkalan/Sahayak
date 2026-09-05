import 'package:flutter/material.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../data/models/booking.dart';
import '../../../data/repositories/app_repository.dart';
import '../../../app_view_model.dart';
import '../../shared_widgets/trust_badges.dart';
import '../booking_status/booking_details_screen.dart';
import '../profile/tax_invoice_dialog.dart';
import 'worker_live_track_dialog.dart';

class MyBookingsScreen extends StatefulWidget {
  final AppRepository? repository;
  final AppViewModel? viewModel;
  final VoidCallback? onBookService;

  const MyBookingsScreen({
    super.key,
    this.repository,
    this.viewModel,
    this.onBookService,
  }) : assert(repository != null || viewModel != null, 'Either repository or viewModel must be provided');

  AppRepository get activeRepository => viewModel?.repository ?? repository!;

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  BookingTab _selectedTab = BookingTab.upcoming;

  AppStrings get s =>
      widget.viewModel?.strings ??
      AppStrings(widget.activeRepository.selectedLanguage.code);

  void _showDoorstepOtpDialog(Booking b) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CooperativeColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.verified_user_rounded, color: CooperativeColors.primary),
            const SizedBox(width: 8),
            const Text('Doorstep Verification OTP'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Share this 4-digit OTP with ${b.worker.name} upon their arrival at your door:'),
            const SizedBox(height: 14),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: CooperativeColors.primaryFixed,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  b.doorstepOtp,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 6.0, color: CooperativeColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Once the worker validates this code in their terminal, work authorization unlocks and work begins.',
              style: TextStyle(fontSize: 12, color: CooperativeColors.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              final success = widget.activeRepository.verifyDoorstepOtp(b.id, b.doorstepOtp);
              if (success) {
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('OTP ${b.doorstepOtp} verified! Job started by ${b.worker.name}.'),
                    backgroundColor: CooperativeColors.secondary,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: CooperativeColors.primary),
            child: const Text('Verify & Start Job'),
          ),
        ],
      ),
    );
  }

  void _handleCompleteAndPay(Booking b) {
    TaxInvoiceDialog.show(
      context,
      invoice: b.invoice,
    );
    widget.activeRepository.completeJobAndPay(b.id, b.invoice);
    setState(() {});
    // Prompt mandatory rating dialog
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _showMandatoryRatingDialog(b);
      }
    });
  }

  void _showMandatoryRatingDialog(Booking b) {
    int rating = 5;
    final textController = TextEditingController(text: 'Excellent work, very professional and on time.');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: CooperativeColors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.star_rounded, color: CooperativeColors.tertiary, size: 24),
              const SizedBox(width: 8),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Worker Review ',
                      style: CooperativeTypography.headlineSm.copyWith(
                        color: CooperativeColors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: '*',
                      style: CooperativeTypography.headlineSm.copyWith(
                        color: CooperativeColors.error,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextSpan(
                      text: ' (Mandatory)',
                      style: CooperativeTypography.caption.copyWith(
                        color: CooperativeColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('How was your service with ${b.worker.name}? Rating is required to complete civic co-op records.'),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final star = index + 1;
                    return IconButton(
                      onPressed: () => setModalState(() => rating = star),
                      icon: Icon(
                        Icons.star,
                        size: 32,
                        color: star <= rating ? CooperativeColors.tertiary : CooperativeColors.outlineVariant,
                      ),
                    );
                  }),
                ),
                Center(
                  child: Text(
                    rating == 5 ? '5 ★ — Exceptional Quality' : '$rating ★ — Cooperative Feedback',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: CooperativeColors.tertiary),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Feedback (Optional notes & details):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: textController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Describe promptness, cleanliness, parts replacement...',
                    filled: true,
                    fillColor: CooperativeColors.surfaceContainerLow,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (rating <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Rating is strictly mandatory (*). Please choose 1 to 5 stars.'),
                      backgroundColor: CooperativeColors.error,
                    ),
                  );
                  return;
                }
                Navigator.pop(ctx);
                widget.activeRepository.submitBookingReview(
                  bookingId: b.id,
                  rating: rating.toDouble(),
                  reviewText: textController.text.trim(),
                );
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Rating and review submitted for ${b.worker.name}!'),
                    backgroundColor: CooperativeColors.secondary,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: CooperativeColors.primary),
              child: const Text('Submit Mandatory Review (*)'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleCustomerCancel(Booking b) {
    final canCancelFree = b.canCancelBefore1Hour;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CooperativeColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              canCancelFree ? Icons.check_circle_outline : Icons.warning_amber_rounded,
              color: canCancelFree ? CooperativeColors.secondary : CooperativeColors.error,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(canCancelFree ? 'Cancel Booking?' : '1-Hour Policy Warning'),
          ],
        ),
        content: Text(
          canCancelFree
              ? 'You are cancelling >1 hour before the scheduled time (${b.scheduledSlot}). Cancellation is completely free with zero penalty.'
              : 'Notice: This cancellation is requested within 1 hour of the scheduled time. Per cooperative fair-work rules, last-minute cancellation applies nominal technician compensation unless delayed. Do you still wish to proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Booking'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.activeRepository.cancelBookingByCustomer(b.id);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(canCancelFree
                      ? 'Booking cancelled with zero fee per 1-hour policy.'
                      : 'Booking cancelled under late cancellation notice.'),
                  backgroundColor: CooperativeColors.primary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: CooperativeColors.error),
            child: const Text('Confirm Cancel'),
          ),
        ],
      ),
    );
  }

  void _simulatePreServiceUpdate(Booking b, WorkerPreServiceStatus status, {int delayMinutes = 0, String? reason}) {
    widget.activeRepository.updateWorkerPreServiceStatus(
      b.id,
      status,
      delayMinutes: delayMinutes,
      cancelReason: reason,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.viewModel != null) {
      return ListenableBuilder(
        listenable: widget.viewModel!,
        builder: (context, _) => _buildScaffoldContent(context),
      );
    }
    return _buildScaffoldContent(context);
  }

  Widget _buildScaffoldContent(BuildContext context) {
    final upcomingList = widget.activeRepository.getBookingsByTab(BookingTab.upcoming);
    final completedList = widget.activeRepository.getBookingsByTab(BookingTab.completed);
    final cancelledList = widget.activeRepository.getBookingsByTab(BookingTab.cancelled);

    return Material(
      color: CooperativeColors.surface,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                  // Subheader
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.get('my_bookings'),
                              style: CooperativeTypography.headlineLg.copyWith(
                                color: CooperativeColors.onSurface,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              s.get('bookings_sub'),
                              style: CooperativeTypography.bodySm.copyWith(
                                color: CooperativeColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const CoOpProtectedBadge(),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Segmented Tabs
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: CooperativeColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        _buildTabButton(
                          title: '${s.get('tab_upcoming')} (${upcomingList.length})',
                          tab: BookingTab.upcoming,
                        ),
                        _buildTabButton(
                          title: '${s.get('tab_completed')} (${completedList.length})',
                          tab: BookingTab.completed,
                        ),
                        _buildTabButton(
                          title: '${s.get('tab_cancelled')} (${cancelledList.length})',
                          tab: BookingTab.cancelled,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tab Content
                  if (_selectedTab == BookingTab.upcoming)
                    _buildUpcomingList(upcomingList)
                  else if (_selectedTab == BookingTab.completed)
                    _buildCompletedList(completedList)
                  else
                    _buildCancelledList(cancelledList),

                  const SizedBox(height: 20),

                  // Cooperative Guarantee Banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: CooperativeColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.handshake, color: CooperativeColors.secondary, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.get('civic_guarantee'),
                                style: CooperativeTypography.labelSm.copyWith(
                                  color: CooperativeColors.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '100% transparent rates, zero middleman commission markup, 30-day rework warranty.',
                                style: CooperativeTypography.caption.copyWith(
                                  color: CooperativeColors.onSurfaceVariant,
                                  height: 1.3,
                                ),
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
        ),
      );
  }

  Widget _buildTabButton({required String title, required BookingTab tab}) {
    final isSelected = _selectedTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = tab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? CooperativeColors.surfaceContainerLowest : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: CooperativeTypography.labelMd.copyWith(
              color: isSelected ? CooperativeColors.primary : CooperativeColors.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingList(List<Booking> bookings) {
    if (bookings.isEmpty) {
      return _buildEmptyState(
        icon: Icons.calendar_today,
        title: s.get('no_upcoming_bookings'),
        subtitle: 'Select from certified trade services to book your home visit.',
      );
    }

    return Column(
      children: bookings.map((b) => _buildUpcomingBookingCard(b)).toList(),
    );
  }

  Widget _buildUpcomingBookingCard(Booking b) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CooperativeColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: CooperativeColors.primaryFixed,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.plumbing, color: CooperativeColors.primary, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b.serviceName,
                      style: CooperativeTypography.headlineSm.copyWith(
                        color: CooperativeColors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Order #${b.id} · ${b.subcategoryTitle}',
                      style: CooperativeTypography.caption.copyWith(
                        color: CooperativeColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: CooperativeColors.tertiaryFixed,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: CooperativeColors.tertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'On The Way',
                      style: CooperativeTypography.labelSm.copyWith(
                        color: CooperativeColors.onTertiaryFixed,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Live ETA highlight bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CooperativeColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.near_me, color: CooperativeColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Arriving in ~${b.minutesUntilArrival} mins',
                        style: CooperativeTypography.labelMd.copyWith(
                          color: CooperativeColors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Worker is ${b.liveDistanceKm} km away from your location',
                        style: CooperativeTypography.caption.copyWith(
                          color: CooperativeColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: CooperativeColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Live',
                    style: CooperativeTypography.labelSm.copyWith(
                      color: CooperativeColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Worker row
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/user_avatar.png',
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Icon(Icons.person, color: CooperativeColors.primary),
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
                            b.worker.name,
                            style: CooperativeTypography.labelLg.copyWith(
                              color: CooperativeColors.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const VerifiedShieldBadge(label: 'Verified'),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: CooperativeColors.tertiary),
                        const SizedBox(width: 2),
                        Text(
                          '${b.worker.rating}',
                          style: CooperativeTypography.caption.copyWith(
                            color: CooperativeColors.tertiary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '· ${b.worker.completedJobsCount} Co-op jobs · Civic ID verified',
                            style: CooperativeTypography.caption.copyWith(
                              color: CooperativeColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Calling ${b.worker.name}...')),
                  );
                },
                icon: const Icon(Icons.phone, size: 20, color: CooperativeColors.primary),
                style: IconButton.styleFrom(
                  backgroundColor: CooperativeColors.surfaceContainer,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Slot & Address grid
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CooperativeColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Slot & Time',
                          style: CooperativeTypography.caption.copyWith(
                            color: CooperativeColors.onSurfaceVariant,
                          )),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 14, color: CooperativeColors.primary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              b.scheduledSlot,
                              style: CooperativeTypography.labelSm.copyWith(
                                color: CooperativeColors.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Service Address',
                          style: CooperativeTypography.caption.copyWith(
                            color: CooperativeColors.onSurfaceVariant,
                          )),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: CooperativeColors.primary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              b.address.fullAddress,
                              style: CooperativeTypography.labelSm.copyWith(
                                color: CooperativeColors.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Doorstep OTP Card (when worker is on the way)
          if (b.stage == BookingStage.workerOnTheWay) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CooperativeColors.primaryFixed,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: CooperativeColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.pin, color: CooperativeColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Doorstep Start OTP',
                            style: CooperativeTypography.caption.copyWith(
                              color: CooperativeColors.primary,
                              fontWeight: FontWeight.bold,
                            )),
                        Text(b.doorstepOtp,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 3,
                              color: CooperativeColors.primary,
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _showDoorstepOtpDialog(b),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CooperativeColors.primary,
                      foregroundColor: CooperativeColors.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: Text(s.get('verify_otp_action'), style: const TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Service In Progress Card
          if (b.stage == BookingStage.jobInProgress) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CooperativeColors.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.build_circle, color: CooperativeColors.onSecondaryContainer, size: 20),
                      const SizedBox(width: 8),
                      Text('Service In Progress...',
                          style: CooperativeTypography.labelMd.copyWith(
                            color: CooperativeColors.onSecondaryContainer,
                            fontWeight: FontWeight.w700,
                          )),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => _handleCompleteAndPay(b),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CooperativeColors.secondary,
                      foregroundColor: CooperativeColors.onSecondary,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: Text(s.get('complete_pay_action')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // 1-Hour Pre-Service Worker Status Banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CooperativeColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CooperativeColors.surfaceContainerHigh),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.access_time_filled, size: 16, color: CooperativeColors.primary),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '1-Hour Pre-Service Status',
                              style: CooperativeTypography.labelSm.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: b.activePreServiceUpdate.status == WorkerPreServiceStatus.onTime
                            ? CooperativeColors.secondaryContainer
                            : (b.activePreServiceUpdate.status == WorkerPreServiceStatus.delayed
                                ? CooperativeColors.tertiaryFixed
                                : CooperativeColors.error.withValues(alpha: 0.15)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        b.activePreServiceUpdate.status == WorkerPreServiceStatus.onTime
                            ? 'On Time'
                            : (b.activePreServiceUpdate.status == WorkerPreServiceStatus.delayed
                                ? '+${b.activePreServiceUpdate.delayMinutes}m Delay'
                                : 'Cancelled'),
                        style: CooperativeTypography.caption.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  b.activePreServiceUpdate.customerNotificationMessage,
                  style: CooperativeTypography.caption.copyWith(color: CooperativeColors.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Text('Simulate Worker:', style: CooperativeTypography.caption.copyWith(fontSize: 10, color: CooperativeColors.outline)),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () => _simulatePreServiceUpdate(b, WorkerPreServiceStatus.onTime),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: CooperativeColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(6)),
                          child: const Text('On Time', style: TextStyle(fontSize: 10, color: CooperativeColors.secondary, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () => _simulatePreServiceUpdate(b, WorkerPreServiceStatus.delayed, delayMinutes: 15, reason: 'Traffic near junction'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: CooperativeColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(6)),
                          child: const Text('+15m Delay', style: TextStyle(fontSize: 10, color: CooperativeColors.tertiary, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () => _simulatePreServiceUpdate(b, WorkerPreServiceStatus.cancelledByWorker, reason: 'Emergency civic pipe burst repair call'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: CooperativeColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(6)),
                          child: const Text('Worker Cancel', style: TextStyle(fontSize: 10, color: CooperativeColors.error, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Actions
          Row(
            children: [
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed: () => WorkerLiveTrackDialog.show(context, booking: b),
                  icon: const Icon(Icons.location_searching, size: 18),
                  label: Text(s.get('track_pro_action')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CooperativeColors.primary,
                    foregroundColor: CooperativeColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingDetailsScreen(booking: b),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: CooperativeColors.surfaceContainer,
                    foregroundColor: CooperativeColors.onSurface,
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(s.get('view_details')),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 1-Hour Cancellation Rule & Trigger
          Row(
            children: [
              Icon(
                b.canCancelBefore1Hour ? Icons.check_circle : Icons.info_outline,
                size: 14,
                color: b.canCancelBefore1Hour ? CooperativeColors.secondary : CooperativeColors.outline,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  b.canCancelBefore1Hour ? 'Free cancel (>1 hr left)' : 'Within 1 hr of schedule',
                  style: CooperativeTypography.caption.copyWith(
                    color: b.canCancelBefore1Hour ? CooperativeColors.secondary : CooperativeColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _handleCustomerCancel(b),
                icon: const Icon(Icons.cancel_outlined, size: 14, color: CooperativeColors.error),
                label: Text(s.get('cancel_booking_action'), style: const TextStyle(color: CooperativeColors.error, fontSize: 12)),
                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedList(List<Booking> bookings) {
    if (bookings.isEmpty) {
      return _buildEmptyState(
        icon: Icons.task_alt,
        title: s.get('no_completed_bookings'),
        subtitle: 'Completed services with tax invoices and review guarantees will appear here.',
      );
    }

    return Column(
      children: bookings.map((b) => _buildCompletedBookingCard(b)).toList(),
    );
  }

  Widget _buildCompletedBookingCard(Booking b) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CooperativeColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: CooperativeColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.format_paint, color: CooperativeColors.primary, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b.serviceName,
                      style: CooperativeTypography.headlineSm.copyWith(
                        color: CooperativeColors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Order #${b.id} · Completed',
                      style: CooperativeTypography.caption.copyWith(
                        color: CooperativeColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: CooperativeColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Paid · ₹${b.invoice?.totalAmount.toInt() ?? 850}',
                  style: CooperativeTypography.labelSm.copyWith(
                    color: CooperativeColors.onSecondaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Worker row
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: CooperativeColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/user_avatar.png',
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Icon(Icons.person, color: CooperativeColors.primary),
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
                              b.worker.name,
                              style: CooperativeTypography.labelMd.copyWith(
                                color: CooperativeColors.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text('✓ Co-op Member',
                              style: CooperativeTypography.caption.copyWith(
                                color: CooperativeColors.secondary,
                                fontWeight: FontWeight.w700,
                              )),
                        ],
                      ),
                      Text('Local Ward Service Guild',
                          style: CooperativeTypography.caption.copyWith(
                            color: CooperativeColors.onSurfaceVariant,
                          )),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: CooperativeColors.tertiaryFixed,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: CooperativeColors.tertiary),
                      const SizedBox(width: 2),
                      Text(b.rating > 0 ? '${b.rating}.0' : '5.0',
                          style: CooperativeTypography.labelSm.copyWith(
                            color: CooperativeColors.onTertiaryFixed,
                            fontWeight: FontWeight.w700,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Feedback pill or Mandatory Rating Pending
          if (b.rating <= 0) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: CooperativeColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: CooperativeColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star_border, color: CooperativeColors.error, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Mandatory Review Pending (*)',
                        style: CooperativeTypography.labelSm.copyWith(
                          color: CooperativeColors.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => _showMandatoryRatingDialog(b),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CooperativeColors.primary,
                      foregroundColor: CooperativeColors.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text('Rate Worker (*)'),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: CooperativeColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 16, color: CooperativeColors.secondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      b.reviewText.isNotEmpty
                          ? 'Feedback: "${b.reviewText}"'
                          : 'Feedback: "Prompt fix, verified doorstep service!"',
                      style: CooperativeTypography.bodySm.copyWith(color: CooperativeColors.onSurface),
                    ),
                  ),
                  Text('Submitted',
                      style: CooperativeTypography.caption.copyWith(color: CooperativeColors.onSurfaceVariant)),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    TaxInvoiceDialog.show(context, invoice: b.invoice);
                  },
                  icon: const Icon(Icons.receipt_long, size: 18, color: CooperativeColors.primary),
                  label: const Text('Invoice (PDF)'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: CooperativeColors.surfaceContainer,
                    foregroundColor: CooperativeColors.onSurface,
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.onBookService,
                  icon: const Icon(Icons.repeat, size: 18),
                  label: const Text('Book Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CooperativeColors.primary,
                    foregroundColor: CooperativeColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCancelledList(List<Booking> bookings) {
    if (bookings.isEmpty) {
      return _buildEmptyState(
        icon: Icons.cancel_outlined,
        title: s.get('no_cancelled_bookings'),
        subtitle: 'The cooperative strives for 100% fulfilled service appointments with free rescheduling.',
      );
    }

    return Column(
      children: bookings.map((b) => _buildCancelledBookingCard(b)).toList(),
    );
  }

  Widget _buildCancelledBookingCard(Booking b) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CooperativeColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  b.serviceName,
                  style: CooperativeTypography.headlineSm.copyWith(
                    color: CooperativeColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: CooperativeColors.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Cancelled',
                  style: CooperativeTypography.labelSm.copyWith(
                    color: CooperativeColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Order #${b.id} · Scheduled: ${b.scheduledSlot}',
            style: CooperativeTypography.caption.copyWith(color: CooperativeColors.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: CooperativeColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: CooperativeColors.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    b.cancellationReason ?? (b.activePreServiceUpdate.reason != null
                        ? 'Reason: ${b.activePreServiceUpdate.reason}'
                        : 'Cancelled by customer under cooperative fair-work policy.'),
                    style: CooperativeTypography.caption.copyWith(color: CooperativeColors.onSurface),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: widget.onBookService,
            icon: const Icon(Icons.replay, size: 16),
            label: const Text('Re-book Service'),
            style: ElevatedButton.styleFrom(
              backgroundColor: CooperativeColors.primary,
              foregroundColor: CooperativeColors.onPrimary,
              minimumSize: const Size.fromHeight(40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: CooperativeColors.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 30, color: CooperativeColors.outline),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: CooperativeTypography.labelLg.copyWith(
              color: CooperativeColors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: CooperativeTypography.bodySm.copyWith(
              color: CooperativeColors.onSurfaceVariant,
            ),
          ),
          if (widget.onBookService != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: widget.onBookService,
              style: ElevatedButton.styleFrom(
                backgroundColor: CooperativeColors.primary,
                foregroundColor: CooperativeColors.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(s.get('book_a_service_now')),
            ),
          ],
        ],
      ),
    );
  }
}
