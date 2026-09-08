class DomainCoordinator {
  final String domain;
  final String domainTitle;
  final String name;
  final String phone;
  final String email;

  const DomainCoordinator({
    required this.domain,
    required this.domainTitle,
    required this.name,
    required this.phone,
    required this.email,
  });

  DomainCoordinator copyWith({
    String? domain,
    String? domainTitle,
    String? name,
    String? phone,
    String? email,
  }) {
    return DomainCoordinator(
      domain: domain ?? this.domain,
      domainTitle: domainTitle ?? this.domainTitle,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
    );
  }

  static String getDomainTitle(String domain) {
    switch (domain.toLowerCase().replaceAll('domain-', '').trim()) {
      case 'electrical':
      case 'electrician':
        return 'Electrical Coordinator';
      case 'cleaner':
      case 'cleaning':
        return 'Sanitation & Cleaning Coordinator';
      case 'plumbing':
      case 'plumber':
        return 'Plumbing & Water Coordinator';
      case 'carpentry':
      case 'carpenter':
        return 'Carpentry & Facilities Coordinator';
      case 'appliance':
      case 'hvac':
        return 'HVAC & Machinery Coordinator';
      case 'painting':
      case 'painter':
        return 'Painting & Waterproofing Coordinator';
      default:
        return '${domain[0].toUpperCase()}${domain.substring(1)} Coordinator';
    }
  }

  static List<DomainCoordinator> defaultInstitutionCoordinators = const [
    DomainCoordinator(
      domain: 'electrical',
      domainTitle: 'Electrical Coordinator',
      name: 'Vignesh Raj',
      phone: '+91 98432 11002',
      email: 'electrical.coord@apextech.in',
    ),
    DomainCoordinator(
      domain: 'cleaner',
      domainTitle: 'Sanitation & Cleaning Coordinator',
      name: 'Meenakshi Sundaram',
      phone: '+91 98432 22003',
      email: 'hygiene.coord@apextech.in',
    ),
    DomainCoordinator(
      domain: 'plumbing',
      domainTitle: 'Plumbing & Water Coordinator',
      name: 'Suresh Kumar',
      phone: '+91 98432 33004',
      email: 'plumbing.coord@apextech.in',
    ),
    DomainCoordinator(
      domain: 'carpentry',
      domainTitle: 'Carpentry & Facilities Coordinator',
      name: 'Anand Viswanathan',
      phone: '+91 98432 44005',
      email: 'carpentry.coord@apextech.in',
    ),
    DomainCoordinator(
      domain: 'appliance',
      domainTitle: 'HVAC & Machinery Coordinator',
      name: 'Karthik Ramanathan',
      phone: '+91 98432 55006',
      email: 'hvac.coord@apextech.in',
    ),
    DomainCoordinator(
      domain: 'painting',
      domainTitle: 'Painting & Waterproofing Coordinator',
      name: 'Dinesh Selvam',
      phone: '+91 98432 66007',
      email: 'civil.coord@apextech.in',
    ),
  ];
}
