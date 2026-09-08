import 'dart:math';
import '../models/language.dart';
import '../models/service.dart';
import '../models/worker.dart';
import '../models/address.dart';
import '../models/booking.dart';
import '../models/invoice.dart';
import '../models/user.dart';
import '../models/coordinator.dart';

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
    Worker.kavithaSelvam,
    Worker.selvarajM,
    Worker.lakshmiNarayanan,
    Worker.muruganP,
    Worker.palaniKumar,
    Worker.vijayAnand,
  ];
  
  final List<SavedAddress> _addresses = [
    SavedAddress.defaultHome,
    SavedAddress.defaultOffice,
  ];

  final List<SavedAddress> _institutionAddresses = [
    SavedAddress.defaultInstitutionFacility,
  ];

  final Map<String, DomainCoordinator> _domainCoordinators = {};

  final List<Booking> _bookings = [];

  AppRepository() {
    // Initialize default domain coordinators for institutions
    for (final coord in DomainCoordinator.defaultInstitutionCoordinators) {
      _domainCoordinators[coord.domain.toLowerCase()] = coord;
    }

    // Initialize default demo account (Household)
    final initialUser = UserAccount(
      id: 'USR-${1000 + Random().nextInt(9000)}',
      name: 'Karthik Sivakumar',
      email: 'karthik.siva@worksolute.in',
      phone: '+91 98432 10842',
      society: 'Shivaji Nagar',
      ward: 'Ward 5',
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      accountType: UserAccountType.household,
    );
    _registeredUsers.add(initialUser);

    // Also register an institution demo account for quick sign-in/testing
    final institutionDemoUser = UserAccount(
      id: 'USR-INST-5001',
      name: 'Rajesh Ramanathan (Admin)',
      email: 'facilities@apextech.in',
      phone: '+91 98432 99887',
      society: 'Peelamedu',
      ward: 'Ward 8',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      accountType: UserAccountType.institution,
      organizationName: 'Apex Technology Park',
      siteAddress: 'Block B Main Building, Peelamedu, Ward 8 - 641014',
    );
    _registeredUsers.add(institutionDemoUser);
    _userPasswords['facilities@apextech.in'] = 'Password123!';

    _currentUser = initialUser;

    // Seed default upcoming & completed bookings (Household + Institution)
    _bookings.addAll([
      Booking.defaultUpcoming,
      Booking.defaultCompleted,
      Booking.defaultInstitutionUpcoming,
      Booking.defaultInstitutionCompleted,
    ]);
  }

  // Getters
  bool get isAuthenticated => _currentUser != null;
  UserAccount? get currentUser => _currentUser;
  bool get isCurrentUserInstitution => _currentUser?.isInstitution ?? false;
  String get userName => _currentUser?.name ?? 'Guest User';
  String get userEmail => _currentUser?.email ?? 'guest@worksolute.in';
  String get userPhone => _currentUser?.phone ?? '+91 90000 00000';
  String get userSociety => _currentUser?.society ?? _currentSociety;
  String get userWard => _currentUser?.ward ?? 'Ward 5';
  String get userMemberId => 'SHK-${(_currentUser?.id ?? '1001').replaceAll('USR-', '').replaceAll('GGL-', '')}';

  AppLanguage get selectedLanguage => _selectedLanguage;
  String get currentWard => _currentWard;
  String get currentSociety => _currentSociety;
  List<ServiceItem> get services => List.unmodifiable(_services);
  List<ServiceSubcategory> get plumbingSubcategories => List.unmodifiable(_plumbingSubcategories);
  List<ServiceSubcategory> getSubcategoriesForService(String serviceId) =>
      ServiceSubcategory.getSubcategoriesForService(serviceId);
  List<Worker> get workers => List.unmodifiable(_workers);
  List<SavedAddress> get _activeAddressList =>
      isCurrentUserInstitution ? _institutionAddresses : _addresses;

  List<SavedAddress> get addresses => List.unmodifiable(
      isCurrentUserInstitution
          ? (_institutionAddresses.isNotEmpty
              ? _institutionAddresses
              : [SavedAddress.defaultInstitutionFacility])
          : _addresses);
  List<Booking> get bookings => List.unmodifiable(_bookings);

  List<Booking> get activeInstitutionBookings =>
      _bookings.where((b) => b.isInstitutionBooking && b.tab == BookingTab.upcoming).toList();

  SavedAddress get defaultAddress {
    final currentList = addresses;
    return currentList.firstWhere((a) => a.isDefault, orElse: () => currentList.first);
  }

  static const List<String> supportedSocieties = [
    'Shivaji Nagar',
    'Peelamedu',
    'RS Puram',
    'Gandhipuram',
    'Saibaba Colony',
  ];

  final Map<String, String> _userPasswords = {
    'consumer@worksolute.coop': 'Password123!',
    'facilities@apextech.in': 'Password123!',
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
        accountType: cleanEmail.contains('apex') || cleanEmail.contains('inst') || cleanEmail.contains('org')
            ? UserAccountType.institution
            : UserAccountType.household,
        organizationName: cleanEmail.contains('apex') || cleanEmail.contains('inst') || cleanEmail.contains('org')
            ? 'Apex Technology Park'
            : null,
      ),
    );
    if (!_registeredUsers.contains(existing)) {
      _registeredUsers.add(existing);
      _userPasswords[cleanEmail] = password;
    }
    _currentUser = existing;

    // Ensure institutional user has their sequential default facility address configured
    if (existing.isInstitution) {
      final siteText = existing.siteAddress ?? 'Block B Main Building, Peelamedu, Ward 8 - 641014';
      if (_institutionAddresses.isEmpty) {
        _institutionAddresses.add(
          SavedAddress(
            id: 'site-${existing.id.replaceAll('USR-', '')}',
            label: 'Office 1 (${existing.organizationName ?? 'Main Facility'})',
            type: 'Office',
            streetAddress: siteText,
            landmark: existing.society.isNotEmpty ? existing.society : 'Peelamedu Tech Hub',
            ward: existing.ward.isNotEmpty ? existing.ward : 'Ward 8',
            pincode: '641014',
            isDefault: true,
            latitude: 11.0280,
            longitude: 77.0035,
          ),
        );
      }
    }

    return true;
  }

  UserAccount signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String society,
    String ward = 'Ward 5',
    UserAccountType accountType = UserAccountType.household,
    String? organizationName,
    String? siteAddress,
  }) {
    final cleanEmail = email.trim().toLowerCase();
    final newUser = UserAccount(
      id: accountType == UserAccountType.institution
          ? 'USR-INST-${1000 + Random().nextInt(9000)}'
          : 'USR-${1000 + Random().nextInt(9000)}',
      name: name.trim(),
      email: cleanEmail,
      phone: phone.trim(),
      society: society,
      ward: ward,
      createdAt: DateTime.now(),
      accountType: accountType,
      organizationName: organizationName?.trim(),
      siteAddress: siteAddress?.trim(),
    );
    _registeredUsers.add(newUser);
    _userPasswords[cleanEmail] = password;
    _currentUser = newUser;
    _currentSociety = society;
    _currentWard = '$ward ($society)';

    // If institution registered, configure default Office 1 facility site address
    if (accountType == UserAccountType.institution) {
      final finalSite = siteAddress?.trim().isNotEmpty == true
          ? siteAddress!.trim()
          : 'Block B Main Building, $society';
      _institutionAddresses.clear();
      _institutionAddresses.add(
        SavedAddress(
          id: 'site-${1000 + Random().nextInt(9000)}',
          label: 'Office 1 (${organizationName?.trim() ?? 'Main Facility'})',
          type: 'Office',
          streetAddress: finalSite,
          landmark: society,
          ward: ward,
          pincode: '641014',
          isDefault: true,
          latitude: 11.0280,
          longitude: 77.0035,
        ),
      );
    }

    return newUser;
  }

  Future<UserAccount> signInWithGoogle({
    String email = 'user.citizen@gmail.com',
    String name = 'Google Citizen',
    String society = 'Shivaji Nagar',
    String ward = 'Ward 5',
    UserAccountType accountType = UserAccountType.household,
    String? organizationName,
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
        accountType: accountType,
        organizationName: organizationName,
      );
      _registeredUsers.add(user);
    }
    _currentUser = user;
    _currentSociety = user.society;
    _currentWard = '${user.ward} (${user.society})';

    if (user.isInstitution) {
      if (_institutionAddresses.isEmpty) {
        _institutionAddresses.add(
          SavedAddress(
            id: 'site-ggl-${user.id.replaceAll('USR-GGL-', '')}',
            label: 'Office 1 (${user.organizationName ?? 'Main Facility'})',
            type: 'Office',
            streetAddress: 'Commercial Complex, ${user.society}',
            landmark: user.society,
            ward: user.ward,
            pincode: '641014',
            isDefault: true,
            latitude: 11.0280,
            longitude: 77.0035,
          ),
        );
      }
    }

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

  // Coordinator Management
  DomainCoordinator getCoordinatorForDomain(String domain) {
    final clean = domain.toLowerCase().replaceAll('domain-', '').trim();
    if (_domainCoordinators.containsKey(clean)) {
      return _domainCoordinators[clean]!;
    }
    for (final entry in _domainCoordinators.entries) {
      if (clean.contains(entry.key) || entry.key.contains(clean)) {
        return entry.value;
      }
    }
    final title = DomainCoordinator.getDomainTitle(domain);
    return DomainCoordinator(
      domain: clean,
      domainTitle: title,
      name: _currentUser?.name ?? 'Facility Administrator',
      phone: _currentUser?.phone ?? '+91 98432 99887',
      email: _currentUser?.email ?? 'facilities@apextech.in',
    );
  }

  void setDomainCoordinator(DomainCoordinator coordinator) {
    final clean = coordinator.domain.toLowerCase().replaceAll('domain-', '').trim();
    _domainCoordinators[clean] = coordinator;
  }

  List<DomainCoordinator> get domainCoordinators =>
      List.unmodifiable(_domainCoordinators.values);

  int get nextOfficeNumber => _institutionAddresses.length + 1;
  String getNextOfficeName() => 'Office $nextOfficeNumber';

  // Address CRUD
  void addAddress(SavedAddress address) {
    if (isCurrentUserInstitution) {
      final index = _institutionAddresses.length + 1;
      String label = address.label.trim();
      if (label.isEmpty || label == 'Home' || label == 'Office' || label == 'Other') {
        label = 'Office $index';
      }
      final newSite = address.copyWith(
        label: label,
        type: 'Office',
        isDefault: address.isDefault || _institutionAddresses.isEmpty,
      );
      if (newSite.isDefault) {
        for (int i = 0; i < _institutionAddresses.length; i++) {
          _institutionAddresses[i] = _institutionAddresses[i].copyWith(isDefault: false);
        }
      }
      _institutionAddresses.add(newSite);
      return;
    }

    final list = _activeAddressList;
    if (address.isDefault) {
      for (int i = 0; i < list.length; i++) {
        list[i] = list[i].copyWith(isDefault: false);
      }
    }
    list.add(address);
  }

  void updateAddress(SavedAddress address) {
    final list = _activeAddressList;
    final index = list.indexWhere((a) => a.id == address.id);
    if (index != -1) {
      if (address.isDefault) {
        for (int i = 0; i < list.length; i++) {
          list[i] = list[i].copyWith(isDefault: false);
        }
      }
      list[index] = address;
    }
  }

  void deleteAddress(String addressId) {
    _activeAddressList.removeWhere((a) => a.id == addressId);
  }

  void setDefaultAddress(String addressId) {
    final list = _activeAddressList;
    for (int i = 0; i < list.length; i++) {
      list[i] = list[i].copyWith(isDefault: list[i].id == addressId);
    }
  }

  // Multi-Domain & Nearest Society Worker Broadcast
  List<WorkerOffer> broadcastJobRequest({
    required List<String> domains,
    required String society,
    required bool isEmergency,
  }) {
    final candidateWorkers = _workers.where((worker) {
      final domainMatch = domains.any((d) {
        final cleanD = d.toLowerCase().trim().replaceAll('domain-', '');
        return worker.supportedDomains.any((wd) {
          final cleanWd = wd.toLowerCase().trim();
          return cleanWd == cleanD ||
              cleanWd.startsWith(cleanD) ||
              cleanD.startsWith(cleanWd) ||
              (cleanD == 'plumber' && cleanWd == 'plumbing') ||
              (cleanD == 'plumbing' && cleanWd == 'plumber') ||
              (cleanD == 'electrician' && cleanWd == 'electrical') ||
              (cleanD == 'electrical' && cleanWd == 'electrician');
        });
      });
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
    final clean = domains.map((d) => d.toLowerCase().replaceAll('domain-', '').trim()).toList();
    return _workers.where((worker) {
      return clean.any((d) {
        return worker.supportedDomains.any((wd) {
          final cleanWd = wd.toLowerCase().trim();
          return cleanWd == d ||
              cleanWd.startsWith(d) ||
              d.startsWith(cleanWd);
        });
      });
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
    String? urgencyLevel,
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
      urgencyLevel: urgencyLevel,
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
    String? urgencyLevel,
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
      urgencyLevel: urgencyLevel,
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
      final isInst = current.isInstitutionBooking;
      final diagFee = isInst ? 500 : current.worker.baseVisitFee.toInt();
      final labFee = isInst ? 4800 : (current.worker.estimatedTotalFee - current.worker.baseVisitFee).toInt();
      final matFee = isInst ? 350 : 0;
      final int platFee = isInst ? (diagFee * 0.18).round() : ((diagFee + labFee + matFee) * 0.10).round();
      final total = diagFee + labFee + matFee + platFee;

      List<InstitutionInvoiceItem> lineItems = const [];
      if (isInst) {
        lineItems = [
          InstitutionInvoiceItem(
            domain: 'electrical',
            domainTitle: 'Licensed Electricians',
            workerCount: 3,
            ratePerWorker: 800,
            diagnosticFee: 300,
            laborFee: 2400,
            materialsFee: 200,
            platformFee: 54, // 18% of 300
            totalAmount: 2954,
          ),
          InstitutionInvoiceItem(
            domain: 'cleaner',
            domainTitle: 'Deep Cleaning Crew',
            workerCount: 4,
            ratePerWorker: 600,
            diagnosticFee: 200,
            laborFee: 2400,
            materialsFee: 150,
            platformFee: 36, // 18% of 200
            totalAmount: 2786,
          ),
        ];
      }

      _bookings[index] = current.copyWith(
        currentStage: BookingStage.jobCompleted,
        invoice: CooperativeInvoice(
          invoiceNumber: 'INV-${DateTime.now().year}-COOP-${100 + index * 37}',
          date: 'Today, ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
          coopRegNumber: isInst ? 'TN-COOP-449-INST' : 'TN-COOP-449',
          technicianName: isInst ? 'Work Solute Cooperative Guild Allocation' : current.worker.name,
          technicianId: isInst ? '#CORP-SEC-04' : current.worker.guildId,
          paymentMethod: isInst ? 'Institutional Corporate Net / UPI' : 'UPI (Instant Settlement)',
          diagnosticFee: diagFee,
          laborFee: labFee,
          materialsFee: matFee,
          platformFee: platFee,
          totalAmount: total,
          isPaid: false,
          isInstitutionInvoice: isInst,
          organizationName: current.organizationName,
          siteName: current.address.label,
          lineItems: lineItems,
        ),
      );
    }
  }

  // Pay Invoice
  void payBookingInvoice(String bookingId, {String paymentMethod = 'UPI (Instant Settlement)'}) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      final current = _bookings[index];
      final isInst = current.isInstitutionBooking;
      final defaultInv = isInst ? CooperativeInvoice.sampleInstitutionInvoice : CooperativeInvoice.sampleInvoice;
      final paidInvoice = current.invoice?.copyWith(
        isPaid: true,
        paymentMethod: paymentMethod,
      ) ?? defaultInv.copyWith(isPaid: true, paymentMethod: paymentMethod);

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
      final isInst = current.isInstitutionBooking;
      final diagFee = isInst ? 500 : current.worker.baseVisitFee.toInt();
      final labFee = isInst ? 4800 : (current.worker.estimatedTotalFee - current.worker.baseVisitFee).toInt();
      final matFee = isInst ? 350 : 0;
      final int platFee = isInst ? (diagFee * 0.18).round() : (diagFee * 0.10).round();
      final total = diagFee + labFee + matFee + platFee;

      final inv = customInvoice ?? current.invoice ?? CooperativeInvoice(
        invoiceNumber: 'INV-${DateTime.now().year}-COOP-${100 + index * 37}',
        date: 'Today, ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        coopRegNumber: isInst ? 'TN-COOP-449-INST' : 'TN-COOP-449',
        technicianName: isInst ? 'Work Solute Cooperative Guild Allocation' : current.worker.name,
        technicianId: isInst ? '#CORP-SEC-04' : current.worker.guildId,
        paymentMethod: isInst ? 'Institutional Corporate Net / UPI' : 'UPI (Instant Settlement)',
        diagnosticFee: diagFee,
        laborFee: labFee,
        materialsFee: matFee,
        platformFee: platFee,
        totalAmount: total,
        isPaid: true,
        isInstitutionInvoice: isInst,
        organizationName: current.organizationName,
        siteName: current.address.label,
        lineItems: isInst ? CooperativeInvoice.sampleInstitutionInvoice.lineItems : const [],
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

  Booking createInstitutionBooking({
    required String serviceName,
    required String subcategoryTitle,
    required Map<String, int> requiredWorkersPerDomain,
    required String problemDescription,
    required String scheduledSlot,
    required DateTime scheduledDateTime,
    required SavedAddress address,
    String? organizationName,
  }) {
    // Generate realistic cooperative worker allocations across requested domains
    final Map<String, List<Worker>> allocations = {};
    final cleanDomains = requiredWorkersPerDomain.keys.toList();

    for (final entry in requiredWorkersPerDomain.entries) {
      final domain = entry.key;
      final count = entry.value;
      final matchingWorkers = _workers.where((w) => w.supportedDomains.contains(domain.toLowerCase())).toList();
      final pool = matchingWorkers.isNotEmpty ? matchingWorkers : _workers;

      final List<Worker> allocated = [];
      // Allocate up to count or leave 1 unfilled if multi-worker to show realistic progressive matching
      final int allocatedCount = count > 1 ? count - 1 : count;
      for (int i = 0; i < allocatedCount; i++) {
        allocated.add(pool[i % pool.length]);
      }
      allocations[domain] = allocated;
    }

    final newBooking = Booking(
      id: 'SK-INST-${10000 + _bookings.length * 111 + 321}',
      serviceName: serviceName,
      subcategoryTitle: subcategoryTitle,
      selectedDomains: cleanDomains,
      isMultiDomain: cleanDomains.length > 1,
      problemDescription: problemDescription,
      scheduledSlot: scheduledSlot,
      scheduledDateTime: scheduledDateTime,
      isEmergency: false,
      address: address,
      worker: allocations.values.isNotEmpty && allocations.values.first.isNotEmpty
          ? allocations.values.first.first
          : _workers.first,
      doorstepOtp: (1000 + Random().nextInt(9000)).toString(),
      currentStage: BookingStage.confirmed,
      tab: BookingTab.upcoming,
      isInstitutionBooking: true,
      organizationName: organizationName ?? _currentUser?.organizationName ?? 'Institution Partner',
      requiredWorkersPerDomain: requiredWorkersPerDomain,
      allocatedWorkersPerDomain: allocations,
      preServiceUpdate: WorkerPreServiceUpdate(
        status: WorkerPreServiceStatus.onTime,
        timestamp: DateTime.now(),
      ),
    );

    _bookings.insert(0, newBooking);
    return newBooking;
  }

  List<Booking> getBookingsByTab(BookingTab tab) {
    final isInst = _currentUser?.isInstitution ?? false;
    return _bookings.where((b) {
      if (isInst) {
        return b.isInstitutionBooking && b.tab == tab;
      } else {
        return !b.isInstitutionBooking && b.tab == tab;
      }
    }).toList();
  }
}
