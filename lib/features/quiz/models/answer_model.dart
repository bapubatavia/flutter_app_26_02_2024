

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
      id: json['AnswerId'] ?? json['_id'] ?? 0,
      code: json['Code'] ?? json['code'] ?? '',
      description: json['Description'] ?? json['description'] ?? '',
      questId: int.tryParse(json['QuestionId']?.toString() ?? json['question_id']?.toString() ?? '0') ?? 0,
      trueFalse: json['TrueOrFalse'] ?? json['correct'] ?? 0,
    );
  }

  toJson(bool toFirestore){
    if (toFirestore){
      return{
        "AnswerId": id,
        "Code": code,
        "Description": description,
        "QuestionId": questId,
        "TrueOrFalse": trueFalse,
      };
    } else {
      return{
        "_id": id,
        "code": code,
        "description": description,
        "question_id": questId,
        "correct": trueFalse,
      };
    }
  }
  @override
  String toString() {
    return 'AnswerModel(id: $id, code: $code, Description: $description, questionID: $questId, TrueOrFalse: $trueFalse)';
  }
}

