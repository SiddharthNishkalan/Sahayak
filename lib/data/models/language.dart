class AppLanguage {
  final String code;
  final String name;
  final String localName;
  final String avatarChar;
  final String description;
  final String? badge;
  final String continueActionText;
  final String continueSubtext;

  const AppLanguage({
    required this.code,
    required this.name,
    required this.localName,
    required this.avatarChar,
    required this.description,
    this.badge,
    required this.continueActionText,
    required this.continueSubtext,
  });

  String get nativeName => localName;
  String get englishName => name;

  static const List<AppLanguage> supportedLanguages = [
    AppLanguage(
      code: 'en',
      name: 'English',
      localName: 'English',
      avatarChar: 'En',
      description: 'English',
      badge: 'Universal',
      continueActionText: 'Continue →',
      continueSubtext: 'Login / Sign Up',
    ),
    AppLanguage(
      code: 'ta',
      name: 'Tamil',
      localName: 'தமிழ்',
      avatarChar: 'த',
      description: 'தமிழ்',
      badge: 'Regional',
      continueActionText: 'தொடரவும் →',
      continueSubtext: 'உள்நுழைவு / பதிவு',
    ),
    AppLanguage(
      code: 'hi',
      name: 'Hindi',
      localName: 'हिंदी',
      avatarChar: 'हिं',
      description: 'हिंदी',
      badge: 'Regional',
      continueActionText: 'आगे बढ़ें →',
      continueSubtext: 'साइन इन / खाता',
    ),
    AppLanguage(
      code: 'ml',
      name: 'Malayalam',
      localName: 'മലയാളം',
      avatarChar: 'മ',
      description: 'മലയാളം',
      badge: 'Regional',
      continueActionText: 'തുടരുക →',
      continueSubtext: 'ലോഗിൻ / സൈൻ അപ്പ്',
    ),
  ];
}
