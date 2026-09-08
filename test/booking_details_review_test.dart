import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:work_solute/data/models/booking.dart';
import 'package:work_solute/ui/features/booking_status/booking_details_screen.dart';

void main() {
  group('BookingDetailsScreen Review and Rating after payment tests', () {
    testWidgets('Unpaid booking gates review and rating behind payment with After Payment indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BookingDetailsScreen(booking: Booking.defaultUpcoming),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Find Payment Summary and Pay button
      expect(find.text('Payment Summary'), findsOneWidget);
      expect(find.text('Pay ₹850 & Generate Invoice'), findsOneWidget);

      // Before payment, review and rating shows "After Payment" indicator
      expect(find.text('After Payment'), findsOneWidget);
      expect(find.textContaining('unlock immediately after completing payment'), findsOneWidget);

      // Submit review button should not be present while unpaid
      expect(find.text('Submit Review to Co-op Guild'), findsNothing);
    });

    testWidgets('Completing payment unlocks interactive review and rating section after payment', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: BookingDetailsScreen(booking: Booking.defaultUpcoming),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final payBtn = find.text('Pay ₹850 & Generate Invoice');
      await tester.scrollUntilVisible(payBtn, 400, scrollable: find.byType(Scrollable).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap Pay button to settle payment
      await tester.tap(payBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Tax invoice bottom sheet opens
      expect(find.textContaining('Invoice'), findsWidgets);

      // Dismiss dialog
      Navigator.of(tester.element(find.textContaining('Invoice').first)).pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Now review & rating is unlocked
      final reviewHeader = find.text('How was your experience with Priya Sharma?');
      await tester.scrollUntilVisible(reviewHeader, 400, scrollable: find.byType(Scrollable).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(reviewHeader, findsOneWidget);

      final submitBtn = find.text('Submit Review to Co-op Guild');
      await tester.scrollUntilVisible(submitBtn, 400, scrollable: find.byType(Scrollable).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(submitBtn, findsOneWidget);

      // Tap Submit Review
      await tester.tap(submitBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify review submitted
      expect(find.text('Submitted'), findsOneWidget);
      expect(find.text('Review Submitted'), findsOneWidget);
    });

    testWidgets('Paid completed booking directly renders interactive review and rating section', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BookingDetailsScreen(booking: Booking.defaultCompleted),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final taxInvoiceBtn = find.text('View Cooperative Tax Invoice');
      await tester.scrollUntilVisible(taxInvoiceBtn, 400, scrollable: find.byType(Scrollable).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // For paid booking, View Cooperative Tax Invoice is shown
      expect(taxInvoiceBtn, findsOneWidget);

      final reviewHeader = find.text('How was your experience with Arun Prasad?');
      await tester.scrollUntilVisible(reviewHeader, 400, scrollable: find.byType(Scrollable).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Review and rating section is unlocked and interactive
      expect(reviewHeader, findsOneWidget);
      expect(find.text('Submitted'), findsOneWidget);
    });

    testWidgets('BookingDetailsScreen does not have any RenderFlex overflow on standard mobile dimensions (360x780)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: BookingDetailsScreen(booking: Booking.defaultUpcoming),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Scroll through each section slowly to trigger layout & render
      final scrollable = find.byType(Scrollable).first;
      for (int i = 0; i < 6; i++) {
        await tester.drag(scrollable, const Offset(0, -250));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Check Side-by-Side proof tab as well
      final sideBySideTab = find.text('Side-by-Side');
      if (sideBySideTab.evaluate().isNotEmpty) {
        await tester.scrollUntilVisible(sideBySideTab, 200, scrollable: scrollable);
        await tester.pump();
        await tester.tap(sideBySideTab);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
      }
    });

    testWidgets('BookingDetailsScreen renders without overflow on ultra-narrow mobile (320x568) for completed booking', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: BookingDetailsScreen(booking: Booking.defaultCompleted),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final scrollable = find.byType(Scrollable).first;
      for (int i = 0; i < 6; i++) {
        await tester.drag(scrollable, const Offset(0, -250));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
      }
    });
  });
}
