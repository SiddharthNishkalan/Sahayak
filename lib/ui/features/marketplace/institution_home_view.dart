import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../data/models/booking.dart';
import '../../../app_view_model.dart';
import '../booking_status/institution_allocation_status_screen.dart';
import '../booking_wizard/institution_request_step1.dart';

class InstitutionHomeView extends StatefulWidget {
  final AppViewModel viewModel;

  const InstitutionHomeView({
    super.key,
    required this.viewModel,
  });

  @override
  State<InstitutionHomeView> createState() => _InstitutionHomeViewState();
}

class _InstitutionHomeViewState extends State<InstitutionHomeView> {
  bool _showMultiTradeIntro = true;

  void _openWorkforceRequestWizard(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => InstitutionRequestStep1Screen(
          viewModel: widget.viewModel,
        ),
      ),
    );
  }

  void _openAllocationStatus(BuildContext context, Booking booking) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => InstitutionAllocationStatusScreen(
          viewModel: widget.viewModel,
          booking: booking,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.viewModel.currentUser;
    final orgName = user?.organizationName ?? user?.name ?? 'Institution Partner';
    final siteName = user?.siteAddress ?? 'Main Facility Campus';
    final activeRequests = widget.viewModel.repository.activeInstitutionBookings;

    return RefreshIndicator(
      onRefresh: () async {
        HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 500));
      },
      color: SahayakColors.secondary,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              // Institution Header Profile Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SahayakColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: SahayakColors.borderSubtle),
                  boxShadow: [
                    BoxShadow(
                      color: SahayakColors.onSurface.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: SahayakColors.secondaryFixed.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: SahayakColors.secondaryFixed),
                      ),
                      child: const Icon(
                        Icons.business_rounded,
                        color: SahayakColors.secondary,
                        size: 26,
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
                                  orgName,
                                  style: SahayakTypography.headlineSm(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: SahayakColors.secondaryContainer.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'INSTITUTION',
                                  style: SahayakTypography.caption(color: SahayakColors.secondary).copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 9,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded, size: 12, color: SahayakColors.outline),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  siteName,
                                  style: SahayakTypography.caption(color: SahayakColors.onSurfaceVariant),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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

              // Dismissible Multi-Trade Introductory Awareness Card
              if (_showMultiTradeIntro) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: SahayakColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: SahayakColors.secondary.withValues(alpha: 0.5), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: SahayakColors.secondary.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: SahayakColors.secondaryFixed,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.hub_rounded, color: SahayakColors.onSecondaryFixed, size: 18),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Multi-Trade Capabilities',
                                style: SahayakTypography.labelLg().copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: SahayakColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              setState(() => _showMultiTradeIntro = false);
                            },
                            icon: const Icon(Icons.close_rounded, size: 18, color: SahayakColors.onSurfaceVariant),
                            tooltip: 'Dismiss awareness card',
                            style: IconButton.styleFrom(
                              backgroundColor: SahayakColors.surfaceContainerLow,
                              minimumSize: const Size(36, 36),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Multi-trade: combine multiple services like electrical, cleaning, and plumbing into a single request with domain coordinators, zero-commission verified workers, and transparent 18% diagnostic fee platform billing.',
                        style: SahayakTypography.bodySm(color: SahayakColors.onSurfaceVariant).copyWith(height: 1.35),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              setState(() => _showMultiTradeIntro = false);
                            },
                            child: Text(
                              'Got it',
                              style: SahayakTypography.caption(color: SahayakColors.outline).copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              _openWorkforceRequestWizard(context);
                            },
                            icon: const Icon(Icons.hub_rounded, size: 16),
                            label: const Text('Configure Multi-Trade'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: SahayakColors.secondary,
                              foregroundColor: SahayakColors.onSecondary,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              // 1. PRIMARY PROMINENT ACTION CARD: Request Workforce
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF0F3E2E),
                      Color(0xFF1B5E45),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1B5E45).withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      _openWorkforceRequestWizard(context);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.hub_rounded, size: 14, color: Color(0xFF86EFAC)),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          'MULTI-TRADE WORKFORCE',
                                          style: SahayakTypography.caption(color: const Color(0xFF86EFAC)).copyWith(
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.8,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Request Workforce',
                            style: SahayakTypography.headlineMd(color: Colors.white).copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Deploy verified cooperative electricians, cleaners, plumbers, and technicians across multiple trades for your facility.',
                            style: SahayakTypography.bodySm(color: Colors.white.withValues(alpha: 0.85)),
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                _openWorkforceRequestWizard(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF86EFAC),
                                foregroundColor: const Color(0xFF0F3E2E),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.add_task_rounded, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Create Workforce Request',
                                    style: SahayakTypography.labelMd(color: const Color(0xFF0F3E2E)).copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 2. SECONDARY SUMMARY CARD: Active Requests at a Glance
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Requests',
                    style: SahayakTypography.labelLg().copyWith(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    '${activeRequests.length} in progress',
                    style: SahayakTypography.caption(color: SahayakColors.secondary).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (activeRequests.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: SahayakColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: SahayakColors.borderSubtle),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.assignment_turned_in_outlined, size: 36, color: SahayakColors.outline),
                      const SizedBox(height: 8),
                      Text(
                        'No active workforce requests',
                        style: SahayakTypography.labelMd(),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap "Request Workforce" above to schedule cooperative teams.',
                        style: SahayakTypography.caption(),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ...activeRequests.map((req) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: SahayakColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: SahayakColors.borderSubtle),
                      boxShadow: [
                        BoxShadow(
                          color: SahayakColors.onSurface.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _openAllocationStatus(context, req);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: SahayakColors.primaryFixed,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      req.id,
                                      style: SahayakTypography.caption(color: SahayakColors.primary).copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: req.isFullyAllocated
                                            ? SahayakColors.secondaryFixed.withValues(alpha: 0.4)
                                            : SahayakColors.primaryFixed.withValues(alpha: 0.4),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            req.isFullyAllocated
                                                ? Icons.check_circle_rounded
                                                : Icons.sync_rounded,
                                            size: 13,
                                            color: req.isFullyAllocated
                                                ? SahayakColors.secondary
                                                : SahayakColors.primary,
                                          ),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              '${req.totalWorkersAllocated}/${req.totalWorkersRequested} Confirmed',
                                              style: SahayakTypography.caption(
                                                color: req.isFullyAllocated
                                                    ? SahayakColors.secondary
                                                    : SahayakColors.primary,
                                              ).copyWith(fontWeight: FontWeight.w700),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                req.serviceName,
                                style: SahayakTypography.labelLg().copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 12,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.schedule_rounded, size: 14, color: SahayakColors.outline),
                                      const SizedBox(width: 4),
                                      Text(
                                        req.scheduledSlot,
                                        style: SahayakTypography.caption(),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.location_on_outlined, size: 14, color: SahayakColors.outline),
                                      const SizedBox(width: 4),
                                      Text(
                                        req.address.label,
                                        style: SahayakTypography.caption(),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Allocation Progress Bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: req.allocationProgressRatio,
                                  backgroundColor: SahayakColors.surfaceContainerHigh,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    req.isFullyAllocated
                                        ? SahayakColors.secondary
                                        : SahayakColors.primary,
                                  ),
                                  minHeight: 6,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${req.selectedDomains.length} Trade Domains Requested',
                                      style: SahayakTypography.caption(color: SahayakColors.onSurfaceVariant),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'View Allocation',
                                        style: SahayakTypography.labelSm(color: SahayakColors.primary).copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(width: 2),
                                      const Icon(Icons.chevron_right_rounded, size: 16, color: SahayakColors.primary),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 14),

              // Cooperative Enterprise Standards Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: SahayakColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: SahayakColors.borderSubtle),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: SahayakColors.surfaceContainerLowest,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.verified_user_rounded, color: SahayakColors.secondary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Work Solute Cooperative Enterprise Guarantee',
                            style: SahayakTypography.labelMd().copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'All dispatched workforce members are verified cooperative members with background checks, standard daily wages, and zero commercial middleman margins.',
                            style: SahayakTypography.caption(color: SahayakColors.onSurfaceVariant),
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
      );
    }
  }
