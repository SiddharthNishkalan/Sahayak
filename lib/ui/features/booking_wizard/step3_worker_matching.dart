import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../data/models/service.dart';
import '../../../data/models/worker.dart';
import '../../../app_view_model.dart';
import '../booking_status/booking_confirmation_screen.dart';

class Step3WorkerMatchingScreen extends StatefulWidget {
  final AppViewModel viewModel;
  final ServiceItem service;

  const Step3WorkerMatchingScreen({
    super.key,
    required this.viewModel,
    required this.service,
  });

  @override
  State<Step3WorkerMatchingScreen> createState() => _Step3WorkerMatchingScreenState();
}

class _Step3WorkerMatchingScreenState extends State<Step3WorkerMatchingScreen> {
  final Map<String, bool> _expandedReviews = {};
  final Map<String, bool> _expandedWhyWorker = {};

  @override
  void initState() {
    super.initState();
    if (widget.viewModel.availableOffers.isEmpty) {
      widget.viewModel.broadcastJobRequest();
    }
  }

  void _confirmBooking() {
    HapticFeedback.mediumImpact();
    final booking = widget.viewModel.confirmAndCreateBooking();
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => BookingConfirmationScreen(
          viewModel: widget.viewModel,
          booking: booking,
          onNavigateToBookings: () {
            widget.viewModel.switchTab(ShellTab.bookings);
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          onBookAnother: () {
            widget.viewModel.switchTab(ShellTab.home);
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final offers = widget.viewModel.availableOffers;
    final selectedOffer = widget.viewModel.selectedOffer ?? (offers.isNotEmpty ? offers.first : null);
    final sortBy = widget.viewModel.offerSortBy;

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
          'Worker Bids & Acceptance',
          style: SahayakTypography.titleMedium().copyWith(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'Available Technician Offers',
                                style: SahayakTypography.headlineSm(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: SahayakColors.secondaryContainer,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '${offers.length} Cooperative Responses',
                                style: SahayakTypography.caption(color: SahayakColors.onSecondaryContainer)
                                    .copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Verified society workers in your area have submitted bids. Compare ratings, visit fees, verified reviews, and proximity.',
                          style: SahayakTypography.bodySm(),
                        ),
                        const SizedBox(height: 12),

                        // Comparison Sort Bar
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Text('Sort By:', style: SahayakTypography.labelSm()),
                              const SizedBox(width: 8),
                              _buildSortChip(label: '⭐ Rating', key: 'rating', activeKey: sortBy),
                              const SizedBox(width: 6),
                              _buildSortChip(label: '💰 Lowest Fee', key: 'fee', activeKey: sortBy),
                              const SizedBox(width: 6),
                              _buildSortChip(label: '📍 Distance', key: 'distance', activeKey: sortBy),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Workers Offer List
                        if (offers.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  const CircularProgressIndicator(),
                                  const SizedBox(height: 12),
                                  Text('Broadcasting request to nearby workers...', style: SahayakTypography.bodySm()),
                                ],
                              ),
                            ),
                          )
                        else
                          Column(
                            children: offers.map((offer) {
                              final worker = offer.worker;
                              final isSelected = selectedOffer?.id == offer.id;
                              final showReviews = _expandedReviews[worker.id] ?? false;
                              final showWhy = _expandedWhyWorker[worker.id] ?? false;

                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                                margin: const EdgeInsets.only(bottom: 14),
                                decoration: BoxDecoration(
                                  color: SahayakColors.surfaceContainerLowest,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected ? SahayakColors.primary : SahayakColors.borderSubtle,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isSelected
                                          ? SahayakColors.primary.withValues(alpha: 0.08)
                                          : SahayakColors.onSurface.withValues(alpha: 0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: InkWell(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    widget.viewModel.selectOffer(offer);
                                  },
                                  borderRadius: BorderRadius.circular(14),
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Header Row: Avatar, Name & Trade, Select Radio
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 48,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                color: SahayakColors.primaryFixed,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              clipBehavior: Clip.antiAlias,
                                              child: Image.network(
                                                worker.avatarUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, _, _) => const Center(
                                                  child: Icon(Icons.person, color: SahayakColors.primary),
                                                ),
                                              ),
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
                                                          worker.name,
                                                          style: SahayakTypography.labelLg().copyWith(fontWeight: FontWeight.w700),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      const Icon(Icons.verified_rounded, size: 16, color: SahayakColors.secondary),
                                                    ],
                                                  ),
                                                  Text(worker.trade, style: SahayakTypography.bodySm()),
                                                  Row(
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                          '${worker.society} · ${worker.distanceKm} km away',
                                                          style: SahayakTypography.caption(color: SahayakColors.onSurfaceVariant),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Icon(
                                              isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                                              color: isSelected ? SahayakColors.primary : SahayakColors.outline,
                                              size: 22,
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 10),

                                        // Worker Offer Note
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: SahayakColors.surfaceContainerLow,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.chat_bubble_outline_rounded, size: 14, color: SahayakColors.primary),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  offer.note,
                                                  style: SahayakTypography.caption().copyWith(fontWeight: FontWeight.w600),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(height: 10),

                                        // Comparison Metrics: Rating, Fee, Arrival ETA
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: SahayakColors.surfaceContainer,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('Rating & Jobs', style: SahayakTypography.caption()),
                                                    Row(
                                                      children: [
                                                        const Icon(Icons.star_rounded, size: 14, color: SahayakColors.tertiary),
                                                        const SizedBox(width: 2),
                                                        Text('${worker.rating}',
                                                            style: SahayakTypography.labelSm().copyWith(fontWeight: FontWeight.w800)),
                                                        const SizedBox(width: 2),
                                                        Flexible(
                                                          child: Text(
                                                            '(${worker.completedJobs})',
                                                            style: SahayakTypography.caption(),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: SahayakColors.surfaceContainer,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('Visit Fee', style: SahayakTypography.caption()),
                                                    Text(
                                                      '₹${offer.quotedVisitFee.toInt()}',
                                                      style: SahayakTypography.labelSm().copyWith(
                                                        fontWeight: FontWeight.w800,
                                                        color: SahayakColors.primary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: SahayakColors.surfaceContainer,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('Arrival ETA', style: SahayakTypography.caption()),
                                                    Text(
                                                      '~${offer.estimatedArrivalMinutes} mins',
                                                      style: SahayakTypography.labelSm().copyWith(fontWeight: FontWeight.w700),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 10),

                                        // "Why This Worker" Trust Pill
                                        InkWell(
                                          onTap: () => setState(() {
                                            _expandedWhyWorker[worker.id] = !showWhy;
                                          }),
                                          borderRadius: BorderRadius.circular(6),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.shield_outlined, size: 14, color: SahayakColors.secondary),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    'Why this worker? Verified Co-op Credentials',
                                                    style: SahayakTypography.caption(color: SahayakColors.secondary)
                                                        .copyWith(fontWeight: FontWeight.w700),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Icon(
                                                  showWhy ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                                  size: 16,
                                                  color: SahayakColors.secondary,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        AnimatedCrossFade(
                                          firstChild: const SizedBox(width: double.infinity, height: 0),
                                          secondChild: Padding(
                                            padding: const EdgeInsets.only(top: 6),
                                            child: _buildWhyWorkerPanel(worker, offer),
                                          ),
                                          crossFadeState: showWhy ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                          duration: const Duration(milliseconds: 200),
                                        ),

                                        // Ratings & Reviews Section with Star-Bar Breakdown
                                        const SizedBox(height: 6),
                                        InkWell(
                                          onTap: () => setState(() {
                                            _expandedReviews[worker.id] = !showReviews;
                                          }),
                                          borderRadius: BorderRadius.circular(6),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.rate_review_outlined, size: 14, color: SahayakColors.primary),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    'Customer Reviews & Rating Breakdown (${worker.recentReviews.length})',
                                                    style: SahayakTypography.caption(color: SahayakColors.primary)
                                                        .copyWith(fontWeight: FontWeight.w700),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Icon(
                                                  showReviews ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                                  size: 16,
                                                  color: SahayakColors.primary,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        AnimatedCrossFade(
                                          firstChild: const SizedBox(width: double.infinity, height: 0),
                                          secondChild: Padding(
                                            padding: const EdgeInsets.only(top: 8),
                                            child: _buildRatingSummaryAndReviews(worker),
                                          ),
                                          crossFadeState: showReviews ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                          duration: const Duration(milliseconds: 200),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Sticky Bottom Action Bar
                if (selectedOffer != null)
                  Container(
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
                    child: SafeArea(
                      top: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Selected: ${selectedOffer.worker.name}',
                                      style: SahayakTypography.labelMd(),
                                    ),
                                    Text(
                                      'Visit Fee: ₹${selectedOffer.quotedVisitFee.toInt()} · Doorstep OTP on confirm',
                                      style: SahayakTypography.caption(color: SahayakColors.primary).copyWith(fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: SahayakColors.secondaryFixed,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Worker Quoted',
                                  style: SahayakTypography.caption(color: SahayakColors.onSecondaryFixed)
                                      .copyWith(fontWeight: FontWeight.w800, fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _confirmBooking,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Confirm Booking with ${selectedOffer.worker.name.split(" ")[0]}',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.check_circle_outline_rounded, size: 18),
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

  // "Why This Worker" Trust Panel
  Widget _buildWhyWorkerPanel(Worker worker, dynamic offer) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SahayakColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: SahayakColors.secondary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTrustPoint(Icons.badge_outlined, 'Co-op ID: SAH-WRK-${worker.id.toUpperCase()} (Guild Certified)'),
          _buildTrustPoint(Icons.security_rounded, 'Police verified resident & certified ${worker.trade}'),
          _buildTrustPoint(Icons.location_on_outlined, 'Stationed at ${worker.society} (${worker.distanceKm} km response perimeter)'),
          _buildTrustPoint(Icons.history_rounded, '${worker.completedJobs}+ jobs fulfilled with 99.4% on-time record'),
          if (worker.certifications.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: worker.certifications.map((c) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: SahayakColors.secondaryFixed.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(c, style: SahayakTypography.caption().copyWith(fontSize: 10, fontWeight: FontWeight.w600)),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTrustPoint(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: SahayakColors.secondary),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: SahayakTypography.caption())),
        ],
      ),
    );
  }

  // Big Rating Summary & 5-Star Breakdown + Individual Review Cards
  Widget _buildRatingSummaryAndReviews(Worker worker) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SahayakColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating Summary Row
          Row(
            children: [
              // Big Numerical Rating
              Column(
                children: [
                  Text(
                    '${worker.rating}',
                    style: SahayakTypography.displayHeroMobile(color: SahayakColors.primary).copyWith(fontSize: 32),
                  ),
                  Row(
                    children: List.generate(
                      5,
                      (i) => const Icon(Icons.star_rounded, size: 14, color: SahayakColors.tertiary),
                    ),
                  ),
                  Text('${worker.completedJobs} Ratings', style: SahayakTypography.caption()),
                ],
              ),
              const SizedBox(width: 16),
              // Per-Star Bar Breakdown
              Expanded(
                child: Column(
                  children: [
                    _buildStarBar(5, 0.88),
                    _buildStarBar(4, 0.09),
                    _buildStarBar(3, 0.02),
                    _buildStarBar(2, 0.01),
                    _buildStarBar(1, 0.00),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(color: SahayakColors.borderSubtle, height: 1),
          const SizedBox(height: 10),

          // Individual Customer Review Cards (Reference Pattern)
          Text('Recent Resident Reviews', style: SahayakTypography.labelSm().copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...worker.recentReviews.map((review) {
            final initial = review.authorName.isNotEmpty ? review.authorName[0].toUpperCase() : 'C';
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: SahayakColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: SahayakColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: SahayakColors.primaryFixed,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initial,
                          style: SahayakTypography.caption(color: SahayakColors.primary).copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review.authorName,
                              style: SahayakTypography.labelSm().copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text('Verified Resident · 2 days ago', style: SahayakTypography.caption().copyWith(fontSize: 10)),
                          ],
                        ),
                      ),
                      Row(
                        children: List.generate(
                          review.rating.round(),
                          (i) => const Icon(Icons.star_rounded, size: 12, color: SahayakColors.tertiary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('"${review.comment}"', style: SahayakTypography.caption()),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStarBar(int stars, double pct) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        children: [
          Text('$stars ★', style: SahayakTypography.caption().copyWith(fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 5,
                backgroundColor: SahayakColors.surfaceContainerHighest,
                valueColor: const AlwaysStoppedAnimation<Color>(SahayakColors.tertiary),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text('${(pct * 100).toInt()}%', style: SahayakTypography.caption().copyWith(fontSize: 9)),
        ],
      ),
    );
  }

  Widget _buildSortChip({required String label, required String key, required String activeKey}) {
    final isSelected = key == activeKey;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.viewModel.sortOffers(key);
      },
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? SahayakColors.primary : SahayakColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: SahayakTypography.caption(
            color: isSelected ? Colors.white : SahayakColors.onSurface,
          ).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
