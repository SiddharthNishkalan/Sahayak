import 'dart:math';
import '../models/language.dart';
import '../models/service.dart';
import '../models/worker.dart';
import '../models/address.dart';
import '../models/booking.dart';
import '../models/invoice.dart';
import '../models/user.dart';

class AppRepository {
  AppLanguage _selectedLanguage = AppLanguage.supportedLanguages[0]; // English default
  String _currentWard = 'Current Location (Live GPS)';
  String _currentSociety = 'Shivaji Nagar';

  UserAccount? _currentUser;
  final List<UserAccount> _registeredUsers = [];

  final List<ServiceItem> _services = List.from(ServiceItem.defaultServices);
  final List<ServiceSubcategory> _plumbingSubcategories = List.from(ServiceSubcategory.plumbingSubcategories);
  
  final List<Worker> _workers = [
    Worker.priyaSharma,
    Worker.rameshKumar,
    Worker.arunPrasad,
    Worker.deepakMurugan,
  ];
  
  final List<SavedAddress> _addresses = [
    SavedAddress.defaultHome,
    SavedAddress.defaultOffice,
  ];

  final List<Booking> _bookings = [];

  AppRepository() {
    // Initialize default demo account
    final initialUser = UserAccount(
      id: 'USR-${1000 + Random().nextInt(9000)}',
      name: 'Karthik Sivakumar',
      email: 'karthik.siva@sahayak.in',
      phone: '+91 98432 10842',
      society: 'Shivaji Nagar',
      ward: 'Ward 5',
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
    );
    _registeredUsers.add(initialUser);
    _currentUser = initialUser;

    // Seed default upcoming & completed bookings
    _bookings.addAll([
      Booking.defaultUpcoming,
      Booking.defaultCompleted,
    ]);
  }

  // Getters
  bool get isAuthenticated => _currentUser != null;
  UserAccount? get currentUser => _currentUser;
  String get userName => _currentUser?.name ?? 'Guest User';
  String get userEmail => _currentUser?.email ?? 'guest@sahayak.in';
  String get userPhone => _currentUser?.phone ?? '+91 90000 00000';
  String get userSociety => _currentUser?.society ?? _currentSociety;
  String get userWard => _currentUser?.ward ?? 'Ward 5';
  String get userMemberId => 'SHK-${(_currentUser?.id ?? '1001').replaceAll('USR-', '').replaceAll('GGL-', '')}';

  AppLanguage get selectedLanguage => _selectedLanguage;
  String get currentWard => _currentWard;
  String get currentSociety => _currentSociety;
  List<ServiceItem> get services => List.unmodifiable(_services);
  List<ServiceSubcategory> get plumbingSubcategories => List.unmodifiable(_plumbingSubcategories);
  List<Worker> get workers => List.unmodifiable(_workers);
  List<SavedAddress> get addresses => List.unmodifiable(_addresses);
  List<Booking> get bookings => List.unmodifiable(_bookings);

  SavedAddress get defaultAddress =>
      _addresses.firstWhere((a) => a.isDefault, orElse: () => _addresses.first);

  static const List<String> supportedSocieties = [
    'Shivaji Nagar',
    'Peelamedu',
    'RS Puram',
    'Gandhipuram',
    'Saibaba Colony',
  ];

  final Map<String, String> _userPasswords = {
    'consumer@sahayak.coop': 'Password123!',
  };

  // Auth Operations
  bool signIn({required String email, required String password}) {
    if (password.trim().isEmpty) return false;
    final cleanEmail = email.trim().toLowerCase();
    if (_userPasswords.containsKey(cleanEmail)) {
      if (_userPasswords[cleanEmail] != password) {
        return false;
      }
    }
    final existing = _registeredUsers.firstWhere(
      (u) => u.email.toLowerCase() == cleanEmail,
      orElse: () => UserAccount(
        id: 'USR-${1000 + Random().nextInt(9000)}',
        name: email.split('@').first.replaceAll('.', ' ').toUpperCase(),
        email: cleanEmail,
        phone: '+91 98432 ${10000 + Random().nextInt(89999)}',
        society: _currentSociety,
        ward: 'Ward 5',
        createdAt: DateTime.now(),
      ),
    );
    if (!_registeredUsers.contains(existing)) {
      _registeredUsers.add(existing);
      _userPasswords[cleanEmail] = password;
    }
    _currentUser = existing;
    return true;
  }

  UserAccount signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String society,
    String ward = 'Ward 5',
  }) {
    final cleanEmail = email.trim().toLowerCase();
    final newUser = UserAccount(
      id: 'USR-${1000 + Random().nextInt(9000)}',
      name: name.trim(),
      email: cleanEmail,
      phone: phone.trim(),
      society: society,
      ward: ward,
      createdAt: DateTime.now(),
    );
    _registeredUsers.add(newUser);
    _userPasswords[cleanEmail] = password;
    _currentUser = newUser;
    _currentSociety = society;
    _currentWard = '$ward ($society)';
    return newUser;
  }

  Future<UserAccount> signInWithGoogle({
    String email = 'user.citizen@gmail.com',
    String name = 'Google Citizen',
    String society = 'Shivaji Nagar',
    String ward = 'Ward 5',
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    UserAccount? user;
    for (final u in _registeredUsers) {
      if (u.email.toLowerCase() == cleanEmail) {
        user = u;
        break;
      }
    }
    if (user == null) {
      user = UserAccount(
        id: 'USR-GGL-${1000 + Random().nextInt(9000)}',
        name: name,
        email: cleanEmail,
        phone: '+91 98765 43210',
        society: society,
        ward: ward,
        createdAt: DateTime.now(),
      );
      _registeredUsers.add(user);
    }
    _currentUser = user;
    _currentSociety = user.society;
    _currentWard = '${user.ward} (${user.society})';
    return user;
  }

  void updateProfile({
    String? name,
    String? phone,
    String? society,
    String? email,
  }) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      name: name?.trim().isNotEmpty == true ? name!.trim() : null,
      phone: phone?.trim().isNotEmpty == true ? phone!.trim() : null,
      society: society?.trim().isNotEmpty == true ? society!.trim() : null,
      email: email?.trim().isNotEmpty == true ? email!.trim().toLowerCase() : null,
    );
    if (society != null && society.trim().isNotEmpty) {
      _currentSociety = society.trim();
      _currentWard = 'Local ($society)';
    }
  }

  void signOut() {
    _currentUser = null;
  }

  void setLanguage(AppLanguage lang) {
    _selectedLanguage = lang;
  }

  void setWard(String ward) {
    _currentWard = ward;
    for (final s in supportedSocieties) {
      if (ward.contains(s)) {
        _currentSociety = s;
        break;
      }
    }
  }

  void setSociety(String society) {
    _currentSociety = society;
    _currentWard = 'Local Ward ($society)';
  }

  // Address CRUD
  void addAddress(SavedAddress address) {
    if (address.isDefault) {
      for (int i = 0; i < _addresses.length; i++) {
        _addresses[i] = _addresses[i].copyWith(isDefault: false);
      }
    }
    _addresses.add(address);
  }

  void updateAddress(SavedAddress address) {
    final index = _addresses.indexWhere((a) => a.id == address.id);
    if (index != -1) {
      if (address.isDefault) {
        for (int i = 0; i < _addresses.length; i++) {
          _addresses[i] = _addresses[i].copyWith(isDefault: false);
        }
      }
      _addresses[index] = address;
    }
  }

  void deleteAddress(String addressId) {
    _addresses.removeWhere((a) => a.id == addressId);
  }

  void setDefaultAddress(String addressId) {
    for (int i = 0; i < _addresses.length; i++) {
      _addresses[i] = _addresses[i].copyWith(isDefault: _addresses[i].id == addressId);
    }
  }

  // Multi-Domain & Nearest Society Worker Broadcast
  List<WorkerOffer> broadcastJobRequest({
    required List<String> domains,
    required String society,
    required bool isEmergency,
  }) {
    final candidateWorkers = _workers.where((worker) {
      // Worker matches if any domain matches or worker handles multiple domains
      final domainMatch = domains.any((d) => worker.supportedDomains.contains(d.toLowerCase()));
      return domainMatch;
    }).toList();

    // If no exact match, fallback to closest available workers
    final finalPool = candidateWorkers.isNotEmpty ? candidateWorkers : _workers;

    return finalPool.map((worker) {
      final isSameSociety = worker.society.toLowerCase() == society.toLowerCase();
      final distance = isSameSociety ? 0.6 + Random().nextDouble() * 0.5 : worker.distanceKm;
      final arrivalMins = isEmergency ? (isSameSociety ? 12 : 18) : (isSameSociety ? 15 : 30);
      final emergencyMultiplier = isEmergency ? 1.2 : 1.0;
      final visitFee = (worker.baseVisitFee * emergencyMultiplier).roundToDouble();
      final totalFee = (worker.estimatedTotalFee * emergencyMultiplier).roundToDouble();

      String customNote = 'Available for dispatch in $society cluster.';
      if (domains.length > 1) {
        customNote = 'Multi-domain diagnostic equipped: can inspect crossover issues.';
      }
      if (isEmergency) {
        customNote = '⚡ EMERGENCY PRIORITY: Can depart within 5 mins with rapid response kit.';
      }

      return WorkerOffer(
        id: 'OFF-${1000 + Random().nextInt(9000)}',
        worker: worker.copyWith(distanceKm: double.parse(distance.toStringAsFixed(1))),
        quotedVisitFee: visitFee,
        estimatedTotalFee: totalFee,
        estimatedArrivalMinutes: arrivalMins,
        note: customNote,
        submittedAt: DateTime.now(),
      );
    }).toList();
  }

  List<Worker> getWorkersForDomains(List<String> domains) {
    final clean = domains.map((d) => d.toLowerCase().replaceAll('domain-', '')).toList();
    return _workers.where((worker) {
      return clean.any((d) => worker.supportedDomains.contains(d));
    }).toList();
  }

  List<WorkerOffer> broadcastJobRequestToWorkers({
    required List<String> selectedDomains,
    required String problemDescription,
    required bool isEmergency,
    String? emergencyTag,
    required String society,
  }) {
    return broadcastJobRequest(
      domains: selectedDomains,
      society: society,
      isEmergency: isEmergency,
    );
  }

  Booking confirmBookingWithWorker({
    required String serviceName,
    required String subcategoryTitle,
    required List<String> selectedDomains,
    required bool isMultiDomain,
    required String problemDescription,
    required List<String> mediaUrls,
    required String scheduledSlot,
    required DateTime scheduledDateTime,
    required bool isEmergency,
    String? emergencyTag,
    required double latitude,
    required double longitude,
    required SavedAddress address,
    required WorkerOffer selectedOffer,
  }) {
    return createJobBooking(
      serviceName: serviceName,
      subcategoryTitle: subcategoryTitle,
      selectedDomains: selectedDomains,
      isMultiDomain: isMultiDomain,
      problemDescription: problemDescription,
      mediaUrls: mediaUrls,
      scheduledSlot: scheduledSlot,
      scheduledDateTime: scheduledDateTime,
      isEmergency: isEmergency,
      emergencyTag: emergencyTag,
      latitude: latitude,
      longitude: longitude,
      address: address,
      selectedOffer: selectedOffer,
    );
  }

  Booking createBooking({
    required String serviceName,
    required String subcategoryTitle,
    required String scheduledSlot,
    DateTime? scheduledDateTime,
    required SavedAddress address,
    required Worker worker,
    String? doorstepOtp,
  }) {
    final otp = doorstepOtp ?? (1000 + Random().nextInt(9000)).toString();
    final newBooking = Booking(
      id: 'SK-${10000 + _bookings.length * 123 + 482}',
      serviceName: serviceName,
      subcategoryTitle: subcategoryTitle,
      scheduledSlot: scheduledSlot,
      scheduledDateTime: scheduledDateTime ?? DateTime.now().add(const Duration(hours: 24)),
      address: address,
      worker: worker,
      doorstepOtp: otp,
      currentStage: BookingStage.confirmed,
      tab: BookingTab.upcoming,
      preServiceUpdate: WorkerPreServiceUpdate(
        status: WorkerPreServiceStatus.onTime,
        timestamp: DateTime.now(),
      ),
    );
    _bookings.insert(0, newBooking);
    return newBooking;
  }

  // Booking Lifecycle
  Booking createJobBooking({
    required String serviceName,
    required String subcategoryTitle,
    required List<String> selectedDomains,
    required bool isMultiDomain,
    required String problemDescription,
    required List<String> mediaUrls,
    required String scheduledSlot,
    required DateTime scheduledDateTime,
    required bool isEmergency,
    String? emergencyTag,
    double? latitude,
    double? longitude,
    required SavedAddress address,
    required WorkerOffer selectedOffer,
  }) {
    // Generate secure 4-digit doorstep verification OTP
    final randomOtp = (1000 + Random().nextInt(9000)).toString();

    final newBooking = Booking(
      id: 'SK-${10000 + _bookings.length * 123 + 482}',
      serviceName: serviceName,
      subcategoryTitle: subcategoryTitle,
      selectedDomains: selectedDomains,
      isMultiDomain: isMultiDomain,
      problemDescription: problemDescription,
      mediaUrls: mediaUrls,
      scheduledSlot: scheduledSlot,
      scheduledDateTime: scheduledDateTime,
      isEmergency: isEmergency,
      emergencyTag: emergencyTag,
      latitude: latitude,
      longitude: longitude,
      address: address,
      worker: selectedOffer.worker,
      doorstepOtp: randomOtp,
      currentStage: BookingStage.confirmed,
      tab: BookingTab.upcoming,
      preServiceUpdate: WorkerPreServiceUpdate(
        status: WorkerPreServiceStatus.onTime,
        timestamp: DateTime.now(),
      ),
      minutesUntilArrival: selectedOffer.estimatedArrivalMinutes,
      liveDistanceKm: selectedOffer.worker.distanceKm,
    );

    _bookings.insert(0, newBooking);
    return newBooking;
  }

  // 1-Hour Pre-Service Worker Status Update Simulator
  void updateWorkerPreServiceStatus(
    String bookingId,
    WorkerPreServiceStatus status, {
    int delayMinutes = 15,
    String? cancelReason,
  }) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      final current = _bookings[index];
      final update = WorkerPreServiceUpdate(
        status: status,
        delayMinutes: delayMinutes,
        cancelReason: cancelReason,
        timestamp: DateTime.now(),
      );

      BookingStage newStage = current.currentStage;
      BookingTab newTab = current.tab;
      String? cancelledBy = current.cancelledBy;
      String? reason = current.cancellationReason;

      if (status == WorkerPreServiceStatus.cancelledWithReason) {
        newTab = BookingTab.cancelled;
        cancelledBy = 'worker';
        reason = cancelReason ?? 'Technician emergency cancellation';
      }

      _bookings[index] = current.copyWith(
        preServiceUpdate: update,
        currentStage: newStage,
        tab: newTab,
        cancelledBy: cancelledBy,
        cancellationReason: reason,
      );
    }
  }

  // Customer Cancellation Rule Check (allowed > 1 hour before scheduled time)
  bool cancelBookingByCustomer(String bookingId, [String reason = 'Cancelled by customer under cooperative fair-work policy']) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) return false;

    final booking = _bookings[index];
    if (!booking.canCancelBefore1Hour) {
      // Within 1 hour: rejection / policy penalty applies
      return false;
    }

    _bookings[index] = booking.copyWith(
      tab: BookingTab.cancelled,
      cancelledBy: 'customer',
      cancellationReason: reason,
    );
    return true;
  }

  // Verify Doorstep OTP
  bool verifyDoorstepOtp(String bookingId, String enteredOtp) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      if (_bookings[index].doorstepOtp == enteredOtp.trim()) {
        _bookings[index] = _bookings[index].copyWith(
          currentStage: BookingStage.jobInProgress,
          tab: BookingTab.inProgress,
        );
        return true;
      }
    }
    return false;
  }

  // Complete Job & Generate Tax Invoice
  void completeJobAndGenerateInvoice(String bookingId) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      final current = _bookings[index];
      _bookings[index] = current.copyWith(
        currentStage: BookingStage.jobCompleted,
        invoice: CooperativeInvoice(
          invoiceNumber: 'INV-${DateTime.now().year}-COOP-${100 + index * 37}',
          date: 'Today, ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
          coopRegNumber: 'TN-COOP-449',
          technicianName: current.worker.name,
          technicianId: current.worker.guildId,
          paymentMethod: 'UPI (Instant Settlement)',
          diagnosticFee: current.worker.baseVisitFee.toInt(),
          laborFee: (current.worker.estimatedTotalFee - current.worker.baseVisitFee).toInt(),
          materialsFee: 0,
          totalAmount: current.worker.estimatedTotalFee.toInt(),
          isPaid: false,
        ),
      );
    }
  }

  // Pay Invoice
  void payBookingInvoice(String bookingId, {String paymentMethod = 'UPI (Instant Settlement)'}) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      final current = _bookings[index];
      final paidInvoice = current.invoice?.copyWith(
        isPaid: true,
        paymentMethod: paymentMethod,
      ) ?? CooperativeInvoice.sampleInvoice.copyWith(isPaid: true, paymentMethod: paymentMethod);

      _bookings[index] = current.copyWith(
        currentStage: BookingStage.paid,
        tab: BookingTab.completed,
        invoice: paidInvoice,
      );
    }
  }

  // Helper combining completion & payment
  void completeJobAndPay(String bookingId, [CooperativeInvoice? customInvoice]) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      final current = _bookings[index];
      final inv = customInvoice ?? current.invoice ?? CooperativeInvoice(
        invoiceNumber: 'INV-${DateTime.now().year}-COOP-${100 + index * 37}',
        date: 'Today, ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        coopRegNumber: 'TN-COOP-449',
        technicianName: current.worker.name,
        technicianId: current.worker.guildId,
        paymentMethod: 'UPI (Instant Settlement)',
        diagnosticFee: current.worker.baseVisitFee.toInt(),
        laborFee: (current.worker.estimatedTotalFee - current.worker.baseVisitFee).toInt(),
        materialsFee: 0,
        totalAmount: current.worker.estimatedTotalFee.toInt(),
        isPaid: true,
      );
      _bookings[index] = current.copyWith(
        currentStage: BookingStage.paid,
        tab: BookingTab.completed,
        invoice: inv.copyWith(isPaid: true),
      );
    }
  }

  // Mandatory Feedback & Rating
  void submitBookingFeedback({
    required String bookingId,
    required int rating,
    required String reviewText,
    List<String> reviewPhotos = const [],
  }) {
    assert(rating >= 1 && rating <= 5, 'Rating must be between 1 and 5 stars');
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      final current = _bookings[index];
      _bookings[index] = current.copyWith(
        rating: rating,
        reviewText: reviewText.trim(),
        reviewPhotos: reviewPhotos,
      );

      // Update worker rating average in repository
      final workerIndex = _workers.indexWhere((w) => w.id == current.worker.id);
      if (workerIndex != -1) {
        final w = _workers[workerIndex];
        final newCount = w.completedJobs + 1;
        final newRating = double.parse((((w.rating * w.completedJobs) + rating) / newCount).toStringAsFixed(1));
        _workers[workerIndex] = w.copyWith(
          completedJobs: newCount,
          rating: newRating,
        );
      }
    }
  }

  // Alias for review submission with double rating
  void submitBookingReview({
    required String bookingId,
    required double rating,
    required String reviewText,
    List<String> reviewPhotos = const [],
  }) {
    submitBookingFeedback(
      bookingId: bookingId,
      rating: rating.round().clamp(1, 5),
      reviewText: reviewText,
      reviewPhotos: reviewPhotos,
    );
  }

  List<Booking> getBookingsByTab(BookingTab tab) {
    return _bookings.where((b) => b.tab == tab).toList();
  }
}
