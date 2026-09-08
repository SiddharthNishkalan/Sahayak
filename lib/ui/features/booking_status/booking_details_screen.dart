import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../data/models/booking.dart';
import '../../../data/models/invoice.dart';
import '../../shared_widgets/custom_vector_map.dart';
import '../../shared_widgets/trust_badges.dart';
import '../profile/tax_invoice_dialog.dart';

class BookingDetailsScreen extends StatefulWidget {
  final Booking booking;
  final VoidCallback? onBackToBookings;

  const BookingDetailsScreen({
    super.key,
    required this.booking,
    this.onBackToBookings,
  });

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  int _selectedRating = 5;
  final TextEditingController _reviewController = TextEditingController(
    text: 'Priya was punctual, polite, and fixed the leak efficiently without any mess.',
  );
  bool _isPaid = false;
  bool _reviewSubmitted = false;
  late Booking _currentBooking;

  @override
  void initState() {
    super.initState();
    _currentBooking = widget.booking;
    _isPaid = _currentBooking.currentStage == BookingStage.paid ||
        _currentBooking.tab == BookingTab.completed ||
        (_currentBooking.invoice?.isPaid ?? false);
    if (_currentBooking.rating > 0) {
      _selectedRating = _currentBooking.rating;
      _reviewSubmitted = true;
    }
    if (_currentBooking.reviewText.isNotEmpty) {
      _reviewController.text = _currentBooking.reviewText;
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  IconData _getServiceIcon(String serviceName) {
    final s = serviceName.toLowerCase();
    if (s.contains('electr')) return Icons.bolt_rounded;
    if (s.contains('clean')) return Icons.cleaning_services_rounded;
    if (s.contains('carpent')) return Icons.carpenter_rounded;
    if (s.contains('caregiv')) return Icons.volunteer_activism_rounded;
    if (s.contains('driv')) return Icons.directions_car_rounded;
    if (s.contains('garden')) return Icons.yard_rounded;
    if (s.contains('appliance')) return Icons.home_repair_service_rounded;
    if (s.contains('plumb')) return Icons.plumbing_rounded;
    if (s.contains('multi')) return Icons.hub_rounded;
    return Icons.handyman_rounded;
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

  void _handlePay() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isPaid = true;
      _currentBooking = _currentBooking.copyWith(
        currentStage: BookingStage.paid,
      );
    });
    TaxInvoiceDialog.show(
      context,
      invoice: _currentBooking.invoice ?? CooperativeInvoice.sampleInvoice,
    );
  }

  void _submitReview() {
    if (!_isPaid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete payment before submitting a review.'),
          backgroundColor: CooperativeColors.error,
        ),
      );
      return;
    }
    if (_selectedRating <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rating is mandatory (*). Please select 1 to 5 stars.'),
          backgroundColor: CooperativeColors.error,
        ),
      );
      return;
    }
    setState(() {
      _reviewSubmitted = true;
      _currentBooking = _currentBooking.copyWith(
        rating: _selectedRating.toInt(),
        reviewText: _reviewController.text.trim(),
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.verified, color: CooperativeColors.secondaryContainer, size: 20),
            Flexible(
              child: Text('Review & Rating (*) submitted to Worker Guild!',
                  style: CooperativeTypography.bodySm.copyWith(color: CooperativeColors.onPrimary)),
            ),
          ],
        ),
        backgroundColor: CooperativeColors.secondary,
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
              ? 'You are cancelling >1 hour before the scheduled time (${_currentBooking.scheduledSlot}). Cancellation is completely free with zero fee.'
              : 'Notice: You are within 1 hour of the scheduled time. Per cooperative fair-work rules, last-minute cancellations may apply a nominal technician compensation fee unless the worker is delayed. Do you still wish to proceed?',
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
              setState(() {
                _currentBooking = _currentBooking.copyWith(status: 'cancelled');
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(canCancelFree
                      ? 'Booking cancelled with zero fee per 1-hour policy.'
                      : 'Booking cancelled under late cancellation policy.'),
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

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 5:
        return '5 — Excellent Quality';
      case 4:
        return '4 — Very Good Service';
      case 3:
        return '3 — Satisfactory';
      case 2:
        return '2 — Needs Improvement';
      case 1:
        return '1 — Unsatisfactory';
      default:
        return '5 — Excellent Quality';
    }
  }

  String _getPreServiceBadgeText(WorkerPreServiceUpdate? update) {
    if (update == null) return 'Pending Check';
    switch (update.status) {
      case WorkerPreServiceStatus.onTime:
        return 'On Time';
      case WorkerPreServiceStatus.delayed:
        return 'Delayed +${update.delayMinutes}m';
      case WorkerPreServiceStatus.cancelled:
      case WorkerPreServiceStatus.cancelledWithReason:
      case WorkerPreServiceStatus.cancelledByWorker:
        return 'Cancelled';
    }
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
            if (widget.onBackToBookings != null) {
              widget.onBackToBookings!();
            }
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Booking Details',
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
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                  // 1. Booking Identification Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CooperativeColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                '#${b.id}',
                                style: CooperativeTypography.headlineSm.copyWith(
                                  color: CooperativeColors.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            InkWell(
                              onTap: _copyBookingId,
                              borderRadius: BorderRadius.circular(8),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                child: Icon(Icons.copy_rounded, size: 16, color: CooperativeColors.onSurfaceVariant),
                              ),
                            ),
                            const Spacer(),
                            const CoOpProtectedBadge(),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Status',
                              style: CooperativeTypography.bodySm.copyWith(color: CooperativeColors.onSurfaceVariant),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _isPaid
                                      ? CooperativeColors.secondaryContainer.withValues(alpha: 0.4)
                                      : CooperativeColors.surfaceContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: _isPaid ? CooperativeColors.secondary : CooperativeColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        _isPaid ? 'Completed · Paid' : 'Job Completed · Pending Pay',
                                        style: CooperativeTypography.labelSm.copyWith(
                                          color: _isPaid ? CooperativeColors.secondary : CooperativeColors.primary,
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
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 2. Service Summary Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CooperativeColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
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
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: CooperativeColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(_getServiceIcon(b.serviceName), color: CooperativeColors.primary, size: 26),
                            ),
                            const SizedBox(width: 12),
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
                                    b.subcategoryTitle,
                                    style: CooperativeTypography.bodySm.copyWith(
                                      color: CooperativeColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: CooperativeColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.schedule, size: 18, color: CooperativeColors.primary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Scheduled Slot',
                                            style: CooperativeTypography.labelSm.copyWith(
                                              color: CooperativeColors.onSurface,
                                              fontWeight: FontWeight.w600,
                                            )),
                                        Text(b.scheduledSlot,
                                            style: CooperativeTypography.bodySm.copyWith(
                                              color: CooperativeColors.onSurfaceVariant,
                                            )),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.location_on, size: 18, color: CooperativeColors.secondary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Service Address',
                                            style: CooperativeTypography.labelSm.copyWith(
                                              color: CooperativeColors.onSurface,
                                              fontWeight: FontWeight.w600,
                                            )),
                                        Text(b.address.fullAddress,
                                            style: CooperativeTypography.bodySm.copyWith(
                                              color: CooperativeColors.onSurfaceVariant,
                                              height: 1.3,
                                            )),
                                      ],
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

                  // 3. Service Progress Timeline
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CooperativeColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Service Progress',
                                style: CooperativeTypography.headlineSm.copyWith(
                                  color: CooperativeColors.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isPaid ? 'Stage 5 of 5' : 'Stage 4 of 5',
                              style: CooperativeTypography.caption.copyWith(
                                color: CooperativeColors.secondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildTimelineStep(
                          isCompleted: true,
                          title: 'Confirmed',
                          subtitle: 'Booking accepted & worker ${b.worker.name} assigned',
                          time: '1:42 PM',
                          icon: Icons.check,
                        ),
                        _buildTimelineStep(
                          isCompleted: true,
                          title: 'Worker On The Way',
                          subtitle: 'Dispatched from Shivaji Nagar Hub (Ward 5)',
                          time: '2:02 PM',
                          icon: Icons.check,
                        ),
                        _buildTimelineStep(
                          isCompleted: true,
                          title: 'Job In Progress',
                          subtitle: 'OTP ${b.doorstepOtp} verified at doorstep',
                          time: '2:14 PM',
                          icon: Icons.check,
                        ),
                        _buildTimelineStep(
                          isCompleted: true,
                          isActive: !_isPaid,
                          title: 'Job Completed',
                          subtitle: 'Seal tested & quality inspection approved by customer',
                          time: '2:56 PM',
                          icon: Icons.done_all,
                        ),
                        _buildTimelineStep(
                          isCompleted: _isPaid,
                          isActive: false,
                          isLast: true,
                          title: 'Paid',
                          subtitle: _isPaid
                              ? 'Cooperative tax invoice generated'
                              : 'Awaiting direct cooperative settlement',
                          time: _isPaid ? 'Settled' : 'Pending',
                          icon: Icons.payments,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 4. Doorstep Verification OTP Security Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CooperativeColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: CooperativeColors.primary.withValues(alpha: 0.15)),
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
                            const Icon(Icons.shield, color: CooperativeColors.primary, size: 18),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'DOORSTEP SECURITY OTP',
                                style: CooperativeTypography.caption.copyWith(
                                  color: CooperativeColors.primary,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: CooperativeColors.secondary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.verified, color: CooperativeColors.secondary, size: 14),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        'Verified',
                                        style: CooperativeTypography.caption.copyWith(
                                          color: CooperativeColors.secondary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: CooperativeColors.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: CooperativeColors.primary.withValues(alpha: 0.2)),
                              ),
                              child: Text(
                                b.doorstepOtp,
                                style: CooperativeTypography.headlineLg.copyWith(
                                  color: CooperativeColors.primary,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 6.0,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            InkWell(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Clipboard.setData(ClipboardData(text: b.doorstepOtp));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('OTP ${b.doorstepOtp} copied to clipboard',
                                        style: CooperativeTypography.bodySm.copyWith(color: CooperativeColors.onPrimary)),
                                    backgroundColor: CooperativeColors.inverseSurface,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                child: Icon(Icons.copy_rounded, size: 18, color: CooperativeColors.primary),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: CooperativeColors.secondary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.key, color: CooperativeColors.secondary, size: 24),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: CooperativeColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.lock_outline, size: 14, color: CooperativeColors.onSurfaceVariant),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Only share with ${b.worker.name.split(' ').first} in person at your door. Never share via phone or message.',
                                  style: CooperativeTypography.caption.copyWith(
                                    color: CooperativeColors.onSurfaceVariant,
                                    fontSize: 11,
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

                  // 5. Assigned Worker Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CooperativeColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                'assets/images/user_avatar.png',
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  width: 56,
                                  height: 56,
                                  color: CooperativeColors.surfaceContainer,
                                  child: const Icon(Icons.person, color: CooperativeColors.primary),
                                ),
                              ),
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
                                      const VerifiedShieldBadge(label: 'Co-op Tech'),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Municipal Guild ID: ${b.worker.guildId}',
                                    style: CooperativeTypography.caption.copyWith(
                                      color: CooperativeColors.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
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
                                      Flexible(
                                        child: Text(
                                          '· ${b.worker.completedJobsCount} completed jobs',
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
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: CooperativeColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(Icons.lock, size: 16, color: CooperativeColors.onSurfaceVariant),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text('+91 98432 •••••',
                                          style: CooperativeTypography.bodySm.copyWith(
                                            color: CooperativeColors.onSurfaceVariant,
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Privacy Masked',
                                style: CooperativeTypography.caption.copyWith(
                                  color: CooperativeColors.secondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Calling ${b.worker.name}...')),
                                  );
                                },
                                icon: const Icon(Icons.call, size: 18, color: CooperativeColors.primary),
                                label: Text('Call ${b.worker.name.split(' ').first}',
                                    style: CooperativeTypography.labelMd.copyWith(color: CooperativeColors.onSurface)),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: CooperativeColors.surfaceContainer,
                                  side: BorderSide.none,
                                  minimumSize: const Size.fromHeight(46),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Connecting to Work Solute Secure Chat...')),
                                  );
                                },
                                icon: const Icon(Icons.chat, size: 18, color: CooperativeColors.primary),
                                label: Text('In-App Chat',
                                    style: CooperativeTypography.labelMd.copyWith(color: CooperativeColors.onSurface)),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: CooperativeColors.surfaceContainer,
                                  side: BorderSide.none,
                                  minimumSize: const Size.fromHeight(46),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 6. Worker 1-Hour Pre-Service Notification Card
                  _buildPreServiceUpdateCard(b),

                  const SizedBox(height: 14),

                  // 7. Live Transit Tracker Preview
                  Container(
                    decoration: BoxDecoration(
                      color: CooperativeColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            const SizedBox(
                              height: 140,
                              width: double.infinity,
                              child: CustomVectorMap(
                                locationLabel: 'Ward 5, Shivaji Nagar',
                                interactive: false,
                                showControls: false,
                              ),
                            ),
                            Positioned(
                              top: 10,
                              left: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: CooperativeColors.surfaceContainerLowest.withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.06),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: CooperativeColors.secondary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Transit Route: Ward 5',
                                      style: CooperativeTypography.caption.copyWith(
                                        color: CooperativeColors.onSurface,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: CooperativeColors.surfaceContainerLowest.withValues(alpha: 0.95),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.06),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle, size: 15, color: CooperativeColors.secondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Technician on-site',
                                      style: CooperativeTypography.caption.copyWith(
                                        color: CooperativeColors.onSurface,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          color: CooperativeColors.surfaceContainerLow,
                          child: Row(
                            children: [
                              const Icon(Icons.near_me, size: 18, color: CooperativeColors.onSurfaceVariant),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '1.4 km from Shivaji Nagar Hub',
                                  style: CooperativeTypography.bodySm.copyWith(
                                    color: CooperativeColors.onSurface,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Arrival: 2:12 PM',
                                  style: CooperativeTypography.caption.copyWith(
                                    color: CooperativeColors.secondary,
                                    fontWeight: FontWeight.w700,
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

                  // 7. Transparent Payment Breakdown Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CooperativeColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Payment Summary',
                                style: CooperativeTypography.headlineSm.copyWith(
                                  color: CooperativeColors.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Zero Commission Model',
                              style: CooperativeTypography.caption.copyWith(
                                color: CooperativeColors.secondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildPriceRow('Standard Visit & Diagnostic Fee', '₹300'),
                        const SizedBox(height: 6),
                        _buildPriceRow('Labor: Pipe replacement & tap valve seating', '₹500'),
                        const SizedBox(height: 6),
                        _buildPriceRow('Material pass-through (Neoprene seal & gasket)', '₹50'),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: CooperativeColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Total Final Amount',
                                        style: CooperativeTypography.headlineSm.copyWith(
                                          color: CooperativeColors.onSurface,
                                          fontWeight: FontWeight.w700,
                                        )),
                                    Text('100% paid to worker & welfare fund',
                                        style: CooperativeTypography.caption.copyWith(
                                          color: CooperativeColors.secondary,
                                          fontWeight: FontWeight.w600,
                                        )),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '₹850',
                                style: CooperativeTypography.headlineLg.copyWith(
                                  color: CooperativeColors.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: CooperativeColors.primary.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_outline, size: 16, color: CooperativeColors.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Final pricing reflects actual work completed and precisely matches the ₹700–950 estimate provided during initial matching. Zero surge fees.',
                                  style: CooperativeTypography.caption.copyWith(
                                    color: CooperativeColors.onSurfaceVariant,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _handlePay,
                            icon: Icon(_isPaid ? Icons.receipt_long : Icons.lock_open, size: 20),
                            label: Text(
                              _isPaid ? 'View Cooperative Tax Invoice' : 'Pay ₹850 & Generate Invoice',
                              style: CooperativeTypography.labelLg.copyWith(fontWeight: FontWeight.w700),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isPaid ? CooperativeColors.secondary : CooperativeColors.primary,
                              foregroundColor: CooperativeColors.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 9. Service Review & Rating Component (Placed directly after payment)
                  _buildReviewAndRatingSection(b),

                  const SizedBox(height: 14),

                  // 9. Cooperative Assurance Guarantee Footer Banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: CooperativeColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: CooperativeColors.secondaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.gavel, color: CooperativeColors.onSecondaryContainer, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '30-Day Service Guarantee',
                                style: CooperativeTypography.labelSm.copyWith(
                                  color: CooperativeColors.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Free rework or immediate dispute mediation backed by Tamil Nadu Cooperative Society Charter.',
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
    );
  }

  Widget _buildPreServiceUpdateCard(Booking b) {
    return Container(
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
                  'Worker 1-Hr Status Check',
                  style: CooperativeTypography.labelMd.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                  _getPreServiceBadgeText(b.preServiceUpdate),
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
          if (b.tab != BookingTab.cancelled) ...[
            const SizedBox(height: 12),
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
                minimumSize: const Size.fromHeight(46),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewAndRatingSection(Booking b) {
    if (!_isPaid) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: CooperativeColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: CooperativeColors.outlineVariant.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: CooperativeColors.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.rate_review_outlined, size: 18, color: CooperativeColors.outline),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Service Review & Rating ',
                          style: CooperativeTypography.labelLg.copyWith(
                            color: CooperativeColors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text: '*',
                          style: CooperativeTypography.labelLg.copyWith(
                            color: CooperativeColors.error,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: CooperativeColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'After Payment',
                    style: CooperativeTypography.caption.copyWith(
                      color: CooperativeColors.outline,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Technician performance review, 5-star rating, and job proof verification will unlock immediately after completing payment for ₹850 above.',
              style: CooperativeTypography.bodySm.copyWith(
                color: CooperativeColors.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CooperativeColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Service Review & Rating ',
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
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_reviewSubmitted) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: CooperativeColors.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Submitted',
                      style: TextStyle(
                          fontSize: 10,
                          color: CooperativeColors.onSecondaryContainer,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
          Text(
            'How was your experience with ${b.worker.name}?',
            style: CooperativeTypography.bodySm.copyWith(
              color: CooperativeColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: CooperativeColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starIndex = index + 1;
                    return IconButton(
                      splashRadius: 24,
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _selectedRating = starIndex;
                        });
                      },
                      icon: Icon(
                        Icons.star,
                        size: 32,
                        color: starIndex <= _selectedRating
                            ? CooperativeColors.tertiary
                            : CooperativeColors.outlineVariant,
                      ),
                    );
                  }),
                ),
                Text(
                  _getRatingLabel(_selectedRating),
                  style: CooperativeTypography.labelMd.copyWith(
                    color: CooperativeColors.tertiary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tell the co-op about the work',
            style: CooperativeTypography.labelSm.copyWith(
              color: CooperativeColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _reviewController,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Share specific details about promptness, hygiene, or craftsmanship...',
              filled: true,
              fillColor: CooperativeColors.surfaceContainerLowest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: CooperativeColors.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: CooperativeColors.outlineVariant.withValues(alpha: 0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: CooperativeColors.primary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _reviewSubmitted ? null : _submitReview,
              icon: Icon(_reviewSubmitted ? Icons.check : Icons.rate_review, size: 18),
              label: Text(_reviewSubmitted ? 'Review Submitted' : 'Submit Review to Co-op Guild'),
              style: ElevatedButton.styleFrom(
                backgroundColor: CooperativeColors.surfaceContainerHighest,
                foregroundColor: CooperativeColors.onSurface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required bool isCompleted,
    bool isActive = false,
    bool isLast = false,
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? (isActive ? CooperativeColors.primary : CooperativeColors.secondary)
                        : CooperativeColors.surfaceContainerHigh,
                    shape: BoxShape.circle,
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: CooperativeColors.primary.withValues(alpha: 0.4),
                              blurRadius: 6,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    icon,
                    color: isCompleted ? CooperativeColors.onPrimary : CooperativeColors.onSurfaceVariant,
                    size: 12,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isCompleted ? CooperativeColors.secondary : CooperativeColors.surfaceContainerHighest,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: CooperativeTypography.labelMd.copyWith(
                            color: isActive ? CooperativeColors.primary : CooperativeColors.onSurface,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: CooperativeTypography.caption.copyWith(
                            color: CooperativeColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    time,
                    style: CooperativeTypography.caption.copyWith(
                      color: time == 'Pending' ? CooperativeColors.tertiary : CooperativeColors.onSurfaceVariant,
                      fontWeight: time == 'Pending' ? FontWeight.w700 : FontWeight.w500,
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

  Widget _buildPriceRow(String label, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: CooperativeTypography.bodySm.copyWith(color: CooperativeColors.onSurfaceVariant),
          ),
        ),
        Text(
          amount,
          style: CooperativeTypography.bodySm.copyWith(
            color: CooperativeColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
