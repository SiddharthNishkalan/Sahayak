import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../data/models/booking.dart';
import '../../../data/models/invoice.dart';
import '../../../data/repositories/app_repository.dart';
import '../../../app_view_model.dart';
import '../../shared_widgets/trust_badges.dart';
import '../booking_status/booking_details_screen.dart';
import '../booking_status/institution_allocation_status_screen.dart';
import '../profile/tax_invoice_dialog.dart';

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

  void _handleCompleteAndPay(Booking b) {
    HapticFeedback.lightImpact();
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
    HapticFeedback.lightImpact();
    int rating = 5;
    final textController = TextEditingController(text: 'Excellent work, very professional and on time.');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: CooperativeColors.surfaceContainerLowest,
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: CooperativeColors.tertiary, size: 28),
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
                const SizedBox(height: 12),
                Text(
                  'How was your service with ${b.worker.name}? Rating is required to complete civic co-op records.',
                  style: CooperativeTypography.bodyMedium,
                ),
                const SizedBox(height: 16),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final star = index + 1;
                      return IconButton(
                        iconSize: 36,
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          setModalState(() => rating = star);
                        },
                        icon: Icon(
                          Icons.star_rounded,
                          color: star <= rating ? CooperativeColors.tertiary : CooperativeColors.outlineVariant,
                        ),
                      );
                    }),
                  ),
                ),
                Center(
                  child: Text(
                    rating == 5 ? '5 ★ — Exceptional Quality' : '$rating ★ — Cooperative Feedback',
                    style: CooperativeTypography.labelMd.copyWith(fontWeight: FontWeight.bold, color: CooperativeColors.tertiary),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Feedback (Optional notes & details):',
                  style: CooperativeTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: textController,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Describe promptness, cleanliness, parts replacement...',
                    filled: true,
                    fillColor: CooperativeColors.surfaceContainerLow,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: CooperativeColors.outlineVariant)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: CooperativeColors.outlineVariant)),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
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
                      HapticFeedback.mediumImpact();
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CooperativeColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Submit Mandatory Review (*)'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            HapticFeedback.lightImpact();
            await Future.delayed(const Duration(milliseconds: 300));
            setState(() {});
          },
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                    // Subheader
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
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
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedTab = tab);
        },
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
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
      children: bookings
          .map((b) => b.isInstitutionBooking
              ? _buildInstitutionUpcomingCard(b)
              : _buildUpcomingBookingCard(b))
          .toList(),
    );
  }

  Widget _buildInstitutionUpcomingCard(Booking b) {
    final totalReq = b.totalWorkersRequested;
    final totalAlloc = b.totalWorkersAllocated;
    final isFullyAlloc = b.isFullyAllocated;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: CooperativeColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CooperativeColors.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => InstitutionAllocationStatusScreen(
                booking: b,
                activeRepository: widget.activeRepository,
                viewModel: widget.viewModel,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          b.serviceName,
                          style: CooperativeTypography.labelLg.copyWith(
                            color: CooperativeColors.onSurface,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${b.organizationName ?? 'Institution'} · #${b.id}',
                          style: CooperativeTypography.caption.copyWith(
                            color: CooperativeColors.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isFullyAlloc ? CooperativeColors.secondaryContainer : CooperativeColors.tertiaryFixed,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isFullyAlloc ? Icons.check_circle_rounded : Icons.hourglass_top_rounded,
                          size: 12,
                          color: isFullyAlloc ? CooperativeColors.onSecondaryContainer : CooperativeColors.onTertiaryFixed,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isFullyAlloc ? 'Fully Confirmed' : '$totalAlloc/$totalReq Confirmed',
                          style: CooperativeTypography.labelSm.copyWith(
                            color: isFullyAlloc ? CooperativeColors.onSecondaryContainer : CooperativeColors.onTertiaryFixed,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Plain text location & timing
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.schedule_rounded, size: 14, color: CooperativeColors.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      b.scheduledSlot,
                      style: CooperativeTypography.caption.copyWith(
                        color: CooperativeColors.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: CooperativeColors.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      b.address.streetAddress.isNotEmpty ? b.address.fullAddress : 'Primary Commercial Facility',
                      style: CooperativeTypography.caption.copyWith(
                        color: CooperativeColors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Domain headcount tags
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: b.requiredWorkersPerDomain.entries.map((entry) {
                  final domain = entry.key;
                  final reqCount = entry.value;
                  final allocCount = b.allocatedWorkersPerDomain[domain]?.length ?? 0;
                  final domainFulfilled = allocCount >= reqCount;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: domainFulfilled
                          ? CooperativeColors.secondary.withValues(alpha: 0.1)
                          : CooperativeColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$domain: $allocCount/$reqCount',
                      style: CooperativeTypography.caption.copyWith(
                        color: domainFulfilled ? CooperativeColors.secondary : CooperativeColors.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 8),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: b.allocationProgressRatio,
                  minHeight: 4,
                  backgroundColor: CooperativeColors.surfaceContainerHigh,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isFullyAlloc ? CooperativeColors.secondary : CooperativeColors.tertiary,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Action button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => InstitutionAllocationStatusScreen(
                          booking: b,
                          activeRepository: widget.activeRepository,
                          viewModel: widget.viewModel,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.group_work_outlined, size: 16),
                  label: Text(isFullyAlloc ? 'View Workforce Team' : 'View Allocation Status'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CooperativeColors.primary,
                    foregroundColor: CooperativeColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingBookingCard(Booking b) {
    final bool isOnTheWay = b.stage == BookingStage.workerOnTheWay;
    final bool isInProgress = b.stage == BookingStage.jobInProgress;

    String statusLabel;
    Color statusBg;
    Color statusFg;
    Widget? statusLeading;

    if (isOnTheWay) {
      statusLabel = 'On the way · ~${b.minutesUntilArrival} min';
      statusBg = CooperativeColors.secondaryContainer;
      statusFg = CooperativeColors.onSecondaryContainer;
      statusLeading = Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: CooperativeColors.secondary,
          shape: BoxShape.circle,
        ),
      );
    } else if (isInProgress) {
      statusLabel = 'In Progress';
      statusBg = CooperativeColors.primaryFixed;
      statusFg = CooperativeColors.primary;
      statusLeading = const Icon(Icons.build_circle_outlined, size: 12, color: CooperativeColors.primary);
    } else if (b.activePreServiceUpdate.status == WorkerPreServiceStatus.delayed) {
      statusLabel = 'Delayed (+${b.activePreServiceUpdate.delayMinutes}m)';
      statusBg = CooperativeColors.tertiaryFixed;
      statusFg = CooperativeColors.onTertiaryFixed;
    } else {
      statusLabel = 'Confirmed';
      statusBg = CooperativeColors.surfaceContainerHigh;
      statusFg = CooperativeColors.onSurface;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: CooperativeColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CooperativeColors.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookingDetailsScreen(booking: b),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Service Name & Status Pill
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          b.serviceName,
                          style: CooperativeTypography.labelLg.copyWith(
                            color: CooperativeColors.onSurface,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '#${b.id} · ${b.subcategoryTitle}',
                          style: CooperativeTypography.caption.copyWith(
                            color: CooperativeColors.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (statusLeading != null) ...[
                          statusLeading,
                          const SizedBox(width: 4),
                        ],
                        Text(
                          statusLabel,
                          style: CooperativeTypography.labelSm.copyWith(
                            color: statusFg,
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
              const Divider(height: 1, thickness: 0.5, color: CooperativeColors.surfaceContainerHigh),
              const SizedBox(height: 10),

              // Worker Row: Avatar, Name, Rating
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      'assets/images/user_avatar.png',
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 32,
                        height: 32,
                        color: CooperativeColors.surfaceContainer,
                        child: const Icon(Icons.person, size: 18, color: CooperativeColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            b.worker.name,
                            style: CooperativeTypography.labelMd.copyWith(
                              color: CooperativeColors.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const VerifiedShieldBadge(label: 'Verified', isSmall: true),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, size: 16, color: CooperativeColors.tertiary),
                      const SizedBox(width: 2),
                      Text(
                        '${b.worker.rating}',
                        style: CooperativeTypography.caption.copyWith(
                          color: CooperativeColors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Date/Time & Location (Plain text lines)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.schedule_rounded, size: 14, color: CooperativeColors.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      b.scheduledSlot,
                      style: CooperativeTypography.caption.copyWith(
                        color: CooperativeColors.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: CooperativeColors.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      b.address.fullAddress,
                      style: CooperativeTypography.caption.copyWith(
                        color: CooperativeColors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Single Primary Action Row
              if (isOnTheWay)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingDetailsScreen(booking: b),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                    label: Text(s.get('view_details')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CooperativeColors.primary,
                      foregroundColor: CooperativeColors.onPrimary,
                      minimumSize: const Size.fromHeight(46),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                )
              else if (isInProgress)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _handleCompleteAndPay(b),
                    icon: const Icon(Icons.check_circle_outline, size: 16),
                    label: Text(s.get('complete_pay_action')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CooperativeColors.secondary,
                      foregroundColor: CooperativeColors.onSecondary,
                      minimumSize: const Size.fromHeight(46),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingDetailsScreen(booking: b),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward_rounded, size: 15),
                    label: Text(s.get('view_details')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: CooperativeColors.primary,
                      side: const BorderSide(color: CooperativeColors.primary),
                      minimumSize: const Size.fromHeight(46),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedList(List<Booking> bookings) {
    if (bookings.isEmpty) {
      return _buildEmptyState(
        icon: Icons.task_alt_rounded,
        title: s.get('no_completed_bookings'),
        subtitle: 'Completed services with tax invoices and review guarantees will appear here.',
      );
    }

    return Column(
      children: bookings
          .map((b) => b.isInstitutionBooking
              ? _buildInstitutionCompletedCard(b)
              : _buildCompletedBookingCard(b))
          .toList(),
    );
  }

  Widget _buildInstitutionCompletedCard(Booking b) {
    final totalStaff = b.totalWorkersAllocated > 0 ? b.totalWorkersAllocated : b.totalWorkersRequested;
    final invoice = b.invoice ?? CooperativeInvoice.sampleInstitutionInvoice;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: CooperativeColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CooperativeColors.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.serviceName,
                        style: CooperativeTypography.labelLg.copyWith(
                          color: CooperativeColors.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${b.organizationName ?? 'Institution'} · #${b.id}',
                        style: CooperativeTypography.caption.copyWith(
                          color: CooperativeColors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: CooperativeColors.secondaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Paid · ₹${invoice.totalAmount.toInt()}',
                    style: CooperativeTypography.labelSm.copyWith(
                      color: CooperativeColors.onSecondaryContainer,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Shift & location lines
            Row(
              children: [
                const Icon(Icons.event_available_rounded, size: 14, color: CooperativeColors.onSurfaceVariant),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Shift completed · ${b.scheduledSlot}',
                    style: CooperativeTypography.caption.copyWith(
                      color: CooperativeColors.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.people_alt_outlined, size: 14, color: CooperativeColors.onSurfaceVariant),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '$totalStaff workers deployed across trades',
                    style: CooperativeTypography.caption.copyWith(
                      color: CooperativeColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      TaxInvoiceDialog.show(context, invoice: invoice);
                    },
                    icon: const Icon(Icons.receipt_long_rounded, size: 15),
                    label: const Text('Invoice'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: CooperativeColors.onSurface,
                      side: const BorderSide(color: CooperativeColors.outlineVariant),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: widget.onBookService,
                    icon: const Icon(Icons.repeat_rounded, size: 15),
                    label: const Text('Re-book'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CooperativeColors.primary,
                      foregroundColor: CooperativeColors.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedBookingCard(Booking b) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: CooperativeColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CooperativeColors.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookingDetailsScreen(booking: b),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Service name & Paid pill
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          b.serviceName,
                          style: CooperativeTypography.labelLg.copyWith(
                            color: CooperativeColors.onSurface,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '#${b.id} · Completed',
                          style: CooperativeTypography.caption.copyWith(
                            color: CooperativeColors.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: CooperativeColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Paid · ₹${b.invoice?.totalAmount.toInt() ?? 850}',
                      style: CooperativeTypography.labelSm.copyWith(
                        color: CooperativeColors.onSecondaryContainer,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1, thickness: 0.5, color: CooperativeColors.surfaceContainerHigh),
              const SizedBox(height: 10),

              // Worker Row
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      'assets/images/user_avatar.png',
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 32,
                        height: 32,
                        color: CooperativeColors.surfaceContainer,
                        child: const Icon(Icons.person, size: 18, color: CooperativeColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      b.worker.name,
                      style: CooperativeTypography.labelMd.copyWith(
                        color: CooperativeColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, size: 16, color: CooperativeColors.tertiary),
                      const SizedBox(width: 2),
                      Text(
                        b.rating > 0 ? '${b.rating}.0' : '5.0',
                        style: CooperativeTypography.caption.copyWith(
                          color: CooperativeColors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Date / Slot plain text
              Row(
                children: [
                  const Icon(Icons.event_available_rounded, size: 14, color: CooperativeColors.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      b.scheduledSlot,
                      style: CooperativeTypography.caption.copyWith(color: CooperativeColors.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Action row (Invoice + Book Again)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        TaxInvoiceDialog.show(context, invoice: b.invoice);
                      },
                      icon: const Icon(Icons.receipt_long_rounded, size: 15),
                      label: const Text('Invoice'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: CooperativeColors.onSurface,
                        side: const BorderSide(color: CooperativeColors.outlineVariant),
                        minimumSize: const Size.fromHeight(44),
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: widget.onBookService,
                      icon: const Icon(Icons.repeat_rounded, size: 15),
                      label: const Text('Book Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CooperativeColors.primary,
                        foregroundColor: CooperativeColors.onPrimary,
                        minimumSize: const Size.fromHeight(44),
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
      children: bookings
          .map((b) => b.isInstitutionBooking
              ? _buildInstitutionCancelledCard(b)
              : _buildCancelledBookingCard(b))
          .toList(),
    );
  }

  Widget _buildInstitutionCancelledCard(Booking b) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: CooperativeColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CooperativeColors.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.serviceName,
                        style: CooperativeTypography.labelLg.copyWith(
                          color: CooperativeColors.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '#${b.id} · Site: ${b.address.streetAddress.isNotEmpty ? b.address.fullAddress : 'Facility Site'}',
                        style: CooperativeTypography.caption.copyWith(color: CooperativeColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: CooperativeColors.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Cancelled',
                    style: CooperativeTypography.labelSm.copyWith(
                      color: CooperativeColors.error,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.info_outline, size: 14, color: CooperativeColors.error),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    b.cancellationReason ?? 'Cancelled per institution schedule update.',
                    style: CooperativeTypography.caption.copyWith(color: CooperativeColors.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: widget.onBookService,
                icon: const Icon(Icons.replay_rounded, size: 15),
                label: const Text('Re-book Workforce'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CooperativeColors.primary,
                  foregroundColor: CooperativeColors.onPrimary,
                  minimumSize: const Size.fromHeight(44),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelledBookingCard(Booking b) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: CooperativeColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CooperativeColors.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.serviceName,
                        style: CooperativeTypography.labelLg.copyWith(
                          color: CooperativeColors.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '#${b.id} · Scheduled: ${b.scheduledSlot}',
                        style: CooperativeTypography.caption.copyWith(color: CooperativeColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: CooperativeColors.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Cancelled',
                    style: CooperativeTypography.labelSm.copyWith(
                      color: CooperativeColors.error,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.info_outline, size: 14, color: CooperativeColors.error),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    b.cancellationReason ?? (b.activePreServiceUpdate.reason != null
                        ? 'Reason: ${b.activePreServiceUpdate.reason}'
                        : 'Cancelled under cooperative fair-work policy.'),
                    style: CooperativeTypography.caption.copyWith(color: CooperativeColors.onSurfaceVariant),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: widget.onBookService,
                icon: const Icon(Icons.replay_rounded, size: 15),
                label: const Text('Re-book Service'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CooperativeColors.primary,
                  foregroundColor: CooperativeColors.onPrimary,
                  minimumSize: const Size.fromHeight(44),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
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
