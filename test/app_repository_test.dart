import 'package:flutter_test/flutter_test.dart';
import 'package:work_solute/data/repositories/app_repository.dart';
import 'package:work_solute/data/models/language.dart';
import 'package:work_solute/data/models/address.dart';
import 'package:work_solute/data/models/worker.dart';
import 'package:work_solute/data/models/booking.dart';

void main() {
  group('AppRepository tests', () {
    late AppRepository repository;

    setUp(() {
      repository = AppRepository();
    });

    test('Initial repository state has default language, ward, and sample bookings', () {
      expect(repository.selectedLanguage.code, 'en');
      expect(repository.currentWard, contains('Current Location'));
      expect(repository.bookings.length, greaterThanOrEqualTo(2));
      expect(repository.services.length, 8);
    });

    test('Language switching updates correctly', () {
      final english = AppLanguage.supportedLanguages.firstWhere((l) => l.code == 'en');
      repository.setLanguage(english);
      expect(repository.selectedLanguage.code, 'en');
    });

    test('Email and password authentication flow (Sign Up, Sign In, Sign Out)', () {
      // 1. Sign Up
      final user = repository.signUp(
        name: 'Ramesh Kumar',
        email: 'ramesh.kumar@example.com',
        phone: '+91 98765 43210',
        password: 'Password123!',
        society: 'Mayflower Sakthi',
        ward: 'Ward 5',
      );

      expect(user.name, 'Ramesh Kumar');
      expect(user.email, 'ramesh.kumar@example.com');
      expect(repository.currentUser?.email, 'ramesh.kumar@example.com');
      expect(repository.currentSociety, 'Mayflower Sakthi');

      // 2. Sign Out
      repository.signOut();
      expect(repository.currentUser, isNull);

      // 3. Sign In with valid credentials
      final signInSuccess = repository.signIn(
        email: 'ramesh.kumar@example.com',
        password: 'Password123!',
      );
      expect(signInSuccess, isTrue);
      expect(repository.currentUser?.name, 'Ramesh Kumar');

      // 4. Sign In with invalid password fails
      final invalidSignIn = repository.signIn(
        email: 'ramesh.kumar@example.com',
        password: 'WrongPassword!',
      );
      expect(invalidSignIn, isFalse);
    });

    test('Multi-domain worker selection returns cross-trade candidate workers', () {
      // Single trade domain
      final plumbingWorkers = repository.getWorkersForDomains(['domain-plumbing']);
      expect(plumbingWorkers.isNotEmpty, isTrue);
      expect(plumbingWorkers.every((w) => w.supportedDomains.contains('plumbing')), isTrue);

      // Multi-domain selection (unsure whether issue is plumbing or electrical)
      final multiTradeWorkers = repository.getWorkersForDomains(['domain-plumbing', 'domain-electrical']);
      expect(multiTradeWorkers.length, greaterThanOrEqualTo(plumbingWorkers.length));
      final hasElectrical = multiTradeWorkers.any((w) => w.supportedDomains.contains('electrical'));
      final hasPlumbing = multiTradeWorkers.any((w) => w.supportedDomains.contains('plumbing'));
      expect(hasElectrical, isTrue);
      expect(hasPlumbing, isTrue);
    });

    test('Worker broadcast and acceptance offers generation', () {
      final offers = repository.broadcastJobRequestToWorkers(
        selectedDomains: ['domain-plumbing', 'domain-electrical'],
        problemDescription: 'Water pipe leaking directly over electrical distribution board',
        isEmergency: true,
        emergencyTag: 'BURST_PIPE',
        society: 'Greenwood Enclave',
      );

      expect(offers.isNotEmpty, isTrue);
      expect(offers.first.quotedVisitFee, greaterThan(0));
      expect(offers.first.estimatedTotalFee, greaterThanOrEqualTo(offers.first.quotedVisitFee));
      expect(offers.first.worker.certifications.isNotEmpty, isTrue);
    });

    test('Booking confirmation with selected worker generates 4-digit doorstep OTP', () {
      final offers = repository.broadcastJobRequestToWorkers(
        selectedDomains: ['domain-plumbing'],
        problemDescription: 'Kitchen tap dripping continuously',
        isEmergency: false,
        society: 'Greenwood Enclave',
      );

      final selectedOffer = offers.first;
      final booking = repository.confirmBookingWithWorker(
        serviceName: 'Plumbing Service',
        subcategoryTitle: 'Tap Leak & Jet Repair',
        selectedDomains: ['domain-plumbing'],
        isMultiDomain: false,
        problemDescription: 'Kitchen tap dripping continuously',
        mediaUrls: ['photo1.jpg'],
        scheduledSlot: 'Tomorrow · 10:00 AM - 12:00 PM',
        scheduledDateTime: DateTime.now().add(const Duration(hours: 24)),
        isEmergency: false,
        latitude: 11.0168,
        longitude: 76.9558,
        address: SavedAddress.defaultHome,
        selectedOffer: selectedOffer,
      );

      expect(booking.id, startsWith('SK-'));
      expect(booking.currentStage, BookingStage.confirmed);
      expect(booking.tab, BookingTab.upcoming);
      expect(booking.doorstepOtp.length, 4);
      expect(int.tryParse(booking.doorstepOtp), isNotNull);
      expect(booking.worker.id, selectedOffer.worker.id);
    });

    test('Doorstep OTP verification unlocks work authorization and starts job', () {
      final offers = repository.broadcastJobRequestToWorkers(
        selectedDomains: ['domain-plumbing'],
        problemDescription: 'Drain blockage',
        isEmergency: false,
        society: 'Greenwood Enclave',
      );
      final booking = repository.confirmBookingWithWorker(
        serviceName: 'Plumbing Service',
        subcategoryTitle: 'Drain Cleaning',
        selectedDomains: ['domain-plumbing'],
        isMultiDomain: false,
        problemDescription: 'Drain blockage',
        mediaUrls: [],
        scheduledSlot: 'Tomorrow · 10:00 AM',
        scheduledDateTime: DateTime.now().add(const Duration(hours: 12)),
        isEmergency: false,
        latitude: 11.0168,
        longitude: 76.9558,
        address: SavedAddress.defaultHome,
        selectedOffer: offers.first,
      );

      // Wrong OTP fails
      final wrongOtpResult = repository.verifyDoorstepOtp(booking.id, '9999');
      expect(wrongOtpResult, isFalse);
      final unverified = repository.bookings.firstWhere((b) => b.id == booking.id);
      expect(unverified.currentStage, isNot(BookingStage.jobInProgress));

      // Correct OTP succeeds and transitions to jobInProgress
      final correctOtpResult = repository.verifyDoorstepOtp(booking.id, booking.doorstepOtp);
      expect(correctOtpResult, isTrue);
      final verified = repository.bookings.firstWhere((b) => b.id == booking.id);
      expect(verified.currentStage, BookingStage.jobInProgress);
      expect(verified.tab, BookingTab.inProgress);
    });

    test('1-Hour Pre-Service worker status update simulator', () {
      final booking = repository.bookings.first;

      // Simulate on-time
      repository.updateWorkerPreServiceStatus(booking.id, WorkerPreServiceStatus.onTime);
      var updated = repository.bookings.firstWhere((b) => b.id == booking.id);
      expect(updated.activePreServiceUpdate.status, WorkerPreServiceStatus.onTime);

      // Simulate delay
      repository.updateWorkerPreServiceStatus(booking.id, WorkerPreServiceStatus.delayed, delayMinutes: 20);
      updated = repository.bookings.firstWhere((b) => b.id == booking.id);
      expect(updated.activePreServiceUpdate.status, WorkerPreServiceStatus.delayed);
      expect(updated.activePreServiceUpdate.delayMinutes, 20);

      // Simulate technician cancellation
      repository.updateWorkerPreServiceStatus(
        booking.id,
        WorkerPreServiceStatus.cancelledWithReason,
        cancelReason: 'Emergency civic municipal pipeline breakdown',
      );
      updated = repository.bookings.firstWhere((b) => b.id == booking.id);
      expect(updated.tab, BookingTab.cancelled);
      expect(updated.cancelledBy, 'worker');
    });

    test('1-Hour Customer Cancellation Rule enforcement', () {
      // Booking scheduled > 1 hour away (can cancel freely)
      final futureBooking = repository.createBooking(
        serviceName: 'Carpentry Service',
        subcategoryTitle: 'Door Latch Repair',
        scheduledSlot: 'Tomorrow · 02:00 PM - 04:00 PM',
        address: SavedAddress.defaultHome,
        worker: Worker.arunPrasad,
        doorstepOtp: '3344',
      );
      expect(futureBooking.canCancelBefore1Hour, isTrue);

      final cancelFutureSuccess = repository.cancelBookingByCustomer(futureBooking.id, 'Change of schedule');
      expect(cancelFutureSuccess, isTrue);
      final cancelledFuture = repository.bookings.firstWhere((b) => b.id == futureBooking.id);
      expect(cancelledFuture.tab, BookingTab.cancelled);
      expect(cancelledFuture.cancelledBy, 'customer');

      // Booking scheduled within 1 hour (blocked or late penalty notice)
      final nearBooking = repository.createBooking(
        serviceName: 'Electrical Service',
        subcategoryTitle: 'Switchboard',
        scheduledSlot: 'Today · in 20 mins',
        scheduledDateTime: DateTime.now().add(const Duration(minutes: 20)),
        address: SavedAddress.defaultHome,
        worker: Worker.priyaSharma,
        doorstepOtp: '1212',
      );

      expect(nearBooking.canCancelBefore1Hour, isFalse);
      final cancelNearResult = repository.cancelBookingByCustomer(nearBooking.id, 'Last minute change');
      expect(cancelNearResult, isFalse);
    });

    test('Job completion, bill payment and mandatory star rating (*)', () {
      final booking = repository.bookings.first;

      // Complete job and pay bill
      repository.completeJobAndPay(booking.id);
      final paidBooking = repository.bookings.firstWhere((b) => b.id == booking.id);
      expect(paidBooking.currentStage, BookingStage.paid);
      expect(paidBooking.tab, BookingTab.completed);
      expect(paidBooking.invoice?.isPaid, isTrue);

      // Mandatory review & rating (*)
      repository.submitBookingReview(
        bookingId: booking.id,
        rating: 5.0,
        reviewText: 'Exceptional civic service! Prompt and verified doorstep OTP arrival.',
      );
      final reviewedBooking = repository.bookings.firstWhere((b) => b.id == booking.id);
      expect(reviewedBooking.rating, 5);
      expect(reviewedBooking.reviewText, contains('Exceptional civic service'));
    });

    test('Address management: add, default, and delete', () {
      const newAddr = SavedAddress(
        id: 'addr-new-test',
        label: 'Sister Flat',
        type: 'Other',
        streetAddress: '12 Ram Nagar, Cross Cut Rd',
        landmark: 'Near Bus Stand',
        ward: 'Ward 6 — Gandhipuram Central',
        pincode: '641012',
      );

      repository.addAddress(newAddr);
      expect(repository.addresses.any((a) => a.id == 'addr-new-test'), true);

      repository.setDefaultAddress('addr-new-test');
      expect(repository.addresses.firstWhere((a) => a.id == 'addr-new-test').isDefault, true);

      repository.deleteAddress('addr-new-test');
      expect(repository.addresses.any((a) => a.id == 'addr-new-test'), false);
    });
  });
}
