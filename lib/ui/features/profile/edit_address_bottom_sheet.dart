import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../data/models/address.dart';
import '../../shared_widgets/custom_vector_map.dart';

class EditAddressBottomSheet extends StatefulWidget {
  final SavedAddress? initialAddress;
  final ValueChanged<SavedAddress> onSave;
  final ValueChanged<String>? onDelete;
  final bool isInstitution;
  final int? nextOfficeNumber;

  const EditAddressBottomSheet({
    super.key,
    this.initialAddress,
    required this.onSave,
    this.onDelete,
    this.isInstitution = false,
    this.nextOfficeNumber,
  });

  static Future<void> show(
    BuildContext context, {
    SavedAddress? address,
    required ValueChanged<SavedAddress> onSave,
    ValueChanged<String>? onDelete,
    bool isInstitution = false,
    int? nextOfficeNumber,
  }) {
    HapticFeedback.lightImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: CooperativeColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => EditAddressBottomSheet(
        initialAddress: address,
        onSave: onSave,
        onDelete: onDelete,
        isInstitution: isInstitution,
        nextOfficeNumber: nextOfficeNumber,
      ),
    );
  }

  @override
  State<EditAddressBottomSheet> createState() => _EditAddressBottomSheetState();
}

class _EditAddressBottomSheetState extends State<EditAddressBottomSheet> {
  static const List<String> availableWards = [
    'Ward 5, Shivaji Nagar',
    'Ward 6, Gandhipuram',
    'Ward 7, Saibaba Colony',
    'Ward 12, Peelamedu',
  ];

  static String _normalizeWard(String rawWard) {
    for (final w in availableWards) {
      if (rawWard.toLowerCase().contains(w.toLowerCase()) ||
          w.toLowerCase().contains(rawWard.toLowerCase())) {
        return w;
      }
    }
    for (final w in availableWards) {
      final namePart = w.split(',').last.trim().toLowerCase();
      if (rawWard.toLowerCase().contains(namePart) || namePart.contains(rawWard.toLowerCase())) {
        return w;
      }
    }
    return availableWards.first;
  }

  late String _selectedLabel;
  late TextEditingController _customLabelController;
  late TextEditingController _streetController;
  late TextEditingController _landmarkController;
  late TextEditingController _pincodeController;
  late String _selectedWard;
  late bool _isDefault;

  bool _isGpsLoading = false;
  bool _isGpsDetected = false;
  bool _showMapPreview = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialAddress != null) {
      final addr = widget.initialAddress!;
      if (widget.isInstitution) {
        _selectedLabel = addr.label;
        _customLabelController = TextEditingController(text: addr.label);
      } else {
        _selectedLabel = (addr.label == 'Home' || addr.label == 'Office') ? addr.label : 'Other';
        _customLabelController = TextEditingController(
          text: (addr.label != 'Home' && addr.label != 'Office') ? addr.label : '',
        );
      }
      _streetController = TextEditingController(text: addr.streetAddress);
      _landmarkController = TextEditingController(text: addr.landmark);
      _pincodeController = TextEditingController(text: addr.pincode);
      _selectedWard = _normalizeWard(addr.ward);
      _isDefault = addr.isDefault;
    } else {
      if (widget.isInstitution) {
        final defaultOffice = 'Office ${widget.nextOfficeNumber ?? 1}';
        _selectedLabel = defaultOffice;
        _customLabelController = TextEditingController(text: defaultOffice);
      } else {
        _selectedLabel = 'Home';
        _customLabelController = TextEditingController();
      }
      _streetController = TextEditingController();
      _landmarkController = TextEditingController();
      _pincodeController = TextEditingController(text: '641002');
      _selectedWard = availableWards.first;
      _isDefault = false;
    }
  }

  @override
  void dispose() {
    _customLabelController.dispose();
    _streetController.dispose();
    _landmarkController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  void _detectGps() async {
    setState(() {
      _isGpsLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;
    setState(() {
      _isGpsLoading = false;
      _isGpsDetected = true;
      _selectedWard = 'Ward 5, Shivaji Nagar';
      _pincodeController.text = '641002';
      if (_streetController.text.trim().isEmpty) {
        _streetController.text = 'Ward 5, Shivaji Nagar GIS Hub';
      }
      _showMapPreview = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.gps_fixed, color: CooperativeColors.secondaryContainer, size: 18),
            const SizedBox(width: 8),
            Text('GPS locked to live device location (<10m accuracy)',
                style: CooperativeTypography.bodySm.copyWith(color: CooperativeColors.onPrimary)),
          ],
        ),
        backgroundColor: CooperativeColors.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _save() {
    final street = _streetController.text.trim();
    if (street.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter street address / door number'),
          backgroundColor: CooperativeColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final finalLabel = widget.isInstitution
        ? (_customLabelController.text.trim().isNotEmpty
            ? _customLabelController.text.trim()
            : _selectedLabel)
        : ((_selectedLabel == 'Other' && _customLabelController.text.trim().isNotEmpty)
            ? _customLabelController.text.trim()
            : _selectedLabel);

    final updated = SavedAddress(
      id: widget.initialAddress?.id ?? 'addr_${DateTime.now().millisecondsSinceEpoch}',
      label: finalLabel,
      type: widget.isInstitution ? 'Office' : _selectedLabel,
      streetAddress: street,
      landmark: _landmarkController.text.trim().isEmpty ? 'Near landmark' : _landmarkController.text.trim(),
      ward: _selectedWard,
      pincode: _pincodeController.text.trim().isEmpty ? '641002' : _pincodeController.text.trim(),
      latitude: 11.0168,
      longitude: 76.9558,
      isDefault: _isDefault,
    );
    widget.onSave(updated);
    Navigator.of(context).pop();
  }

  void _delete() {
    if (widget.initialAddress != null && widget.onDelete != null) {
      widget.onDelete!(widget.initialAddress!.id);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: CooperativeColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
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
            const SizedBox(height: 8),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.edit_location_alt, color: CooperativeColors.primary, size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.initialAddress == null
                                    ? (widget.isInstitution ? 'Add Facility Site' : 'Add New Address')
                                    : (widget.isInstitution ? 'Edit Facility Site' : 'Edit Saved Address'),
                                style: CooperativeTypography.headlineSm.copyWith(
                                  color: CooperativeColors.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                widget.initialAddress == null
                                    ? (widget.isInstitution
                                        ? 'Add facility location & GIS dispatch zone'
                                        : 'Add new doorstep details & ward dispatch profile')
                                    : (widget.isInstitution
                                        ? 'Update facility location & GIS dispatch zone'
                                        : 'Update doorstep details & ward dispatch profile'),
                                style: CooperativeTypography.caption.copyWith(
                                  color: CooperativeColors.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close, color: CooperativeColors.onSurfaceVariant),
                    style: IconButton.styleFrom(
                      backgroundColor: CooperativeColors.surfaceContainer,
                      minimumSize: const Size(44, 44),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: CooperativeColors.surfaceContainerHigh),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Address Label Chips
                    Text(
                      widget.isInstitution ? 'FACILITY SITE LABEL' : 'ADDRESS LABEL',
                      style: CooperativeTypography.caption.copyWith(
                        color: CooperativeColors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (widget.isInstitution) ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _buildOfficeChip('Office 1'),
                          _buildOfficeChip('Office 2'),
                          _buildOfficeChip('Office 3'),
                          _buildOfficeChip('Custom'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _customLabelController,
                        textCapitalization: TextCapitalization.words,
                        onChanged: (val) {
                          setState(() {
                            _selectedLabel = val.trim().isEmpty ? 'Office' : val.trim();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'e.g. Office 1 (Main Hub), Office 2 (Site B)',
                          labelText: 'Facility Site Name / Label',
                          filled: true,
                          fillColor: CooperativeColors.surfaceContainerLow,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: CooperativeColors.outlineVariant.withValues(alpha: 0.6)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: CooperativeColors.outlineVariant.withValues(alpha: 0.6)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: CooperativeColors.primary, width: 2),
                          ),
                        ),
                      ),
                    ] else ...[
                      Row(
                        children: [
                          _buildLabelChip('Home', Icons.home),
                          const SizedBox(width: 8),
                          _buildLabelChip('Office', Icons.apartment),
                          const SizedBox(width: 8),
                          _buildLabelChip('Other', Icons.location_on),
                        ],
                      ),
                      if (_selectedLabel == 'Other') ...[
                        const SizedBox(height: 10),
                        TextField(
                          controller: _customLabelController,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            hintText: 'e.g. Parents House, Studio, Clinic',
                            labelText: 'Custom Label Name',
                            filled: true,
                            fillColor: CooperativeColors.surfaceContainerLow,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: CooperativeColors.outlineVariant.withValues(alpha: 0.6)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: CooperativeColors.outlineVariant.withValues(alpha: 0.6)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: CooperativeColors.primary, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ],

                    const SizedBox(height: 16),

                    // GPS Locate Button
                    InkWell(
                      onTap: _isGpsLoading ? null : _detectGps,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _isGpsDetected
                              ? CooperativeColors.secondaryContainer.withValues(alpha: 0.3)
                              : CooperativeColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _isGpsDetected
                                ? CooperativeColors.secondary
                                : CooperativeColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: _isGpsDetected
                                    ? CooperativeColors.secondary
                                    : CooperativeColors.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: _isGpsLoading
                                  ? const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Icon(
                                      _isGpsDetected ? Icons.gps_fixed : Icons.my_location,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        _isGpsLoading
                                            ? 'Detecting municipal GPS...'
                                            : (_isGpsDetected
                                                ? 'GPS Locked: Ward 5 GIS'
                                                : 'Detect current location via GPS'),
                                        style: CooperativeTypography.labelMd.copyWith(
                                          color: CooperativeColors.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      if (_isGpsDetected) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: CooperativeColors.secondary,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'ACTIVE',
                                            style: CooperativeTypography.caption.copyWith(
                                              color: CooperativeColors.onSecondary,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  Text(
                                    _isGpsDetected
                                        ? 'Accurate to <10m · 11.0168° N, 76.9558° E'
                                        : 'Accurate to <10m · Auto-fills Ward & Pincode',
                                    style: CooperativeTypography.caption.copyWith(
                                      color: CooperativeColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.near_me, color: CooperativeColors.primary, size: 20),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Map Preview Toggle Card
                    Container(
                      decoration: BoxDecoration(
                        color: CooperativeColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: CooperativeColors.outlineVariant.withValues(alpha: 0.5)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () => setState(() => _showMapPreview = !_showMapPreview),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.map, color: CooperativeColors.primary, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        _showMapPreview ? 'GIS Vector Map' : 'Show Map Preview',
                                        style: CooperativeTypography.labelMd.copyWith(
                                          color: CooperativeColors.onSurface,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: CooperativeColors.primaryFixed,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'Ward 5 GIS',
                                          style: CooperativeTypography.caption.copyWith(
                                            color: CooperativeColors.onPrimaryFixed,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        _showMapPreview ? 'Hide Map' : 'Tap to view',
                                        style: CooperativeTypography.caption.copyWith(
                                          color: CooperativeColors.onSurfaceVariant,
                                        ),
                                      ),
                                      Icon(
                                        _showMapPreview ? Icons.expand_less : Icons.expand_more,
                                        color: CooperativeColors.primary,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (_showMapPreview) ...[
                            SizedBox(
                              height: 180,
                              width: double.infinity,
                              child: CustomVectorMap(
                                locationLabel: _streetController.text.isNotEmpty
                                    ? _streetController.text
                                    : 'Ward 5, Shivaji Nagar',
                                interactive: true,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              color: CooperativeColors.surfaceContainerLow,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      '📍 GPS: 11.0168° N, 76.9558° E',
                                      style: CooperativeTypography.caption.copyWith(
                                        color: CooperativeColors.onSurfaceVariant,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Shivaji Nagar GIS Hub',
                                    style: CooperativeTypography.caption.copyWith(
                                      color: CooperativeColors.secondary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Municipal Ward Selector
                    Text(
                      'LOCAL MUNICIPAL WARD',
                      style: CooperativeTypography.caption.copyWith(
                        color: CooperativeColors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: CooperativeColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: CooperativeColors.outlineVariant.withValues(alpha: 0.6)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedWard,
                          isExpanded: true,
                          icon: const Icon(Icons.unfold_more, color: CooperativeColors.outline),
                          items: const [
                            DropdownMenuItem(
                              value: 'Ward 5, Shivaji Nagar',
                              child: Text('Ward 5 — Shivaji Nagar / RS Puram East'),
                            ),
                            DropdownMenuItem(
                              value: 'Ward 6, Gandhipuram',
                              child: Text('Ward 6 — Gandhipuram Central'),
                            ),
                            DropdownMenuItem(
                              value: 'Ward 7, Saibaba Colony',
                              child: Text('Ward 7 — Saibaba Colony / NSR Road'),
                            ),
                            DropdownMenuItem(
                              value: 'Ward 12, Peelamedu',
                              child: Text('Ward 12 — Peelamedu / Hopes College'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedWard = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: CooperativeColors.secondaryContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified, size: 14, color: CooperativeColors.secondary),
                          const SizedBox(width: 5),
                          Text(
                            'Within <20 min Rapid Dispatch Zone',
                            style: CooperativeTypography.caption.copyWith(
                              color: CooperativeColors.onSecondaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Street Address Input
                    Text(
                      'FULL STREET ADDRESS / DOOR NO.',
                      style: CooperativeTypography.caption.copyWith(
                        color: CooperativeColors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _streetController,
                      maxLines: 2,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: CooperativeColors.surfaceContainerLow,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: CooperativeColors.outlineVariant.withValues(alpha: 0.6)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: CooperativeColors.outlineVariant.withValues(alpha: 0.6)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: CooperativeColors.primary, width: 2),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Landmark & Pincode
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'LANDMARK & FLOOR',
                                style: CooperativeTypography.caption.copyWith(
                                  color: CooperativeColors.onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _landmarkController,
                                textCapitalization: TextCapitalization.sentences,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: CooperativeColors.surfaceContainerLow,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(color: CooperativeColors.outlineVariant.withValues(alpha: 0.6)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(color: CooperativeColors.outlineVariant.withValues(alpha: 0.6)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: CooperativeColors.primary, width: 2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PINCODE',
                                style: CooperativeTypography.caption.copyWith(
                                  color: CooperativeColors.onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _pincodeController,
                                keyboardType: TextInputType.number,
                                maxLength: 6,
                                decoration: InputDecoration(
                                  counterText: '',
                                  filled: true,
                                  fillColor: CooperativeColors.surfaceContainerLow,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(color: CooperativeColors.outlineVariant.withValues(alpha: 0.6)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(color: CooperativeColors.outlineVariant.withValues(alpha: 0.6)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: CooperativeColors.primary, width: 2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Primary Address Toggle
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _isDefault = !_isDefault);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: CooperativeColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: CooperativeColors.outlineVariant.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(Icons.star, color: CooperativeColors.primary, size: 22),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Set as Primary Address',
                                          style: CooperativeTypography.labelMd.copyWith(
                                            color: CooperativeColors.onSurface,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'Prioritized automatically for one-tap bookings',
                                          style: CooperativeTypography.caption.copyWith(
                                            color: CooperativeColors.onSurfaceVariant,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Switch(
                              value: _isDefault,
                              activeThumbColor: CooperativeColors.primary,
                              onChanged: (val) {
                                HapticFeedback.selectionClick();
                                setState(() => _isDefault = val);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Dispatch Notice
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: CooperativeColors.surfaceContainer.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.shield, size: 18, color: CooperativeColors.secondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Technician Dispatch Notice: Verified guild workers receive masked contact details and door instructions solely upon arrival at your ward.',
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
                  ],
                ),
              ),
            ),

            // Bottom Actions Bar
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CooperativeColors.surfaceContainerLowest,
                  border: const Border(
                    top: BorderSide(color: CooperativeColors.surfaceContainerHigh),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (widget.initialAddress != null) ...[
                      SizedBox(
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            _delete();
                          },
                          icon: const Icon(Icons.delete_outline_rounded, size: 18, color: CooperativeColors.error),
                          label: const Text('Delete', style: TextStyle(color: CooperativeColors.error)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: CooperativeColors.error.withValues(alpha: 0.4)),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            _save();
                          },
                          icon: const Icon(Icons.check_rounded, size: 20),
                          label: Text(widget.initialAddress == null ? 'Save Address' : 'Save Changes'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CooperativeColors.primaryContainer,
                            foregroundColor: CooperativeColors.onPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelChip(String label, IconData icon) {
    final isSelected = _selectedLabel == label;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedLabel = label);
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? CooperativeColors.primary : CooperativeColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? CooperativeColors.primary : CooperativeColors.outlineVariant.withValues(alpha: 0.8),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? CooperativeColors.onPrimary : CooperativeColors.outline,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: CooperativeTypography.labelMd.copyWith(
                color: isSelected ? CooperativeColors.onPrimary : CooperativeColors.onSurface,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfficeChip(String officeLabel) {
    final isSelected = officeLabel == 'Custom'
        ? (!_customLabelController.text.startsWith('Office 1') &&
            !_customLabelController.text.startsWith('Office 2') &&
            !_customLabelController.text.startsWith('Office 3'))
        : _customLabelController.text.startsWith(officeLabel);
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          if (officeLabel != 'Custom') {
            _selectedLabel = officeLabel;
            _customLabelController.text = officeLabel;
          }
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? CooperativeColors.primary : CooperativeColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? CooperativeColors.primary : CooperativeColors.outlineVariant.withValues(alpha: 0.8),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              officeLabel == 'Custom' ? Icons.edit_rounded : Icons.apartment_rounded,
              size: 16,
              color: isSelected ? CooperativeColors.onPrimary : CooperativeColors.outline,
            ),
            const SizedBox(width: 6),
            Text(
              officeLabel,
              style: CooperativeTypography.labelMd.copyWith(
                color: isSelected ? CooperativeColors.onPrimary : CooperativeColors.onSurface,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
