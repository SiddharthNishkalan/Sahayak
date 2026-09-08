import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../app_view_model.dart';

class EmergencyServiceDialog extends StatelessWidget {
  final AppViewModel viewModel;

  const EmergencyServiceDialog({
    super.key,
    required this.viewModel,
  });

  static Future<void> show(BuildContext context, {required AppViewModel viewModel}) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: SahayakColors.surfaceContainerLowest,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => EmergencyServiceDialog(viewModel: viewModel),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: SahayakColors.errorContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.bolt_rounded, color: SahayakColors.error, size: 26),
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
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: SahayakColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.timer_rounded, size: 18, color: SahayakColors.secondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Guaranteed arrival in < 20 minutes',
                            style: SahayakTypography.labelSm(color: SahayakColors.secondary).copyWith(fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.verified_user_rounded, size: 18, color: SahayakColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '3 on-duty cooperative technicians alerted',
                            style: SahayakTypography.bodySm(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
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
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SahayakColors.error,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        HapticFeedback.heavyImpact();
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
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    ),
  );
}
}
