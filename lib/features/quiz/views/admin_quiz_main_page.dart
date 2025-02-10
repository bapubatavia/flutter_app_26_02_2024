import 'package:app_with_tabs/features/quiz/views/newQuestionPage.dart';
import 'package:app_with_tabs/services/database_helper.dart';
import 'package:app_with_tabs/features/quiz/views/admin_quiz_display.dart';
import 'package:flutter/material.dart';

class AdminQuizMainPage extends StatelessWidget {
  const AdminQuizMainPage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 50),
          height: MediaQuery.of(context).size.height,
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
                  Text("Admin quiz gateway!",
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
                  image: DecorationImage(image: AssetImage('assets/img/setting.png')),
                ),
              ),
              Column(
                children: <Widget>[
                  MaterialButton(
                    minWidth: double.infinity,
                    height: 60,
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) =>  const AdminQuizListPage()));
                    },
                    shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      color: Colors.black,
                    ),
                    borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Text("View Quizzes", style: TextStyle(
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) =>  const NewQuestionPage()));
                    },
                    shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      color: Colors.black,
                    ),
                    borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Text("Add quiz", style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    )),
                  ),
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
                            content: const Text("This will delete all your created quizzes and answers, is that OK?"),
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
                                  DatabaseHelper.instance.clearTable("table");
                                  // DatabaseHelper.instance.deleteQuizQuestions();
                                  DatabaseHelper.instance.queryAllRows("table", printResult: true);
                                  // DatabaseHelper.instance.queryAllRowsforQuizQuestions();
                                  DatabaseHelper.instance.clearTable("table2");
                                  // DatabaseHelper.instance.deleteQuizAnswers();
                                  DatabaseHelper.instance.queryAllRows("table2", printResult: true);
                                  // DatabaseHelper.instance.queryAllRowsforQuizAnswers();
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
                    child: const Text("Delete all quizzes", style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    )),
                  ),                
                ],
              )
            ],
          )
        ), 
      ),
    );
  }
}