import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../data/models/language.dart';
import '../../../app_view_model.dart';

class LanguageSelectionScreen extends StatelessWidget {
  final AppViewModel viewModel;

  const LanguageSelectionScreen({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final selectedLang = viewModel.selectedLanguage;
    final s = viewModel.strings;

    return Scaffold(
      backgroundColor: SahayakColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                children: [
                  const Spacer(flex: 1),

                  // Brand Icon & Title
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: SahayakColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: SahayakColors.borderSubtle),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.home_work_rounded,
                        size: 36,
                        color: SahayakColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Sahayak',
                    style: SahayakTypography.headlineMd().copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s.get('select_language'),
                    style: SahayakTypography.headlineSm(color: SahayakColors.primary),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 28),

                  // 4 Simple Language Options
                  ...AppLanguage.supportedLanguages.map((lang) {
                    final isSelected = lang.code == selectedLang.code;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => viewModel.selectLanguage(lang),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? SahayakColors.primaryFixed.withValues(alpha: 0.3)
                                : SahayakColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? SahayakColors.primary : SahayakColors.borderSubtle,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                lang.avatarChar,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? SahayakColors.primary : SahayakColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  lang.localName,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                    color: isSelected ? SahayakColors.primary : SahayakColors.onSurface,
                                  ),
                                ),
                              ),
                              Icon(
                                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                                color: isSelected ? SahayakColors.primary : SahayakColors.outline,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  const Spacer(flex: 2),

                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => viewModel.navigateTo(AppScreen.login),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SahayakColors.primary,
                        foregroundColor: SahayakColors.onPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        selectedLang.continueActionText,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
