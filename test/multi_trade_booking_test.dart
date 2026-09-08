import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:work_solute/app_view_model.dart';
import 'package:work_solute/data/repositories/app_repository.dart';
import 'package:work_solute/data/models/service.dart';
import 'package:work_solute/ui/features/marketplace/marketplace_home_screen.dart';
import 'package:work_solute/ui/features/booking_wizard/step1_problem_details.dart';

void main() {
  testWidgets('Marketplace Book a Service opens sheet showing Single Trade and Multi-Trade options', (WidgetTester tester) async {
    final repository = AppRepository();
    final viewModel = AppViewModel(repository: repository);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MarketplaceHomeScreen(
            viewModel: viewModel,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Find and tap the "Book a Service" tile
    final bookTile = find.text('Book a Service');
    expect(bookTile, findsWidgets);
    await tester.ensureVisible(bookTile.first);
    await tester.pumpAndSettle();
    await tester.tap(bookTile.first);
    await tester.pumpAndSettle();

    // Verify bottom sheet is displayed with both tabs
    expect(find.text('Single Trade'), findsOneWidget);
    expect(find.text('Multi-Trade'), findsOneWidget);

    // Verify domains are shown
    expect(find.text('Plumber'), findsWidgets);
    expect(find.text('Electrician'), findsWidgets);

    // Switch to Multi-Trade tab
    await tester.tap(find.text('Multi-Trade'));
    await tester.pumpAndSettle();

    // Verify Multi-Trade description and options
    expect(find.text('Plumbing & Water'), findsOneWidget);
    expect(find.text('Electrical & Power'), findsOneWidget);
    expect(find.textContaining('Trades Selected'), findsOneWidget);
    expect(find.textContaining('Continue with'), findsOneWidget);
  });

  testWidgets('Step1ProblemDetailsScreen does not have multi-trade in subcategories for single trade', (WidgetTester tester) async {
    final repository = AppRepository();
    final viewModel = AppViewModel(repository: repository);
    final plumber = ServiceItem.defaultServices.firstWhere((s) => s.id == 'plumber');

    viewModel.setService(plumber);

    await tester.pumpWidget(
      MaterialApp(
        home: Step1ProblemDetailsScreen(
          viewModel: viewModel,
          service: plumber,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify subcategories are displayed
    expect(find.text('Service Subcategories'), findsOneWidget);
    expect(find.text('Tap Repair & Replacement'), findsOneWidget);

    // Verify "Exact Domain" / "Multi-Trade" tabs are NOT in subcategories
    expect(find.text('Exact Domain'), findsNothing);
  });

  testWidgets('Step1ProblemDetailsScreen shows Multi-Trade Scope card when booking multi-trade', (WidgetTester tester) async {
    final repository = AppRepository();
    final viewModel = AppViewModel(repository: repository);

    viewModel.setMultiTradeDomains({'plumbing', 'electrical'});

    const multiService = ServiceItem(
      id: 'multi_trade',
      title: 'Multi-Trade (Plumbing + Electrical)',
      description: 'Cross-domain diagnostic',
      basePrice: 0,
      priceUnit: 'quote',
      nearCount: 15,
      icon: Icons.hub_rounded,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Step1ProblemDetailsScreen(
          viewModel: viewModel,
          service: multiService,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Multi-Trade Scope card is shown instead of single-trade subcategories
    expect(find.text('Multi-Trade Request Scope'), findsOneWidget);
    expect(find.text('2 Trades Active'), findsOneWidget);
    expect(find.text('Plumbing & Water'), findsOneWidget);
    expect(find.text('Electrical & Power'), findsOneWidget);
    expect(find.text('Service Subcategories'), findsNothing);
  });
}
