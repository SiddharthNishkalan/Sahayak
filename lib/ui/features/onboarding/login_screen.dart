import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../data/models/language.dart';
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
  final TextEditingController _signUpNameController = TextEditingController();
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
    _signUpEmailController.dispose();
    _signUpPhoneController.dispose();
    _signUpPasswordController.dispose();
    _signUpConfirmPasswordController.dispose();
    super.dispose();
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: SahayakColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
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
                  childAspectRatio: 2.8,
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
      );
    }
  }

  void _handleGoogleSignIn() {
    widget.viewModel.signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.viewModel.strings;

    return Scaffold(
      backgroundColor: SahayakColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: SahayakColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: SahayakColors.borderSubtle),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.home_work_rounded,
                                color: SahayakColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sahayak',
                                style: SahayakTypography.headlineSm(),
                              ),
                              Text(
                                s.get('coop_union').toUpperCase(),
                                style: SahayakTypography.caption(color: SahayakColors.secondary).copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Language Selector Pill
                      InkWell(
                        onTap: _showLanguagePicker,
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                  const SizedBox(height: 20),
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
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    s.get('welcome_title'),
                    style: SahayakTypography.displayHeroMobile(),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.get('welcome_sub'),
                    style: SahayakTypography.bodyMd(color: SahayakColors.onSurfaceVariant),
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

                  const SizedBox(height: 16),
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
                  const SizedBox(height: 16),
                  Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: SahayakColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(4),
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

                  const SizedBox(height: 20),

                  // Tab View Content
                  AnimatedBuilder(
                    animation: _tabController,
                    builder: (context, _) {
                      return _tabController.index == 0 ? _buildSignInForm(s) : _buildSignUpForm(s);
                    },
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
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
          const SizedBox(height: 14),

          Text(s.get('password_label'), style: SahayakTypography.labelMd()),
          const SizedBox(height: 6),
          TextFormField(
            controller: _signInPasswordController,
            obscureText: _obscureSignInPassword,
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
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: _rememberDevice,
                      activeColor: SahayakColors.primaryContainer,
                      onChanged: (val) => setState(() => _rememberDevice = val ?? true),
                    ),
                    Flexible(
                      child: Text(
                        s.get('remember_device'),
                        style: SahayakTypography.bodySm(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password reset link sent to registered email.')),
                  );
                },
                child: Text(
                  s.get('forgot_password'),
                  style: SahayakTypography.labelSm(color: SahayakColors.primary),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _handleSignIn,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(s.get('sign_in')),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpForm(dynamic s) {
    return Form(
      key: _signUpFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.get('full_name'), style: SahayakTypography.labelMd()),
          const SizedBox(height: 6),
          TextFormField(
            controller: _signUpNameController,
            decoration: const InputDecoration(
              hintText: 'e.g. Karthik Sivakumar',
              prefixIcon: Icon(Icons.person_outline_rounded, color: SahayakColors.outline),
            ),
            validator: (val) {
              if (val == null || val.trim().length < 2) return 'Please enter your name';
              return null;
            },
          ),
          const SizedBox(height: 14),

          Text(s.get('email_label'), style: SahayakTypography.labelMd()),
          const SizedBox(height: 6),
          TextFormField(
            controller: _signUpEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'user@example.com',
              prefixIcon: Icon(Icons.email_outlined, color: SahayakColors.outline),
            ),
            validator: (val) {
              if (val == null || !val.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 14),

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
          const SizedBox(height: 14),

          Text(s.get('neighborhood'), style: SahayakTypography.labelMd()),
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
                    child: Text(soc),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedSociety = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 14),

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
          const SizedBox(height: 14),

          Text(s.get('password_label'), style: SahayakTypography.labelMd()),
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
          ElevatedButton(
            onPressed: _handleSignUp,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(s.get('create_account')),
                const SizedBox(width: 8),
                const Icon(Icons.check_circle_outline, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
