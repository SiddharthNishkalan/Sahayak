import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:work_solute/app_view_model.dart';
import 'package:work_solute/data/repositories/app_repository.dart';
import 'package:work_solute/main.dart';
import 'package:work_solute/ui/features/bookings_list/my_bookings_screen.dart';

void main() {
  testWidgets('MyBookingsScreen renders upcoming bookings and switches tabs without errors', (WidgetTester tester) async {
    final repository = AppRepository();
    final viewModel = AppViewModel(repository: repository);

    await tester.pumpWidget(
      MaterialApp(
        home: MyBookingsScreen(
          viewModel: viewModel,
          repository: repository,
          onBookService: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('My Bookings'), findsOneWidget);
    expect(find.text('Plumbing Service'), findsWidgets);
    expect(find.textContaining('Upcoming'), findsWidgets);

    // Switch to Completed Tab
    await tester.tap(find.textContaining('Completed'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Completed'), findsWidgets);

    // Switch to Cancelled Tab
    await tester.tap(find.textContaining('Cancelled'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Cancelled'), findsWidgets);
  });

  testWidgets('MyBookingsScreen card tap opens BookingDetailsScreen with OTP dialog/view', (WidgetTester tester) async {
    final repository = AppRepository();
    final viewModel = AppViewModel(repository: repository);

    await tester.pumpWidget(
      MaterialApp(
        home: MyBookingsScreen(
          viewModel: viewModel,
          repository: repository,
          onBookService: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final detailsButton = find.text('View Details');
    expect(detailsButton, findsWidgets);

    await tester.tap(detailsButton.first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Booking Details'), findsOneWidget);
    expect(find.textContaining('SECURITY OTP'), findsWidgets);
  });

  testWidgets('WorkSoluteApp renders MyBookingsScreen when on bookings tab', (WidgetTester tester) async {
    final repository = AppRepository();
    final viewModel = AppViewModel(repository: repository);
    viewModel.navigateTo(AppScreen.mainShell);
    viewModel.switchTab(ShellTab.bookings);

    await tester.pumpWidget(
      WorkSoluteApp(viewModel: viewModel),
    );
    await tester.pumpAndSettle();

    expect(find.text('My Bookings'), findsNWidgets(2));
    expect(find.text('Plumbing Service'), findsWidgets);
  });
}

