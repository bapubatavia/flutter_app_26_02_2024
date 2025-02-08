

class QuestionModel {
  final int id;
  final String question;
  final String quizTitle;

  const QuestionModel({
    required this.id,
    required this.question,
    required this.quizTitle
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['QuestionId'] as int,
      question: json['Question'] as String,
      quizTitle: json['QuizTitle'] as String,
    );
  }

  toJson(){
    return{
      "QuestionId": id,
      "Question": question,
      "QuizTitle": quizTitle,
    };
  }
}

