import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../data/models/language.dart';
import '../../../app_view_model.dart';

import 'package:flutter/services.dart';

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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    // Brand Icon & Title
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: SahayakColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: SahayakColors.borderSubtle),
                        boxShadow: [
                          BoxShadow(
                            color: SahayakColors.primary.withValues(alpha: 0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Image.asset(
                        'assets/images/logo_mark.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.home_work_rounded,
                          size: 36,
                          color: SahayakColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Work Solute',
                      style: SahayakTypography.headlineMd().copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s.get('select_language'),
                      style: SahayakTypography.headlineSm(color: SahayakColors.primary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        s.get('select_language_subtitle'),
                        style: SahayakTypography.bodySm(),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 4 Simple Language Options
                    ...AppLanguage.supportedLanguages.map((lang) {
                      final isSelected = lang.code == selectedLang.code;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            viewModel.selectLanguage(lang);
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                                  style: SahayakTypography.headlineSm(
                                    color: isSelected ? SahayakColors.primary : SahayakColors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    lang.localName,
                                    style: SahayakTypography.bodyLg(
                                      color: isSelected ? SahayakColors.primary : SahayakColors.onSurface,
                                    ).copyWith(
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                    ),
                                  ),
                                ),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: Icon(
                                    isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                    key: ValueKey(isSelected),
                                    color: isSelected ? SahayakColors.primary : SahayakColors.outline,
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Anchored Continue Button in Safe Bottom Area
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: SahayakColors.surface,
                border: Border(top: BorderSide(color: SahayakColors.borderSubtle, width: 0.5)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    viewModel.navigateTo(AppScreen.login);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SahayakColors.primary,
                    foregroundColor: SahayakColors.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    selectedLang.continueActionText,
                    style: SahayakTypography.labelLg(color: SahayakColors.onPrimary),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
