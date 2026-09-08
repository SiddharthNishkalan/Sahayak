class SavedAddress {
  final String id;
  final String label;
  final String type; // 'Home', 'Office', 'Other'
  final String streetAddress;
  final String landmark;
  final String ward;
  final String pincode;
  final bool isDefault;
  final double latitude;
  final double longitude;

  const SavedAddress({
    required this.id,
    required this.label,
    required this.type,
    required this.streetAddress,
    required this.landmark,
    required this.ward,
    required this.pincode,
    this.isDefault = false,
    this.latitude = 11.0168,
    this.longitude = 76.9558,
  });

  SavedAddress copyWith({
    String? id,
    String? label,
    String? type,
    String? streetAddress,
    String? landmark,
    String? ward,
    String? pincode,
    bool? isDefault,
    double? latitude,
    double? longitude,
  }) {
    return SavedAddress(
      id: id ?? this.id,
      label: label ?? this.label,
      type: type ?? this.type,
      streetAddress: streetAddress ?? this.streetAddress,
      landmark: landmark ?? this.landmark,
      ward: ward ?? this.ward,
      pincode: pincode ?? this.pincode,
      isDefault: isDefault ?? this.isDefault,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  String get fullAddress => '$streetAddress, $ward - $pincode';

  String get society {
    for (final s in ['Greenwood Enclave', 'Mayflower Sakthi', 'Tristar Residency', 'Shivaji Nagar', 'Sobha Emerald']) {
      if (streetAddress.contains(s) || landmark.contains(s) || ward.contains(s)) {
        return s;
      }
    }
    return 'Shivaji Nagar';
  }

  String get notes => landmark;

  static const SavedAddress defaultHome = SavedAddress(
    id: 'addr-home',
    label: 'Home',
    type: 'Home',
    streetAddress: 'Flat 302, Green Meadows Apt, near Water Tank, Shivaji Nagar',
    landmark: 'Opposite Kaveri Water Tank, 3rd Flr (Lift avail)',
    ward: 'Shivaji Nagar',
    pincode: '641002',
    isDefault: true,
    latitude: 11.0168,
    longitude: 76.9558,
  );

  static const SavedAddress defaultOffice = SavedAddress(
    id: 'addr-office',
    label: 'Office',
    type: 'Office',
    streetAddress: 'Suite 4B, Cross Cut Road, Gandhipuram',
    landmark: 'Near Central commercial complex',
    ward: 'Gandhipuram Central',
    pincode: '641012',
    isDefault: false,
    latitude: 11.0183,
    longitude: 76.9654,
  );

  static const SavedAddress defaultInstitutionFacility = SavedAddress(
    id: 'site-apex-main',
    label: 'Office 1 (Apex Technology Park)',
    type: 'Office',
    streetAddress: 'Block B Main Building, Peelamedu',
    landmark: 'Near Avinashi Road Tech Hub',
    ward: 'Ward 8',
    pincode: '641014',
    isDefault: true,
    latitude: 11.0280,
    longitude: 77.0040,
  );
}
