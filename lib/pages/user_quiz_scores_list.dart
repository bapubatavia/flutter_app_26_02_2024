import 'package:app_with_tabs/database_helper.dart';
import 'package:app_with_tabs/pages/user_quiz_result.dart';
import 'package:flutter/material.dart';

class UserQuizScoresListPage extends StatefulWidget {
  const UserQuizScoresListPage({Key? key}) : super(key: key);

  @override
  _UserQuizScoresListPageState createState() => _UserQuizScoresListPageState();
}

class _UserQuizScoresListPageState extends State<UserQuizScoresListPage> {
  late Future<List<Map<String, dynamic>>> _quizScoresFuture;

  @override
  void initState() {
    super.initState();
    _quizScoresFuture = _loadQuizScores();
  }

  Future<List<Map<String, dynamic>>> _loadQuizScores() async {
    return await DatabaseHelper.instance.queryAnsweredQuizTitles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Scores List'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _quizScoresFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No quizzes found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length * 2 - 1,
              itemBuilder: (context, index) {
                if (index.isOdd) {
                  return Divider(
                    color: Colors.grey[300],
                    thickness: 1,
                  );
                } else {
                  final quizIndex = index ~/ 2;
                  print(snapshot.data);
                  final quizTitle = snapshot.data![quizIndex][DatabaseHelper.columnQuizTitle1];
                  final quizScore = snapshot.data![quizIndex][DatabaseHelper.columnScore];
                  final quizTotal = snapshot.data![quizIndex][DatabaseHelper.columnTotal];

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Text((index + 1).toString()),
                    ),
                    title: Text('$quizTitle (Score: $quizScore / $quizTotal)'),
                    onTap: () {
                      if (quizTitle != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizResultPage(score: quizScore, totalQuestions: quizTotal),
                          ),
                        );
                      } else {
                        print('Quiz title is null');
                      }
                    },
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}
