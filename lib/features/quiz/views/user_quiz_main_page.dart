import 'package:app_with_tabs/features/quiz/views/user_quiz_scores_list.dart';
import 'package:app_with_tabs/services/database_helper.dart';
import 'package:app_with_tabs/features/quiz/views/user_quiz_list.dart';
import 'package:flutter/material.dart';

class UserQuizMainPage extends StatelessWidget {
  const UserQuizMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 50),
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Column(
                  children: <Widget>[
                    Text("Welcome to our", 
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),),
                    SizedBox(height: 20,),
                    Text("Fantastic quiz game!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),),
                  ],
                ),
                Container(
                  height: MediaQuery.of(context).size.height / 3,
                  decoration: const BoxDecoration(
                    image: DecorationImage(image: AssetImage('assets/img/questions.png')),
                  ),
                ),
                Column(
                  children: <Widget>[
                    MaterialButton(
                      minWidth: double.infinity,
                      height: 60,
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) =>  const UserQuizListPage()));
                      },
                      shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        color: Colors.black,
                      ),
                      borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Text("View available quizzes", style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      )),
                    ),
                    const SizedBox(height: 20),
                    MaterialButton(
                      color: Colors.green[400],
                      elevation: 0,
                      minWidth: double.infinity,
                      height: 60,
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) =>  const UserQuizScoresListPage()));
                      },
                      shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        color: Colors.black,
                      ),
                      borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Text("View your scores", style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      )),
                    ),  
                    const SizedBox(height: 20),
                    MaterialButton(
                      color: Colors.red[400],
                      elevation: 0,
                      minWidth: double.infinity,
                      height: 40,
                      onPressed: () {
                        showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Confirm Deletion"),
                              content: const Text("This will delete all your progress and current results, is that OK?"),
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
                                    DatabaseHelper.instance.clearTable(DatabaseHelper.table3);
                                    // DatabaseHelper.instance.deleteQuizScore();
                                    DatabaseHelper.instance.queryAllRows(DatabaseHelper.table3, printResult: true);
                                    // DatabaseHelper.instance.queryAllRowsforQuizScore();
                                    DatabaseHelper.instance.clearTable(DatabaseHelper.table4);
                                    // DatabaseHelper.instance.deleteQuestionAnswered();
                                    DatabaseHelper.instance.queryAllRows(DatabaseHelper.table4, printResult: true);
                                    // DatabaseHelper.instance.queryAllRowsforQuestion();
                                    DatabaseHelper.instance.clearTable(DatabaseHelper.table5);
                                    // DatabaseHelper.instance.deleteAnswersPicked();
                                    DatabaseHelper.instance.queryAllRows(DatabaseHelper.table5, printResult: true);
                                    // DatabaseHelper.instance.queryAllRowsforAnswers();
                                  },
                                  child: const Text("Confirm"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        color: Colors.black,
                      ),
                      borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Text("Delete all progress", style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      )),
                    ),                                  
                  ],
                )
              ],
            ),
          )
        ), 
      ),
    );
  }


}