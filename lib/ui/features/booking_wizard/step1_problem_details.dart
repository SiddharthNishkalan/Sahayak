import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../data/models/service.dart';
import '../../../app_view_model.dart';
import 'step2_time_location.dart';

class Step1ProblemDetailsScreen extends StatefulWidget {
  final AppViewModel viewModel;
  final ServiceItem service;

  const Step1ProblemDetailsScreen({
    super.key,
    required this.viewModel,
    required this.service,
  });

  @override
  State<Step1ProblemDetailsScreen> createState() => _Step1ProblemDetailsScreenState();
}

class _Step1ProblemDetailsScreenState extends State<Step1ProblemDetailsScreen> {
  late TextEditingController _descController;
  bool _descriptionError = false;

  final List<Map<String, dynamic>> _tradeDomains = [
    {'id': 'plumbing', 'name': 'Plumbing & Water', 'desc': 'Pipes, taps, leakages, drains', 'icon': Icons.plumbing_rounded},
    {'id': 'electrical', 'name': 'Electrical & Power', 'desc': 'Wiring, switches, tripping, shorts', 'icon': Icons.bolt_rounded},
    {'id': 'appliance', 'name': 'Appliances & Motors', 'desc': 'Water heaters, pumps, motors', 'icon': Icons.home_repair_service_rounded},
    {'id': 'carpentry', 'name': 'Carpentry & Fittings', 'desc': 'Cabinets, hinges, woodwork', 'icon': Icons.carpenter_rounded},
    {'id': 'painting', 'name': 'Painting & Sealing', 'desc': 'Waterproofing, moisture spots', 'icon': Icons.format_paint_rounded},
    {'id': 'cleaner', 'name': 'Deep Cleaning', 'desc': 'Sanitation, drain clearance', 'icon': Icons.cleaning_services_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _descController = TextEditingController(text: widget.viewModel.wizardProblemDescription);
    widget.viewModel.setService(widget.service);
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  void _goToStep2() {
    final text = _descController.text.trim();
    if (text.isEmpty) {
      setState(() => _descriptionError = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Problem description is mandatory (*). Please describe what needs fixing.'),
          backgroundColor: SahayakColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _descriptionError = false);
    widget.viewModel.setProblemDescription(text);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Step2TimeLocationScreen(
          viewModel: widget.viewModel,
          service: widget.service,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subcategories = widget.viewModel.repository.plumbingSubcategories;
    final selectedSubId = widget.viewModel.wizardSelectedSubcategoryId;
    final photos = widget.viewModel.wizardUploadedPhotos;
    final videos = widget.viewModel.wizardUploadedVideos;
    final isMultiDomain = widget.viewModel.wizardIsMultiDomain;
    final selectedDomains = widget.viewModel.wizardSelectedDomains;

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Booking Wizard · Step 1', style: SahayakTypography.labelLg(), overflow: TextOverflow.ellipsis),
                  Text(
                    'Sahayak Co-op • Request Formulation',
                    style: SahayakTypography.caption(color: SahayakColors.primary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: SahayakColors.primary, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: SahayakColors.outlineVariant, shape: BoxShape.circle)),
              ],
            ),
          ),
        ],
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
                        // Progress Indicator Banner
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: SahayakColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: const BoxDecoration(
                                            color: SahayakColors.primary,
                                            shape: BoxShape.circle,
                                          ),
                                          alignment: Alignment.center,
                                          child: const Text(
                                            '1',
                                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Describe your issue',
                                            style: SahayakTypography.headlineSm(),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('Step 1 of 2', style: SahayakTypography.caption()),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Select your domain trade(s), describe the problem, and attach photos or videos so workers arrive prepared.',
                                style: SahayakTypography.bodySm(),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: SahayakColors.primary,
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Container(
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: SahayakColors.surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Section 1: Domain Selection Mode (Single vs Multi-Domain)
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: SahayakColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: SahayakColors.borderSubtle),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Domain Selection',
                                      style: SahayakTypography.labelMd(),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isMultiDomain
                                          ? SahayakColors.secondaryFixed
                                          : SahayakColors.surfaceContainerHigh,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      isMultiDomain ? '${selectedDomains.length} Selected' : 'Single Trade',
                                      style: SahayakTypography.caption(
                                        color: isMultiDomain ? SahayakColors.onSecondaryFixed : SahayakColors.primary,
                                      ).copyWith(fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // Choice Tabs: Known Trade vs Unsure / Multi-Domain
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: SahayakColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () => setState(() => widget.viewModel.toggleMultiDomain(false)),
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          decoration: BoxDecoration(
                                            color: !isMultiDomain ? SahayakColors.surfaceContainerLowest : Colors.transparent,
                                            borderRadius: BorderRadius.circular(10),
                                            boxShadow: !isMultiDomain
                                                ? [
                                                    BoxShadow(
                                                      color: Colors.black.withValues(alpha: 0.05),
                                                      blurRadius: 4,
                                                      offset: const Offset(0, 1),
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Exact Domain',
                                            style: SahayakTypography.labelSm(
                                              color: !isMultiDomain ? SahayakColors.primary : SahayakColors.onSurfaceVariant,
                                            ).copyWith(fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () => setState(() => widget.viewModel.toggleMultiDomain(true)),
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          decoration: BoxDecoration(
                                            color: isMultiDomain ? SahayakColors.surfaceContainerLowest : Colors.transparent,
                                            borderRadius: BorderRadius.circular(10),
                                            boxShadow: isMultiDomain
                                                ? [
                                                    BoxShadow(
                                                      color: Colors.black.withValues(alpha: 0.05),
                                                      blurRadius: 4,
                                                      offset: const Offset(0, 1),
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                          alignment: Alignment.center,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.hub_rounded, size: 14, color: SahayakColors.secondary),
                                              const SizedBox(width: 4),
                                              Flexible(
                                                child: Text(
                                                  'Multi-Trade',
                                                  style: SahayakTypography.labelSm(
                                                    color: isMultiDomain ? SahayakColors.secondary : SahayakColors.onSurfaceVariant,
                                                  ).copyWith(fontWeight: FontWeight.w700),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Multi-Domain Picker UI
                              if (isMultiDomain) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: SahayakColors.secondaryFixed.withValues(alpha: 0.35),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.info_outline_rounded, size: 16, color: SahayakColors.secondary),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Know the problem but not sure who handles it? Select multiple possible trades. We notify workers across all chosen trades so the right specialist can accept.',
                                          style: SahayakTypography.caption(color: SahayakColors.onSurface),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Column(
                                  children: _tradeDomains.map((trade) {
                                    final id = trade['id'] as String;
                                    final isSelected = selectedDomains.contains(id);
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: InkWell(
                                        onTap: () => setState(() => widget.viewModel.toggleDomainSelection(id)),
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? SahayakColors.surfaceContainerHigh
                                                : SahayakColors.surfaceContainerLow,
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                              color: isSelected ? SahayakColors.primary : Colors.transparent,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(trade['icon'] as IconData, size: 20, color: isSelected ? SahayakColors.primary : SahayakColors.onSurfaceVariant),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(trade['name'] as String, style: SahayakTypography.labelSm().copyWith(fontWeight: FontWeight.w700)),
                                                    Text(trade['desc'] as String, style: SahayakTypography.caption()),
                                                  ],
                                                ),
                                              ),
                                              Icon(
                                                isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                                                color: isSelected ? SahayakColors.primary : SahayakColors.outline,
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ] else ...[
                                const SizedBox(height: 12),
                                // Subcategories for Selected Single Domain
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${widget.service.title} Subcategory',
                                        style: SahayakTypography.labelSm(),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text('Select 1 option', style: SahayakTypography.caption(color: SahayakColors.primary)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                GridView.count(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  childAspectRatio: 1.25,
                                  children: subcategories.map((sub) {
                                    final isSel = sub.id == selectedSubId;
                                    return InkWell(
                                      onTap: () => setState(() {
                                        widget.viewModel.setSubcategory(sub.id);
                                      }),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: isSel
                                              ? SahayakColors.surfaceContainerHigh
                                              : SahayakColors.surfaceContainerLow,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isSel ? SahayakColors.primary : Colors.transparent,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  width: 32,
                                                  height: 32,
                                                  decoration: BoxDecoration(
                                                    color: isSel
                                                        ? SahayakColors.primary
                                                        : SahayakColors.surfaceContainerHighest,
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Icon(
                                                    sub.icon,
                                                    size: 18,
                                                    color: isSel ? Colors.white : SahayakColors.onSurface,
                                                  ),
                                                ),
                                                Icon(
                                                  isSel ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
                                                  size: 18,
                                                  color: isSel ? SahayakColors.primary : Colors.transparent,
                                                ),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  sub.title,
                                                  style: SahayakTypography.labelSm().copyWith(fontWeight: FontWeight.w700),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  sub.description,
                                                  style: SahayakTypography.caption(),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Section 2: Problem Description (Mandatory *)
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: SahayakColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _descriptionError ? SahayakColors.error : SahayakColors.borderSubtle,
                              width: _descriptionError ? 1.5 : 1.0,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'What do you need help with? ',
                                            style: SahayakTypography.labelMd(color: SahayakColors.onSurface),
                                          ),
                                          TextSpan(
                                            text: '*',
                                            style: SahayakTypography.labelMd(color: SahayakColors.error).copyWith(fontWeight: FontWeight.w800),
                                          ),
                                          TextSpan(
                                            text: ' (Required)',
                                            style: SahayakTypography.caption(color: SahayakColors.error),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_descController.text.length}/300',
                                    style: SahayakTypography.caption(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _descController,
                                maxLines: 4,
                                maxLength: 300,
                                onChanged: (val) {
                                  setState(() {
                                    if (_descriptionError && val.trim().isNotEmpty) {
                                      _descriptionError = false;
                                    }
                                  });
                                },
                                decoration: InputDecoration(
                                  counterText: '',
                                  hintText: 'Describe your issue in detail (e.g., tap leaking continuously, circuit breaker tripping)...',
                                  fillColor: SahayakColors.surfaceContainerLow,
                                  errorText: _descriptionError ? 'Description is required to help workers bring correct spares' : null,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.lightbulb_outline_rounded, size: 16, color: SahayakColors.primary),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'A specific description allows nearest cooperative workers to accurately evaluate and bring proper fittings.',
                                      style: SahayakTypography.caption(),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Section 3: Photo & Video Upload
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: SahayakColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: SahayakColors.borderSubtle),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Photos & Video Note (Optional)',
                                      style: SahayakTypography.labelMd(),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('${photos.length + videos.length} files attached', style: SahayakTypography.caption()),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Adding a photo or short 15s video helps workers assess whether specialized tools or replacement valves are needed.',
                                style: SahayakTypography.bodySm(),
                              ),
                              const SizedBox(height: 10),

                              // Photos & Videos Row
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    // Photos
                                    ...photos.asMap().entries.map((entry) {
                                      final idx = entry.key;
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: Stack(
                                          children: [
                                            Container(
                                              width: 76,
                                              height: 76,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                                color: SahayakColors.surfaceContainer,
                                                border: Border.all(color: SahayakColors.borderSubtle),
                                              ),
                                              clipBehavior: Clip.antiAlias,
                                              child: Image.asset(
                                                'assets/images/logo.png',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Positioned(
                                              top: 4,
                                              right: 4,
                                              child: InkWell(
                                                onTap: () => setState(() => widget.viewModel.removeWizardPhoto(idx)),
                                                child: Container(
                                                  padding: const EdgeInsets.all(2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black.withValues(alpha: 0.6),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 4,
                                              left: 4,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                                decoration: BoxDecoration(
                                                  color: SahayakColors.secondary,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: const Text('Photo', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),

                                    // Videos
                                    ...videos.asMap().entries.map((entry) {
                                      final idx = entry.key;
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: Stack(
                                          children: [
                                            Container(
                                              width: 76,
                                              height: 76,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                                color: SahayakColors.surfaceContainerHigh,
                                                border: Border.all(color: SahayakColors.primary.withValues(alpha: 0.5)),
                                              ),
                                              child: const Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.videocam_rounded, color: SahayakColors.primary, size: 28),
                                                  SizedBox(height: 2),
                                                  Text('0:15s', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                                                ],
                                              ),
                                            ),
                                            Positioned(
                                              top: 4,
                                              right: 4,
                                              child: InkWell(
                                                onTap: () => setState(() => widget.viewModel.removeWizardVideo(idx)),
                                                child: Container(
                                                  padding: const EdgeInsets.all(2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black.withValues(alpha: 0.6),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 4,
                                              left: 4,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                                decoration: BoxDecoration(
                                                  color: SahayakColors.primary,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: const Text('Video', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),

                                    // Add Photo Button
                                    if (photos.length < 3)
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: InkWell(
                                          onTap: () => setState(() => widget.viewModel.addWizardPhoto('assets/images/logo.png')),
                                          borderRadius: BorderRadius.circular(12),
                                          child: Container(
                                            width: 76,
                                            height: 76,
                                            decoration: BoxDecoration(
                                              color: SahayakColors.surfaceContainerLow,
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: SahayakColors.borderSubtle),
                                            ),
                                            child: const Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.add_a_photo_outlined, size: 22, color: SahayakColors.primary),
                                                SizedBox(height: 2),
                                                Text('+ Photo', style: TextStyle(fontSize: 11, color: SahayakColors.primary, fontWeight: FontWeight.w600)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),

                                    // Add Video Button
                                    if (videos.length < 2)
                                      InkWell(
                                        onTap: () => setState(() => widget.viewModel.addWizardVideo('sample_video_clip.mp4')),
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          width: 76,
                                          height: 76,
                                          decoration: BoxDecoration(
                                            color: SahayakColors.surfaceContainerLow,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: SahayakColors.borderSubtle),
                                          ),
                                          child: const Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.video_call_outlined, size: 24, color: SahayakColors.secondary),
                                              SizedBox(height: 2),
                                              Text('+ Video', style: TextStyle(fontSize: 11, color: SahayakColors.secondary, fontWeight: FontWeight.w600)),
                                            ],
                                          ),
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

                // Bottom Sticky CTA
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    color: SahayakColors.surfaceContainerLowest,
                    border: Border(top: BorderSide(color: SahayakColors.borderSubtle)),
                  ),
                  child: ElevatedButton(
                    onPressed: _goToStep2,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            'Continue to Time & Location',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
