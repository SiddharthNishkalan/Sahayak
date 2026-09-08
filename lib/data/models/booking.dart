import 'worker.dart';
import 'address.dart';
import 'invoice.dart';

enum BookingStage {
  matching, // Waiting for workers to accept/bid
  confirmed, // Customer accepted worker, OTP generated
  workerOnTheWay,
  jobInProgress, // Doorstep OTP verified
  jobCompleted,
  paid,
}

enum BookingTab {
  upcoming,
  inProgress,
  completed,
  cancelled,
}

enum WorkerPreServiceStatus {
  onTime,
  delayed,
  cancelled,
  cancelledWithReason,
  cancelledByWorker,
}

class WorkerPreServiceUpdate {
  final WorkerPreServiceStatus status;
  final int delayMinutes;
  final String? cancelReason;
  final DateTime timestamp;

  WorkerPreServiceUpdate({
    required this.status,
    this.delayMinutes = 0,
    String? cancelReason,
    String? reason,
    DateTime? timestamp,
    DateTime? sentAt,
  })  : cancelReason = cancelReason ?? reason,
        timestamp = timestamp ?? sentAt ?? DateTime.now();

  String? get reason => cancelReason;
  DateTime get sentAt => timestamp;
  String get customerNotificationMessage => displayMessage;
  String get statusLabel => displayTitle;

  String get displayTitle {
    switch (status) {
      case WorkerPreServiceStatus.onTime:
        return 'Technician Confirmed: On Time';
      case WorkerPreServiceStatus.delayed:
        return 'Technician Delay Notice: +$delayMinutes mins';
      case WorkerPreServiceStatus.cancelled:
      case WorkerPreServiceStatus.cancelledWithReason:
      case WorkerPreServiceStatus.cancelledByWorker:
        return 'Technician Emergency Cancellation';
    }
  }

  String get displayMessage {
    switch (status) {
      case WorkerPreServiceStatus.onTime:
        return 'Technician is on schedule and packing diagnostic tools.';
      case WorkerPreServiceStatus.delayed:
        return 'Technician was delayed on prior society job. New estimated arrival updated.';
      case WorkerPreServiceStatus.cancelled:
      case WorkerPreServiceStatus.cancelledWithReason:
      case WorkerPreServiceStatus.cancelledByWorker:
        return cancelReason ?? 'Unforeseen emergency. Co-op auto-reassigning available worker.';
    }
  }
}

class WorkerOffer {
  final String id;
  final Worker worker;
  final double quotedVisitFee;
  final double estimatedTotalFee;
  final int estimatedArrivalMinutes;
  final String note;
  final DateTime submittedAt;

  const WorkerOffer({
    required this.id,
    required this.worker,
    required this.quotedVisitFee,
    required this.estimatedTotalFee,
    required this.estimatedArrivalMinutes,
    required this.note,
    required this.submittedAt,
  });
}

class Booking {
  final String id;
  final String serviceName;
  final String subcategoryTitle;
  final List<String> selectedDomains;
  final bool isMultiDomain;
  final String problemDescription;
  final List<String> mediaUrls;
  final String scheduledSlot;
  final DateTime scheduledDateTime;
  final bool isEmergency;
  final String? emergencyTag;
  final double? latitude;
  final double? longitude;
  final SavedAddress address;
  final Worker worker;
  final List<WorkerOffer> workerOffers;
  final String doorstepOtp;
  final BookingStage currentStage;
  final BookingTab tab;
  final CooperativeInvoice? invoice;
  final WorkerPreServiceUpdate? preServiceUpdate;
  final int rating;
  final String reviewText;
  final List<String> reviewPhotos;
  final int minutesUntilArrival;
  final double liveDistanceKm;
  final String? cancellationReason;
  final String? cancelledBy;
  final String? urgencyLevel;

  // Institutional Multi-Worker Fields
  final bool isInstitutionBooking;
  final String? organizationName;
  final Map<String, int> requiredWorkersPerDomain;
  final Map<String, List<Worker>> allocatedWorkersPerDomain;

  const Booking({
    required this.id,
    required this.serviceName,
    required this.subcategoryTitle,
    this.selectedDomains = const ['plumbing'],
    this.isMultiDomain = false,
    this.problemDescription = '',
    this.mediaUrls = const [],
    required this.scheduledSlot,
    required this.scheduledDateTime,
    this.isEmergency = false,
    this.emergencyTag,
    this.latitude,
    this.longitude,
    required this.address,
    required this.worker,
    this.workerOffers = const [],
    required this.doorstepOtp,
    required this.currentStage,
    required this.tab,
    this.invoice,
    this.preServiceUpdate,
    this.rating = 0,
    this.reviewText = '',
    this.reviewPhotos = const [],
    this.minutesUntilArrival = 15,
    this.liveDistanceKm = 1.4,
    this.cancellationReason,
    this.cancelledBy,
    this.urgencyLevel,
    this.isInstitutionBooking = false,
    this.organizationName,
    this.requiredWorkersPerDomain = const {},
    this.allocatedWorkersPerDomain = const {},
  });

  /// Check if cancellation is allowed (allowed before 1 hour of scheduled time)
  bool get canCancelBefore1Hour {
    final now = DateTime.now();
    final difference = scheduledDateTime.difference(now);
    return difference.inMinutes >= 60;
  }

  BookingStage get stage => currentStage;
  BookingStage get status => currentStage;
  WorkerPreServiceUpdate get activePreServiceUpdate =>
      preServiceUpdate ?? WorkerPreServiceUpdate(status: WorkerPreServiceStatus.onTime);

  int get minutesRemainingUntilSchedule {
    final now = DateTime.now();
    final diff = scheduledDateTime.difference(now).inMinutes;
    return diff > 0 ? diff : 0;
  }

  // Institutional Multi-Worker Aggregate Getters
  int get totalWorkersRequested {
    if (!isInstitutionBooking || requiredWorkersPerDomain.isEmpty) {
      return 1;
    }
    return requiredWorkersPerDomain.values.fold(0, (sum, count) => sum + count);
  }

  int get totalWorkersAllocated {
    if (!isInstitutionBooking || allocatedWorkersPerDomain.isEmpty) {
      return (currentStage == BookingStage.matching) ? 0 : 1;
    }
    return allocatedWorkersPerDomain.values.fold(0, (sum, list) => sum + list.length);
  }

  bool get isFullyAllocated => totalWorkersAllocated >= totalWorkersRequested;

  int get remainingPositionsCount {
    final diff = totalWorkersRequested - totalWorkersAllocated;
    return diff > 0 ? diff : 0;
  }

  double get allocationProgressRatio {
    if (totalWorkersRequested <= 0) return 1.0;
    return (totalWorkersAllocated / totalWorkersRequested).clamp(0.0, 1.0);
  }

  List<Worker> get allAllocatedWorkers {
    if (!isInstitutionBooking) {
      return [worker];
    }
    final List<Worker> list = [];
    for (final workers in allocatedWorkersPerDomain.values) {
      list.addAll(workers);
    }
    return list.isNotEmpty ? list : [worker];
  }

  Booking copyWith({
    String? id,
    String? serviceName,
    String? subcategoryTitle,
    List<String>? selectedDomains,
    bool? isMultiDomain,
    String? problemDescription,
    List<String>? mediaUrls,
    String? scheduledSlot,
    DateTime? scheduledDateTime,
    bool? isEmergency,
    String? emergencyTag,
    double? latitude,
    double? longitude,
    SavedAddress? address,
    Worker? worker,
    List<WorkerOffer>? workerOffers,
    String? doorstepOtp,
    BookingStage? currentStage,
    BookingTab? tab,
    dynamic status,
    CooperativeInvoice? invoice,
    WorkerPreServiceUpdate? preServiceUpdate,
    int? rating,
    String? reviewText,
    List<String>? reviewPhotos,
    int? minutesUntilArrival,
    double? liveDistanceKm,
    String? cancellationReason,
    String? cancelledBy,
    String? urgencyLevel,
    bool? isInstitutionBooking,
    String? organizationName,
    Map<String, int>? requiredWorkersPerDomain,
    Map<String, List<Worker>>? allocatedWorkersPerDomain,
  }) {
    BookingTab resolvedTab = tab ?? this.tab;
    String? resolvedCancelledBy = cancelledBy ?? this.cancelledBy;
    if (status == 'cancelled' || status == BookingTab.cancelled) {
      resolvedTab = BookingTab.cancelled;
      resolvedCancelledBy ??= 'customer';
    }

    return Booking(
      id: id ?? this.id,
      serviceName: serviceName ?? this.serviceName,
      subcategoryTitle: subcategoryTitle ?? this.subcategoryTitle,
      selectedDomains: selectedDomains ?? this.selectedDomains,
      isMultiDomain: isMultiDomain ?? this.isMultiDomain,
      problemDescription: problemDescription ?? this.problemDescription,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      scheduledSlot: scheduledSlot ?? this.scheduledSlot,
      scheduledDateTime: scheduledDateTime ?? this.scheduledDateTime,
      isEmergency: isEmergency ?? this.isEmergency,
      emergencyTag: emergencyTag ?? this.emergencyTag,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      worker: worker ?? this.worker,
      workerOffers: workerOffers ?? this.workerOffers,
      doorstepOtp: doorstepOtp ?? this.doorstepOtp,
      currentStage: currentStage ?? this.currentStage,
      tab: resolvedTab,
      invoice: invoice ?? this.invoice,
      preServiceUpdate: preServiceUpdate ?? this.preServiceUpdate,
      rating: rating ?? this.rating,
      reviewText: reviewText ?? this.reviewText,
      reviewPhotos: reviewPhotos ?? this.reviewPhotos,
      minutesUntilArrival: minutesUntilArrival ?? this.minutesUntilArrival,
      liveDistanceKm: liveDistanceKm ?? this.liveDistanceKm,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancelledBy: resolvedCancelledBy,
      urgencyLevel: urgencyLevel ?? this.urgencyLevel,
      isInstitutionBooking: isInstitutionBooking ?? this.isInstitutionBooking,
      organizationName: organizationName ?? this.organizationName,
      requiredWorkersPerDomain: requiredWorkersPerDomain ?? this.requiredWorkersPerDomain,
      allocatedWorkersPerDomain: allocatedWorkersPerDomain ?? this.allocatedWorkersPerDomain,
    );
  }

  static Booking defaultUpcoming = Booking(
    id: 'SK-88219',
    serviceName: 'Plumbing Service',
    subcategoryTitle: 'Tap Leak & Jet Repair',
    selectedDomains: const ['plumbing'],
    problemDescription: 'Main kitchen sink tap is leaking constantly and spraying water under the counter.',
    mediaUrls: const ['assets/images/logo.png'],
    scheduledSlot: 'Today · 3:00 PM - 5:00 PM',
    scheduledDateTime: DateTime.now().add(const Duration(hours: 3)),
    address: SavedAddress.defaultHome,
    worker: Worker.priyaSharma,
    doorstepOtp: '4829',
    currentStage: BookingStage.workerOnTheWay,
    tab: BookingTab.upcoming,
    preServiceUpdate: WorkerPreServiceUpdate(
      status: WorkerPreServiceStatus.onTime,
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    minutesUntilArrival: 12,
    liveDistanceKm: 0.8,
  );

  static Booking defaultCompleted = Booking(
    id: 'SK-87941',
    serviceName: 'Electrical Service',
    subcategoryTitle: 'MCB Switch Tripping',
    selectedDomains: const ['electrical'],
    problemDescription: 'Living room power circuit tripping whenever AC turns on.',
    mediaUrls: const [],
    scheduledSlot: 'Yesterday · 11:00 AM',
    scheduledDateTime: DateTime.now().subtract(const Duration(days: 1)),
    address: SavedAddress.defaultHome,
    worker: Worker.arunPrasad,
    doorstepOtp: '9124',
    currentStage: BookingStage.paid,
    tab: BookingTab.completed,
    rating: 5,
    reviewText: 'Arun identified the neutral leak very fast. Clean professional work!',
    invoice: CooperativeInvoice(
      invoiceNumber: 'INV-2026-COOP-984',
      date: 'Yesterday, 11:45 AM',
      coopRegNumber: 'TN-COOP-449',
      technicianName: 'Arun Prasad',
      technicianId: '#ELE-089',
      paymentMethod: 'UPI (GPay)',
      diagnosticFee: 200,
      laborFee: 450,
      materialsFee: 280,
      platformFee: 20, // 10% of 200 Diagnostic Fee only
      totalAmount: 950, // 200 + 450 + 280 + 20
      isPaid: true,
    ),
  );

  static Booking defaultInstitutionUpcoming = Booking(
    id: 'SK-INST-9021',
    serviceName: 'Institutional Workforce Request',
    subcategoryTitle: 'Facility Maintenance Crew',
    selectedDomains: const ['electrical', 'cleaner'],
    isMultiDomain: true,
    problemDescription: 'Pre-event electrical load testing and floor sanitation across Block B wings.',
    mediaUrls: const [],
    scheduledSlot: 'Tomorrow · 9:00 AM – 1:00 PM',
    scheduledDateTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
    address: const SavedAddress(
      id: 'site-apex-b',
      label: 'Office 1 (Main Campus - Block B)',
      type: 'Office',
      streetAddress: 'Apex Tech Park, Avinashi Road',
      landmark: 'Gate 2 Loading Bay',
      ward: 'Peelamedu Ward 8',
      pincode: '641014',
      isDefault: true,
    ),
    worker: Worker.arunPrasad,
    doorstepOtp: '6741',
    currentStage: BookingStage.confirmed,
    tab: BookingTab.upcoming,
    isInstitutionBooking: true,
    organizationName: 'Apex Technology Park',
    requiredWorkersPerDomain: const {
      'electrical': 3,
      'cleaner': 4,
    },
    allocatedWorkersPerDomain: {
      'electrical': [Worker.arunPrasad, Worker.rameshKumar, Worker.deepakMurugan],
      'cleaner': [Worker.priyaSharma, Worker.deepakMurugan],
    },
    preServiceUpdate: WorkerPreServiceUpdate(
      status: WorkerPreServiceStatus.onTime,
      timestamp: DateTime.now(),
    ),
  );

  static Booking defaultInstitutionCompleted = Booking(
    id: 'SK-INST-8842',
    serviceName: 'Campus Electrical & Carpentry Maintenance',
    subcategoryTitle: 'Scheduled Bulk Maintenance',
    selectedDomains: const ['electrical', 'carpentry'],
    isMultiDomain: true,
    problemDescription: 'Comprehensive server room earthing and classroom furniture repairs.',
    mediaUrls: const [],
    scheduledSlot: '2 days ago · 10:00 AM – 4:00 PM',
    scheduledDateTime: DateTime.now().subtract(const Duration(days: 2)),
    address: const SavedAddress(
      id: 'site-apex-b',
      label: 'Office 1 (Main Campus - Block B)',
      type: 'Office',
      streetAddress: 'Apex Tech Park, Avinashi Road',
      landmark: 'Gate 2 Loading Bay',
      ward: 'Peelamedu Ward 8',
      pincode: '641014',
      isDefault: true,
    ),
    worker: Worker.arunPrasad,
    doorstepOtp: '8932',
    currentStage: BookingStage.paid,
    tab: BookingTab.completed,
    isInstitutionBooking: true,
    organizationName: 'Apex Technology Park',
    requiredWorkersPerDomain: const {
      'electrical': 2,
      'carpentry': 2,
    },
    allocatedWorkersPerDomain: {
      'electrical': [Worker.arunPrasad, Worker.rameshKumar],
      'carpentry': [Worker.deepakMurugan, Worker.priyaSharma],
    },
    rating: 5,
    reviewText: 'All 4 workers reported on time with full toolkits. Co-op allocation was seamless.',
    invoice: CooperativeInvoice.sampleInstitutionInvoice,
  );
}
