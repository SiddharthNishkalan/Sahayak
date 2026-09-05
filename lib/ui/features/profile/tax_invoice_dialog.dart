import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../data/models/invoice.dart';

class TaxInvoiceDialog extends StatelessWidget {
  final CooperativeInvoice invoice;

  const TaxInvoiceDialog({
    super.key,
    required this.invoice,
  });

  static Future<void> show(BuildContext context, {CooperativeInvoice? invoice}) {
    return showDialog(
      context: context,
      builder: (ctx) => TaxInvoiceDialog(
        invoice: invoice ?? CooperativeInvoice.sampleInvoice,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: CooperativeColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.verified, color: CooperativeColors.secondary, size: 18),
                          const SizedBox(width: 5),
                          Text(
                            'Payment Receipt Confirmed',
                            style: CooperativeTypography.labelSm.copyWith(
                              color: CooperativeColors.secondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Cooperative Tax Invoice',
                        style: CooperativeTypography.headlineSm.copyWith(
                          color: CooperativeColors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: CooperativeColors.onSurfaceVariant),
                    style: IconButton.styleFrom(
                      backgroundColor: CooperativeColors.surfaceContainer,
                      minimumSize: const Size(36, 36),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Metadata card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: CooperativeColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    _buildMetaRow('Invoice Number:', invoice.invoiceNumber, isBold: true),
                    const SizedBox(height: 6),
                    _buildMetaRow('Date of Service:', invoice.date),
                    const SizedBox(height: 6),
                    _buildMetaRow('Co-op Reg Number:', invoice.coopRegNumber),
                    const SizedBox(height: 6),
                    _buildMetaRow('Service Technician:', '${invoice.technicianName} (${invoice.technicianId})'),
                    const SizedBox(height: 6),
                    _buildMetaRow('Settlement Mode:', invoice.paymentMethod),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Breakdown items
              Text(
                'ITEMIZED CHARGES',
                style: CooperativeTypography.caption.copyWith(
                  color: CooperativeColors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),

              _buildChargeRow('Standard Diagnostic & Inspection', '₹${invoice.diagnosticFee}'),
              const SizedBox(height: 6),
              _buildChargeRow('Certified Trade Labor (Tap & Pipe)', '₹${invoice.laborFee}'),
              const SizedBox(height: 6),
              _buildChargeRow('Materials (At Co-op Wholesale Cost)', '₹${invoice.materialsFee}'),

              const Divider(height: 24, thickness: 1, color: CooperativeColors.surfaceContainerHigh),

              // Total Amount
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CooperativeColors.primaryFixed.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Paid',
                          style: CooperativeTypography.labelLg.copyWith(
                            color: CooperativeColors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '100% to technician & welfare fund',
                          style: CooperativeTypography.caption.copyWith(
                            color: CooperativeColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '₹${invoice.totalAmount}',
                      style: CooperativeTypography.headlineLg.copyWith(
                        color: CooperativeColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Civic tax exemption note
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: CooperativeColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: CooperativeColors.outline),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Zero commission cooperative model. Exempt from commercial intermediary levy under Tamil Nadu Cooperative Societies Act 1983.',
                        style: CooperativeTypography.caption.copyWith(
                          color: CooperativeColors.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.picture_as_pdf, color: CooperativeColors.secondaryContainer, size: 18),
                                const SizedBox(width: 8),
                                Text('Downloaded ${invoice.invoiceNumber}.pdf',
                                    style: CooperativeTypography.bodySm.copyWith(color: CooperativeColors.onPrimary)),
                              ],
                            ),
                            backgroundColor: CooperativeColors.inverseSurface,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      },
                      icon: const Icon(Icons.download, size: 18, color: CooperativeColors.primary),
                      label: const Text('Download PDF'),
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
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.email, color: CooperativeColors.secondaryContainer, size: 18),
                                const SizedBox(width: 8),
                                Text('Invoice sent to registered member email',
                                    style: CooperativeTypography.bodySm.copyWith(color: CooperativeColors.onPrimary)),
                              ],
                            ),
                            backgroundColor: CooperativeColors.primary,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      },
                      icon: const Icon(Icons.send, size: 18),
                      label: const Text('Email Invoice'),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: CooperativeTypography.bodySm.copyWith(color: CooperativeColors.onSurfaceVariant),
        ),
        Text(
          value,
          style: CooperativeTypography.bodySm.copyWith(
            color: CooperativeColors.onSurface,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildChargeRow(String label, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: CooperativeTypography.bodySm.copyWith(color: CooperativeColors.onSurface),
        ),
        Text(
          amount,
          style: CooperativeTypography.labelMd.copyWith(
            color: CooperativeColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
