import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    HapticFeedback.lightImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: CooperativeColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => TaxInvoiceDialog(
        invoice: invoice ?? CooperativeInvoice.sampleInvoice,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.verified_rounded, color: CooperativeColors.secondary, size: 18),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                'Payment Receipt Confirmed',
                                style: CooperativeTypography.labelSm.copyWith(
                                  color: CooperativeColors.secondary,
                                  fontWeight: FontWeight.w700,
                                ),
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
                    if (invoice.isInstitutionInvoice && invoice.organizationName != null) ...[
                      const SizedBox(height: 6),
                      _buildMetaRow('Billed Entity:', invoice.organizationName!),
                    ],
                    if (invoice.isInstitutionInvoice && invoice.siteName != null) ...[
                      const SizedBox(height: 6),
                      _buildMetaRow('Facility Site:', invoice.siteName!),
                    ],
                    const SizedBox(height: 6),
                    _buildMetaRow(
                      invoice.isInstitutionInvoice ? 'Allocation Guild:' : 'Service Technician:',
                      invoice.isInstitutionInvoice
                          ? invoice.technicianName
                          : '${invoice.technicianName} (${invoice.technicianId})',
                    ),
                    const SizedBox(height: 6),
                    _buildMetaRow('Settlement Mode:', invoice.paymentMethod),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Breakdown items
              Text(
                invoice.isInstitutionInvoice ? 'CONSOLIDATED WORKFORCE CHARGES' : 'ITEMIZED CHARGES',
                style: CooperativeTypography.caption.copyWith(
                  color: CooperativeColors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),

              if (invoice.isInstitutionInvoice && invoice.lineItems.isNotEmpty) ...[
                ...invoice.lineItems.map((item) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: CooperativeColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: CooperativeColors.surfaceContainerHigh, width: 0.8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${item.workerCount}x ${item.domainTitle}',
                              style: CooperativeTypography.labelMd.copyWith(
                                fontWeight: FontWeight.w700,
                                color: CooperativeColors.onSurface,
                              ),
                            ),
                            Text(
                              '₹${item.effectiveTotalAmount}',
                              style: CooperativeTypography.labelMd.copyWith(
                                fontWeight: FontWeight.w700,
                                color: CooperativeColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        _buildSubChargeRow('• Visit & Diagnostic Fee', '₹${item.diagnosticFee}'),
                        _buildSubChargeRow('• Trade Labor (${item.workerCount}x @ ₹${item.ratePerWorker})', '₹${item.laborFee}'),
                        if (item.materialsFee > 0)
                          _buildSubChargeRow('• Materials (0% platform fee)', '₹${item.materialsFee}'),
                        _buildSubChargeRow(
                          '• Platform Fee (18% on Visit only)',
                          '₹${item.platformFee}',
                          highlight: true,
                        ),
                      ],
                    ),
                  );
                }),
                if (invoice.materialsFee > 0 && invoice.lineItems.every((i) => i.materialsFee == 0))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: _buildChargeRow('Additional Materials (0% platform fee)', '₹${invoice.materialsFee}'),
                  ),
              ] else if (invoice.isInstitutionInvoice) ...[
                _buildChargeRow('Visit & Diagnostic Fee', '₹${invoice.diagnosticFee}'),
                const SizedBox(height: 6),
                _buildChargeRow('Trade Labor Cost', '₹${invoice.laborFee}'),
                const SizedBox(height: 6),
                _buildChargeRow('Material Cost (0% platform fee)', '₹${invoice.materialsFee}'),
                const SizedBox(height: 6),
                _buildChargeRow('Platform Fee (18% on Visit/Diagnostic)', '₹${invoice.effectivePlatformFee}', isFee: true),
              ] else ...[
                _buildChargeRow('Standard Diagnostic & Inspection', '₹${invoice.diagnosticFee}'),
                const SizedBox(height: 6),
                _buildChargeRow('Certified Trade Labor', '₹${invoice.laborFee}'),
                if (invoice.materialsFee > 0) ...[
                  const SizedBox(height: 6),
                  _buildChargeRow('Materials (At Co-op Wholesale Cost)', '₹${invoice.materialsFee}'),
                ],
                const SizedBox(height: 6),
                _buildChargeRow('Platform Fee (10% on Visit/Diagnostic)', '₹${invoice.effectivePlatformFee}', isFee: true),
              ],

              const Divider(height: 20, thickness: 1, color: CooperativeColors.surfaceContainerHigh),

              // Total Amount
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CooperativeColors.primaryFixed.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(14),
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
                                'Total Paid',
                                style: CooperativeTypography.labelLg.copyWith(
                                  color: CooperativeColors.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Complete settlement split breakdown',
                                style: CooperativeTypography.caption.copyWith(
                                  color: CooperativeColors.secondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '₹${invoice.totalAmount}',
                          style: CooperativeTypography.headlineSm.copyWith(
                            color: CooperativeColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: CooperativeColors.surfaceContainerLowest.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Direct Worker Payout (100% of service):',
                              style: CooperativeTypography.caption.copyWith(
                                color: CooperativeColors.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            '₹${invoice.workerPayout}',
                            style: CooperativeTypography.caption.copyWith(
                              color: CooperativeColors.secondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: CooperativeColors.surfaceContainerLowest.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Cooperative Platform & Welfare Share:',
                              style: CooperativeTypography.caption.copyWith(
                                color: CooperativeColors.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            '₹${invoice.cooperativePlatformShare}',
                            style: CooperativeTypography.caption.copyWith(
                              color: CooperativeColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
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
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 16, color: CooperativeColors.outline),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        invoice.isInstitutionInvoice
                            ? 'Institutional services bill 18% platform fee strictly on visit/diagnostic fee. Labor and materials are passed through at 100% direct value.'
                            : 'Zero commission cooperative model. 10% platform fee applies strictly to diagnostic inspection. Labor and materials pass through 100% directly to workers.',
                        style: CooperativeTypography.caption.copyWith(
                          color: CooperativeColors.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Action Buttons (Compact, standard 44px touch target)
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.picture_as_pdf_rounded, color: CooperativeColors.secondaryContainer, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Downloaded ${invoice.invoiceNumber}.pdf',
                                      style: CooperativeTypography.bodySm.copyWith(color: CooperativeColors.onPrimary),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: CooperativeColors.inverseSurface,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                        icon: const Icon(Icons.download_rounded, size: 16, color: CooperativeColors.primary),
                        label: Text(
                          'Download PDF',
                          style: CooperativeTypography.labelMd.copyWith(
                            color: CooperativeColors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          backgroundColor: CooperativeColors.surfaceContainer,
                          foregroundColor: CooperativeColors.onSurface,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.email_rounded, color: CooperativeColors.secondaryContainer, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Invoice sent to registered email',
                                      style: CooperativeTypography.bodySm.copyWith(color: CooperativeColors.onPrimary),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: CooperativeColors.primary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                        icon: const Icon(Icons.send_rounded, size: 16),
                        label: Text(
                          'Email Invoice',
                          style: CooperativeTypography.labelMd.copyWith(
                            color: CooperativeColors.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          backgroundColor: CooperativeColors.primary,
                          foregroundColor: CooperativeColors.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: CooperativeTypography.bodySm.copyWith(color: CooperativeColors.onSurfaceVariant),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 6,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: CooperativeTypography.bodySm.copyWith(
              color: CooperativeColors.onSurface,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChargeRow(String label, String amount, {bool isFee = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: CooperativeTypography.bodySm.copyWith(
              color: isFee ? CooperativeColors.primary : CooperativeColors.onSurface,
              fontWeight: isFee ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            amount,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: CooperativeTypography.labelMd.copyWith(
              color: isFee ? CooperativeColors.primary : CooperativeColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubChargeRow(String label, String amount, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: CooperativeTypography.caption.copyWith(
                color: highlight ? CooperativeColors.primary : CooperativeColors.onSurfaceVariant,
                fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            amount,
            textAlign: TextAlign.end,
            style: CooperativeTypography.caption.copyWith(
              color: highlight ? CooperativeColors.primary : CooperativeColors.onSurface,
              fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
