import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../data/models/address.dart';
import '../../shared_widgets/custom_vector_map.dart';

class EditAddressBottomSheet extends StatefulWidget {
  final SavedAddress? initialAddress;
  final ValueChanged<SavedAddress> onSave;
  final ValueChanged<String>? onDelete;

  const EditAddressBottomSheet({
    super.key,
    this.initialAddress,
    required this.onSave,
    this.onDelete,
  });

  static Future<void> show(
    BuildContext context, {
    SavedAddress? address,
    required ValueChanged<SavedAddress> onSave,
    ValueChanged<String>? onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditAddressBottomSheet(
        initialAddress: address,
        onSave: onSave,
        onDelete: onDelete,
      ),
    );
  }

  @override
  State<EditAddressBottomSheet> createState() => _EditAddressBottomSheetState();
}

class _EditAddressBottomSheetState extends State<EditAddressBottomSheet> {
  late String _selectedLabel;
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
    final addr = widget.initialAddress ?? SavedAddress.defaultHome;
    _selectedLabel = addr.label;
    _streetController = TextEditingController(text: addr.fullAddress);
    _landmarkController = TextEditingController(text: addr.landmark);
    _pincodeController = TextEditingController(text: addr.pincode);
    _selectedWard = addr.ward;
    _isDefault = addr.isDefault;
  }

  @override
  void dispose() {
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
      _selectedWard = 'Shivaji Nagar';
      _pincodeController.text = '641002';
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
    final updated = SavedAddress(
      id: widget.initialAddress?.id ?? 'addr_${DateTime.now().millisecondsSinceEpoch}',
      label: _selectedLabel,
      type: _selectedLabel,
      streetAddress: _streetController.text.trim(),
      landmark: _landmarkController.text.trim(),
      ward: _selectedWard,
      pincode: _pincodeController.text.trim(),
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
                  Row(
                    children: [
                      const Icon(Icons.edit_location_alt, color: CooperativeColors.primary, size: 24),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.initialAddress == null ? 'Add New Address' : 'Edit Saved Address',
                            style: CooperativeTypography.headlineSm.copyWith(
                              color: CooperativeColors.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Update doorstep details & ward dispatch profile',
                            style: CooperativeTypography.caption.copyWith(
                              color: CooperativeColors.onSurfaceVariant,
                            ),
                          ),
                        ],
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
            ),

            const Divider(height: 1, color: CooperativeColors.surfaceContainerHigh),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Address Label Chips
                    Text(
                      'ADDRESS LABEL',
                      style: CooperativeTypography.caption.copyWith(
                        color: CooperativeColors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildLabelChip('Home', Icons.home),
                        const SizedBox(width: 8),
                        _buildLabelChip('Office', Icons.apartment),
                        const SizedBox(width: 8),
                        _buildLabelChip('Other', Icons.location_on),
                      ],
                    ),

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
                        borderRadius: BorderRadius.circular(12),
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
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: CooperativeColors.surfaceContainerLow,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: CooperativeColors.outlineVariant.withValues(alpha: 0.6)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: CooperativeColors.outlineVariant.withValues(alpha: 0.6)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
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
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: CooperativeColors.surfaceContainerLow,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: CooperativeColors.outlineVariant.withValues(alpha: 0.6)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: CooperativeColors.outlineVariant.withValues(alpha: 0.6)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
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
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: CooperativeColors.outlineVariant.withValues(alpha: 0.6)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: CooperativeColors.outlineVariant.withValues(alpha: 0.6)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
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
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: CooperativeColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: CooperativeColors.outlineVariant.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.star, color: CooperativeColors.primary, size: 22),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Set as Primary Address',
                                    style: CooperativeTypography.labelMd.copyWith(
                                      color: CooperativeColors.onSurface,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'Prioritized automatically for one-tap bookings',
                                    style: CooperativeTypography.caption.copyWith(
                                      color: CooperativeColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Switch(
                            value: _isDefault,
                            activeThumbColor: CooperativeColors.primary,
                            onChanged: (val) => setState(() => _isDefault = val),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Dispatch Notice
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: CooperativeColors.surfaceContainer.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: CooperativeColors.surfaceContainerLowest,
                border: Border(
                  top: BorderSide(color: CooperativeColors.surfaceContainerHigh),
                ),
              ),
              child: Row(
                children: [
                  if (widget.initialAddress != null) ...[
                    OutlinedButton.icon(
                      onPressed: _delete,
                      icon: const Icon(Icons.delete, size: 18, color: CooperativeColors.error),
                      label: const Text('Delete', style: TextStyle(color: CooperativeColors.error)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: CooperativeColors.error.withValues(alpha: 0.4)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.check, size: 20),
                      label: const Text('Save Changes'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CooperativeColors.primaryContainer,
                        foregroundColor: CooperativeColors.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelChip(String label, IconData icon) {
    final isSelected = _selectedLabel == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedLabel = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
}
