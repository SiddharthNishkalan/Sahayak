import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:work_solute/app_view_model.dart';
import 'package:work_solute/data/repositories/app_repository.dart';
import 'package:work_solute/data/models/service.dart';
import 'package:work_solute/ui/features/booking_wizard/step1_problem_details.dart';

void main() {
  group('Category Subcategories Data Model & Repository Tests', () {
    final repository = AppRepository();

    test('All 8 services have distinct, non-empty subcategory lists', () {
      final services = ServiceItem.defaultServices;
      expect(services.length, equals(8));

      final expectedTrades = [
        'plumber',
        'electrician',
        'cleaner',
        'carpenter',
        'caregiver',
        'driver',
        'gardener',
        'appliance',
      ];

      for (final tradeId in expectedTrades) {
        final subcategories = repository.getSubcategoriesForService(tradeId);
        expect(subcategories, isNotEmpty, reason: 'Trade $tradeId should have subcategories');
        expect(subcategories.length, greaterThanOrEqualTo(5),
            reason: 'Trade $tradeId should have at least 5 subcategories');

        // All subcategories belong to this serviceId
        for (final sub in subcategories) {
          expect(sub.serviceId, equals(tradeId),
              reason: 'Subcategory ${sub.id} must have serviceId == $tradeId');
        }
      }
    });

    test('Non-plumbing categories do not contain plumbing subcategories', () {
      final nonPlumbingTrades = [
        'electrician',
        'cleaner',
        'carpenter',
        'caregiver',
        'driver',
        'gardener',
        'appliance',
      ];

      for (final tradeId in nonPlumbingTrades) {
        final subcategories = repository.getSubcategoriesForService(tradeId);
        final hasTap = subcategories.any((s) => s.id == 'plumb_tap' || s.title.contains('Tap Repair'));
        final hasPipes = subcategories.any((s) => s.id == 'plumb_leakage' || s.title.contains('Pipe Repair'));
        final hasSanitary = subcategories.any((s) => s.id == 'plumb_sanitary');

        expect(hasTap, isFalse, reason: '$tradeId must not have tap repair');
        expect(hasPipes, isFalse, reason: '$tradeId must not have pipe repair');
        expect(hasSanitary, isFalse, reason: '$tradeId must not have sanitary fitting');
      }
    });

    test('Electrician subcategories contain electrical specific services', () {
      final electricianSubs = repository.getSubcategoriesForService('electrician');
      expect(electricianSubs.any((s) => s.title == 'Switchboard & Socket'), isTrue);
      expect(electricianSubs.any((s) => s.title == 'Fan & Light Fixture'), isTrue);
      expect(electricianSubs.any((s) => s.title == 'Circuit Breaker & MCB'), isTrue);
      expect(electricianSubs.any((s) => s.title == 'Inverter & UPS Wiring'), isTrue);
    });

    test('Cleaner subcategories contain cleaning specific services', () {
      final cleanerSubs = repository.getSubcategoriesForService('cleaner');
      expect(cleanerSubs.any((s) => s.title == 'Full Deep Home Cleaning'), isTrue);
      expect(cleanerSubs.any((s) => s.title == 'Kitchen & Chimney'), isTrue);
      expect(cleanerSubs.any((s) => s.title == 'Bathroom Sanitization'), isTrue);
    });

    test('Carpenter subcategories contain carpentry specific services', () {
      final carpenterSubs = repository.getSubcategoriesForService('carpenter');
      expect(carpenterSubs.any((s) => s.title == 'Door & Lock Repair'), isTrue);
      expect(carpenterSubs.any((s) => s.title == 'Furniture Assembly'), isTrue);
      expect(carpenterSubs.any((s) => s.title == 'Cupboard & Hinge Fix'), isTrue);
    });

    test('Caregiver subcategories contain caregiving specific services', () {
      final caregiverSubs = repository.getSubcategoriesForService('caregiver');
      expect(caregiverSubs.any((s) => s.title == 'Elderly Daily Assistance'), isTrue);
      expect(caregiverSubs.any((s) => s.title == 'Post-Surgery Care'), isTrue);
      expect(caregiverSubs.any((s) => s.title == 'Mobility & Walking Support'), isTrue);
    });

    test('Driver subcategories contain driving specific services', () {
      final driverSubs = repository.getSubcategoriesForService('driver');
      expect(driverSubs.any((s) => s.title == 'City Chauffeur (Hourly)'), isTrue);
      expect(driverSubs.any((s) => s.title == 'Airport Transfer Driver'), isTrue);
      expect(driverSubs.any((s) => s.title == 'Daily Office Commute'), isTrue);
    });

    test('Gardener subcategories contain gardening specific services', () {
      final gardenerSubs = repository.getSubcategoriesForService('gardener');
      expect(gardenerSubs.any((s) => s.title == 'Lawn Mowing & Trimming'), isTrue);
      expect(gardenerSubs.any((s) => s.title == 'Plant Pruning & Weeding'), isTrue);
      expect(gardenerSubs.any((s) => s.title == 'Balcony Garden Setup'), isTrue);
    });

    test('Appliance Tech subcategories contain appliance specific services', () {
      final applianceSubs = repository.getSubcategoriesForService('appliance');
      expect(applianceSubs.any((s) => s.title == 'AC Service & Gas Charging'), isTrue);
      expect(applianceSubs.any((s) => s.title == 'Refrigerator Cooling Fix'), isTrue);
      expect(applianceSubs.any((s) => s.title == 'Washing Machine Drum/Motor'), isTrue);
    });
  });

  group('AppViewModel Category State & Switching Tests', () {
    test('Switching category in AppViewModel updates wizardSubcategories and resets subcategory selection', () {
      final repository = AppRepository();
      final viewModel = AppViewModel(repository: repository);

      final electrician = ServiceItem.defaultServices.firstWhere((s) => s.id == 'electrician');
      viewModel.setService(electrician);

      expect(viewModel.wizardServiceId, equals('electrician'));
      expect(viewModel.wizardServiceName, equals('Electrician'));
      expect(viewModel.wizardSelectedSubcategoryId, equals('elec_switch'));
      expect(viewModel.wizardSubcategories.first.title, equals('Switchboard & Socket'));
      expect(viewModel.wizardSelectedSubcategory?.title, equals('Switchboard & Socket'));

      // Now switch to Cleaner
      final cleaner = ServiceItem.defaultServices.firstWhere((s) => s.id == 'cleaner');
      viewModel.setService(cleaner);

      expect(viewModel.wizardServiceId, equals('cleaner'));
      expect(viewModel.wizardServiceName, equals('Cleaner'));
      expect(viewModel.wizardSelectedSubcategoryId, equals('clean_deep_home'));
      expect(viewModel.wizardSubcategories.first.title, equals('Full Deep Home Cleaning'));
      expect(viewModel.wizardSelectedSubcategory?.title, equals('Full Deep Home Cleaning'));
    });
  });

  group('Step1ProblemDetailsScreen Category Subcategories UI Tests', () {
    testWidgets('Opening Electrician category displays electrical subcategories', (WidgetTester tester) async {
      final repository = AppRepository();
      final viewModel = AppViewModel(repository: repository);
      final electrician = ServiceItem.defaultServices.firstWhere((s) => s.id == 'electrician');

      await tester.pumpWidget(
        MaterialApp(
          home: Step1ProblemDetailsScreen(
            viewModel: viewModel,
            service: electrician,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should display Electrician subcategories
      expect(find.text('Switchboard & Socket'), findsOneWidget);
      expect(find.text('Fan & Light Fixture'), findsOneWidget);
      expect(find.text('Circuit Breaker & MCB'), findsOneWidget);

      // Should NOT display Plumber subcategories
      expect(find.text('Tap Repair & Replacement'), findsNothing);
      expect(find.text('Water Tank & Motor'), findsNothing);
    });

    testWidgets('Opening Driver category displays driver subcategories', (WidgetTester tester) async {
      final repository = AppRepository();
      final viewModel = AppViewModel(repository: repository);
      final driver = ServiceItem.defaultServices.firstWhere((s) => s.id == 'driver');

      await tester.pumpWidget(
        MaterialApp(
          home: Step1ProblemDetailsScreen(
            viewModel: viewModel,
            service: driver,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should display Driver subcategories
      expect(find.text('City Chauffeur (Hourly)'), findsOneWidget);
      expect(find.text('Airport Transfer Driver'), findsOneWidget);
      expect(find.text('Daily Office Commute'), findsOneWidget);

      // Should NOT display Plumber subcategories
      expect(find.text('Tap Repair & Replacement'), findsNothing);
    });

    testWidgets('Opening Gardener category displays gardener subcategories', (WidgetTester tester) async {
      final repository = AppRepository();
      final viewModel = AppViewModel(repository: repository);
      final gardener = ServiceItem.defaultServices.firstWhere((s) => s.id == 'gardener');

      await tester.pumpWidget(
        MaterialApp(
          home: Step1ProblemDetailsScreen(
            viewModel: viewModel,
            service: gardener,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should display Gardener subcategories
      expect(find.text('Lawn Mowing & Trimming'), findsOneWidget);
      expect(find.text('Plant Pruning & Weeding'), findsOneWidget);
      expect(find.text('Balcony Garden Setup'), findsOneWidget);

      // Should NOT display Plumber subcategories
      expect(find.text('Tap Repair & Replacement'), findsNothing);
    });
  });
}
