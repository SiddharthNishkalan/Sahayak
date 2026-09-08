import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:work_solute/app_view_model.dart';
import 'package:work_solute/data/models/address.dart';
import 'package:work_solute/data/models/booking.dart';
import 'package:work_solute/data/models/coordinator.dart';
import 'package:work_solute/data/models/invoice.dart';
import 'package:work_solute/data/repositories/app_repository.dart';
import 'package:work_solute/ui/features/booking_status/institution_allocation_status_screen.dart';
import 'package:work_solute/ui/features/booking_wizard/institution_request_step1.dart';
import 'package:work_solute/ui/features/marketplace/institution_home_view.dart';
import 'package:work_solute/ui/features/profile/profile_settings_screen.dart';
import 'package:work_solute/ui/features/profile/tax_invoice_dialog.dart';

void main() {
  group('Platform Fees & Invoice Settlement Calculation Tests', () {
    late AppRepository repository;

    setUp(() {
      repository = AppRepository();
    });

    test('Household Invoice applies 10% Platform Fee strictly on Visit & Diagnostic Fee only', () {
      // Diagnostic: 300, Labor: 500, Materials: 50 => Service Subtotal = 850
      // Platform Fee = 10% of 300 Diagnostic Fee = 30 (Labor and Materials pass through with 0% fee)
      // Total Amount = 850 + 30 = 880
      // Worker Payout = 850 (100% pass-through), Platform Share = 30
      final invoice = CooperativeInvoice.sampleInvoice;

      expect(invoice.isInstitutionInvoice, isFalse);
      expect(invoice.serviceSubtotal, equals(850));
      expect(invoice.effectivePlatformFee, equals(30));
      expect(invoice.totalAmount, equals(880));
      expect(invoice.workerPayout, equals(850));
      expect(invoice.cooperativePlatformShare, equals(30));
    });

    test('Institution Invoice applies 18% Platform Fee strictly on Visit & Diagnostic Fee only', () {
      // Item 1: Electrical (Diag: 300, Labor: 2400, Mat: 200) -> PlatFee = 18% of 300 = 54. Total = 2954.
      // Item 2: Cleaner (Diag: 200, Labor: 2400, Mat: 150) -> PlatFee = 18% of 200 = 36. Total = 2786.
      // Total Diagnostic = 500. Total Labor = 4800. Total Materials = 350.
      // Total Platform Fee = 54 + 36 = 90 (18% of 500).
      // Total Invoice Amount = 500 + 4800 + 350 + 90 = 5740.
      // Worker Payout = 500 + 4800 + 350 = 5650 (100% of diagnostic + labor + materials).
      // Platform Share = 90.
      final invoice = CooperativeInvoice.sampleInstitutionInvoice;

      expect(invoice.isInstitutionInvoice, isTrue);
      expect(invoice.lineItems.length, equals(2));

      final electrical = invoice.lineItems[0];
      expect(electrical.diagnosticFee, equals(300));
      expect(electrical.laborFee, equals(2400));
      expect(electrical.materialsFee, equals(200));
      expect(electrical.effectivePlatformFee, equals(54)); // 18% of 300
      expect(electrical.effectiveTotalAmount, equals(2954));

      final cleaner = invoice.lineItems[1];
      expect(cleaner.diagnosticFee, equals(200));
      expect(cleaner.laborFee, equals(2400));
      expect(cleaner.materialsFee, equals(150));
      expect(cleaner.effectivePlatformFee, equals(36)); // 18% of 200
      expect(cleaner.effectiveTotalAmount, equals(2786));

      expect(invoice.effectivePlatformFee, equals(90));
      expect(invoice.totalAmount, equals(5740));
      expect(invoice.workerPayout, equals(5650));
      expect(invoice.cooperativePlatformShare, equals(90));
    });

    test('Repository generates correct platform fee during institution booking settlement', () {
      final booking = repository.createInstitutionBooking(
        serviceName: 'Commercial Cleaning & Repair',
        subcategoryTitle: 'Deep Sanitization & Plumbing',
        requiredWorkersPerDomain: {'cleaner': 2, 'plumbing': 1},
        problemDescription: 'Quarterly facility maintenance',
        scheduledSlot: 'Tomorrow · 9:00 AM – 5:00 PM',
        scheduledDateTime: DateTime.now().add(const Duration(days: 1)),
        address: const SavedAddress(
          id: 'site-test',
          label: 'Office 2 (East Wing)',
          type: 'Office',
          streetAddress: 'Avinashi Road',
          landmark: 'Peelamedu',
          ward: 'Ward 8',
          pincode: '641014',
        ),
        organizationName: 'Apex Technology Park',
      );

      // Verify booking creation with 100% allocation
      expect(booking.isInstitutionBooking, isTrue);
      expect(booking.totalWorkersRequested, equals(3));
    });
  });

  group('Sequential Site Auto-Naming Tests', () {
    late AppRepository repository;

    setUp(() {
      repository = AppRepository();
    });

    test('Institution user has sequential Office 1 by default and gets Office 2 on next addition', () {
      repository.signIn(email: 'facilities@apextech.in', password: 'Password123!');
      expect(repository.currentUser?.isInstitution, isTrue);

      expect(repository.addresses.length, equals(1));
      expect(repository.addresses.first.label, contains('Office 1'));

      // Next default office name
      expect(repository.getNextOfficeName(), equals('Office 2'));

      // Add a second office without label
      repository.addAddress(const SavedAddress(
        id: 'office-2-test',
        label: '',
        type: 'Office',
        streetAddress: 'Block B, Sector 4',
        landmark: 'Near Cafeteria',
        ward: 'Ward 9',
        pincode: '641014',
      ));

      expect(repository.addresses.length, equals(2));
      expect(repository.addresses.last.label, equals('Office 2'));
      expect(repository.getNextOfficeName(), equals('Office 3'));
    });
  });

  group('Per-Domain Coordinator Tests', () {
    late AppRepository repository;
    late AppViewModel viewModel;

    setUp(() {
      repository = AppRepository();
      viewModel = AppViewModel(repository: repository);
    });

    test('DomainCoordinator model returns proper trade aliases and copyWith', () {
      final coord = DomainCoordinator(
        domain: 'electrical',
        domainTitle: 'Electrical Coordinator',
        name: 'Vignesh Raj',
        phone: '+91 98432 11002',
        email: 'electrical.coord@apextech.in',
      );

      expect(coord.domainTitle, equals('Electrical Coordinator'));

      final updated = coord.copyWith(name: 'Vignesh Kumar');
      expect(updated.name, equals('Vignesh Kumar'));
      expect(updated.phone, equals('+91 98432 11002'));
    });

    test('Repository and ViewModel provide default coordinators and allow domain updates', () {
      repository.signIn(email: 'facilities@apextech.in', password: 'Password123!');

      final electrical = viewModel.getCoordinatorForDomain('electrical');
      expect(electrical.name, equals('Vignesh Raj'));

      final plumbing = viewModel.getCoordinatorForDomain('plumbing');
      expect(plumbing.name, equals('Suresh Kumar'));

      // Update plumbing coordinator
      viewModel.setDomainCoordinator(
        const DomainCoordinator(
          domain: 'plumbing',
          domainTitle: 'Plumbing & Water Coordinator',
          name: 'K. Rajesh',
          phone: '+91 98432 99887',
          email: 'rajesh.plumbing@apextech.in',
        ),
      );

      final updatedPlumbing = viewModel.getCoordinatorForDomain('plumbing');
      expect(updatedPlumbing.name, equals('K. Rajesh'));
      expect(updatedPlumbing.phone, equals('+91 98432 99887'));
    });
  });

  group('UI & Widget Verification Tests', () {
    late AppRepository repository;
    late AppViewModel viewModel;

    setUp(() {
      repository = AppRepository();
      viewModel = AppViewModel(repository: repository);
    });

    testWidgets('TaxInvoiceDialog displays Platform Fee and compact action buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                TaxInvoiceDialog.show(
                  context,
                  invoice: CooperativeInvoice.sampleInstitutionInvoice,
                );
              },
              child: const Text('Open Tax Invoice'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Tax Invoice'));
      await tester.pumpAndSettle();

      // Check header and line items
      expect(find.text('Cooperative Tax Invoice'), findsOneWidget);
      expect(find.text('• Visit & Diagnostic Fee'), findsWidgets);
      expect(find.textContaining('• Platform Fee (18% on Visit only)'), findsWidgets);
      expect(find.text('Direct Worker Payout (100% of service):'), findsOneWidget);

      // Check compact action buttons
      expect(find.text('Download PDF'), findsOneWidget);
      expect(find.text('Email Invoice'), findsOneWidget);
    });

    testWidgets('InstitutionRequestStep1Screen shows Multi-Trade in-context description banner', (tester) async {
      repository.signIn(email: 'facilities@apextech.in', password: 'Password123!');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InstitutionRequestStep1Screen(viewModel: viewModel),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Multi-Trade Request'), findsOneWidget);
      expect(find.textContaining('Multi-trade: combine multiple services like electrical and cleaning'), findsOneWidget);
    });

    testWidgets('InstitutionHomeView displays dismissible Multi-Trade introductory awareness card', (tester) async {
      repository.signIn(email: 'facilities@apextech.in', password: 'Password123!');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InstitutionHomeView(viewModel: viewModel),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Multi-Trade Capabilities'), findsOneWidget);
      expect(find.textContaining('Multi-trade: combine multiple services like electrical, cleaning, and plumbing'), findsOneWidget);
      expect(find.text('Configure Multi-Trade'), findsOneWidget);

      // Dismiss card
      await tester.tap(find.byTooltip('Dismiss awareness card'));
      await tester.pumpAndSettle();

      expect(find.text('Multi-Trade Capabilities'), findsNothing);
    });

    testWidgets('InstitutionAllocationStatusScreen displays trade coordinator banner under domain breakdown', (tester) async {
      repository.signIn(email: 'facilities@apextech.in', password: 'Password123!');
      final booking = Booking.defaultInstitutionUpcoming;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InstitutionAllocationStatusScreen(
              viewModel: viewModel,
              booking: booking,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Trade Allocation Breakdown'), findsOneWidget);
      expect(find.textContaining('Site Coordinator: Vignesh Raj'), findsOneWidget);
      expect(find.textContaining('Site Coordinator: Meenakshi Sundaram'), findsOneWidget);
    });

    testWidgets('ProfileSettingsScreen allows managing Facility Sites and Domain Coordinators', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      repository.signIn(email: 'facilities@apextech.in', password: 'Password123!');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileSettingsScreen(viewModel: viewModel),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Facility Sites Section
      expect(find.text('Facility Sites & Locations'), findsOneWidget);
      expect(find.textContaining('Office 1'), findsWidgets);

      // Domain Coordinators Section
      expect(find.text('Service Domain Coordinators'), findsOneWidget);
      expect(find.text('Vignesh Raj'), findsOneWidget);
      expect(find.text('Electrical Coordinator'), findsWidgets);
    });
  });
}
