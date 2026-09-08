import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../data/models/language.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/app_repository.dart';
import '../../../app_view_model.dart';

class LoginScreen extends StatefulWidget {
  final AppViewModel viewModel;

  const LoginScreen({
    super.key,
    required this.viewModel,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _signInFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();

  // Sign In Controllers
  final TextEditingController _signInEmailController = TextEditingController();
  final TextEditingController _signInPasswordController = TextEditingController();
  bool _obscureSignInPassword = true;
  bool _rememberDevice = true;

  // Sign Up Controllers
  UserAccountType _selectedAccountType = UserAccountType.household;
  final TextEditingController _signUpNameController = TextEditingController();
  final TextEditingController _signUpOrgNameController = TextEditingController();
  final TextEditingController _signUpSiteAddressController = TextEditingController();
  final TextEditingController _signUpEmailController = TextEditingController();
  final TextEditingController _signUpPhoneController = TextEditingController();
  final TextEditingController _signUpPasswordController = TextEditingController();
  final TextEditingController _signUpConfirmPasswordController = TextEditingController();
  String _selectedSociety = AppRepository.supportedSocieties.first;
  bool _obscureSignUpPassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _signInEmailController.dispose();
    _signInPasswordController.dispose();
    _signUpNameController.dispose();
    _signUpOrgNameController.dispose();
    _signUpSiteAddressController.dispose();
    _signUpEmailController.dispose();
    _signUpPhoneController.dispose();
    _signUpPasswordController.dispose();
    _signUpConfirmPasswordController.dispose();
    super.dispose();
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: SahayakColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Community Dialect',
                  style: SahayakTypography.labelMd(),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  childAspectRatio: 2.4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  physics: const NeverScrollableScrollPhysics(),
                  children: AppLanguage.supportedLanguages.map((lang) {
                    final isSel = lang.code == widget.viewModel.selectedLanguage.code;
                    return InkWell(
                      onTap: () {
                        widget.viewModel.selectLanguage(lang);
                        Navigator.pop(ctx);
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel ? SahayakColors.primaryFixed : SahayakColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${lang.localName} (${lang.code.toUpperCase()})',
                          style: SahayakTypography.labelMd(
                            color: isSel ? SahayakColors.onPrimaryFixed : SahayakColors.onSurface,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleSignIn() {
    if (_signInFormKey.currentState?.validate() ?? false) {
      widget.viewModel.signIn(
        _signInEmailController.text.trim(),
        _signInPasswordController.text,
      );
    }
  }

  void _handleSignUp() {
    if (_signUpFormKey.currentState?.validate() ?? false) {
      widget.viewModel.signUp(
        name: _signUpNameController.text.trim(),
        email: _signUpEmailController.text.trim(),
        phone: _signUpPhoneController.text.trim(),
        password: _signUpPasswordController.text,
        society: _selectedSociety,
        accountType: _selectedAccountType,
        organizationName: _selectedAccountType == UserAccountType.institution
            ? _signUpOrgNameController.text.trim()
            : null,
        siteAddress: _selectedAccountType == UserAccountType.institution
            ? _signUpSiteAddressController.text.trim()
            : null,
      );
    }
  }

  void _handleGoogleSignIn() {
    widget.viewModel.signInWithGoogle(
      accountType: _selectedAccountType,
      organizationName: _selectedAccountType == UserAccountType.institution
          ? 'Apex Technology Park'
          : null,
    );
  }

  Widget _buildSignUpForm(dynamic s) {
    final isInstitution = _selectedAccountType == UserAccountType.institution;

    return Form(
      key: _signUpFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Account Type Segmented Selector
          Text('Account Type', style: SahayakTypography.labelMd()),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: SahayakColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedAccountType = UserAccountType.household),
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: !isInstitution ? SahayakColors.surfaceContainerLowest : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: !isInstitution
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.home_rounded,
                            size: 16,
                            color: !isInstitution ? SahayakColors.primary : SahayakColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Household',
                            style: SahayakTypography.labelSm(
                              color: !isInstitution ? SahayakColors.primary : SahayakColors.onSurfaceVariant,
                            ).copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedAccountType = UserAccountType.institution),
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isInstitution ? SahayakColors.surfaceContainerLowest : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: isInstitution
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.business_rounded,
                            size: 16,
                            color: isInstitution ? SahayakColors.secondary : SahayakColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Institution',
                            style: SahayakTypography.labelSm(
                              color: isInstitution ? SahayakColors.secondary : SahayakColors.onSurfaceVariant,
                            ).copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Institution specific fields
          if (isInstitution) ...[
            Text('Organization / Institution Name *', style: SahayakTypography.labelMd()),
            const SizedBox(height: 6),
            TextFormField(
              controller: _signUpOrgNameController,
              decoration: const InputDecoration(
                hintText: 'e.g. Apex Technology Park / St. Mary School',
                prefixIcon: Icon(Icons.apartment_rounded, color: SahayakColors.secondary),
              ),
              validator: (val) {
                if (val == null || val.trim().length < 2) return 'Please enter organization name';
                return null;
              },
            ),
            const SizedBox(height: 12),

            Text('Primary Site / Campus Address *', style: SahayakTypography.labelMd()),
            const SizedBox(height: 6),
            TextFormField(
              controller: _signUpSiteAddressController,
              decoration: const InputDecoration(
                hintText: 'e.g. Block B Main Campus, Avinashi Road',
                prefixIcon: Icon(Icons.location_on_outlined, color: SahayakColors.secondary),
              ),
              validator: (val) {
                if (val == null || val.trim().length < 5) return 'Please enter initial site address';
                return null;
              },
            ),
            const SizedBox(height: 12),
          ],

          Text(
            isInstitution ? 'Representative / Admin Name *' : s.get('full_name'),
            style: SahayakTypography.labelMd(),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _signUpNameController,
            decoration: InputDecoration(
              hintText: isInstitution ? 'e.g. Rajesh Ramanathan (Facilities Mgr)' : 'e.g. Karthik Sivakumar',
              prefixIcon: const Icon(Icons.person_outline_rounded, color: SahayakColors.outline),
            ),
            validator: (val) {
              if (val == null || val.trim().length < 2) return 'Please enter contact name';
              return null;
            },
          ),
          const SizedBox(height: 12),

          Text(
            isInstitution ? 'Official Corporate Email *' : s.get('email_label'),
            style: SahayakTypography.labelMd(),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _signUpEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: isInstitution ? 'facilities@company.org' : 'user@example.com',
              prefixIcon: const Icon(Icons.email_outlined, color: SahayakColors.outline),
            ),
            validator: (val) {
              if (val == null || !val.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 12),

          Text(s.get('phone_number'), style: SahayakTypography.labelMd()),
          const SizedBox(height: 6),
          TextFormField(
            controller: _signUpPhoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              hintText: '+91 98432 00000',
              prefixIcon: Icon(Icons.phone_outlined, color: SahayakColors.outline),
            ),
            validator: (val) {
              if (val == null || val.trim().length < 10) return 'Enter a valid phone number';
              return null;
            },
          ),
          const SizedBox(height: 12),

          Text(
            isInstitution ? 'City Ward / Cluster' : s.get('neighborhood'),
            style: SahayakTypography.labelMd(),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: SahayakColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SahayakColors.borderSubtle),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedSociety,
                isExpanded: true,
                icon: const Icon(Icons.location_city_rounded, color: SahayakColors.primary),
                items: AppRepository.supportedSocieties.map((soc) {
                  return DropdownMenuItem(
                    value: soc,
                    child: Text(soc, style: SahayakTypography.bodyMd()),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedSociety = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          Text(s.get('password_label'), style: SahayakTypography.labelMd()),
          const SizedBox(height: 6),
          TextFormField(
            controller: _signUpPasswordController,
            obscureText: _obscureSignUpPassword,
            decoration: InputDecoration(
              hintText: '••••••••',
              prefixIcon: const Icon(Icons.lock_outline_rounded, color: SahayakColors.outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureSignUpPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: SahayakColors.outline,
                ),
                onPressed: () => setState(() => _obscureSignUpPassword = !_obscureSignUpPassword),
              ),
            ),
            validator: (val) {
              if (val == null || val.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 12),

          Text('Confirm Password', style: SahayakTypography.labelMd()),
          const SizedBox(height: 6),
          TextFormField(
            controller: _signUpConfirmPasswordController,
            obscureText: _obscureSignUpPassword,
            decoration: const InputDecoration(
              hintText: '••••••••',
              prefixIcon: Icon(Icons.lock_reset_rounded, color: SahayakColors.outline),
            ),
            validator: (val) {
              if (val != _signUpPasswordController.text) return 'Passwords do not match';
              return null;
            },
          ),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _handleSignUp,
              style: isInstitution
                  ? ElevatedButton.styleFrom(
                      backgroundColor: SahayakColors.secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    )
                  : ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      isInstitution ? 'Create Institution Account' : s.get('create_account'),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.check_circle_outline, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.viewModel.strings;

    return Scaffold(
      backgroundColor: SahayakColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                  // Top Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: SahayakColors.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: SahayakColors.borderSubtle),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: Image.asset(
                                'assets/images/logo_mark.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                  Icons.home_work_rounded,
                                  size: 20,
                                  color: SahayakColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Work Solute',
                                    style: SahayakTypography.labelLg(),
                                  ),
                                  Text(
                                    s.get('coop_union').toUpperCase(),
                                    style: SahayakTypography.caption(color: SahayakColors.secondary).copyWith(
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
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
                      // Language Selector Pill
                      InkWell(
                        onTap: _showLanguagePicker,
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          constraints: const BoxConstraints(minHeight: 36),
                          decoration: BoxDecoration(
                            color: SahayakColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🌐', style: TextStyle(fontSize: 12)),
                              const SizedBox(width: 4),
                              Text(
                                widget.viewModel.selectedLanguage.code.toUpperCase(),
                                style: SahayakTypography.labelSm(),
                              ),
                              const Icon(Icons.expand_more, size: 16, color: SahayakColors.onSurface),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Hero Header Area
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: SahayakColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_rounded, size: 14, color: SahayakColors.secondary),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            s.get('municipal_network'),
                            style: SahayakTypography.caption(color: SahayakColors.secondary).copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s.get('welcome_title'),
                    style: SahayakTypography.headlineLg(),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.get('welcome_sub'),
                    style: SahayakTypography.bodySm(),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Google Sign-In Button
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: _handleGoogleSignIn,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: SahayakColors.surfaceContainerLowest,
                        side: const BorderSide(color: SahayakColors.borderSubtle),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.g_mobiledata_rounded, size: 28, color: Color(0xFF4285F4)),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              s.get('continue_google'),
                              style: SahayakTypography.labelMd(color: SahayakColors.onSurface).copyWith(fontWeight: FontWeight.w700),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Expanded(child: Divider(color: SahayakColors.borderSubtle)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          s.get('or_use_email').toUpperCase(),
                          style: SahayakTypography.caption(color: SahayakColors.outline).copyWith(letterSpacing: 1),
                        ),
                      ),
                      const Expanded(child: Divider(color: SahayakColors.borderSubtle)),
                    ],
                  ),

                  // Tab Bar (Sign In / Sign Up)
                  const SizedBox(height: 14),
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: SahayakColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: SahayakColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      labelColor: SahayakColors.primary,
                      unselectedLabelColor: SahayakColors.onSurfaceVariant,
                      labelStyle: SahayakTypography.labelMd().copyWith(fontWeight: FontWeight.w700),
                      unselectedLabelStyle: SahayakTypography.labelMd(),
                      dividerColor: Colors.transparent,
                      tabs: [
                        Tab(text: s.get('sign_in')),
                        Tab(text: s.get('create_account')),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tab View Content
                  AnimatedBuilder(
                    animation: _tabController,
                    builder: (context, _) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: _tabController.index == 0
                            ? _buildSignInForm(s)
                            : _buildSignUpForm(s),
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      }

  Widget _buildSignInForm(dynamic s) {
    return Form(
      key: _signInFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.get('email_label'), style: SahayakTypography.labelMd()),
          const SizedBox(height: 6),
          TextFormField(
            controller: _signInEmailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: 'name@society.in',
              prefixIcon: const Icon(Icons.email_outlined, color: SahayakColors.outline),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Please enter your email address';
              if (!val.contains('@') || !val.contains('.')) return 'Please enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 12),

          Text(s.get('password_label'), style: SahayakTypography.labelMd()),
          const SizedBox(height: 6),
          TextFormField(
            controller: _signInPasswordController,
            obscureText: _obscureSignInPassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleSignIn(),
            decoration: InputDecoration(
              hintText: '••••••••',
              prefixIcon: const Icon(Icons.lock_outline_rounded, color: SahayakColors.outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureSignInPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: SahayakColors.outline,
                ),
                onPressed: () => setState(() => _obscureSignInPassword = !_obscureSignInPassword),
              ),
            ),
            validator: (val) {
              if (val == null || val.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),

          // Remember & Forgot
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _rememberDevice,
                        activeColor: SahayakColors.primaryContainer,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onChanged: (val) => setState(() => _rememberDevice = val ?? true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        s.get('remember_device'),
                        style: SahayakTypography.bodySm(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password reset link sent to registered email.')),
                  );
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  minimumSize: const Size(44, 36),
                ),
                child: Text(
                  s.get('forgot_password'),
                  style: SahayakTypography.labelSm(color: SahayakColors.primary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _handleSignIn,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(s.get('sign_in')),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
