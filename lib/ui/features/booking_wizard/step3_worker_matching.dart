import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../data/models/service.dart';
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
  final Map<String, bool> _expandedCerts = {};

  @override
  void initState() {
    super.initState();
    if (widget.viewModel.availableOffers.isEmpty) {
      widget.viewModel.broadcastJobRequest();
    }
  }

  void _confirmBooking() {
    final booking = widget.viewModel.confirmAndCreateBooking();
    Navigator.push(
      context,
      MaterialPageRoute(
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
              child: Text(
                'Worker Acceptance & Bids',
                style: SahayakTypography.headlineSm(),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Worker Acceptance Offers',
                                style: SahayakTypography.headlineSm(),
                                overflow: TextOverflow.ellipsis,
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
                                '${offers.length} Responses',
                                style: SahayakTypography.caption(color: SahayakColors.secondary).copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Nearest society workers have reviewed your request and submitted acceptance bids. Compare by rating, visit fee, certifications, and customer reviews.',
                          style: SahayakTypography.bodySm(),
                        ),
                        const SizedBox(height: 12),

                        // Comparison Sort Bar using SingleChildScrollView to prevent overflow
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Text('Compare:', style: SahayakTypography.labelSm()),
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
                              final showCerts = _expandedCerts[worker.id] ?? false;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: SahayakColors.surfaceContainerLowest,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected ? SahayakColors.primary : SahayakColors.borderSubtle,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.03),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: InkWell(
                                  onTap: () => widget.viewModel.selectOffer(offer),
                                  borderRadius: BorderRadius.circular(16),
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
                                              width: 46,
                                              height: 46,
                                              decoration: BoxDecoration(
                                                color: SahayakColors.primaryFixed,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              clipBehavior: Clip.antiAlias,
                                              child: Image.network(
                                                worker.avatarUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, _, _) => Center(
                                                  child: const Icon(Icons.person, color: SahayakColors.primary),
                                                ),
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
                                                          style: SahayakTypography.labelLg(),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      const Icon(Icons.verified_rounded, size: 14, color: SahayakColors.secondary),
                                                    ],
                                                  ),
                                                  Text(worker.trade, style: SahayakTypography.bodySm()),
                                                  Row(
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                          '${worker.society} · ${worker.distanceKm} km',
                                                          style: SahayakTypography.caption(color: SahayakColors.onSurfaceVariant),
                                                          overflow: TextOverflow.ellipsis,
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
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: SahayakColors.surfaceContainerLow,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.mark_chat_read_outlined, size: 14, color: SahayakColors.primary),
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
                                                        Text('${worker.rating}', style: SahayakTypography.labelSm().copyWith(fontWeight: FontWeight.w800)),
                                                        const SizedBox(width: 4),
                                                        Text('(${worker.completedJobs})', style: SahayakTypography.caption()),
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
                                                    Text('Quoted Visit Fee', style: SahayakTypography.caption()),
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

                                        // Certifications Expandable Pill
                                        const SizedBox(height: 8),
                                        InkWell(
                                          onTap: () => setState(() {
                                            _expandedCerts[worker.id] = !showCerts;
                                          }),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.verified_outlined, size: 14, color: SahayakColors.secondary),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${worker.certifications.length} Verified Certifications',
                                                style: SahayakTypography.caption(color: SahayakColors.secondary).copyWith(fontWeight: FontWeight.w700),
                                              ),
                                              const Spacer(),
                                              Icon(showCerts ? Icons.expand_less : Icons.expand_more, size: 16, color: SahayakColors.secondary),
                                            ],
                                          ),
                                        ),
                                        if (showCerts) ...[
                                          const SizedBox(height: 4),
                                          Wrap(
                                            spacing: 4,
                                            runSpacing: 4,
                                            children: worker.certifications.map((c) {
                                              return Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: SahayakColors.secondaryFixed.withValues(alpha: 0.3),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(c, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                                              );
                                            }).toList(),
                                          ),
                                        ],

                                        // Reviews Expandable Pill
                                        const SizedBox(height: 6),
                                        InkWell(
                                          onTap: () => setState(() {
                                            _expandedReviews[worker.id] = !showReviews;
                                          }),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.reviews_outlined, size: 14, color: SahayakColors.primary),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Customer Reviews (${worker.recentReviews.length})',
                                                style: SahayakTypography.caption(color: SahayakColors.primary).copyWith(fontWeight: FontWeight.w700),
                                              ),
                                              const Spacer(),
                                              Icon(showReviews ? Icons.expand_less : Icons.expand_more, size: 16, color: SahayakColors.primary),
                                            ],
                                          ),
                                        ),
                                        if (showReviews) ...[
                                          const SizedBox(height: 6),
                                          Column(
                                            children: worker.recentReviews.map((r) {
                                              return Container(
                                                margin: const EdgeInsets.only(bottom: 4),
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: SahayakColors.surfaceContainer,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(r.authorName, style: SahayakTypography.labelSm()),
                                                        Row(
                                                          children: [
                                                            const Icon(Icons.star, size: 12, color: SahayakColors.tertiary),
                                                            Text('${r.rating}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text('"${r.comment}"', style: SahayakTypography.caption()),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ],
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
                    decoration: const BoxDecoration(
                      color: SahayakColors.surfaceContainerLowest,
                      border: Border(top: BorderSide(color: SahayakColors.borderSubtle)),
                    ),
                    child: Column(
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
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Visit Fee: ₹${selectedOffer.quotedVisitFee.toInt()} · Est. Total: ₹${selectedOffer.estimatedTotalFee.toInt()}',
                                    style: SahayakTypography.caption(color: SahayakColors.primary).copyWith(fontWeight: FontWeight.w700),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Doorstep OTP on confirm',
                              style: SahayakTypography.caption(color: SahayakColors.secondary).copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _confirmBooking,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  'Accept & Confirm Booking with ${selectedOffer.worker.name.split(" ")[0]}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.check_circle_outline_rounded, size: 18),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSortChip({required String label, required String key, required String activeKey}) {
    final isSelected = key == activeKey;
    return InkWell(
      onTap: () => widget.viewModel.sortOffers(key),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? SahayakColors.primary : SahayakColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : SahayakColors.onSurface,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
