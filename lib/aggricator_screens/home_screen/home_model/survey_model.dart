class SurveyModel {
  final String choicename;
  final int choiceid;

  SurveyModel({required this.choicename, required this.choiceid});

  factory SurveyModel.fromJson(Map<String, dynamic> json) {
    return SurveyModel(
      choicename: json['choicename'],
      choiceid: json['choiceid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'choicename': choicename,
      'choiceid': choiceid,
    };
  }
}
