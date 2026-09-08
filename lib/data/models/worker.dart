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

  static const Worker kavithaSelvam = Worker(
    id: 'kavitha',
    name: 'Kavitha Selvam',
    trade: 'Deep Home Cleaning Specialist',
    avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
    isVerified: true,
    rating: 4.9,
    completedJobs: 165,
    distanceKm: 0.7,
    society: 'Shivaji Nagar',
    availableSlot: 'Today · 2:00–4:00 PM',
    visitEst: '₹350–450',
    totalEst: '₹800–1200',
    guildId: '#CLN-052',
    maskedPhone: '+91 98411 •••••',
    isBestMatch: true,
    isFairWorkPriority: true,
    supportedDomains: ['cleaner', 'cleaning'],
    certifications: [
      'Eco-Safe Hospital Grade Sanitization',
      'Cooperative Hygiene Guild Member',
      'Background & Police Verified',
    ],
    matchReasons: [
      '0.7 km away with certified non-toxic deep steam equipment',
      'Specialized in kitchen degreasing & bathroom tile restoration',
      'Top rated cooperative cleaner in Shivaji Nagar cluster',
    ],
    baseVisitFee: 350,
    estimatedTotalFee: 950,
  );

  static const Worker selvarajM = Worker(
    id: 'selvaraj',
    name: 'Selvaraj M.',
    trade: 'Master Carpenter & Furniture Specialist',
    avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
    isVerified: true,
    rating: 4.8,
    completedJobs: 142,
    distanceKm: 0.9,
    society: 'Peelamedu',
    availableSlot: 'Today · 3:00–5:00 PM',
    visitEst: '₹300–400',
    totalEst: '₹750–1100',
    guildId: '#CRP-077',
    maskedPhone: '+91 98455 •••••',
    isBestMatch: true,
    isFairWorkPriority: true,
    supportedDomains: ['carpenter', 'carpentry'],
    certifications: [
      'Master Woodcraft & Joinery Certificate',
      'Locksmith & Hardware Specialist',
      'Cooperative Union Verified',
    ],
    matchReasons: [
      '0.9 km from your society with mobile woodcraft toolkit',
      '15+ years experience in wardrobe hinge & lock repairs',
      'High customer satisfaction for clean door alignment',
    ],
    baseVisitFee: 300,
    estimatedTotalFee: 850,
  );

  static const Worker lakshmiNarayanan = Worker(
    id: 'lakshmi',
    name: 'Lakshmi Narayanan',
    trade: 'Certified Elderly & Patient Caregiver',
    avatarUrl: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=150',
    isVerified: true,
    rating: 5.0,
    completedJobs: 98,
    distanceKm: 0.5,
    society: 'Shivaji Nagar',
    availableSlot: 'Today · 2:00–6:00 PM',
    visitEst: '₹450–600',
    totalEst: '₹900–1500',
    guildId: '#CRG-031',
    maskedPhone: '+91 98433 •••••',
    isBestMatch: true,
    isFairWorkPriority: true,
    supportedDomains: ['caregiver', 'caregiving'],
    certifications: [
      'Red Cross Certified First Aid & CPR',
      'Geriatric Assistance Qualified Caregiver',
      'Police Verified Medical Assistant',
    ],
    matchReasons: [
      '0.5 km away in Shivaji Nagar; available for immediate care',
      'Certified in vital signs tracking & post-surgery mobility assistance',
      '100% 5-star community reviews for compassionate patient care',
    ],
    baseVisitFee: 450,
    estimatedTotalFee: 1100,
  );

  static const Worker muruganP = Worker(
    id: 'murugan',
    name: 'Murugan P.',
    trade: 'Professional City & Highway Chauffeur',
    avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
    isVerified: true,
    rating: 4.9,
    completedJobs: 230,
    distanceKm: 0.6,
    society: 'Shivaji Nagar',
    availableSlot: 'Today · Available Now',
    visitEst: '₹200–300',
    totalEst: '₹600–900',
    guildId: '#DRV-019',
    maskedPhone: '+91 98422 •••••',
    isBestMatch: true,
    isFairWorkPriority: true,
    supportedDomains: ['driver', 'driving'],
    certifications: [
      'Commercial Transport Heavy/Light Licensed',
      'Defensive Driving Certified Pro',
      'Zero-Accident Safety Record (10+ Yrs)',
    ],
    matchReasons: [
      '0.6 km from your pickup spot with instant dispatch ready',
      'Familiar with city traffic shortcuts & outstation routes',
      'Experienced in luxury, automatic, and EV vehicle handling',
    ],
    baseVisitFee: 200,
    estimatedTotalFee: 650,
  );

  static const Worker palaniKumar = Worker(
    id: 'palani',
    name: 'Palani Kumar',
    trade: 'Landscape & Horticulture Specialist',
    avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
    isVerified: true,
    rating: 4.8,
    completedJobs: 88,
    distanceKm: 1.0,
    society: 'RS Puram',
    availableSlot: 'Today · 3:30–5:30 PM',
    visitEst: '₹250–350',
    totalEst: '₹650–900',
    guildId: '#GDN-044',
    maskedPhone: '+91 98499 •••••',
    isBestMatch: true,
    isFairWorkPriority: true,
    supportedDomains: ['gardener', 'gardening'],
    certifications: [
      'Urban Horticulture & Drip Setup Certified',
      'Organic Pest Control Specialist',
      'Cooperative Green Council Member',
    ],
    matchReasons: [
      '1.0 km away with lawn mower & pruning tools ready',
      'Specialist in organic potting mix & balcony plant revival',
      'Highly rated for thorough garden trimming & tidy cleanup',
    ],
    baseVisitFee: 250,
    estimatedTotalFee: 700,
  );

  static const Worker vijayAnand = Worker(
    id: 'vijayanand',
    name: 'Vijay Anand',
    trade: 'Senior HVAC & Appliance Technician',
    avatarUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150',
    isVerified: true,
    rating: 4.9,
    completedJobs: 178,
    distanceKm: 0.8,
    society: 'Shivaji Nagar',
    availableSlot: 'Today · 2:30–4:30 PM',
    visitEst: '₹300–400',
    totalEst: '₹800–1200',
    guildId: '#APP-095',
    maskedPhone: '+91 98466 •••••',
    isBestMatch: true,
    isFairWorkPriority: true,
    supportedDomains: ['appliance', 'appliances', 'electrical'],
    certifications: [
      'National HVAC & Refrigerant Certified',
      'Inverter PCB Diagnostics Specialist',
      'Cooperative Master Technician',
    ],
    matchReasons: [
      '0.8 km away in Shivaji Nagar with digital manifold gauge',
      'Specialist in AC gas charging, fridge compressors & washing machines',
      'Transparent 30-day warranty on all diagnostic services',
    ],
    baseVisitFee: 300,
    estimatedTotalFee: 850,
  );
}
