// ignore_for_file: avoid_print

import 'package:app_with_tabs/database_helper.dart';
import 'package:app_with_tabs/models/answer_model.dart';
import 'package:app_with_tabs/models/question_model.dart';
import 'package:app_with_tabs/pages/user_quiz_result.dart';
import 'package:app_with_tabs/repository/answer_repository.dart';
import 'package:app_with_tabs/repository/question_repository.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserQuizTakingPage extends StatefulWidget {
  final String quizTitle;

  const UserQuizTakingPage({Key? key, required this.quizTitle}) : super(key: key);

  @override
  _UserQuizTakingPageState createState() => _UserQuizTakingPageState();
}

class _UserQuizTakingPageState extends State<UserQuizTakingPage> {
  QuestionRepository queRepo = QuestionRepository();
  AnswerRepository ansRepo = AnswerRepository();
  int currentQuestionIndex = 0;
  late List<QuestionModel> questions = [];
  late List<int?> answersPerQuestions = [];
  late List<List<AnswerModel>> answers = [];
  late List<int?> scores = [];
  String? userEmail = FirebaseAuth.instance.currentUser!.email;
  int answerId = 0;
  int answerTof = 0;
  String answerCode = "";
  String answerDesc = "";

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      List<QuestionModel> fetchedQuestions = [];
      List<List<AnswerModel>> fetchedAnswers = [];
      List<int?> initialScores = [];

      if(connectivityResult == ConnectivityResult.none){
        fetchedQuestions = await DatabaseHelper.instance.queryQuizQuestionsQM(widget.quizTitle);

        for (var question in fetchedQuestions) {
          List<AnswerModel> questionAnswers = await DatabaseHelper.instance.queryQuizAnswersAM(question.id);
          fetchedAnswers.add(questionAnswers);
          initialScores.add(null);
        }
      }else{
        fetchedQuestions = await queRepo.getQuestionsByTitle(widget.quizTitle);

        for (var question in fetchedQuestions) {
          List<AnswerModel> questionAnswers = await ansRepo.getAnswersPerQuestion(question);
          fetchedAnswers.add(questionAnswers);
          initialScores.add(null);
        }        
      }
      List<Map<String, dynamic>> answeredQuestions = await DatabaseHelper.instance.queryAnsweredQuestions(userEmail!, widget.quizTitle);
      print(answeredQuestions);
      int nextUnansweredQuestionIndex = 0;
      if (answeredQuestions.isNotEmpty) {
        List<int> answeredQuestionIds = answeredQuestions.map((question) => question['id'] as int).toList();

        for (int i = 0; i < fetchedQuestions.length; i++) {
          if (!answeredQuestionIds.contains(fetchedQuestions[i].id)) {
            nextUnansweredQuestionIndex = i;
            break;
          }
        }
      }

      for (int i = 0; i < fetchedQuestions.length; i++) {
        List<AnswerModel> questionAnswers = await ansRepo.getAnswersPerQuestion(fetchedQuestions[i]);
        fetchedAnswers.add(questionAnswers);
        initialScores.add(null);
      }

      setState(() {
        questions = fetchedQuestions;
        answers = fetchedAnswers;
        answersPerQuestions = initialScores;
        currentQuestionIndex = nextUnansweredQuestionIndex;
      });
    } catch (error) {
      print('Error loading questions: $error');
    }
  }

  void handleNextQuestion(int answerId, int questionId, int answerTof, String ansCode, String ansDesc) async {
    if (currentQuestionIndex < questions.length - 1) {
      await insertAnswerPicked(answerId, questionId, answerTof, ansCode, ansDesc);
      await insertQuestionAnswered(questionId, userEmail!, widget.quizTitle);
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      for (int i = 0; i < answersPerQuestions.length; i++) {
        for (int j = 0; j < answers[i].length; j++) {
          if (answersPerQuestions[i] == answers[i][j].id) {
            scores.add(answers[i][j].trueFalse);
          }
        }
      }

      int score = scores.where((score) => score == 1).length;
      await insertAnswerPicked(answerId, questionId, answerTof, ansCode, ansDesc);
      await insertQuestionAnswered(questionId, userEmail!, widget.quizTitle);
      await insertScore(userEmail!, widget.quizTitle, score, questions.length);
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizResultPage(score: score, totalQuestions: questions.length),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const Center(child: CircularProgressIndicator(backgroundColor: Colors.white));
    }

    QuestionModel currentQuestion = questions[currentQuestionIndex];
    List<AnswerModel> currentAnswers = answers[currentQuestionIndex];

    int questionId = currentQuestion.id;

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Confirm Exit"),
              content: const Text("Exit will save your progress so you can pick up where you left off later, is that OK?"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text("Confirm"),
                ),
              ],
            );
          },
        ) ?? false; // Return false if user cancels the dialog
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quiz'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentQuestion.question,
                style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: currentAnswers
                    .map((answer) => RadioListTile<int?>(
                          title: Text(answer.description),
                          value: answer.id,
                          groupValue: answersPerQuestions[currentQuestionIndex],
                          onChanged: (int? value) {
                            setState(() {
                              answersPerQuestions[currentQuestionIndex] = value;
                              if (value != null) {
                                answerId = value;
                                answerTof = answer.trueFalse;
                                answerCode = answer.code;
                                answerDesc = answer.description;
                              }
                              print(answerId);
                            });
                          },
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20.0),
              Center(
                child: MaterialButton(
                  elevation: 0,
                  height: 40,
                  color: Colors.green,
                  onPressed: () {
                    setState(() {
                      handleNextQuestion(answerId, questionId, answerTof, answerCode, answerDesc);
                    });
                  },
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      color: Colors.black,
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(currentQuestionIndex == questions.length - 1 ? 'Finish' : 'Next Question'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<int> insertScore(String email, String qTitle, int score, int total) async {
    Map<String, dynamic> userScore = {
      DatabaseHelper.columnEmail: email,
      DatabaseHelper.columnQuizTitle1: qTitle,
      DatabaseHelper.columnScore: score,
      DatabaseHelper.columnTotal: total
    };

    int id = await DatabaseHelper.instance.insert('quizScore', userScore);
    print('Inserted score id: $id');
    print('Inserted score email: $email');
    print('Inserted score title: $qTitle');
    print('Inserted score marks: $score');
    print('Inserted score total: $total');
    return id;
  }

  Future<int> insertQuestionAnswered(int qId, String email, String qTitle) async {
    Map<String, dynamic> questionAnswered = {
      DatabaseHelper.columnId: qId,
      DatabaseHelper.columnEmail: email,
      DatabaseHelper.columnQuizTitle1: qTitle,
    };

    int id = await DatabaseHelper.instance.insert('questionsAnswered', questionAnswered);
    print('Inserted answered question id: $id');
    print('Inserted answered question email: $email');
    print('Inserted answered question quiz title: $qTitle');
    return id;
  }

  Future<int> insertAnswerPicked(int aId, int qId, int tof, String code, String desc) async {
    print(aId);
    print(qId);
    print(tof);
    print(code);
    print(desc);
    Map<String, dynamic> answerPicked = {
      DatabaseHelper.columnId: aId,
      DatabaseHelper.columnQuesId: qId,
      DatabaseHelper.columnTrueFalse: tof,
      DatabaseHelper.columnCode: code,
      DatabaseHelper.columnDescription: desc,
    };

    int id = await DatabaseHelper.instance.insert('answersPicked', answerPicked);
    print('Inserted picked answer id: $id');
    print('Inserted picked answer questionId: $qId');
    print('Inserted picked answer question code: $code');
    print('Inserted picked answer question description: $desc');
    print('Inserted picked answer true or false : $tof');
    return id;
  }
}