class WordsModel {
  final int id;
  final String name;
  final String value;
  final String gpt;
  final String llama;
  final String gemini;

  WordsModel({
    required this.id,
    required this.name,
    required this.value,
    required this.gpt,
    required this.llama,
    required this.gemini,
  });

  factory WordsModel.fromJson(Map<String, dynamic> json) {
    return WordsModel(
      id: json['id'],
      name: json['name'],
      value: json['value'],
      gpt: json['gpt'],
      llama: json['llama'],
      gemini: json['gemini'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'value': value,
      'gpt': gpt,
      'llama': llama,
      'gemini': gemini,
    };
  }
}
