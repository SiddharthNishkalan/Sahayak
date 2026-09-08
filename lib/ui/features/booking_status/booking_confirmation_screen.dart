import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../data/models/booking.dart';
import '../../../app_view_model.dart';
import '../../shared_widgets/trust_badges.dart';
import '../../shared_widgets/timeline_tracker.dart';
import 'booking_details_screen.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final Booking booking;
  final AppViewModel? viewModel;
  final VoidCallback? onNavigateToBookings;
  final VoidCallback? onBookAnother;

  const BookingConfirmationScreen({
    super.key,
    required this.booking,
    this.viewModel,
    this.onNavigateToBookings,
    this.onBookAnother,
  });

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  bool _isFaqExpanded = false;
  late Booking _currentBooking;

  @override
  void initState() {
    super.initState();
    _currentBooking = widget.booking;
  }

  void _copyBookingId() {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: _currentBooking.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: CooperativeColors.secondaryContainer, size: 20),
            const SizedBox(width: 8),
            Text('Booking ID ${_currentBooking.id} copied to clipboard',
                style: CooperativeTypography.bodySm.copyWith(color: CooperativeColors.onPrimary)),
          ],
        ),
        backgroundColor: CooperativeColors.inverseSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _makePhoneCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling ${_currentBooking.worker.name} (+91 98432 •••••)...',
            style: CooperativeTypography.bodySm.copyWith(color: CooperativeColors.onPrimary)),
        backgroundColor: CooperativeColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _openChat() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening secure cooperative chat with ${_currentBooking.worker.name}...',
            style: CooperativeTypography.bodySm.copyWith(color: CooperativeColors.onPrimary)),
        backgroundColor: CooperativeColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }



  void _handleCustomerCancellation() {
    final canCancelFree = _currentBooking.canCancelBefore1Hour;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CooperativeColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: [
            Icon(
              canCancelFree ? Icons.check_circle_outline : Icons.warning_amber_rounded,
              color: canCancelFree ? CooperativeColors.secondary : CooperativeColors.error,
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                canCancelFree ? 'Cancel Service Booking?' : '1-Hour Policy Warning',
                style: SahayakTypography.titleMedium().copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          canCancelFree
              ? 'You are cancelling >1 hour before the scheduled time (${_currentBooking.scheduledSlot}). Cancellation is completely free with zero penalty.'
              : 'Notice: This cancellation is requested within 1 hour of the scheduled time. Per cooperative fair-work charter, technicians reserved this slot exclusively. Last-minute cancellation applies nominal transit compensation unless the worker is delayed. Do you wish to proceed?',
          style: CooperativeTypography.bodySm,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Booking'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (widget.viewModel != null) {
                widget.viewModel!.cancelBooking(_currentBooking.id);
                final updated = widget.viewModel!.repository.bookings.firstWhere(
                  (b) => b.id == _currentBooking.id,
                  orElse: () => _currentBooking.copyWith(status: 'cancelled'),
                );
                setState(() => _currentBooking = updated);
              } else {
                setState(() => _currentBooking = _currentBooking.copyWith(status: 'cancelled'));
              }
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

  @override
  Widget build(BuildContext context) {
    final b = _currentBooking;

    return Scaffold(
      backgroundColor: CooperativeColors.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          splashRadius: 24,
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Service Confirmation',
          style: SahayakTypography.titleMedium().copyWith(
            color: CooperativeColors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                  // 1. Success Celebration Banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CooperativeColors.secondaryContainer.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: CooperativeColors.secondary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: CooperativeColors.secondary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            color: CooperativeColors.onSecondary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Booking Confirmed',
                                    style: CooperativeTypography.headlineSm.copyWith(
                                      color: CooperativeColors.onSurface,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: CooperativeColors.secondary.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Live',
                                      style: CooperativeTypography.labelSm.copyWith(
                                        color: CooperativeColors.secondary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    'Booking ID: ',
                                    style: CooperativeTypography.bodySm.copyWith(
                                      color: CooperativeColors.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    b.id,
                                    style: CooperativeTypography.labelSm.copyWith(
                                      color: CooperativeColors.onSurface,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  InkWell(
                                    onTap: _copyBookingId,
                                    borderRadius: BorderRadius.circular(8),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                      child: Icon(
                                        Icons.copy_rounded,
                                        size: 16,
                                        color: CooperativeColors.primary,
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

                  const SizedBox(height: 14),

                  // 2. Booking Summary Overview Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CooperativeColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'SERVICE BOOKING',
                                    style: CooperativeTypography.caption.copyWith(
                                      color: CooperativeColors.primary,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${b.serviceName} — ${b.worker.name}',
                                    style: CooperativeTypography.headlineMd.copyWith(
                                      color: CooperativeColors.onSurface,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: CooperativeColors.secondary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: CooperativeColors.secondary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Confirmed',
                                    style: CooperativeTypography.labelSm.copyWith(
                                      color: CooperativeColors.secondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: CooperativeColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 20, color: CooperativeColors.primary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Scheduled Slot',
                                        style: CooperativeTypography.caption.copyWith(
                                          color: CooperativeColors.onSurfaceVariant,
                                        )),
                                    Text(b.scheduledSlot,
                                        style: CooperativeTypography.labelMd.copyWith(
                                          color: CooperativeColors.onSurface,
                                          fontWeight: FontWeight.w600,
                                        )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: CooperativeColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, size: 20, color: CooperativeColors.primary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Service Address',
                                        style: CooperativeTypography.caption.copyWith(
                                          color: CooperativeColors.onSurfaceVariant,
                                        )),
                                    Text(
                                      b.address.fullAddress,
                                      style: CooperativeTypography.labelMd.copyWith(
                                        color: CooperativeColors.onSurface,
                                        fontWeight: FontWeight.w600,
                                      ),
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

                  // 3. Security OTP Highlight Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CooperativeColors.primaryFixed,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: CooperativeColors.primary.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
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
                                  const Icon(Icons.verified_user, color: CooperativeColors.primary, size: 24),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Job Start Security OTP',
                                      style: CooperativeTypography.labelLg.copyWith(
                                        color: CooperativeColors.onPrimaryFixed,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: CooperativeColors.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                b.doorstepOtp,
                                style: CooperativeTypography.headlineMd.copyWith(
                                  color: CooperativeColors.primary,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 4.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        RichText(
                          text: TextSpan(
                            style: CooperativeTypography.bodySm.copyWith(
                              color: CooperativeColors.onSurfaceVariant,
                            ),
                            children: [
                              const TextSpan(text: 'Share this 4-digit OTP with '),
                              TextSpan(
                                text: b.worker.name,
                                style: CooperativeTypography.bodySm.copyWith(fontWeight: FontWeight.w700, color: CooperativeColors.onSurface),
                              ),
                              const TextSpan(text: ' only when they arrive at your doorstep to begin work.'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 4. Assigned Worker Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CooperativeColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: CooperativeColors.surfaceContainer,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: CooperativeColors.outlineVariant.withValues(alpha: 0.4)),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.asset(
                                      'assets/images/user_avatar.png',
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => const Icon(
                                        Icons.person,
                                        size: 32,
                                        color: CooperativeColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: -2,
                                  right: -2,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: const BoxDecoration(
                                      color: CooperativeColors.secondary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: CooperativeColors.onSecondary,
                                      size: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          b.worker.name,
                                          style: CooperativeTypography.headlineSm.copyWith(
                                            color: CooperativeColors.onSurface,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const VerifiedShieldBadge(label: 'Verified', isSmall: true),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, size: 15, color: CooperativeColors.tertiary),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${b.worker.rating}',
                                        style: CooperativeTypography.labelSm.copyWith(
                                          color: CooperativeColors.tertiary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '• ${b.worker.completedJobsCount} jobs completed',
                                        style: CooperativeTypography.caption.copyWith(
                                          color: CooperativeColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Guild ID: ${b.worker.guildId}',
                                    style: CooperativeTypography.caption.copyWith(
                                      color: CooperativeColors.outline,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  _makePhoneCall();
                                },
                                icon: const Icon(Icons.call, size: 18, color: CooperativeColors.primary),
                                label: Text('Call ${b.worker.name.split(' ').first}',
                                    style: CooperativeTypography.labelMd.copyWith(color: CooperativeColors.onSurface)),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: CooperativeColors.surfaceContainer,
                                  side: BorderSide.none,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  minimumSize: const Size.fromHeight(46),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  _openChat();
                                },
                                icon: const Icon(Icons.chat, size: 18, color: CooperativeColors.primary),
                                label: Text('In-App Chat',
                                    style: CooperativeTypography.labelMd.copyWith(color: CooperativeColors.onSurface)),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: CooperativeColors.surfaceContainer,
                                  side: BorderSide.none,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  minimumSize: const Size.fromHeight(46),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 5. Canonical 5-Stage Booking Timeline Tracker
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CooperativeColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        BookingTimelineTracker(
                          currentStage: BookingStage.workerOnTheWay,
                          estimatedArrivalMinutes: 12,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 6. Interactive What Happens Next Accordion
                  Container(
                    decoration: BoxDecoration(
                      color: CooperativeColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        initiallyExpanded: _isFaqExpanded,
                        onExpansionChanged: (val) {
                          HapticFeedback.selectionClick();
                          setState(() => _isFaqExpanded = val);
                        },
                        leading: const Icon(Icons.help_outline, color: CooperativeColors.primary, size: 22),
                        trailing: Icon(
                          _isFaqExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                          color: CooperativeColors.onSurfaceVariant,
                        ),
                        title: Text(
                          'What happens next?',
                          style: CooperativeTypography.labelLg.copyWith(
                            color: CooperativeColors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        children: [
                          _buildStepItem(1, 'Worker receives your booking:', '${b.worker.name} has accepted and mapped your address.'),
                          const SizedBox(height: 10),
                          _buildStepItem(2, 'Worker travels to your location:', 'You will receive an in-app & SMS notification as they approach.'),
                          const SizedBox(height: 10),
                          _buildStepItem(3, 'Worker verifies the job with OTP:', 'Provide code ${b.doorstepOtp} to unlock work authorization.'),
                          const SizedBox(height: 10),
                          _buildStepItem(4, 'Service is completed:', 'Standard diagnostic and repair checks carried out per co-op guidelines.'),
                          const SizedBox(height: 10),
                          _buildStepItem(5, 'Final payment & invoice:', 'Transparent billing with zero hidden middleman markups.'),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 7. Worker 1-Hour Pre-Service Notification Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CooperativeColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: b.preServiceUpdate?.status == WorkerPreServiceStatus.delayed
                            ? CooperativeColors.tertiary
                            : b.preServiceUpdate?.status == WorkerPreServiceStatus.cancelled
                                ? CooperativeColors.error
                                : CooperativeColors.secondary.withValues(alpha: 0.3),
                      ),
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
                                  Icon(
                                    Icons.notifications_active_rounded,
                                    color: b.preServiceUpdate?.status == WorkerPreServiceStatus.delayed
                                        ? CooperativeColors.tertiary
                                        : b.preServiceUpdate?.status == WorkerPreServiceStatus.cancelled
                                            ? CooperativeColors.error
                                            : CooperativeColors.secondary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Worker 1-Hr Update',
                                      style: CooperativeTypography.labelMd.copyWith(fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: b.preServiceUpdate != null
                                    ? (b.preServiceUpdate!.status == WorkerPreServiceStatus.onTime
                                        ? CooperativeColors.secondaryContainer
                                        : b.preServiceUpdate!.status == WorkerPreServiceStatus.delayed
                                            ? CooperativeColors.tertiaryFixed
                                            : CooperativeColors.errorContainer)
                                    : CooperativeColors.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                b.preServiceUpdate?.statusLabel ?? 'Pending 1-Hr Check',
                                style: SahayakTypography.caption().copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: b.preServiceUpdate != null
                                      ? (b.preServiceUpdate!.status == WorkerPreServiceStatus.onTime
                                          ? CooperativeColors.onSecondaryContainer
                                          : b.preServiceUpdate!.status == WorkerPreServiceStatus.delayed
                                              ? CooperativeColors.onTertiaryFixed
                                              : CooperativeColors.error)
                                      : CooperativeColors.outline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          b.preServiceUpdate != null
                              ? (b.preServiceUpdate!.status == WorkerPreServiceStatus.onTime
                                  ? '🟢 ${b.worker.name} checked in: "On schedule, tools ready, proceeding to your address."'
                                  : b.preServiceUpdate!.status == WorkerPreServiceStatus.delayed
                                      ? '🟡 ${b.worker.name} notified: Delayed by ${b.preServiceUpdate!.delayMinutes} mins (${b.preServiceUpdate!.reason ?? "En-route traffic"}).'
                                      : '🔴 ${b.worker.name} cancelled: ${b.preServiceUpdate!.reason ?? "Emergency breakdown"}. Re-dispatch available.')
                              : 'Per Work Solute workflow, the worker submits an operational status check 1 hour prior to scheduled service (${b.scheduledSlot}).',
                          style: CooperativeTypography.bodySm.copyWith(color: CooperativeColors.onSurfaceVariant),
                        ),

                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 8. Cooperative Cancellation Policy
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: CooperativeColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lock_clock, size: 20, color: CooperativeColors.secondary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cooperative Cancellation Policy (1-Hour Rule)',
                                style: CooperativeTypography.labelMd.copyWith(
                                  color: CooperativeColors.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Free cancellation up to 1 hour before scheduled time. No cancellation charges apply if the technician is delayed.',
                                style: CooperativeTypography.bodySm.copyWith(
                                  color: CooperativeColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 9. Bottom Interactive Actions
                  if (b.tab != BookingTab.cancelled) ...[
                    OutlinedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        _handleCustomerCancellation();
                      },
                      icon: const Icon(Icons.cancel_presentation_rounded, size: 18, color: CooperativeColors.error),
                      label: Text(
                        b.canCancelBefore1Hour
                            ? 'Cancel Booking (Free >1hr Window)'
                            : 'Cancel Booking (Within 1hr Notice)',
                        style: CooperativeTypography.labelMd.copyWith(
                          color: CooperativeColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: CooperativeColors.error),
                        minimumSize: const Size.fromHeight(48),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: CooperativeColors.errorContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: CooperativeColors.error.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.cancel, color: CooperativeColors.error, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'This booking is cancelled.',
                            style: CooperativeTypography.labelMd.copyWith(
                              color: CooperativeColors.error,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      if (widget.viewModel != null) {
                        widget.viewModel!.switchTab(ShellTab.bookings);
                      }
                      if (widget.onNavigateToBookings != null) {
                        widget.onNavigateToBookings!();
                      }
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    icon: const Icon(Icons.calendar_month_rounded, size: 20),
                    label: const Text('View in My Bookings'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CooperativeColors.primaryContainer,
                      foregroundColor: CooperativeColors.onPrimary,
                      minimumSize: const Size.fromHeight(50),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (_) => BookingDetailsScreen(
                            booking: _currentBooking,
                            onBackToBookings: () {
                              widget.viewModel?.switchTab(ShellTab.bookings);
                              Navigator.of(context).popUntil((route) => route.isFirst);
                            },
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.receipt_long_rounded, size: 20),
                    label: const Text('View Booking Slip & Details'),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: CooperativeColors.surfaceContainer,
                      foregroundColor: CooperativeColors.onSurface,
                      side: BorderSide.none,
                      minimumSize: const Size.fromHeight(50),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      if (widget.onBookAnother != null) {
                        widget.onBookAnother!();
                      } else {
                        widget.viewModel?.switchTab(ShellTab.home);
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      }
                    },
                    icon: const Icon(Icons.home_repair_service_rounded, size: 20),
                    label: const Text('Book Another Service'),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: CooperativeColors.surfaceContainer,
                      foregroundColor: CooperativeColors.onSurface,
                      side: BorderSide.none,
                      minimumSize: const Size.fromHeight(50),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
        ),
      ),
    );
  }

  Widget _buildStepItem(int stepNumber, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: CooperativeColors.primaryFixed,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$stepNumber',
            style: CooperativeTypography.caption.copyWith(
              color: CooperativeColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: CooperativeTypography.bodySm.copyWith(color: CooperativeColors.onSurface),
              children: [
                TextSpan(
                  text: '$title ',
                  style: CooperativeTypography.bodySm.copyWith(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text: description,
                  style: CooperativeTypography.bodySm.copyWith(color: CooperativeColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
