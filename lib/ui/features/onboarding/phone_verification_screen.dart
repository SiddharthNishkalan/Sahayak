import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    HapticFeedback.lightImpact();
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
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          onPressed: () {
            HapticFeedback.lightImpact();
            widget.viewModel.navigateTo(AppScreen.login);
          },
        ),
        title: Text(s.get('otp_verification_title'), style: SahayakTypography.labelLg()),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // Toast notification
                  if (_showToast) ...[
                    Container(
                      padding: const EdgeInsets.only(left: 14, top: 10, bottom: 10, right: 4),
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
                            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                            onPressed: () => setState(() => _showToast = false),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
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
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    s.get('verify_phone_title'),
                    style: SahayakTypography.headlineMd(),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.get('verify_phone_desc'),
                    style: SahayakTypography.bodySm(),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Phone Number Card
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: SahayakColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
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
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: SahayakColors.surfaceContainerLowest,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('🇮🇳', style: TextStyle(fontSize: 14)),
                                    const SizedBox(width: 4),
                                    Text('+91', style: SahayakTypography.labelMd()),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '98432 10842',
                                  style: SahayakTypography.labelLg().copyWith(letterSpacing: 1.5),
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
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: SahayakColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
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
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(s.get('secure_pin'), style: SahayakTypography.caption(color: SahayakColors.primary).copyWith(fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (index) {
                            return Flexible(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                height: 50,
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
                        const SizedBox(height: 12),
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
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: _secondsRemaining == 0 ? _startTimer : null,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                minimumSize: const Size(44, 36),
                              ),
                              child: Text(
                                s.get('resend_sms'),
                                style: SahayakTypography.labelSm(
                                  color: _secondsRemaining == 0 ? SahayakColors.primary : SahayakColors.outline,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                            style: TextButton.styleFrom(
                              minimumSize: const Size(44, 36),
                            ),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Data Protection Callout
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: SahayakColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: const BoxDecoration(
                            color: SahayakColors.secondaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.security_rounded,
                            color: SahayakColors.onSecondaryContainer,
                            size: 18,
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

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Anchored Bottom Actions
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: SahayakColors.surface,
                border: Border(top: BorderSide(color: SahayakColors.borderSubtle, width: 0.5)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.heavyImpact();
                        widget.viewModel.navigateTo(AppScreen.mainShell);
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(s.get('verify_continue')),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      widget.viewModel.navigateTo(AppScreen.login);
                    },
                    style: TextButton.styleFrom(
                      minimumSize: const Size(double.infinity, 40),
                    ),
                    child: Text(
                      s.get('change_phone'),
                      style: SahayakTypography.labelSm(color: SahayakColors.onSurfaceVariant),
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
}
