class UserAccount {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String society;
  final String ward;
  final DateTime createdAt;

  const UserAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.society,
    required this.ward,
    required this.createdAt,
  });

  String get initials {
    final parts = name.trim().split(' ');
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
  }) {
    return UserAccount(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      society: society ?? this.society,
      ward: ward ?? this.ward,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
