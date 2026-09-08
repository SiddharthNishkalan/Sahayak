import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../data/models/address.dart';
import '../../../data/models/language.dart';
import '../../../data/models/booking.dart';
import '../../../data/models/coordinator.dart';
import '../../../data/repositories/app_repository.dart';
import '../../../app_view_model.dart';
import 'edit_address_bottom_sheet.dart';

class ProfileSettingsScreen extends StatelessWidget {
  final AppViewModel viewModel;
  final VoidCallback? onLogout;

  const ProfileSettingsScreen({
    super.key,
    required this.viewModel,
    this.onLogout,
  });

  void _confirmLogout(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: CooperativeColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: CooperativeColors.errorContainer.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.logout_rounded, color: CooperativeColors.error, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      viewModel.strings.get('confirm_logout'),
                      style: CooperativeTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                viewModel.strings.get('logout_confirm_msg'),
                style: CooperativeTypography.bodyMedium,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          Navigator.pop(ctx);
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(viewModel.strings.get('cancel')),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          Navigator.pop(ctx);
                          viewModel.signOut();
                          if (onLogout != null) {
                            onLogout!();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CooperativeColors.error,
                          foregroundColor: CooperativeColors.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(viewModel.strings.get('log_out')),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    HapticFeedback.lightImpact();
    final nameController = TextEditingController(text: viewModel.currentUser?.name ?? viewModel.userName);
    final phoneController = TextEditingController(text: viewModel.currentUser?.phone ?? viewModel.userPhone);
    String selectedSociety = viewModel.currentUser?.society ?? viewModel.currentSociety;
    if (!AppRepository.supportedSocieties.contains(selectedSociety)) {
      selectedSociety = AppRepository.supportedSocieties.first;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: CooperativeColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              4,
              20,
              MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(
                  viewModel.strings.get('edit_profile'),
                  style: CooperativeTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  viewModel.strings.get('full_name'),
                  style: CooperativeTypography.labelMd.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: viewModel.strings.get('full_name'),
                    prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                    filled: true,
                    fillColor: CooperativeColors.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: CooperativeColors.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: CooperativeColors.outlineVariant),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  viewModel.strings.get('phone_number'),
                  style: CooperativeTypography.labelMd.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: '+91 98432 00000',
                    prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                    filled: true,
                    fillColor: CooperativeColors.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: CooperativeColors.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: CooperativeColors.outlineVariant),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  viewModel.strings.get('neighborhood'),
                  style: CooperativeTypography.labelMd.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: CooperativeColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: CooperativeColors.outlineVariant),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedSociety,
                      items: AppRepository.supportedSocieties.map((s) {
                        return DropdownMenuItem(value: s, child: Text(s));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          HapticFeedback.selectionClick();
                          setDialogState(() {
                            selectedSociety = val;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            Navigator.pop(ctx);
                          },
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text(viewModel.strings.get('cancel')),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            viewModel.updateProfile(
                              name: nameController.text.trim(),
                              phone: phoneController.text.trim(),
                              society: selectedSociety,
                            );
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Profile details updated successfully!'),
                                backgroundColor: CooperativeColors.secondary,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CooperativeColors.primary,
                            foregroundColor: CooperativeColors.onPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text(viewModel.strings.get('save_changes')),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final addresses = viewModel.repository.addresses;
    final selectedLang = viewModel.selectedLanguage;
    final s = viewModel.strings;
    final isInstitution = viewModel.currentUser?.isInstitution ?? false;

    return Material(
      color: CooperativeColors.surface,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
                // Page Context Sub-header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.get('my_profile_title'),
                            style: CooperativeTypography.headlineLg.copyWith(
                              color: CooperativeColors.onSurface,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            s.get('profile_sub'),
                            style: CooperativeTypography.bodySm.copyWith(
                              color: CooperativeColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: CooperativeColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified, size: 15, color: CooperativeColors.secondary),
                          const SizedBox(width: 4),
                          Text(
                            viewModel.currentUser?.society ?? viewModel.userSociety,
                            style: CooperativeTypography.labelSm.copyWith(
                              color: CooperativeColors.secondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // User Profile Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CooperativeColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: CooperativeColors.primaryFixed,
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                child: Center(
                                  child: Text(
                                    viewModel.currentUser?.initials ?? 'U',
                                    style: CooperativeTypography.headlineSm.copyWith(
                                      color: CooperativeColors.onPrimaryFixed,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: CooperativeColors.secondary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: CooperativeColors.onSecondary,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        viewModel.currentUser?.name ?? viewModel.userName,
                                        style: CooperativeTypography.headlineSm.copyWith(
                                          color: CooperativeColors.onSurface,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, size: 18, color: CooperativeColors.primary),
                                      tooltip: s.get('edit_profile'),
                                      onPressed: () {
                                        HapticFeedback.lightImpact();
                                        _showEditProfileDialog(context);
                                      },
                                      style: IconButton.styleFrom(
                                        backgroundColor: CooperativeColors.surfaceContainerHigh,
                                        minimumSize: const Size(38, 38),
                                        padding: const EdgeInsets.all(8),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: CooperativeColors.secondaryContainer,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.verified, color: CooperativeColors.onSecondaryContainer, size: 12),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          '${s.get('verified_citizen')} · ${viewModel.currentUser?.society ?? viewModel.userSociety}',
                                          style: CooperativeTypography.caption.copyWith(
                                            color: CooperativeColors.onSecondaryContainer,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'ID: #${viewModel.userMemberId}',
                                  style: CooperativeTypography.caption.copyWith(
                                    color: CooperativeColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Verified Contact Credentials
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: CooperativeColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.phone_iphone, size: 18, color: CooperativeColors.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(s.get('primary_contact'),
                                          style: CooperativeTypography.caption.copyWith(
                                            color: CooperativeColors.onSurfaceVariant,
                                          )),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                            viewModel.currentUser?.phone.isNotEmpty == true
                                                ? viewModel.currentUser!.phone
                                                : viewModel.userPhone,
                                            style: CooperativeTypography.labelMd.copyWith(
                                              color: CooperativeColors.onSurface,
                                              fontWeight: FontWeight.w700,
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: CooperativeColors.secondaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.check_circle, size: 12, color: CooperativeColors.onSecondaryContainer),
                                      const SizedBox(width: 4),
                                      Text(
                                        s.get('verified_otp'),
                                        style: CooperativeTypography.caption.copyWith(
                                          color: CooperativeColors.onSecondaryContainer,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 16, thickness: 0.5, color: CooperativeColors.surfaceContainerHigh),
                            Row(
                              children: [
                                const Icon(Icons.mail, size: 18, color: CooperativeColors.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(s.get('invoicing_email'),
                                          style: CooperativeTypography.caption.copyWith(
                                            color: CooperativeColors.onSurfaceVariant,
                                          )),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                            viewModel.currentUser?.email.isNotEmpty == true
                                                ? viewModel.currentUser!.email
                                                : viewModel.userEmail,
                                            style: CooperativeTypography.labelMd.copyWith(
                                              color: CooperativeColors.onSurface,
                                              fontWeight: FontWeight.w700,
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: CooperativeColors.secondaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.check_circle, size: 12, color: CooperativeColors.onSecondaryContainer),
                                      const SizedBox(width: 4),
                                      Text(
                                        s.get('verified_label'),
                                        style: CooperativeTypography.caption.copyWith(
                                          color: CooperativeColors.onSecondaryContainer,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
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

                // Interactive User Activity Stats Bar
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: CooperativeColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            viewModel.switchTab(ShellTab.bookings);
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.receipt_long, size: 16, color: CooperativeColors.primary),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${viewModel.repository.bookings.length}',
                                      style: CooperativeTypography.headlineSm.copyWith(
                                        color: CooperativeColors.primary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  s.get('stat_bookings'),
                                  style: CooperativeTypography.caption.copyWith(
                                    color: CooperativeColors.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(width: 1, height: 32, color: CooperativeColors.surfaceContainerHigh),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            viewModel.switchTab(ShellTab.bookings);
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.check_circle_outline, size: 16, color: CooperativeColors.secondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${viewModel.repository.getBookingsByTab(BookingTab.completed).length}',
                                      style: CooperativeTypography.headlineSm.copyWith(
                                        color: CooperativeColors.secondary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  s.get('stat_completed'),
                                  style: CooperativeTypography.caption.copyWith(
                                    color: CooperativeColors.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(width: 1, height: 32, color: CooperativeColors.surfaceContainerHigh),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    const Icon(Icons.pin_drop_outlined, size: 16, color: CooperativeColors.tertiary),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${addresses.length}',
                                      style: CooperativeTypography.headlineSm.copyWith(
                                        color: CooperativeColors.tertiary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                s.get('stat_addresses'),
                                style: CooperativeTypography.caption.copyWith(
                                  color: CooperativeColors.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Saved Addresses / Facility Sites Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            isInstitution ? Icons.apartment_rounded : Icons.pin_drop,
                            color: CooperativeColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              isInstitution ? 'Facility Sites & Locations' : s.get('saved_addresses'),
                              style: CooperativeTypography.headlineSm.copyWith(
                                color: CooperativeColors.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        EditAddressBottomSheet.show(
                          context,
                          isInstitution: isInstitution,
                          nextOfficeNumber: addresses.length + 1,
                          onSave: (newAddr) => viewModel.saveAddress(newAddr),
                        );
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: Text(isInstitution ? 'Add Site' : s.get('add_address')),
                      style: TextButton.styleFrom(
                        foregroundColor: CooperativeColors.primary,
                        backgroundColor: CooperativeColors.surfaceContainerHigh,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Address / Facility site list items
                ...addresses.map((addr) => _buildAddressCard(context, addr, isInstitution: isInstitution)),

                // Dedicated Trade Domain Coordinators Section for Institutions
                if (isInstitution) ...[
                  const SizedBox(height: 16),
                  _buildCoordinatorsSection(context),
                ],

                const SizedBox(height: 16),

                // App Language Selection Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CooperativeColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.translate, color: CooperativeColors.primary, size: 20),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              s.get('app_language'),
                              style: CooperativeTypography.headlineSm.copyWith(
                                color: CooperativeColors.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // 2x2 Language Grid with full overflow immunity
                      GridView.builder(
                        itemCount: AppLanguage.supportedLanguages.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 2.4,
                        ),
                        itemBuilder: (context, index) {
                          final lang = AppLanguage.supportedLanguages[index];
                          final isSelected = lang.code == selectedLang.code;
                          return InkWell(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              viewModel.selectLanguage(lang);
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected ? CooperativeColors.primary : CooperativeColors.surfaceContainer,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? CooperativeColors.primary : Colors.transparent,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          lang.localName,
                                          style: CooperativeTypography.labelMd.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: isSelected ? CooperativeColors.onPrimary : CooperativeColors.onSurface,
                                          ),
                                        ),
                                        Text(
                                          lang.name,
                                          style: CooperativeTypography.caption.copyWith(
                                            fontSize: 11,
                                            color: isSelected
                                                ? CooperativeColors.onPrimary.withValues(alpha: 0.8)
                                                : CooperativeColors.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                                    size: 18,
                                    color: isSelected ? CooperativeColors.onPrimary : CooperativeColors.outline,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Preferences & Notification Settings
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CooperativeColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.tune, color: CooperativeColors.primary, size: 20),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              s.get('notification_prefs'),
                              style: CooperativeTypography.headlineSm.copyWith(
                                color: CooperativeColors.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildToggleRow(
                        icon: Icons.chat,
                        iconColor: CooperativeColors.secondary,
                        title: s.get('whatsapp_updates'),
                        subtitle: s.get('whatsapp_sub'),
                        value: viewModel.whatsappUpdates,
                        onChanged: (val) => viewModel.toggleWhatsApp(val),
                      ),
                      const Divider(height: 16, thickness: 0.5, color: CooperativeColors.surfaceContainerHigh),
                      _buildToggleRow(
                        icon: Icons.sms,
                        iconColor: CooperativeColors.primary,
                        title: s.get('sms_otp'),
                        subtitle: s.get('sms_sub'),
                        value: viewModel.smsOtp,
                        onChanged: (val) => viewModel.toggleSms(val),
                      ),
                      const Divider(height: 16, thickness: 0.5, color: CooperativeColors.surfaceContainerHigh),
                      _buildToggleRow(
                        icon: Icons.notifications_active,
                        iconColor: CooperativeColors.primary,
                        title: s.get('booking_reminders'),
                        subtitle: s.get('reminders_sub'),
                        value: viewModel.bookingReminders,
                        onChanged: (val) => viewModel.toggleReminders(val),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Cooperative Civic Guarantee & Safety
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CooperativeColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.verified_user, color: CooperativeColors.secondary, size: 20),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              s.get('civic_guarantee'),
                              style: CooperativeTypography.headlineSm.copyWith(
                                color: CooperativeColors.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildNavRow(
                        icon: Icons.request_quote,
                        iconColor: CooperativeColors.secondary,
                        title: s.get('zero_commission_title'),
                        subtitle: s.get('zero_commission_sub'),
                      ),
                      const SizedBox(height: 8),
                      _buildNavRow(
                        icon: Icons.engineering,
                        iconColor: CooperativeColors.primary,
                        title: s.get('guild_standards_title'),
                        subtitle: s.get('guild_standards_sub'),
                      ),
                      const SizedBox(height: 8),
                      _buildNavRow(
                        icon: Icons.health_and_safety,
                        iconColor: CooperativeColors.secondary,
                        title: s.get('insurance_title'),
                        subtitle: s.get('insurance_sub'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Help & Municipal Support
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CooperativeColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.support_agent, color: CooperativeColors.primary, size: 20),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              s.get('help_support'),
                              style: CooperativeTypography.headlineSm.copyWith(
                                color: CooperativeColors.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Dialing 24/7 Co-op Helpline: 1800 425 0005...')),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.call, size: 18, color: CooperativeColors.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(s.get('support_helpline'),
                                    style: CooperativeTypography.bodyMd.copyWith(color: CooperativeColors.onSurface)),
                              ),
                              const SizedBox(width: 8),
                              Text('1800 425 0005',
                                  style: CooperativeTypography.labelSm.copyWith(
                                    color: CooperativeColors.primary,
                                    fontWeight: FontWeight.w700,
                                  )),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 16, thickness: 0.5, color: CooperativeColors.surfaceContainerHigh),
                      _buildNavRow(
                        icon: Icons.quiz,
                        iconColor: CooperativeColors.onSurfaceVariant,
                        title: s.get('faqs'),
                        subtitle: s.get('faqs_sub'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Log Out Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmLogout(context),
                    icon: const Icon(Icons.logout_rounded, color: CooperativeColors.error, size: 20),
                    label: Text(
                      s.get('log_out'),
                      style: CooperativeTypography.labelLg.copyWith(
                        color: CooperativeColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: CooperativeColors.surfaceContainerHigh,
                      side: BorderSide(color: CooperativeColors.error.withValues(alpha: 0.3)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Civic App Info Footer
                Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.public, size: 14, color: CooperativeColors.secondary),
                          const SizedBox(width: 4),
                          Text(
                            s.get('app_version_label'),
                            style: CooperativeTypography.caption.copyWith(
                              color: CooperativeColors.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        s.get('app_footer_desc'),
                        style: CooperativeTypography.caption.copyWith(
                          color: CooperativeColors.onSurfaceVariant,
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
      );
    }

  Widget _buildAddressCard(BuildContext context, SavedAddress addr, {bool isInstitution = false}) {
    final s = viewModel.strings;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CooperativeColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
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
                    Icon(
                      isInstitution
                          ? Icons.apartment_rounded
                          : (addr.label.toLowerCase() == 'home' ? Icons.home : Icons.apartment),
                      color: addr.isDefault ? CooperativeColors.primary : CooperativeColors.outline,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        addr.label,
                        style: CooperativeTypography.labelLg.copyWith(
                          color: CooperativeColors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (addr.isDefault) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: CooperativeColors.primaryFixed,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          s.get('default_badge'),
                          style: CooperativeTypography.caption.copyWith(
                            color: CooperativeColors.onPrimaryFixed,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      EditAddressBottomSheet.show(
                        context,
                        address: addr,
                        isInstitution: isInstitution,
                        onSave: (updated) => viewModel.saveAddress(updated),
                        onDelete: (id) => viewModel.deleteAddress(id),
                      );
                    },
                    icon: const Icon(Icons.edit, size: 18, color: CooperativeColors.onSurfaceVariant),
                    style: IconButton.styleFrom(
                      backgroundColor: CooperativeColors.surfaceContainerLow,
                      minimumSize: const Size(38, 38),
                    ),
                  ),
                  if (!addr.isDefault) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        viewModel.deleteAddress(addr.id);
                      },
                      icon: const Icon(Icons.delete, size: 18, color: CooperativeColors.error),
                      style: IconButton.styleFrom(
                        backgroundColor: CooperativeColors.errorContainer.withValues(alpha: 0.3),
                        minimumSize: const Size(38, 38),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  addr.fullAddress,
                  style: CooperativeTypography.bodyMd.copyWith(
                    color: CooperativeColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                if (addr.isDefault)
                  Row(
                    children: [
                      const Icon(Icons.bolt, color: CooperativeColors.secondary, size: 14),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          s.get('rapid_dispatch_badge'),
                          style: CooperativeTypography.caption.copyWith(
                            color: CooperativeColors.secondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      viewModel.setDefaultAddress(addr.id);
                    },
                    child: Text(
                      s.get('set_default'),
                      style: CooperativeTypography.labelSm.copyWith(
                        color: CooperativeColors.primary,
                        fontWeight: FontWeight.w700,
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

  Widget _buildCoordinatorsSection(BuildContext context) {
    final coordinators = viewModel.domainCoordinators;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CooperativeColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                    const Icon(Icons.supervisor_account_rounded, color: CooperativeColors.secondary, size: 22),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Service Domain Coordinators',
                        style: CooperativeTypography.headlineSm.copyWith(
                          color: CooperativeColors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: CooperativeColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${coordinators.length} Domains',
                  style: CooperativeTypography.caption.copyWith(
                    color: CooperativeColors.onSecondaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Trade-specific managers shared with dispatched workforce per domain.',
            style: CooperativeTypography.caption.copyWith(
              color: CooperativeColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          ...coordinators.map((coord) {
            IconData domainIcon;
            switch (coord.domain.toLowerCase()) {
              case 'electrical':
                domainIcon = Icons.bolt_rounded;
                break;
              case 'cleaner':
              case 'cleaning':
                domainIcon = Icons.cleaning_services_rounded;
                break;
              case 'plumbing':
                domainIcon = Icons.plumbing_rounded;
                break;
              case 'carpentry':
                domainIcon = Icons.handyman_rounded;
                break;
              case 'appliance':
                domainIcon = Icons.hvac_rounded;
                break;
              case 'painting':
                domainIcon = Icons.format_paint_rounded;
                break;
              default:
                domainIcon = Icons.business_center_rounded;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CooperativeColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: CooperativeColors.surfaceContainerHigh, width: 0.8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: CooperativeColors.primaryFixed,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(domainIcon, size: 18, color: CooperativeColors.onPrimaryFixed),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          coord.domainTitle,
                          style: CooperativeTypography.labelMd.copyWith(
                            fontWeight: FontWeight.w700,
                            color: CooperativeColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          coord.name,
                          style: CooperativeTypography.bodySm.copyWith(
                            fontWeight: FontWeight.w600,
                            color: CooperativeColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.phone_outlined, size: 13, color: CooperativeColors.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                coord.phone,
                                style: CooperativeTypography.caption.copyWith(color: CooperativeColors.onSurfaceVariant),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.email_outlined, size: 13, color: CooperativeColors.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                coord.email,
                                style: CooperativeTypography.caption.copyWith(color: CooperativeColors.onSurfaceVariant),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _showEditCoordinatorDialog(context, coord);
                    },
                    icon: const Icon(Icons.edit_outlined, size: 18, color: CooperativeColors.primary),
                    style: IconButton.styleFrom(
                      backgroundColor: CooperativeColors.surfaceContainer,
                      minimumSize: const Size(38, 38),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showEditCoordinatorDialog(BuildContext context, DomainCoordinator coord) {
    HapticFeedback.lightImpact();
    final nameCtrl = TextEditingController(text: coord.name);
    final phoneCtrl = TextEditingController(text: coord.phone);
    final emailCtrl = TextEditingController(text: coord.email);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: CooperativeColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 10,
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.badge_rounded, color: CooperativeColors.primary, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Edit ${coord.domainTitle}',
                      style: CooperativeTypography.headlineSm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: CooperativeColors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'This contact is shared with trade technicians assigned to ${coord.domainTitle}.',
                style: CooperativeTypography.caption.copyWith(color: CooperativeColors.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Coordinator Name',
                  prefixIcon: const Icon(Icons.person_outline),
                  filled: true,
                  fillColor: CooperativeColors.surfaceContainerLow,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Contact Phone Number',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  filled: true,
                  fillColor: CooperativeColors.surfaceContainerLow,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Official Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  filled: true,
                  fillColor: CooperativeColors.surfaceContainerLow,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final updated = coord.copyWith(
                      name: nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : coord.name,
                      phone: phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : coord.phone,
                      email: emailCtrl.text.trim().isNotEmpty ? emailCtrl.text.trim() : coord.email,
                    );
                    viewModel.setDomainCoordinator(updated);
                    HapticFeedback.mediumImpact();
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${coord.domainTitle} updated successfully!'),
                        backgroundColor: CooperativeColors.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Save Coordinator'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CooperativeColors.primary,
                    foregroundColor: CooperativeColors.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: CooperativeTypography.labelMd.copyWith(
                  color: CooperativeColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: CooperativeTypography.bodySm.copyWith(
                  color: CooperativeColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          activeThumbColor: CooperativeColors.primary,
          onChanged: (newVal) {
            HapticFeedback.selectionClick();
            onChanged(newVal);
          },
        ),
      ],
    );
  }

  Widget _buildNavRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: CooperativeColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: CooperativeTypography.labelMd.copyWith(
                    color: CooperativeColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: CooperativeTypography.caption.copyWith(
                    color: CooperativeColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: CooperativeColors.outline, size: 18),
        ],
      ),
    );
  }
}
