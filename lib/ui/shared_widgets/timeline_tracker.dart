import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../data/models/booking.dart';

class TimelineTracker extends StatelessWidget {
  final BookingStage currentStage;
  final int? estimatedArrivalMinutes;

  const TimelineTracker({
    super.key,
    required this.currentStage,
    this.estimatedArrivalMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final stages = [
      _StageInfo(
        stage: BookingStage.confirmed,
        title: 'Confirmed',
        subtitle: 'Booking accepted & worker Priya Sharma assigned',
        time: '1:42 PM',
        icon: Icons.check,
      ),
      _StageInfo(
        stage: BookingStage.workerOnTheWay,
        title: 'Worker On The Way',
        subtitle: estimatedArrivalMinutes != null
            ? 'Dispatched from Shivaji Nagar Hub • ETA $estimatedArrivalMinutes mins'
            : 'Dispatched from Shivaji Nagar Hub (Ward 5)',
        time: '2:02 PM',
        icon: Icons.near_me_rounded,
      ),
      _StageInfo(
        stage: BookingStage.jobInProgress,
        title: 'Job In Progress',
        subtitle: 'OTP 4829 verified at doorstep',
        time: '2:14 PM',
        icon: Icons.key_rounded,
      ),
      _StageInfo(
        stage: BookingStage.jobCompleted,
        title: 'Job Completed',
        subtitle: 'Seal tested & quality inspection approved',
        time: '2:56 PM',
        icon: Icons.done_all_rounded,
      ),
      _StageInfo(
        stage: BookingStage.paid,
        title: 'Paid',
        subtitle: 'Awaiting direct cooperative settlement',
        time: 'Pending',
        icon: Icons.payments_outlined,
      ),
    ];

    final activeIndex = stages.indexWhere((s) => s.stage == currentStage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Service Progress Tracker',
              style: SahayakTypography.headlineSm(),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: SahayakColors.secondaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Step ${activeIndex + 1} of 5',
                style: SahayakTypography.caption(color: SahayakColors.secondary).copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stages.length,
          itemBuilder: (context, index) {
            final stage = stages[index];
            final isPast = index < activeIndex;
            final isCurrent = index == activeIndex;
            final isLast = index == stages.length - 1;

            Color nodeColor;
            Color iconColor;
            if (isPast) {
              nodeColor = SahayakColors.secondary;
              iconColor = SahayakColors.onSecondary;
            } else if (isCurrent) {
              nodeColor = SahayakColors.primary;
              iconColor = SahayakColors.onPrimary;
            } else {
              nodeColor = SahayakColors.surfaceContainerHigh;
              iconColor = SahayakColors.onSurfaceVariant;
            }

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timeline Track & Node
                  SizedBox(
                    width: 28,
                    child: Column(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: nodeColor,
                            shape: BoxShape.circle,
                            border: isCurrent
                                ? Border.all(color: SahayakColors.primaryFixed, width: 3)
                                : null,
                          ),
                          child: Icon(stage.icon, size: 12, color: iconColor),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: isPast ? SahayakColors.secondary : SahayakColors.surfaceContainerHighest,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Content
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      stage.title,
                                      style: SahayakTypography.labelMd(
                                        color: isCurrent
                                            ? SahayakColors.primary
                                            : SahayakColors.onSurface,
                                      ).copyWith(
                                        fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                                      ),
                                    ),
                                    if (isCurrent && stage.stage == BookingStage.workerOnTheWay) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: SahayakColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  stage.subtitle,
                                  style: SahayakTypography.bodySm(color: SahayakColors.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            stage.time,
                            style: SahayakTypography.caption(
                              color: isCurrent
                                  ? SahayakColors.primary
                                  : SahayakColors.onSurfaceVariant,
                            ).copyWith(
                              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _StageInfo {
  final BookingStage stage;
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;

  _StageInfo({
    required this.stage,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
  });
}

typedef BookingTimelineTracker = TimelineTracker;

