import 'package:app_with_tabs/pages/newQuestionPage.dart';
import 'package:flutter/material.dart';
import 'package:app_with_tabs/database_helper.dart';

class AdminQuizListPage extends StatefulWidget {
  const AdminQuizListPage({Key? key}) : super(key: key);

  @override
  _AdminQuizListPageState createState() => _AdminQuizListPageState();
}

class _AdminQuizListPageState extends State<AdminQuizListPage> {
  late Future<List<Map<String, dynamic>>> _quizTitlesFuture;

  @override
  void initState() {
    super.initState();
    _quizTitlesFuture = _loadQuizTitles();
  }

  Future<List<Map<String, dynamic>>> _loadQuizTitles() async {
    return await DatabaseHelper.instance.queryDistinctQuizTitles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz List'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
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
                  final quizTitle = snapshot.data![quizIndex][DatabaseHelper.columnQuizTitle];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Text((index + 1).toString()),
                    ),
                    title: Text(quizTitle),
                    trailing: GestureDetector(
                    onTap: () {},
                        
                    child: const Icon(Icons.delete_forever, color: Colors.red,
                    ),
                  ),
                    onTap: () {

                      if (quizTitle != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminQuizQuestionsPage(quizTitle: quizTitle),
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

class AdminQuizQuestionsPage extends StatelessWidget {
  final String quizTitle;

  const AdminQuizQuestionsPage({Key? key, required this.quizTitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(quizTitle),
      ),
      floatingActionButton:  FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
            MaterialPageRoute(builder: (context) => NewQuestionPage(quizTitle: quizTitle),
            ),
          );
        },
        child: Icon(Icons.add, color: Theme.of(context).brightness == Brightness.dark? Colors.black : Colors.white),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadQuizQuestions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No quiz questions found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final question = snapshot.data![index][DatabaseHelper.columnQuestion];
                final questionId = snapshot.data![index]['id'];
                final questionDetails = snapshot.data![index]['question'];
                return ListTile(
                  title: Text(question),
                  trailing: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Confirm Deletion"),
                            content: const Text("Delete this question?"),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); 
                                },
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  DatabaseHelper.instance.deleteQuestion(questionId);
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Confirm"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Icon(Icons.delete_forever, color: Colors.red,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminQuestionDetailsPage(questionId: questionId, questionDetails: questionDetails),
                      ),
                    );  
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _loadQuizQuestions() async {
    return await DatabaseHelper.instance.queryQuizQuestions(quizTitle);
  }
}


class AdminQuestionDetailsPage extends StatefulWidget {
  final int questionId;
  final String questionDetails;

  const AdminQuestionDetailsPage({Key? key, required this.questionId, required this.questionDetails}) : super(key: key);

  @override
  _AdminQuestionDetailsPageState createState() => _AdminQuestionDetailsPageState();
}

class _AdminQuestionDetailsPageState extends State<AdminQuestionDetailsPage> {
  late List<TextEditingController> _controllers;
  late List<int> _correct;

  @override
  void initState() {
    super.initState();
    _controllers = [];
    _correct = [];
    _initializeState();
  }

  void _initializeState() async {
    // Load answers and initialize _controllers and _correct
    final answers = await _loadAnswersForQuestion();
    setState(() {
      _controllers = List.generate(answers.length, (index) => TextEditingController(text: answers[index]['description']));
      _correct = List.generate(answers.length, (index) => answers[index]['correct'] == 1 ? 1 : 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.questionDetails),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadAnswersForQuestion(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No answers for this question found.'));
          } else {
            print(snapshot.data);
            return ListView.builder(
              itemCount: snapshot.data!.length + 1, // Add 1 for the button
              itemBuilder: (context, index) {
                if (index == snapshot.data!.length) {
                  return Container(
                    width: 200,
                    child: MaterialButton(
                      color: Colors.white,
                      elevation: 0,
                      minWidth: double.infinity,
                      height: 45,
                      onPressed: () async {
                        for (var i = 0; i < _controllers.length; i++) {
                          print(snapshot.data![i]['code']);
                          await _updateAnswers(
                            answer: _controllers[i].value.text,
                            code: snapshot.data![i]['code'],
                            questionTF: _correct[i],
                            questionId: widget.questionId,
                          );
                        }
                      },
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          color: Colors.black,
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Text(
                        "Update Answers",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  );
                } else {
                  return ListTile(
                    title: TextField(
                      controller: _controllers[index],
                      onChanged: (value) {
                        setState(() {
                          _controllers[index].text = value;
                        });
                      },
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RadioListTile<int>(
                          value: 1,
                          groupValue: _correct[index],
                          onChanged: (value) {
                            setState(() {
                              _correct[index] = value!;
                              print(_correct);
                            });
                          },
                          title: const Text("True"),
                        ),
                        RadioListTile<int>(
                          value: 0,
                          groupValue: _correct[index],
                          onChanged: (value) {
                            setState(() {
                              _correct[index] = value!;
                              print(_correct);
                            });
                          },
                          title: const Text("False"),
                        ),
                      ],
                    ),
                  );
                }
              },
            );
          }
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _loadAnswersForQuestion() async {
    return await DatabaseHelper.instance.queryQuizAnswers(widget.questionId);
  }

  Future<void> _updateAnswers({answer, code, questionId, questionTF}) async{

    Map<String, dynamic> answers = {
      DatabaseHelper.columnCode: code,
      DatabaseHelper.columnDescription: answer,
      DatabaseHelper.columnQuesId: questionId,
      DatabaseHelper.columnTrueFalse: questionTF
    };

    int id = await DatabaseHelper.instance.updateAnswers(answers, questionId);
    print('Inserted answer id: $id');
    print('Inserted answer code: $code');
    print('Inserted answer description: $answer');
    print('Inserted answer question_id: $questionId');
    print('Inserted answer trueOrNot: $questionTF');
  }
}