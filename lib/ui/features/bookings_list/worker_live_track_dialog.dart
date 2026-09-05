import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../data/models/booking.dart';
import '../../shared_widgets/custom_vector_map.dart';
import '../../shared_widgets/trust_badges.dart';

class WorkerLiveTrackDialog extends StatelessWidget {
  final Booking booking;

  const WorkerLiveTrackDialog({
    super.key,
    required this.booking,
  });

  static Future<void> show(BuildContext context, {required Booking booking}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => WorkerLiveTrackDialog(booking: booking),
    );
  }

  @override
  Widget build(BuildContext context) {
    final b = booking;

    return Container(
      decoration: const BoxDecoration(
        color: CooperativeColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: CooperativeColors.outlineVariant.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: CooperativeColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/user_avatar.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(Icons.person, color: CooperativeColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              b.worker.name,
                              style: CooperativeTypography.labelLg.copyWith(
                                color: CooperativeColors.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const VerifiedShieldBadge(label: 'On Route'),
                          ],
                        ),
                        Text(
                          'Guild ID: ${b.worker.guildId}',
                          style: CooperativeTypography.caption.copyWith(
                            color: CooperativeColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: CooperativeColors.secondaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
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
                      const SizedBox(width: 6),
                      Text(
                        '~${b.minutesUntilArrival} mins',
                        style: CooperativeTypography.labelSm.copyWith(
                          color: CooperativeColors.secondary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Map Container
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CooperativeColors.outlineVariant.withValues(alpha: 0.5)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                CustomVectorMap(
                  locationLabel: b.address.fullAddress,
                  interactive: true,
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: CooperativeColors.surfaceContainerLowest.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.near_me, size: 14, color: CooperativeColors.primary),
                        const SizedBox(width: 5),
                        Text(
                          '${b.liveDistanceKm} km away',
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
          ),

          const SizedBox(height: 14),

          // Details note
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CooperativeColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.directions_bike, size: 20, color: CooperativeColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Traveling via Avinashi Road towards Shivaji Nagar Ward 5. Normal traffic conditions.',
                      style: CooperativeTypography.bodySm.copyWith(
                        color: CooperativeColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Calling ${b.worker.name}...')),
                      );
                    },
                    icon: const Icon(Icons.call, size: 18, color: CooperativeColors.primary),
                    label: const Text('Call Worker'),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: CooperativeColors.surfaceContainer,
                      foregroundColor: CooperativeColors.onSurface,
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sent landmark clarification to technician')),
                      );
                    },
                    icon: const Icon(Icons.pin_drop, size: 18),
                    label: const Text('Send Landmark'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CooperativeColors.primary,
                      foregroundColor: CooperativeColors.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
