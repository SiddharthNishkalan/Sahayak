import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../app_view_model.dart';

class EmergencyServiceDialog extends StatelessWidget {
  final AppViewModel viewModel;

  const EmergencyServiceDialog({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: SahayakColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: SahayakColors.errorContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.bolt_rounded, color: SahayakColors.error, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Priority Emergency Dispatch',
                        style: SahayakTypography.headlineSm(color: SahayakColors.onSurface),
                      ),
                      Text(
                        'Local Ward Rapid Hub',
                        style: SahayakTypography.caption(color: SahayakColors.error).copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SahayakColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.timer_rounded, size: 16, color: SahayakColors.secondary),
                      const SizedBox(width: 8),
                      Text(
                        'Guaranteed arrival in < 20 minutes',
                        style: SahayakTypography.labelSm(color: SahayakColors.secondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.verified_user_rounded, size: 16, color: SahayakColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        '3 on-duty cooperative technicians alerted',
                        style: SahayakTypography.bodySm(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'For electrical sparks, burst water lines, gas valve repairs, or door lockouts. Direct municipal union dispatch with zero surge price markup.',
              style: SahayakTypography.bodySm(color: SahayakColors.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SahayakColors.primary,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🚨 Emergency alert broadcasted to 3 nearest technicians in Ward 5!'),
                          backgroundColor: SahayakColors.inverseSurface,
                        ),
                      );
                    },
                    child: const Text('Dispatch Now'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
