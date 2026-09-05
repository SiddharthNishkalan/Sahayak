class WorkerReview {
  final String authorName;
  final double rating;
  final String comment;
  final String date;

  const WorkerReview({
    required this.authorName,
    required this.rating,
    required this.comment,
    required this.date,
  });
}

class Worker {
  final String id;
  final String name;
  final String trade;
  final String avatarUrl;
  final bool isVerified;
  final double rating;
  final int completedJobs;
  final double distanceKm;
  final String availableSlot;
  final String visitEst;
  final String totalEst;
  final String guildId;
  final String maskedPhone;
  final bool isBestMatch;
  final bool isFairWorkPriority;
  final List<String> matchReasons;
  final String society;
  final List<String> certifications;
  final List<String> supportedDomains;
  final List<WorkerReview> recentReviews;
  final double baseVisitFee;
  final double estimatedTotalFee;

  const Worker({
    required this.id,
    required this.name,
    required this.trade,
    required this.avatarUrl,
    this.isVerified = true,
    required this.rating,
    required this.completedJobs,
    required this.distanceKm,
    required this.availableSlot,
    required this.visitEst,
    required this.totalEst,
    required this.guildId,
    required this.maskedPhone,
    this.isBestMatch = false,
    this.isFairWorkPriority = false,
    required this.matchReasons,
    this.society = 'Shivaji Nagar',
    this.certifications = const [
      'Municipal Certified A-Grade',
      'Police Clearance Verified',
      'National Skill Qualification',
    ],
    this.supportedDomains = const ['plumbing'],
    this.recentReviews = const [
      WorkerReview(
        authorName: 'Sundaram K.',
        rating: 5.0,
        comment: 'Very professional, diagnosed the leaking valve in 10 mins and replaced washers cleanly.',
        date: '2 days ago',
      ),
      WorkerReview(
        authorName: 'Ananya V.',
        rating: 5.0,
        comment: 'On time, courteous, and transparent pricing with no hidden charges.',
        date: '1 week ago',
      ),
    ],
    this.baseVisitFee = 250,
    this.estimatedTotalFee = 750,
  });

  int get completedJobsCount => completedJobs;
  int get reviewCount => completedJobs;

  Worker copyWith({
    String? id,
    String? name,
    String? trade,
    String? avatarUrl,
    bool? isVerified,
    double? rating,
    int? completedJobs,
    double? distanceKm,
    String? availableSlot,
    String? visitEst,
    String? totalEst,
    String? guildId,
    String? maskedPhone,
    bool? isBestMatch,
    bool? isFairWorkPriority,
    List<String>? matchReasons,
    String? society,
    List<String>? certifications,
    List<String>? supportedDomains,
    List<WorkerReview>? recentReviews,
    double? baseVisitFee,
    double? estimatedTotalFee,
  }) {
    return Worker(
      id: id ?? this.id,
      name: name ?? this.name,
      trade: trade ?? this.trade,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isVerified: isVerified ?? this.isVerified,
      rating: rating ?? this.rating,
      completedJobs: completedJobs ?? this.completedJobs,
      distanceKm: distanceKm ?? this.distanceKm,
      availableSlot: availableSlot ?? this.availableSlot,
      visitEst: visitEst ?? this.visitEst,
      totalEst: totalEst ?? this.totalEst,
      guildId: guildId ?? this.guildId,
      maskedPhone: maskedPhone ?? this.maskedPhone,
      isBestMatch: isBestMatch ?? this.isBestMatch,
      isFairWorkPriority: isFairWorkPriority ?? this.isFairWorkPriority,
      matchReasons: matchReasons ?? this.matchReasons,
      society: society ?? this.society,
      certifications: certifications ?? this.certifications,
      supportedDomains: supportedDomains ?? this.supportedDomains,
      recentReviews: recentReviews ?? this.recentReviews,
      baseVisitFee: baseVisitFee ?? this.baseVisitFee,
      estimatedTotalFee: estimatedTotalFee ?? this.estimatedTotalFee,
    );
  }

  static const Worker priyaSharma = Worker(
    id: 'priya',
    name: 'Priya Sharma',
    trade: 'General & Emergency Plumbing',
    avatarUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150',
    isVerified: true,
    rating: 4.8,
    completedJobs: 126,
    distanceKm: 0.8,
    society: 'Shivaji Nagar',
    availableSlot: 'Today · 2:00–4:00 PM',
    visitEst: '₹250–350',
    totalEst: '₹700–950',
    guildId: '#PLM-104',
    maskedPhone: '+91 98432 •••••',
    isBestMatch: true,
    isFairWorkPriority: true,
    supportedDomains: ['plumbing', 'appliances'],
    certifications: [
      'Municipal Certified A-Grade',
      'Police Clearance Verified',
      'Advanced Sanitary Hydraulics',
    ],
    matchReasons: [
      '0.8 km from your society (estimated 8 min transit)',
      'Certified plumber with 5+ years field experience',
      'Unreserved slot open in your requested afternoon time',
      'Consistently rated 5 stars for tidiness & transparent billing',
      'Supports co-op rotational roster for fair wage access',
    ],
    baseVisitFee: 250,
    estimatedTotalFee: 750,
  );

  static const Worker rameshKumar = Worker(
    id: 'ramesh',
    name: 'Ramesh Kumar',
    trade: 'Senior Sanitary & Pipe Specialist',
    avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150',
    isVerified: true,
    rating: 4.9,
    completedJobs: 210,
    distanceKm: 1.4,
    society: 'Peelamedu',
    availableSlot: 'Today · 2:30–4:30 PM',
    visitEst: '₹300–400',
    totalEst: '₹750–980',
    guildId: '#PLM-042',
    maskedPhone: '+91 98765 •••••',
    isBestMatch: false,
    isFairWorkPriority: true,
    supportedDomains: ['plumbing'],
    certifications: [
      'Master Plumber Municipal Guild ID #42',
      'Cooperative Union Founding Member',
      'High-Pressure Pipe Certified',
    ],
    matchReasons: [
      '1.4 km away in adjacent Peelamedu cluster',
      'Master technician with 12+ years experience in overhead tanks',
      'Highly rated for leak detection without breaking wall tiles',
      'Cooperative union founding member',
    ],
    baseVisitFee: 300,
    estimatedTotalFee: 850,
  );

  static const Worker arunPrasad = Worker(
    id: 'arun',
    name: 'Arun Prasad',
    trade: 'Certified Master Electrician',
    avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
    isVerified: true,
    rating: 4.9,
    completedJobs: 184,
    distanceKm: 0.6,
    society: 'Shivaji Nagar',
    availableSlot: 'Today · 2:15–4:00 PM',
    visitEst: '₹200–300',
    totalEst: '₹600–850',
    guildId: '#ELE-089',
    maskedPhone: '+91 98421 •••••',
    isBestMatch: false,
    isFairWorkPriority: true,
    supportedDomains: ['electrical', 'appliances'],
    certifications: [
      'State Electricity Board Licensed Wireman',
      'Surge Protection & Earthing Specialist',
      'Police Verification Cleared',
    ],
    matchReasons: [
      '0.6 km from your society in Shivaji Nagar Hub',
      'Experienced in cross-domain diagnosis (electrical leaks & pumps)',
      'Carries calibrated digital insulation tester',
    ],
    baseVisitFee: 200,
    estimatedTotalFee: 650,
  );

  static const Worker deepakMurugan = Worker(
    id: 'deepak',
    name: 'Deepak Murugan',
    trade: 'Electro-Mechanical Technician',
    avatarUrl: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=150',
    isVerified: true,
    rating: 4.7,
    completedJobs: 94,
    distanceKm: 1.1,
    society: 'RS Puram',
    availableSlot: 'Today · 2:45–5:00 PM',
    visitEst: '₹250–350',
    totalEst: '₹750–900',
    guildId: '#MCH-115',
    maskedPhone: '+91 97890 •••••',
    isBestMatch: false,
    isFairWorkPriority: false,
    supportedDomains: ['plumbing', 'electrical'],
    certifications: [
      'Dual Trade Certified (Pumps & Motors)',
      'Municipal Ward 5 Cooperative Rep',
    ],
    matchReasons: [
      'Multi-domain specialist: Handles both water motor plumbing & electrical tripping',
      'Fast diagnosis for mysterious pump failures',
    ],
    baseVisitFee: 250,
    estimatedTotalFee: 800,
  );
}
