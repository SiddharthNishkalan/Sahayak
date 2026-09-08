import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:work_solute/app_view_model.dart';
import 'package:work_solute/data/models/booking.dart';
import 'package:work_solute/data/models/invoice.dart';
import 'package:work_solute/data/models/user.dart';
import 'package:work_solute/data/models/address.dart';
import 'package:work_solute/data/repositories/app_repository.dart';
import 'package:work_solute/ui/features/booking_status/institution_allocation_status_screen.dart';
import 'package:work_solute/ui/features/booking_wizard/institution_request_step1.dart';
import 'package:work_solute/ui/features/booking_wizard/institution_request_step2.dart';
import 'package:work_solute/ui/features/marketplace/institution_home_view.dart';
import 'package:work_solute/ui/features/profile/tax_invoice_dialog.dart';

void main() {
  group('Institution Account & Workforce Flow Tests', () {
    late AppRepository repository;
    late AppViewModel viewModel;

    setUp(() {
      repository = AppRepository();
      viewModel = AppViewModel(repository: repository);
    });

    test('Institution Sign-Up creates institution user with organization details', () {
      repository.signUp(
        name: 'Apex Facilities Team',
        email: 'facilities@apextech.in',
        phone: '+91 98432 11223',
        password: 'Password123!',
        society: 'Shivaji Nagar',
        accountType: UserAccountType.institution,
        organizationName: 'Apex Technology Park',
        siteAddress: 'Apex Tech Park, Avinashi Road, Peelamedu',
      );

      final user = repository.currentUser;
      expect(user, isNotNull);
      expect(user!.isInstitution, isTrue);
      expect(user.organizationName, equals('Apex Technology Park'));
      expect(user.displayName, equals('Apex Technology Park'));
    });

    test('Institutional login has only one default facility address in saved addresses', () {
      // Household user initially has 2 addresses (Home, Office)
      expect(repository.currentUser?.isInstitution, isFalse);
      expect(repository.addresses.length, equals(2));
      expect(repository.defaultAddress.type, equals('Home'));

      // Sign in as institution
      repository.signIn(email: 'facilities@apextech.in', password: 'Password123!');
      expect(repository.currentUser?.isInstitution, isTrue);

      // Verify institutional login only has 1 default address
      expect(repository.addresses.length, equals(1));
      final instAddress = repository.addresses.first;
      expect(instAddress.isDefault, isTrue);
      expect(instAddress.label, contains('Office 1'));
      expect(instAddress.type, equals('Office'));
      expect(repository.defaultAddress.id, equals(instAddress.id));
    });

    test('Create Institution Booking generates multi-domain booking with aggregate counts', () {
      final booking = repository.createInstitutionBooking(
        serviceName: 'Facility Multi-Trade Workforce',
        subcategoryTitle: '5 Cooperative Specialists',
        requiredWorkersPerDomain: {'electrical': 3, 'plumbing': 2},
        problemDescription: 'Annual substation & plumbing overhaul',
        scheduledSlot: 'Tomorrow · 9:00 AM – 5:00 PM',
        scheduledDateTime: DateTime.now().add(const Duration(days: 1)),
        address: const SavedAddress(
          id: 'site-apex',
          label: 'Apex Tech Campus Block A',
          type: 'Office',
          streetAddress: 'Avinashi Road',
          landmark: 'Peelamedu',
          ward: 'Ward 8',
          pincode: '641014',
        ),
        organizationName: 'Apex Technology Park',
      );

      expect(booking.isInstitutionBooking, isTrue);
      expect(booking.organizationName, equals('Apex Technology Park'));
      expect(booking.totalWorkersRequested, equals(5));
      expect(booking.totalWorkersAllocated, equals(3));
      expect(booking.isFullyAllocated, isFalse);
      expect(booking.remainingPositionsCount, equals(2));
      expect(booking.allocationProgressRatio, closeTo(0.6, 0.01));
    });

    test('getBookingsByTab filters upcoming and completed bookings for institution accounts', () {
      // Sign in as default institution account
      repository.signIn(email: 'facilities@apextech.in', password: 'Password123!');
      expect(repository.currentUser?.isInstitution, isTrue);

      final upcoming = repository.getBookingsByTab(BookingTab.upcoming);
      expect(upcoming, isNotEmpty);
      expect(upcoming.first.isInstitutionBooking, isTrue);

      final completed = repository.getBookingsByTab(BookingTab.completed);
      expect(completed, isNotEmpty);
      expect(completed.first.isInstitutionBooking, isTrue);
    });

    testWidgets('InstitutionHomeView renders Request Workforce CTA and zero emergency buttons', (tester) async {
      repository.signIn(email: 'facilities@apextech.in', password: 'Password123!');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InstitutionHomeView(viewModel: viewModel),
          ),
        ),
      );

      // Verify header and organization title
      expect(find.text('Apex Technology Park'), findsOneWidget);
      expect(find.text('INSTITUTION'), findsOneWidget);

      // Verify primary CTA
      expect(find.text('Request Workforce'), findsOneWidget);

      // Verify absence of Emergency SOS shortcuts
      expect(find.text('Emergency (SOS)'), findsNothing);
      expect(find.text('SOS Emergency'), findsNothing);
    });

    testWidgets('InstitutionRequestStep1Screen renders trade counters and site selector', (tester) async {
      repository.signIn(email: 'facilities@apextech.in', password: 'Password123!');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InstitutionRequestStep1Screen(viewModel: viewModel),
          ),
        ),
      );

      expect(find.text('Workforce Request'), findsOneWidget);
      expect(find.text('Step 1 of 2'), findsOneWidget);
      expect(find.text('1. Required Trades & Headcount'), findsOneWidget);
      expect(find.text('2. Deployment Site'), findsOneWidget);
      expect(find.text('Set Timing'), findsOneWidget);
    });

    testWidgets('InstitutionRequestStep2Screen renders shift selection and cost breakdown', (tester) async {
      repository.signIn(email: 'facilities@apextech.in', password: 'Password123!');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InstitutionRequestStep2Screen(viewModel: viewModel),
          ),
        ),
      );

      expect(find.text('Deployment Timing'), findsOneWidget);
      expect(find.text('Step 2 of 2'), findsOneWidget);
      expect(find.text('1. Select Service Date'), findsOneWidget);
      expect(find.text('2. Select Shift Window'), findsOneWidget);
      expect(find.text('3. Workforce Allocation Summary'), findsOneWidget);
      expect(find.text('Submit Request'), findsOneWidget);
    });

    testWidgets('InstitutionAllocationStatusScreen displays fulfillment progress and contact society desk', (tester) async {
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

      expect(find.text('Allocation Status'), findsOneWidget);
      expect(find.text('Institutional Workforce Request'), findsOneWidget);
      expect(find.text('Workforce Fulfillment'), findsOneWidget);
      expect(find.text('Trade Allocation Breakdown'), findsOneWidget);
      expect(find.text('Contact Society Desk'), findsOneWidget);
    });

    testWidgets('TaxInvoiceDialog renders line items for institutional invoice', (tester) async {
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
              child: const Text('Show Invoice'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Invoice'));
      await tester.pumpAndSettle();

      expect(find.text('Cooperative Tax Invoice'), findsOneWidget);
      expect(find.text('CONSOLIDATED WORKFORCE CHARGES'), findsOneWidget);
      expect(find.text('Apex Technology Park'), findsOneWidget);
      expect(find.textContaining('Licensed Electricians'), findsWidgets);
      expect(find.textContaining('Deep Cleaning Crew'), findsWidgets);
    });
  });
}
