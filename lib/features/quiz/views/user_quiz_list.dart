import 'package:app_with_tabs/services/database_helper.dart';
import 'package:app_with_tabs/features/quiz/views/user_quiz.dart';
import 'package:flutter/material.dart';

class UserQuizListPage extends StatefulWidget {
  const UserQuizListPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UserQuizListPageState createState() => _UserQuizListPageState();
}

class _UserQuizListPageState extends State<UserQuizListPage> {
  late Future<List<String>> _quizTitlesFuture;
  @override
  void initState() {
    super.initState();
    _quizTitlesFuture = _loadQuizTitles();
  }

  Future<List<String>> _loadQuizTitles() async {
      return await DatabaseHelper.instance.getQuizTitles();
  }

  Future<List<bool>> _progressOrNot() async {
      List<String> filtered = await _loadQuizTitles();

      List<bool> inProgress = [];
      for (var title in filtered) {
        bool isNotInDb = await DatabaseHelper.instance.quizTitleNotInDb(title, 'questionsAnswered');
        inProgress.add(isNotInDb);
      }
      return inProgress;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz List'),
      ),
      body: FutureBuilder<List<String>>(
        future: _quizTitlesFuture,
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
                  final quizTitle = snapshot.data![quizIndex];
                  return FutureBuilder<List<bool>>(
                    future: _progressOrNot(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        final inProgress = snapshot.data![quizIndex];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Text((index + 1).toString()),
                          ),
                          trailing: inProgress ? const Text('*NEW*') : const Text('ON GOING'),
                          title: Text(quizTitle),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserQuizTakingPage(quizTitle: quizTitle),
                              ),
                            );
                          },
                        );
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
