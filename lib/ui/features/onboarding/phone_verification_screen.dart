import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../app_view_model.dart';

class PhoneVerificationScreen extends StatefulWidget {
  final AppViewModel viewModel;

  const PhoneVerificationScreen({
    super.key,
    required this.viewModel,
  });

  @override
  State<PhoneVerificationScreen> createState() => _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  int _secondsRemaining = 24;
  Timer? _timer;
  bool _showToast = true;

  @override
  void initState() {
    super.initState();
    // Default initial mock digits: 4, 8, 2, 9
    _controllers[0].text = '4';
    _controllers[1].text = '8';
    _controllers[2].text = '2';
    _controllers[3].text = '9';

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsRemaining = 24;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.viewModel.strings;

    return Scaffold(
      backgroundColor: SahayakColors.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => widget.viewModel.navigateTo(AppScreen.login),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: SahayakColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: SahayakColors.borderSubtle),
              ),
              padding: const EdgeInsets.all(3),
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.home_work_rounded,
                  size: 20,
                  color: SahayakColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(s.get('otp_verification_title'), style: SahayakTypography.headlineSm()),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Toast notification
                  if (_showToast) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: SahayakColors.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: SahayakColors.secondary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${s.get('sms_sent_to')} +91 98432 10842',
                              style: SahayakTypography.labelSm(color: SahayakColors.onSecondaryContainer),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            color: SahayakColors.onSecondaryContainer,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => setState(() => _showToast = false),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Step tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: SahayakColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_user_rounded, size: 14, color: SahayakColors.primary),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            s.get('step_security'),
                            style: SahayakTypography.caption(color: SahayakColors.primary).copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    s.get('verify_phone_title'),
                    style: SahayakTypography.headlineLg(),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    s.get('verify_phone_desc'),
                    style: SahayakTypography.bodyMd(color: SahayakColors.onSurfaceVariant),
                  ),

                  // Phone Number Card
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: SahayakColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: SahayakColors.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${s.get('mobile_number')} *', style: SahayakTypography.labelSm(color: SahayakColors.onSurfaceVariant)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: SahayakColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: SahayakColors.surfaceContainerLowest,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  children: [
                                    Text('🇮🇳', style: TextStyle(fontSize: 14)),
                                    SizedBox(width: 4),
                                    Text('+91', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '98432 10842',
                                  style: SahayakTypography.headlineSm().copyWith(letterSpacing: 1.5),
                                ),
                              ),
                              Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  color: SahayakColors.secondaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check, size: 14, color: SahayakColors.secondary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, size: 14, color: SahayakColors.outline),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(s.get('otp_sms_sent_desc'), style: SahayakTypography.caption()),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 6-Digit OTP Boxes Section
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
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
                                s.get('enter_otp'),
                                style: SahayakTypography.labelMd(),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(s.get('secure_pin'), style: SahayakTypography.caption(color: SahayakColors.primary).copyWith(fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (index) {
                            return Flexible(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                height: 56,
                                child: TextField(
                                  controller: _controllers[index],
                                  focusNode: _focusNodes[index],
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  maxLength: 1,
                                  style: SahayakTypography.headlineMd(color: SahayakColors.onSurface),
                                  decoration: InputDecoration(
                                    counterText: '',
                                    contentPadding: EdgeInsets.zero,
                                    fillColor: _controllers[index].text.isNotEmpty
                                        ? SahayakColors.surfaceContainerLowest
                                        : SahayakColors.surfaceContainerLow,
                                  ),
                                  onChanged: (val) => _onDigitChanged(index, val),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.timer_outlined, size: 16, color: SahayakColors.outline),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      '${s.get('resend_otp_in')} 00:${_secondsRemaining.toString().padLeft(2, '0')}',
                                      style: SahayakTypography.labelSm(color: SahayakColors.onSurfaceVariant),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: _secondsRemaining == 0 ? _startTimer : null,
                              child: Text(
                                s.get('resend_sms'),
                                style: SahayakTypography.labelSm(
                                  color: _secondsRemaining == 0 ? SahayakColors.primary : SahayakColors.outline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: SahayakColors.secondary),
                            label: Text(
                              s.get('whatsapp_otp'),
                              style: SahayakTypography.labelSm(color: SahayakColors.secondary),
                            ),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Data Protection Callout
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: SahayakColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: SahayakColors.secondaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.security_rounded,
                            color: SahayakColors.onSecondaryContainer,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.get('zero_spam_title'),
                                style: SahayakTypography.labelMd(),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                s.get('zero_spam_desc'),
                                style: SahayakTypography.bodySm(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Actions
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => widget.viewModel.navigateTo(AppScreen.mainShell),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(s.get('verify_continue')),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: () => widget.viewModel.navigateTo(AppScreen.login),
                      child: Text(
                        s.get('change_phone'),
                        style: SahayakTypography.labelMd(color: SahayakColors.onSurfaceVariant),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
