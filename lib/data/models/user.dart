enum UserAccountType {
  household,
  institution,
}

class UserAccount {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String society;
  final String ward;
  final DateTime createdAt;
  final UserAccountType accountType;
  final String? organizationName;
  final String? siteAddress;

  const UserAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.society,
    required this.ward,
    required this.createdAt,
    this.accountType = UserAccountType.household,
    this.organizationName,
    this.siteAddress,
  });

  bool get isInstitution => accountType == UserAccountType.institution;
  bool get isHousehold => accountType == UserAccountType.household;

  String get displayName => (isInstitution && organizationName != null && organizationName!.isNotEmpty)
      ? organizationName!
      : name;

  String get initials {
    final target = displayName;
    final parts = target.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'U';
  }

  UserAccount copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? society,
    String? ward,
    DateTime? createdAt,
    UserAccountType? accountType,
    String? organizationName,
    String? siteAddress,
  }) {
    return UserAccount(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      society: society ?? this.society,
      ward: ward ?? this.ward,
      createdAt: createdAt ?? this.createdAt,
      accountType: accountType ?? this.accountType,
      organizationName: organizationName ?? this.organizationName,
      siteAddress: siteAddress ?? this.siteAddress,
    );
  }
}
