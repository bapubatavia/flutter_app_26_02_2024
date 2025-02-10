

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
      id: json['QuestionId'] ?? json['id'] ?? 0,
      question: json['Question'] ?? json['question'] ?? '',
      quizTitle: json['QuizTitle'] ?? json['title'] ?? '',
    );
  }

  toJson(bool toFirestore){
    if (toFirestore){
      return{
        "QuestionId": id,
        "Question": question,
        "QuizTitle": quizTitle,
      };
    } else {
      return{
        "id": id,
        "question": question,
        "title": quizTitle,
      };
    }
  }

  @override
  String toString() {
    return 'QuestionModel(id: $id, question: $question, quizTitle: $quizTitle)';
  }
}

