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

  String getDisplayName() {
    // We can prefer English display name or based on current locale, but for now
    // English seems good as a fallback, or we can use the symbol/native logic.
    // Given the names, 'en' contains the English name.
    return name['en']?.toString() ?? "Unknown";
  }
}
