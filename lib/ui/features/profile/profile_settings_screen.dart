import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../data/models/address.dart';
import '../../../data/models/language.dart';
import '../../../data/models/booking.dart';
import '../../../data/repositories/app_repository.dart';
import '../../../app_view_model.dart';
import 'edit_address_bottom_sheet.dart';
import 'tax_invoice_dialog.dart';

class ProfileSettingsScreen extends StatelessWidget {
  final AppViewModel viewModel;
  final VoidCallback? onLogout;

  const ProfileSettingsScreen({
    super.key,
    required this.viewModel,
    this.onLogout,
  });

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CooperativeColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          viewModel.strings.get('confirm_logout'),
          style: CooperativeTypography.headlineSm.copyWith(
            color: CooperativeColors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          viewModel.strings.get('logout_confirm_msg'),
          style: CooperativeTypography.bodySm.copyWith(
            color: CooperativeColors.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(viewModel.strings.get('cancel'), style: const TextStyle(color: CooperativeColors.outline)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              viewModel.signOut();
              if (onLogout != null) {
                onLogout!();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CooperativeColors.error,
              foregroundColor: CooperativeColors.onPrimary,
            ),
            child: Text(viewModel.strings.get('log_out')),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final nameController = TextEditingController(text: viewModel.currentUser?.name ?? viewModel.userName);
    final phoneController = TextEditingController(text: viewModel.currentUser?.phone ?? viewModel.userPhone);
    String selectedSociety = viewModel.currentUser?.society ?? viewModel.currentSociety;
    if (!AppRepository.supportedSocieties.contains(selectedSociety)) {
      selectedSociety = AppRepository.supportedSocieties.first;
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: CooperativeColors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            viewModel.strings.get('edit_profile'),
            style: CooperativeTypography.headlineSm.copyWith(
              color: CooperativeColors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  viewModel.strings.get('full_name'),
                  style: CooperativeTypography.labelMd.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: viewModel.strings.get('full_name'),
                    prefixIcon: const Icon(Icons.person_outline, size: 20),
                    filled: true,
                    fillColor: CooperativeColors.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  viewModel.strings.get('neighborhood'),
                  style: CooperativeTypography.labelMd.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: CooperativeColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
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
                          setDialogState(() {
                            selectedSociety = val;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(viewModel.strings.get('cancel'), style: const TextStyle(color: CooperativeColors.outline)),
            ),
            ElevatedButton(
              onPressed: () {
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
              ),
              child: Text(viewModel.strings.get('save_changes')),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final addresses = viewModel.repository.addresses;
    final selectedLang = viewModel.selectedLanguage;
    final s = viewModel.strings;

    return Material(
      color: CooperativeColors.surface,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
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
                    borderRadius: BorderRadius.circular(16),
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
                                      onPressed: () => _showEditProfileDialog(context),
                                      style: IconButton.styleFrom(
                                        backgroundColor: CooperativeColors.surfaceContainerHigh,
                                        minimumSize: const Size(32, 32),
                                        padding: const EdgeInsets.all(6),
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
                                      Text(
                                          viewModel.currentUser?.phone.isNotEmpty == true
                                              ? viewModel.currentUser!.phone
                                              : viewModel.userPhone,
                                          style: CooperativeTypography.labelMd.copyWith(
                                            color: CooperativeColors.onSurface,
                                            fontWeight: FontWeight.w700,
                                          )),
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
                                      Text(
                                          viewModel.currentUser?.email.isNotEmpty == true
                                              ? viewModel.currentUser!.email
                                              : viewModel.userEmail,
                                          style: CooperativeTypography.labelMd.copyWith(
                                            color: CooperativeColors.onSurface,
                                            fontWeight: FontWeight.w700,
                                          )),
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
                    borderRadius: BorderRadius.circular(16),
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
                          onTap: () => viewModel.switchTab(ShellTab.bookings),
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
                          onTap: () => viewModel.switchTab(ShellTab.bookings),
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

                // Saved Addresses Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.pin_drop, color: CooperativeColors.primary, size: 20),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              s.get('saved_addresses'),
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
                        EditAddressBottomSheet.show(
                          context,
                          onSave: (newAddr) => viewModel.saveAddress(newAddr),
                        );
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: Text(s.get('add_address')),
                      style: TextButton.styleFrom(
                        foregroundColor: CooperativeColors.primary,
                        backgroundColor: CooperativeColors.surfaceContainerHigh,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Address list items
                ...addresses.map((addr) => _buildAddressCard(context, addr)),

                const SizedBox(height: 16),

                // Cooperative Membership & Finance
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CooperativeColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
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
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.account_balance, color: CooperativeColors.primary, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Cooperative Finance & Shares',
                                style: CooperativeTypography.headlineSm.copyWith(
                                  color: CooperativeColors.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: CooperativeColors.secondaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Active Member',
                              style: CooperativeTypography.caption.copyWith(
                                color: CooperativeColors.onSecondaryContainer,
                                fontWeight: FontWeight.w700,
                              ).copyWith(fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildPlainSettingsTile(
                        icon: Icons.savings_outlined,
                        iconColor: CooperativeColors.secondary,
                        title: 'Member Share Capital',
                        subtitle: '10 Voting Shares in Municipal Guild',
                        trailingText: '₹1,000',
                      ),
                      const Divider(height: 16, thickness: 0.5, color: CooperativeColors.surfaceContainerHigh),
                      _buildPlainSettingsTile(
                        icon: Icons.pie_chart_outline,
                        iconColor: CooperativeColors.tertiary,
                        title: 'Annual Patronage Dividend',
                        subtitle: 'FY25-26 Cooperative Surplus Pool',
                        trailingText: '8.4% Return',
                      ),
                      const Divider(height: 16, thickness: 0.5, color: CooperativeColors.surfaceContainerHigh),
                      _buildPlainSettingsTile(
                        icon: Icons.receipt_long_outlined,
                        iconColor: CooperativeColors.primary,
                        title: 'Tax Invoices & GST Receipts',
                        subtitle: 'Official tax invoice with cooperative GSTIN',
                        onTap: () => TaxInvoiceDialog.show(context),
                        showChevron: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // App Language Selection Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CooperativeColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
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
                          childAspectRatio: 2.6,
                        ),
                        itemBuilder: (context, index) {
                          final lang = AppLanguage.supportedLanguages[index];
                          final isSelected = lang.code == selectedLang.code;
                          return InkWell(
                            onTap: () => viewModel.selectLanguage(lang),
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
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: isSelected ? CooperativeColors.onPrimary : CooperativeColors.onSurface,
                                          ),
                                        ),
                                        Text(
                                          lang.name,
                                          style: TextStyle(
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
                    borderRadius: BorderRadius.circular(16),
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
                    borderRadius: BorderRadius.circular(16),
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
                    borderRadius: BorderRadius.circular(16),
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
                OutlinedButton.icon(
                  onPressed: () => _confirmLogout(context),
                  icon: const Icon(Icons.logout, color: CooperativeColors.error, size: 20),
                  label: Text(s.get('log_out'), style: const TextStyle(color: CooperativeColors.error)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: CooperativeColors.surfaceContainerHigh,
                    side: BorderSide(color: CooperativeColors.error.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, SavedAddress addr) {
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
                      addr.label.toLowerCase() == 'home' ? Icons.home : Icons.apartment,
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
                      EditAddressBottomSheet.show(
                        context,
                        address: addr,
                        onSave: (updated) => viewModel.saveAddress(updated),
                        onDelete: (id) => viewModel.deleteAddress(id),
                      );
                    },
                    icon: const Icon(Icons.edit, size: 18, color: CooperativeColors.onSurfaceVariant),
                    style: IconButton.styleFrom(
                      backgroundColor: CooperativeColors.surfaceContainerLow,
                      minimumSize: const Size(32, 32),
                    ),
                  ),
                  if (!addr.isDefault) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: () => viewModel.deleteAddress(addr.id),
                      icon: const Icon(Icons.delete, size: 18, color: CooperativeColors.error),
                      style: IconButton.styleFrom(
                        backgroundColor: CooperativeColors.errorContainer.withValues(alpha: 0.3),
                        minimumSize: const Size(32, 32),
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
                    onTap: () => viewModel.setDefaultAddress(addr.id),
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
          onChanged: onChanged,
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
        borderRadius: BorderRadius.circular(10),
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

  Widget _buildPlainSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    String? trailingText,
    VoidCallback? onTap,
    bool showChevron = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
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
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: CooperativeTypography.caption.copyWith(
                      color: CooperativeColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (trailingText != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: CooperativeColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  trailingText,
                  style: CooperativeTypography.labelSm.copyWith(
                    color: CooperativeColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
            if (showChevron) ...[
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, size: 18, color: CooperativeColors.outline),
            ],
          ],
        ),
      ),
    );
  }
}
