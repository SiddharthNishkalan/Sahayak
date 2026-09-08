import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:work_solute/app_view_model.dart';
import 'package:work_solute/data/models/service.dart';
import 'package:work_solute/data/repositories/app_repository.dart';
import 'package:work_solute/ui/features/booking_wizard/step2_time_location.dart';

void main() {
  group('Booking Urgency Mode Tests', () {
    late AppRepository repository;
    late AppViewModel viewModel;
    late ServiceItem testService;

    setUp(() {
      repository = AppRepository();
      viewModel = AppViewModel(repository: repository);
      testService = repository.services.first;
    });

    testWidgets('Scheduled mode hides scheduled visit urgency and emergency requests, showing date/slot directly',
        (WidgetTester tester) async {
      viewModel.setTimingMode(isEmergency: false);
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

      // Scheduled visit urgency and checklist MUST NOT be displayed
      expect(find.text('Scheduled Visit Urgency'), findsNothing);
      expect(find.text('Standard Visit'), findsNothing);
      expect(find.text('Priority Slot'), findsNothing);
      expect(find.text('Flexible Window'), findsNothing);

      // Should display date and slot pickers directly
      expect(find.text('Select Date'), findsOneWidget);
      expect(find.text('Available Slots'), findsOneWidget);

      // MUST NOT display emergency request or urgency options
      expect(find.text('Emergency SOS Urgency'), findsNothing);
      expect(find.text('⚡ Emergency'), findsNothing);
      expect(find.text('< 20 min rapid dispatch'), findsNothing);
      expect(find.text('Emergency Priority Tag *'), findsNothing);
      expect(find.text('Live GPS Geolocation Activated'), findsNothing);
    });

    testWidgets('Emergency mode shows emergency SOS urgency and hides scheduled options',
        (WidgetTester tester) async {
      viewModel.setTimingMode(isEmergency: true, emergencyTag: 'BURST_PIPE');
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

      // Should display emergency urgency header and options
      expect(find.text('Emergency SOS Urgency'), findsOneWidget);
      expect(find.text('Critical Risk SOS'), findsOneWidget);
      expect(find.text('High Urgency'), findsOneWidget);
      expect(find.text('Emergency Priority Tag *'), findsOneWidget);
      expect(find.text('Live GPS Geolocation Activated'), findsOneWidget);

      // MUST NOT display scheduled urgency or date/slot pickers
      expect(find.text('Scheduled Visit Urgency'), findsNothing);
      expect(find.text('Select Date'), findsNothing);
      expect(find.text('Available Slots'), findsNothing);

      // Selecting High Urgency should update viewModel
      await tester.tap(find.text('High Urgency'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(viewModel.wizardEmergencySeverity, 'high');
    });

    test('ViewModel maintains distinct scheduled and emergency urgency values and sets booking urgency', () {
      viewModel.setTimingMode(isEmergency: false);
      viewModel.setScheduledUrgency('priority');
      viewModel.setEmergencySeverity('high');

      expect(viewModel.wizardScheduledUrgency, 'priority');
      expect(viewModel.wizardEmergencySeverity, 'high');

      // Scheduled booking takes scheduled urgency
      viewModel.broadcastJobRequest();
      final scheduledBooking = viewModel.confirmAndCreateBooking();
      expect(scheduledBooking.isEmergency, false);
      expect(scheduledBooking.urgencyLevel, 'priority');

      // Emergency booking takes emergency urgency
      viewModel.setTimingMode(isEmergency: true, emergencyTag: 'BURST_PIPE');
      viewModel.setEmergencySeverity('critical');
      viewModel.broadcastJobRequest();
      final emergencyBooking = viewModel.confirmAndCreateBooking();
      expect(emergencyBooking.isEmergency, true);
      expect(emergencyBooking.urgencyLevel, 'critical');
    });
  });
}
