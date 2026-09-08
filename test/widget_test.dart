import 'package:flutter_test/flutter_test.dart';
import 'package:work_solute/main.dart';
import 'package:work_solute/app_view_model.dart';
import 'package:work_solute/data/repositories/app_repository.dart';
import 'package:work_solute/data/models/language.dart';
import 'package:work_solute/ui/shared_widgets/bottom_nav_bar.dart';

void main() {
  testWidgets('WorkSoluteApp loads language selection and navigates through onboarding', (WidgetTester tester) async {
    final repository = AppRepository();
    final viewModel = AppViewModel(repository: repository);

    await tester.pumpWidget(WorkSoluteApp(viewModel: viewModel));
    await tester.pumpAndSettle();

    // Verify Language Selection Screen is shown first
    expect(find.text('Select your language'), findsOneWidget);
    expect(find.text('English'), findsWidgets);
    expect(find.text('தமிழ்'), findsWidgets);

    // Switch to Tamil
    final tamil = AppLanguage.supportedLanguages.firstWhere((l) => l.code == 'ta');
    viewModel.selectLanguage(tamil);
    await tester.pumpAndSettle();
    expect(viewModel.selectedLanguage.code, 'ta');

    // Tap continue to go to Login
    final continueButton = find.text(tamil.continueActionText);
    expect(continueButton, findsOneWidget);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    // Verify Login Screen in Tamil
    expect(find.text(viewModel.strings.get('municipal_network')), findsOneWidget);
    expect(find.text('Work Solute'), findsWidgets);

    // Proceed to Phone Verification
    viewModel.navigateTo(AppScreen.phoneVerification);
    await tester.pumpAndSettle();
    expect(find.text(viewModel.strings.get('otp_verification_title')), findsOneWidget);

    // Proceed to MainShell
    viewModel.navigateTo(AppScreen.mainShell);
    await tester.pumpAndSettle();

    // Verify MainShell is visible with home tab
    expect(find.byType(CooperativeBottomNavBar), findsOneWidget);
  });
}
