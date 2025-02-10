

class AnswerModel {
  final int id;
  final String code;
  final String description;
  final int questId;
  final int trueFalse;


  const AnswerModel({
    required this.id,
    required this.code,
    required this.description,
    required this.questId,
    required this.trueFalse,
  });

  factory AnswerModel.fromJson(Map<String, dynamic> json) {
    return AnswerModel(
      id: json['AnswerId'] as int,
      code: json['Code'] as String,
      description: json['Description'] as String,
      questId: json['QuestionId'] as int,
      trueFalse: json['TrueOrFalse'] as int,

    );
  }

  toJson(){
    return{
      "AnswerId": id,
      "Code": code,
      "Description": description,
      "QuestionId": questId,
      "TrueOrFalse": trueFalse,
    };
  }
}

