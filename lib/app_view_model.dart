import 'dart:math';
import 'package:flutter/material.dart';

import 'data/models/language.dart';
import 'data/models/service.dart';
import 'data/models/address.dart';
import 'data/models/booking.dart';
import 'data/models/user.dart';
import 'data/models/coordinator.dart';
import 'data/repositories/app_repository.dart';
import 'core/localization/app_strings.dart';

enum AppScreen { languageSelection, login, phoneVerification, mainShell }

enum ShellTab { home, bookings, profile }

class AppViewModel extends ChangeNotifier {
  final AppRepository _repository;

  AppViewModel({AppRepository? repository})
    : _repository = repository ?? AppRepository();

  AppScreen _currentScreen = AppScreen.languageSelection;
  ShellTab _currentTab = ShellTab.home;
  String _serviceSearchQuery = '';

  // Notification Preferences
  bool _whatsappUpdates = true;
  bool _smsOtp = true;
  bool _bookingReminders = true;

  // Booking Wizard State
  String _wizardServiceId = 'plumber';
  String _wizardServiceName = 'Plumbing Service';
  String _wizardProblemDescription =
      'Kitchen sink tap is leaking continuously under the counter, causing water pooling on the floor.';
  String _wizardSelectedSubcategoryId = 'plumb_tap';
  final List<String> _wizardUploadedPhotos = ['assets/images/logo.png'];
  final List<String> _wizardUploadedVideos = [];

  // Single vs Multi-Domain Selection
  bool _wizardIsMultiDomain = false;
  final List<String> _wizardSelectedDomains = ['plumbing'];

  // Scheduling & Emergency Dispatch
  bool _wizardIsEmergency = false;
  String? _wizardEmergencyTag;
  String _wizardScheduledUrgency = 'standard'; // 'standard', 'priority', 'flexible'
  String _wizardEmergencySeverity = 'critical'; // 'critical', 'high'
  double? _wizardLatitude = 12.9716; // Live device latitude
  double? _wizardLongitude = 77.5946; // Live device longitude
  bool _isDetectingLocation = false;
  bool get isDetectingLocation => _isDetectingLocation;
  int _wizardSelectedDateIndex = 0;
  String _wizardSelectedTimeSlot = '2:00 PM – 4:00 PM';
  SavedAddress? _wizardSelectedAddress;

  // Worker Bidding / Offers
  List<WorkerOffer> _availableOffers = [];
  WorkerOffer? _selectedOffer;
  String _offerSortBy = 'rating'; // 'rating', 'fee', 'distance'

  Booking? _lastCreatedBooking;

  // Getters
  AppRepository get repository => _repository;
  AppScreen get currentScreen => _currentScreen;
  ShellTab get currentTab => _currentTab;
  UserAccount? get currentUser => _repository.currentUser;
  bool get isLoggedIn => _repository.isAuthenticated;

  AppLanguage get selectedLanguage => _repository.selectedLanguage;
  AppStrings get strings => AppStrings(_repository.selectedLanguage.code);
  String get currentWard => _repository.currentWard;
  String get currentSociety => _repository.currentSociety;
  String get userName => _repository.userName;
  String get userEmail => _repository.userEmail;
  String get userPhone => _repository.userPhone;
  String get userSociety => _repository.userSociety;
  String get userMemberId => _repository.userMemberId;
  String get serviceSearchQuery => _serviceSearchQuery;

  bool get whatsappUpdates => _whatsappUpdates;
  bool get smsOtp => _smsOtp;
  bool get bookingReminders => _bookingReminders;

  String get wizardServiceId => _wizardServiceId;
  String get wizardServiceName => _wizardServiceName;
  String get wizardProblemDescription => _wizardProblemDescription;
  String get wizardSelectedSubcategoryId => _wizardSelectedSubcategoryId;
  List<ServiceSubcategory> get wizardSubcategories =>
      _repository.getSubcategoriesForService(_wizardServiceId);
  ServiceSubcategory? get wizardSelectedSubcategory {
    final subcats = wizardSubcategories;
    return subcats.firstWhere(
      (s) => s.id == _wizardSelectedSubcategoryId,
      orElse: () => subcats.isNotEmpty
          ? subcats.first
          : ServiceSubcategory.plumbingSubcategories.first,
    );
  }
  List<String> get wizardUploadedPhotos =>
      List.unmodifiable(_wizardUploadedPhotos);
  List<String> get wizardUploadedVideos =>
      List.unmodifiable(_wizardUploadedVideos);
  bool get wizardIsMultiDomain => _wizardIsMultiDomain;
  List<String> get wizardSelectedDomains =>
      List.unmodifiable(_wizardSelectedDomains);

  bool get wizardIsEmergency => _wizardIsEmergency;
  String? get wizardEmergencyTag => _wizardEmergencyTag;
  String get wizardScheduledUrgency => _wizardScheduledUrgency;
  String get wizardEmergencySeverity => _wizardEmergencySeverity;
  double? get wizardLatitude => _wizardLatitude;
  double? get wizardLongitude => _wizardLongitude;
  int get wizardSelectedDateIndex => _wizardSelectedDateIndex;
  String get wizardSelectedTimeSlot => _wizardSelectedTimeSlot;
  bool get isInstitution => _repository.isCurrentUserInstitution;
  SavedAddress get wizardSelectedAddress {
    if (isInstitution) {
      return _repository.addresses.first;
    }
    return _wizardSelectedAddress ?? _repository.defaultAddress;
  }

  List<WorkerOffer> get availableOffers => List.unmodifiable(_availableOffers);
  WorkerOffer? get selectedOffer =>
      _selectedOffer ??
      (_availableOffers.isNotEmpty ? _availableOffers.first : null);
  String get offerSortBy => _offerSortBy;
  Booking? get lastCreatedBooking => _lastCreatedBooking;

  List<ServiceItem> get filteredServices {
    if (_serviceSearchQuery.trim().isEmpty) return _repository.services;
    final query = _serviceSearchQuery.toLowerCase().trim();
    return _repository.services.where((s) {
      return s.title.toLowerCase().contains(query) ||
          s.description.toLowerCase().contains(query);
    }).toList();
  }

  // Navigation
  void navigateTo(AppScreen screen) {
    _currentScreen = screen;
    notifyListeners();
  }

  void switchTab(ShellTab tab) {
    _currentTab = tab;
    notifyListeners();
  }

  // Auth
  bool signIn(String email, String password) {
    final success = _repository.signIn(email: email, password: password);
    if (success) {
      _wizardSelectedAddress = null;
      _currentScreen = AppScreen.mainShell;
      notifyListeners();
    }
    return success;
  }

  void signUp({
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
    _repository.signUp(
      name: name,
      email: email,
      phone: phone,
      password: password,
      society: society,
      ward: ward,
      accountType: accountType,
      organizationName: organizationName,
      siteAddress: siteAddress,
    );
    _wizardSelectedAddress = null;
    _currentScreen = AppScreen.mainShell;
    notifyListeners();
  }

  void signOut() {
    _repository.signOut();
    _wizardSelectedAddress = null;
    _currentScreen = AppScreen.login;
    notifyListeners();
  }

  Future<bool> signInWithGoogle({
    String? email,
    String? name,
    UserAccountType accountType = UserAccountType.household,
    String? organizationName,
  }) async {
    await _repository.signInWithGoogle(
      email: email ?? 'citizen.user@gmail.com',
      name: name ?? 'Google Citizen',
      accountType: accountType,
      organizationName: organizationName,
    );
    _wizardSelectedAddress = null;
    _currentScreen = AppScreen.mainShell;
    _currentTab = ShellTab.home;
    notifyListeners();
    return true;
  }

  void updateProfile({
    String? name,
    String? phone,
    String? society,
    String? email,
  }) {
    _repository.updateProfile(
      name: name,
      phone: phone,
      society: society,
      email: email,
    );
    notifyListeners();
  }

  Future<void> detectCurrentDeviceLocation() async {
    _isDetectingLocation = true;
    notifyListeners();
    // Simulate real device GPS hardware lock
    await Future.delayed(const Duration(milliseconds: 600));
    _wizardLatitude = 12.9716 + (Random().nextDouble() - 0.5) * 0.05;
    _wizardLongitude = 77.5946 + (Random().nextDouble() - 0.5) * 0.05;
    _repository.setWard('Live Device Location (Active)');
    _isDetectingLocation = false;
    notifyListeners();
  }

  // Language & Ward
  void selectLanguage(AppLanguage lang) {
    _repository.setLanguage(lang);
    notifyListeners();
  }

  void updateWard(String ward) {
    _repository.setWard(ward);
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _serviceSearchQuery = query;
    notifyListeners();
  }

  // Notification Toggles
  void toggleWhatsApp(bool val) {
    _whatsappUpdates = val;
    notifyListeners();
  }

  void toggleSms(bool val) {
    _smsOtp = val;
    notifyListeners();
  }

  void toggleReminders(bool val) {
    _bookingReminders = val;
    notifyListeners();
  }

  // Address Actions
  void saveAddress(SavedAddress address) {
    final existing = _repository.addresses.any((a) => a.id == address.id);
    if (existing) {
      _repository.updateAddress(address);
    } else {
      _repository.addAddress(address);
    }
    notifyListeners();
  }

  void deleteAddress(String id) {
    _repository.deleteAddress(id);
    notifyListeners();
  }

  void setDefaultAddress(String id) {
    _repository.setDefaultAddress(id);
    notifyListeners();
  }

  int get nextOfficeNumber => _repository.nextOfficeNumber;
  String getNextOfficeName() => _repository.getNextOfficeName();

  // Coordinator Actions
  List<DomainCoordinator> get domainCoordinators => _repository.domainCoordinators;
  DomainCoordinator getCoordinatorForDomain(String domain) => _repository.getCoordinatorForDomain(domain);
  void setDomainCoordinator(DomainCoordinator coordinator) {
    _repository.setDomainCoordinator(coordinator);
    notifyListeners();
  }

  // Wizard Domain Selection
  void setService(ServiceItem service) {
    _wizardServiceId = service.id;
    _wizardServiceName = service.title;
    if (service.id != 'multi_trade') {
      _wizardIsMultiDomain = false;
      _wizardSelectedDomains.clear();
      _wizardSelectedDomains.add(service.id);
      final subcats = _repository.getSubcategoriesForService(service.id);
      if (subcats.isNotEmpty) {
        final matches = subcats.any((s) => s.id == _wizardSelectedSubcategoryId);
        if (!matches) {
          _wizardSelectedSubcategoryId = subcats.first.id;
        }
      }
      _wizardProblemDescription = _getDefaultDescriptionForService(service.id);
    }
    notifyListeners();
  }

  void startBookingWizard(ServiceItem service) {
    setService(service);
    _wizardUploadedPhotos.clear();
    _wizardUploadedVideos.clear();
    _selectedOffer = null;
    _availableOffers = [];
    notifyListeners();
  }

  static String _getDefaultDescriptionForService(String serviceId) {
    switch (serviceId.toLowerCase().trim()) {
      case 'plumber':
      case 'plumbing':
        return 'Kitchen sink tap is leaking continuously under the counter, causing water pooling on the floor.';
      case 'electrician':
      case 'electrical':
        return 'Ceiling fan regulator is sparking and switchboard socket needs repair.';
      case 'cleaner':
      case 'cleaning':
        return 'Need deep cleaning and sanitization for 2BHK home including kitchen & bathrooms.';
      case 'carpenter':
      case 'carpentry':
        return 'Main bedroom wardrobe door hinges are loose and sliding lock needs repair.';
      case 'caregiver':
      case 'caregiving':
        return 'Daily morning mobility assistance and vital monitoring support needed for elderly parent.';
      case 'driver':
      case 'driving':
        return 'Need experienced city chauffeur for daily commute and local errand trips.';
      case 'gardener':
      case 'gardening':
        return 'Lawn trimming, weeding and organic fertilizer treatment required for garden.';
      case 'appliance':
      case 'appliances':
        return 'Split AC cooling is low and gas pressure check & filter wash is required.';
      default:
        return 'Please inspect and diagnose the required service repairs.';
    }
  }

  void setMultiTradeDomains(Set<String> domains) {
    _wizardIsMultiDomain = true;
    _wizardSelectedDomains.clear();
    _wizardSelectedDomains.addAll(domains);
    final domainTitles = domains.map((d) => d[0].toUpperCase() + d.substring(1)).join(' + ');
    _wizardServiceName = 'Multi-Trade ($domainTitles)';
    notifyListeners();
  }

  void toggleMultiDomain(bool enable) {
    _wizardIsMultiDomain = enable;
    if (!enable && _wizardSelectedDomains.length > 1) {
      final first = _wizardSelectedDomains.first;
      _wizardSelectedDomains.clear();
      _wizardSelectedDomains.add(first);
    }
    notifyListeners();
  }

  void toggleDomainSelection(String domainId) {
    if (_wizardSelectedDomains.contains(domainId)) {
      if (_wizardSelectedDomains.length > 1) {
        _wizardSelectedDomains.remove(domainId);
      }
    } else {
      _wizardSelectedDomains.add(domainId);
    }
    notifyListeners();
  }

  void setProblemDescription(String desc) {
    _wizardProblemDescription = desc;
    notifyListeners();
  }

  void setSubcategory(String id) {
    _wizardSelectedSubcategoryId = id;
    notifyListeners();
  }

  // Media
  void addWizardPhoto(String path) {
    if (_wizardUploadedPhotos.length < 5) {
      _wizardUploadedPhotos.add(path);
      notifyListeners();
    }
  }

  void removeWizardPhoto(int index) {
    if (index >= 0 && index < _wizardUploadedPhotos.length) {
      _wizardUploadedPhotos.removeAt(index);
      notifyListeners();
    }
  }

  void addWizardVideo(String path) {
    if (_wizardUploadedVideos.length < 2) {
      _wizardUploadedVideos.add(path);
      notifyListeners();
    }
  }

  void removeWizardVideo(int index) {
    if (index >= 0 && index < _wizardUploadedVideos.length) {
      _wizardUploadedVideos.removeAt(index);
      notifyListeners();
    }
  }

  // Emergency & Scheduling
  void setTimingMode({required bool isEmergency, String? emergencyTag}) {
    _wizardIsEmergency = isEmergency;
    _wizardEmergencyTag = emergencyTag;
    notifyListeners();
  }

  void setScheduledUrgency(String urgency) {
    _wizardScheduledUrgency = urgency;
    notifyListeners();
  }

  void setEmergencySeverity(String severity) {
    _wizardEmergencySeverity = severity;
    notifyListeners();
  }

  void setGeolocation({required double lat, required double lng}) {
    _wizardLatitude = lat;
    _wizardLongitude = lng;
    notifyListeners();
  }

  void setDateIndex(int index) {
    _wizardSelectedDateIndex = index;
    notifyListeners();
  }

  void setTimeSlot(String slot) {
    _wizardSelectedTimeSlot = slot;
    notifyListeners();
  }

  void setWizardAddress(SavedAddress address) {
    _wizardSelectedAddress = address;
    notifyListeners();
  }

  // Broadcast & Fetch Worker Offers
  void broadcastJobRequest() {
    _availableOffers = _repository.broadcastJobRequest(
      domains: _wizardSelectedDomains,
      society: wizardSelectedAddress.society.isNotEmpty
          ? wizardSelectedAddress.society
          : _repository.currentSociety,
      isEmergency: _wizardIsEmergency,
    );
    sortOffers(_offerSortBy);
    if (_availableOffers.isNotEmpty) {
      _selectedOffer = _availableOffers.first;
    }
    notifyListeners();
  }

  void sortOffers(String sortBy) {
    _offerSortBy = sortBy;
    if (sortBy == 'rating') {
      _availableOffers.sort(
        (a, b) => b.worker.rating.compareTo(a.worker.rating),
      );
    } else if (sortBy == 'fee') {
      _availableOffers.sort(
        (a, b) => a.quotedVisitFee.compareTo(b.quotedVisitFee),
      );
    } else if (sortBy == 'distance') {
      _availableOffers.sort(
        (a, b) => a.worker.distanceKm.compareTo(b.worker.distanceKm),
      );
    }
    notifyListeners();
  }

  void selectOffer(WorkerOffer offer) {
    _selectedOffer = offer;
    notifyListeners();
  }

  // Confirm and Create Booking
  Booking confirmAndCreateBooking() {
    final offer =
        selectedOffer ??
        (_availableOffers.isNotEmpty ? _availableOffers.first : null);
    if (offer == null) {
      broadcastJobRequest();
    }
    final chosenOffer = selectedOffer ?? _availableOffers.first;

    final targetDateTime = _wizardIsEmergency
        ? DateTime.now().add(const Duration(minutes: 20))
        : DateTime.now().add(
            Duration(days: _wizardSelectedDateIndex, hours: 2),
          );

    final selectedSub = wizardSelectedSubcategory;
    final subTitle = selectedSub?.title ?? _wizardSelectedSubcategoryId.toUpperCase();

    final booking = _repository.createJobBooking(
      serviceName: _wizardIsMultiDomain
          ? 'Multi-Trade Inspection (${_wizardSelectedDomains.join(', ').toUpperCase()})'
          : _wizardServiceName,
      subcategoryTitle: subTitle,
      selectedDomains: _wizardSelectedDomains,
      isMultiDomain: _wizardIsMultiDomain,
      problemDescription: _wizardProblemDescription,
      mediaUrls: [..._wizardUploadedPhotos, ..._wizardUploadedVideos],
      scheduledSlot: _wizardIsEmergency
          ? 'EMERGENCY (< 20 min priority dispatch)'
          : _wizardSelectedTimeSlot,
      scheduledDateTime: targetDateTime,
      isEmergency: _wizardIsEmergency,
      emergencyTag: _wizardEmergencyTag,
      urgencyLevel: _wizardIsEmergency ? _wizardEmergencySeverity : _wizardScheduledUrgency,
      latitude: _wizardLatitude,
      longitude: _wizardLongitude,
      address: wizardSelectedAddress,
      selectedOffer: chosenOffer,
    );

    _lastCreatedBooking = booking;
    notifyListeners();
    return booking;
  }

  // 1-Hour Status Simulator
  void simulateOneHourUpdate(
    String bookingId,
    WorkerPreServiceStatus status, {
    int delayMinutes = 15,
    String? reason,
  }) {
    _repository.updateWorkerPreServiceStatus(
      bookingId,
      status,
      delayMinutes: delayMinutes,
      cancelReason: reason,
    );
    notifyListeners();
  }

  Booking? simulate1HourPreServiceUpdate({
    required String bookingId,
    required WorkerPreServiceStatus status,
    int delayMinutes = 0,
    String? reason,
  }) {
    simulateOneHourUpdate(
      bookingId,
      status,
      delayMinutes: delayMinutes,
      reason: reason,
    );
    try {
      return _repository.bookings.firstWhere((b) => b.id == bookingId);
    } catch (_) {
      return null;
    }
  }

  // Customer Cancellation
  bool cancelBookingByCustomer(String bookingId, String reason) {
    final success = _repository.cancelBookingByCustomer(bookingId, reason);
    notifyListeners();
    return success;
  }

  bool cancelBooking(
    String bookingId, [
    String reason = 'Cancelled by customer under cooperative fair-work policy',
  ]) {
    return cancelBookingByCustomer(bookingId, reason);
  }

  // Doorstep OTP Verification
  bool verifyDoorstepOtp(String bookingId, String otp) {
    final success = _repository.verifyDoorstepOtp(bookingId, otp);
    notifyListeners();
    return success;
  }

  // Complete Job & Invoice
  void markJobCompleted(String bookingId) {
    _repository.completeJobAndGenerateInvoice(bookingId);
    notifyListeners();
  }

  void payInvoice(
    String bookingId, {
    String paymentMethod = 'UPI (Instant Settlement)',
  }) {
    _repository.payBookingInvoice(bookingId, paymentMethod: paymentMethod);
    notifyListeners();
  }

  // Mandatory Feedback
  void submitReview({
    required String bookingId,
    required int rating,
    required String feedback,
    List<String> photos = const [],
  }) {
    _repository.submitBookingFeedback(
      bookingId: bookingId,
      rating: rating,
      reviewText: feedback,
      reviewPhotos: photos,
    );
    notifyListeners();
  }

  // ==========================================
  // INSTITUTION WORKFORCE REQUEST WIZARD STATE
  // ==========================================
  final Map<String, int> _institutionDomainWorkerCounts = {
    'electrical': 2,
    'cleaner': 2,
  };
  SavedAddress? _institutionSelectedSite;
  String _institutionTaskNotes = '';
  int _institutionSelectedDateIndex = 0; // Tomorrow default
  String _institutionSelectedTimeSlot = '9:00 AM – 1:00 PM (Morning Shift)';

  Map<String, int> get institutionDomainWorkerCounts =>
      Map.unmodifiable(_institutionDomainWorkerCounts);

  int get institutionTotalWorkers =>
      _institutionDomainWorkerCounts.values.fold(0, (sum, count) => sum + count);

  SavedAddress get institutionSelectedSite =>
      _institutionSelectedSite ?? _repository.defaultAddress;

  String get institutionTaskNotes => _institutionTaskNotes;
  int get institutionSelectedDateIndex => _institutionSelectedDateIndex;
  String get institutionSelectedTimeSlot => _institutionSelectedTimeSlot;

  void toggleInstitutionDomain(String domainId) {
    if (_institutionDomainWorkerCounts.containsKey(domainId)) {
      if (_institutionDomainWorkerCounts.length > 1) {
        _institutionDomainWorkerCounts.remove(domainId);
      }
    } else {
      _institutionDomainWorkerCounts[domainId] = 2; // default 2 workers
    }
    notifyListeners();
  }

  void updateInstitutionWorkerCount(String domainId, int count) {
    if (count <= 0) {
      if (_institutionDomainWorkerCounts.length > 1) {
        _institutionDomainWorkerCounts.remove(domainId);
      }
    } else {
      _institutionDomainWorkerCounts[domainId] = count.clamp(1, 25);
    }
    notifyListeners();
  }

  void setInstitutionSite(SavedAddress site) {
    _institutionSelectedSite = site;
    notifyListeners();
  }

  void setInstitutionTaskNotes(String notes) {
    _institutionTaskNotes = notes;
    notifyListeners();
  }

  void setInstitutionDateIndex(int index) {
    _institutionSelectedDateIndex = index;
    notifyListeners();
  }

  void setInstitutionTimeSlot(String slot) {
    _institutionSelectedTimeSlot = slot;
    notifyListeners();
  }

  Booking createInstitutionWorkforceBooking() {
    final cleanCounts = Map<String, int>.from(_institutionDomainWorkerCounts);
    if (cleanCounts.isEmpty) {
      cleanCounts['electrical'] = 2;
    }

    final domainTitles = cleanCounts.keys
        .map((d) => d[0].toUpperCase() + d.substring(1))
        .join(' & ');

    final targetDate = DateTime.now().add(
      Duration(days: _institutionSelectedDateIndex + 1, hours: 2),
    );

    final site = institutionSelectedSite;

    final booking = _repository.createInstitutionBooking(
      serviceName: '$domainTitles Workforce Allocation',
      subcategoryTitle: '$institutionTotalWorkers Cooperative Specialists',
      requiredWorkersPerDomain: cleanCounts,
      problemDescription: _institutionTaskNotes.isNotEmpty
          ? _institutionTaskNotes
          : 'Scheduled multi-trade facility workforce deployment at ${site.label}.',
      scheduledSlot: _institutionSelectedTimeSlot,
      scheduledDateTime: targetDate,
      address: site,
      organizationName: currentUser?.organizationName ?? 'Institutional Partner',
    );

    _lastCreatedBooking = booking;
    notifyListeners();
    return booking;
  }
}
