class LanguageModel {
  final int id;
  final String? code;
  final Map<String, dynamic> name;
  final bool status;
  final String symbol;

  LanguageModel({
    required this.id,
    this.code,
    required this.name,
    required this.status,
    required this.symbol,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      id: json['id'] ?? 0,
      code: json['code']?.toString(),
      name: json['name'] ?? {},
      status: json['status'] ?? false,
      symbol: json['symbol'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'status': status,
      'symbol': symbol,
    };
  }

  static const Map<String, String> _nativeNameMap = {
    'te': 'తెలుగు',
    'en': 'English',
    'hi': 'हिन्दी',
    'ta': 'தமிழ்',
    'kn': 'ಕನ್ನಡ',
    'ml': 'മലയാളം',
    'mr': 'मराठी',
    'bn': 'বাংলা',
    'gu': 'ગુજરાતી',
    'pa': 'ਪੰਜਾਬੀ',
    'or': 'ଓଡ଼ିଆ',
  };

  static const Map<String, String> _englishNameMap = {
    'te': 'Telugu',
    'en': 'English',
    'hi': 'Hindi',
    'ta': 'Tamil',
    'kn': 'Kannada',
    'ml': 'Malayalam',
    'mr': 'Marathi',
    'bn': 'Bengali',
    'gu': 'Gujarati',
    'pa': 'Punjabi',
    'or': 'Odia',
  };

  String getNativeName() {
    final c = code?.toLowerCase() ?? '';
    if (_nativeNameMap.containsKey(c)) {
      return _nativeNameMap[c]!;
    }
    if (name.containsKey(c)) {
      return name[c]?.toString() ?? getDisplayName();
    }
    if (symbol.isNotEmpty) {
      return symbol;
    }
    return getDisplayName();
  }

  String getEnglishName() {
    final c = code?.toLowerCase() ?? '';
    if (_englishNameMap.containsKey(c)) {
      return _englishNameMap[c]!;
    }
    if (name.containsKey('en')) {
      return name['en']?.toString() ?? getDisplayName();
    }
    return getDisplayName();
  }

  String getDisplayName() {
    return name['en']?.toString() ??
        (name.values.isNotEmpty ? name.values.first?.toString() : null) ??
        code ??
        "Telugu";
  }
}
