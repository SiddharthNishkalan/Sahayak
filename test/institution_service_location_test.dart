import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:work_solute/app_view_model.dart';
import 'package:work_solute/data/models/service.dart';
import 'package:work_solute/data/repositories/app_repository.dart';
import 'package:work_solute/ui/features/booking_wizard/step1_problem_details.dart';
import 'package:work_solute/ui/features/booking_wizard/step2_time_location.dart';
import 'package:work_solute/ui/features/booking_wizard/institution_request_step1.dart';

void main() {
  group('Institution Login Service Location & Urgency/Checklist Removal Tests', () {
    late AppRepository repository;
    late AppViewModel viewModel;
    late ServiceItem testService;

    setUp(() {
      repository = AppRepository();
      viewModel = AppViewModel(repository: repository);
      testService = repository.services.first;
    });

    testWidgets('Step 1 Problem Details does not display the removed What\'s Included checklist',
        (WidgetTester tester) async {
      viewModel.setService(testService);

      await tester.pumpWidget(
        MaterialApp(
          home: Step1ProblemDetailsScreen(
            viewModel: viewModel,
            service: testService,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('What\'s Included'), findsNothing);
      expect(find.text('Certified cooperative member technician'), findsNothing);
      expect(find.text('Standard diagnostic inspection and visit included'), findsNothing);
    });

    testWidgets('Institution login under Service Location in Step 2 keeps ONLY one address and excludes all other addresses',
        (WidgetTester tester) async {
      // Sign in as institution user
      viewModel.signIn('facilities@apextech.in', 'Password123!');
      expect(viewModel.isInstitution, true);
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

      // Heading Service Location is present
      expect(find.text('Service Location'), findsOneWidget);

      // Institution single registered facility address is shown
      expect(find.textContaining('Office 1'), findsWidgets);
      expect(find.text('Single Registered Institution Campus · Facility Site'), findsOneWidget);

      // All other addresses MUST NOT be shown
      expect(find.text('Home'), findsNothing);
      expect(find.text('+ Add Address'), findsNothing);
      expect(find.byKey(const Key('add_saved_address_chip')), findsNothing);
    });

    testWidgets('Institution workforce request step 1 keeps ONLY one deployment site address and has no Add Site button',
        (WidgetTester tester) async {
      // Sign in as institution user
      viewModel.signIn('facilities@apextech.in', 'Password123!');
      expect(viewModel.isInstitution, true);

      await tester.pumpWidget(
        MaterialApp(
          home: InstitutionRequestStep1Screen(
            viewModel: viewModel,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Shows single Primary Facility header
      expect(find.text('Primary Facility'), findsOneWidget);
      expect(find.textContaining('Office 1'), findsOneWidget);

      // Add Site button is removed
      expect(find.text('Add Site'), findsNothing);
    });
  });
}
