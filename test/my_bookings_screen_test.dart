import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sahayak_home_services/app_view_model.dart';
import 'package:sahayak_home_services/data/repositories/app_repository.dart';
import 'package:sahayak_home_services/main.dart';
import 'package:sahayak_home_services/ui/features/bookings_list/my_bookings_screen.dart';

void main() {
  testWidgets('MyBookingsScreen renders upcoming bookings and switches tabs without errors', (WidgetTester tester) async {
    final repository = AppRepository();
    final viewModel = AppViewModel(repository: repository);

    await tester.pumpWidget(
      MaterialApp(
        home: MyBookingsScreen(
          viewModel: viewModel,
          repository: repository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify header and tab labels
    expect(find.text('My Bookings'), findsOneWidget);
    expect(find.textContaining('Upcoming'), findsOneWidget);
    expect(find.textContaining('Completed'), findsOneWidget);
    expect(find.textContaining('Cancelled'), findsOneWidget);

    // Verify upcoming booking card elements
    expect(find.text('Plumbing Service'), findsWidgets);
    expect(find.text('Track Pro'), findsOneWidget);
    expect(find.text('Details'), findsOneWidget);
    expect(find.text('Doorstep OTP'), findsOneWidget);

    // Switch to Completed tab
    await tester.tap(find.textContaining('Completed'));
    await tester.pumpAndSettle();

    expect(find.text('Electrical Service'), findsWidgets);
    expect(find.text('Book Again'), findsOneWidget);

    // Switch to Cancelled tab
    await tester.tap(find.textContaining('Cancelled'));
    await tester.pumpAndSettle();

    expect(find.text('No cancelled bookings'), findsOneWidget);

    // Switch back to Upcoming tab
    await tester.tap(find.textContaining('Upcoming'));
    await tester.pumpAndSettle();

    // Verify Doorstep OTP Dialog triggers
    await tester.tap(find.text('Doorstep OTP'));
    await tester.pumpAndSettle();
    expect(find.text('Doorstep Verification OTP'), findsOneWidget);

    // Close dialog
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Doorstep Verification OTP'), findsNothing);
  });

  testWidgets('SahayakApp renders MyBookingsScreen when on bookings tab', (WidgetTester tester) async {
    final repository = AppRepository();
    final viewModel = AppViewModel(repository: repository);
    viewModel.navigateTo(AppScreen.mainShell);
    viewModel.switchTab(ShellTab.bookings);

    await tester.pumpWidget(
      SahayakApp(viewModel: viewModel),
    );
    await tester.pumpAndSettle();

    expect(find.text('My Bookings'), findsNWidgets(2));
    expect(find.text('Plumbing Service'), findsWidgets);
  });
}

