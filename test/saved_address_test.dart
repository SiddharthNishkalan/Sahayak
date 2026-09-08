import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:work_solute/app_view_model.dart';
import 'package:work_solute/data/models/address.dart';
import 'package:work_solute/data/models/service.dart';
import 'package:work_solute/data/repositories/app_repository.dart';
import 'package:work_solute/ui/features/booking_wizard/step2_time_location.dart';
import 'package:work_solute/ui/features/profile/edit_address_bottom_sheet.dart';

void main() {
  group('Saved Address Add Option Tests', () {
    late AppRepository repository;
    late AppViewModel viewModel;
    late ServiceItem testService;

    setUp(() {
      repository = AppRepository();
      viewModel = AppViewModel(repository: repository);
      testService = repository.services.first;
    });

    testWidgets('Step2TimeLocationScreen shows "+ Add Address" chip alongside existing addresses',
        (WidgetTester tester) async {
      viewModel.setService(testService);

      await tester.pumpWidget(
        MaterialApp(
          home: Step2TimeLocationScreen(
            viewModel: viewModel,
            service: testService,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Check that existing addresses and + Add Address chip are present
      expect(find.byKey(const Key('add_saved_address_chip')), findsOneWidget);
      expect(find.text('+ Add Address'), findsOneWidget);
    });

    testWidgets('EditAddressBottomSheet initializes with clean fields when adding new address',
        (WidgetTester tester) async {
      SavedAddress? savedResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  EditAddressBottomSheet.show(
                    context,
                    onSave: (addr) => savedResult = addr,
                  );
                },
                child: const Text('Open Add Address'),
              ),
            ),
          ),
        ),
      );

      // Open sheet
      await tester.tap(find.text('Open Add Address'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Header should say "Add New Address"
      expect(find.text('Add New Address'), findsOneWidget);
      expect(find.text('Add new doorstep details & ward dispatch profile'), findsOneWidget);

      // Save button should say "Save Address"
      expect(find.text('Save Address'), findsOneWidget);

      // Trying to save without street address shows validation message
      await tester.tap(find.text('Save Address'));
      await tester.pump();
      expect(find.text('Please enter street address / door number'), findsOneWidget);
      expect(savedResult, isNull);

      // Fill in street address
      final streetFinder = find.widgetWithText(TextField, '');
      await tester.enterText(streetFinder.first, '124, Lotus Villa, 2nd Cross');
      await tester.pump();

      // Tap Save Address
      await tester.tap(find.text('Save Address'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Sheet should close and onSave called
      expect(savedResult, isNotNull);
      expect(savedResult!.streetAddress, '124, Lotus Villa, 2nd Cross');
      expect(savedResult!.label, 'Home');
    });

    testWidgets('Adding address with custom label works properly',
        (WidgetTester tester) async {
      SavedAddress? savedResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  EditAddressBottomSheet.show(
                    context,
                    onSave: (addr) => savedResult = addr,
                  );
                },
                child: const Text('Open Add Address'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Add Address'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Select 'Other' label
      await tester.tap(find.text('Other'));
      await tester.pump();

      // Custom Label input should appear
      expect(find.text('Custom Label Name'), findsOneWidget);

      // Enter custom label and address
      // Enter custom label
      await tester.enterText(find.byType(TextField).at(0), 'Parents Villa');
      // Enter street address
      await tester.enterText(find.byType(TextField).at(1), '42 Gandhi Nagar');
      await tester.pump();

      await tester.tap(find.text('Save Address'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(savedResult, isNotNull);
      expect(savedResult!.label, 'Parents Villa');
      expect(savedResult!.streetAddress, '42 Gandhi Nagar');
    });

    test('Saving a new address updates AppViewModel and sets wizard selected address', () {
      final initialCount = repository.addresses.length;
      const newAddress = SavedAddress(
        id: 'addr-new-test',
        label: 'Sister Studio',
        type: 'Other',
        streetAddress: '77 Art Lane, Peelamedu',
        landmark: 'Opposite Art College',
        ward: 'Ward 12, Peelamedu',
        pincode: '641014',
      );

      viewModel.saveAddress(newAddress);
      viewModel.setWizardAddress(newAddress);

      expect(repository.addresses.length, initialCount + 1);
      expect(viewModel.wizardSelectedAddress.id, 'addr-new-test');
      expect(viewModel.wizardSelectedAddress.label, 'Sister Studio');
    });
  });
}
