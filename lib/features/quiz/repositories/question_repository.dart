import 'package:app_with_tabs/features/quiz/models/question_model.dart';
import 'package:app_with_tabs/features/quiz/repositories/answer_repository.dart';
import 'package:app_with_tabs/services/database_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class QuestionRepository extends GetxController{
  static QuestionRepository get instance => Get.put(QuestionRepository());

  final _db = FirebaseFirestore.instance;

  Future<void> createQuestion(QuestionModel question) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if(connectivityResult != ConnectivityResult.none){
      try{
        await _db.collection("Questions").add(question.toJson(true));
        Get.snackbar("Success", "Question stored successfully.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green
        );
        }catch(error) {
          handleErrors(error,"Questions");
        }
    }else{
      print('no connection');
    }
  }

  List<QuestionModel> FirestoreQuestionsList(QuerySnapshot querySnapshot) {
    return querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return QuestionModel.fromJson(data);
    }).toList();
  }

  Future<List<QuestionModel>> getQuestionsByTitle(String quizTitle) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      try {
        QuerySnapshot querySnapshot = await _db.collection("Questions").where("QuizTitle", isEqualTo: quizTitle).get();
        List<QuestionModel> questions = FirestoreQuestionsList(querySnapshot);
        
        return questions;
      } catch (error) {
        handleErrors(error,"Questions");
        return [];
      }
    } else {
      print('no connection');
      return [];
    }
  }

  Future<void> updateQuestion(QuestionModel question) async {
    try {
      // Update question in Firestore
      await _db.collection("Questions").doc(question.id as String?).update(question.toJson(true));
    } catch (error) {
      handleErrors(error,"Questions");
    }
  }

  Future<void> deleteQuestion(int id) async {
    try {
      // Delete question from Firestore
      await _db.collection("Questions").doc(id as String?).delete();
    } catch (error) {
      handleErrors(error,"Questions");
    }
  }

  Future<void> deleteQuizQuestions(String quizTitle) async {
    try {
      // Delete all questions for a specific quiz from Firestore
      QuerySnapshot querySnapshot = await _db.collection("Questions").where('QuizTitle', isEqualTo: quizTitle).get();
      List<QuestionModel> firestoreQuestions = await getQuestionsByTitle(quizTitle);
      print("about to loop");
      for(QuestionModel question in firestoreQuestions){
          print("about to delete ${question.question}");
          for(var qst in querySnapshot.docs){
            qst.reference.delete();
          }
          //delete question's answers as well
          await AnswerRepository.instance.deleteQuizAnswers(question);
      }
    } catch (error) {
      handleErrors(error,"Questions");
    }
  }

  Future<void> deleteAllQuestions() async {
    try {
      // Delete question from Firestore
      QuerySnapshot querySnapshot = await _db.collection("Questions").get();
      print("about to delete ${querySnapshot.size} questions");
      for (var question in querySnapshot.docs){
        question.reference.delete();
      }
    } catch (error) {
      handleErrors(error,"Questions");
    }
  }


  Future<void> syncQuestionsWithFirestore() async {
    try {
      //Get all questions from firestore
      QuerySnapshot querySnapshot = await _db.collection("Questions").get();
      List<QuestionModel> firestoreQuestions = FirestoreQuestionsList(querySnapshot);

      //Get all questions from sqlite
      List<QuestionModel> sqliteQuestions = [];
      List<Map<String, dynamic>> questionRows = (await DatabaseHelper.instance.queryAllRows(DatabaseHelper.table, printResult: false)) ?? [];
      for (Map<String, dynamic> row in questionRows) {
        sqliteQuestions.add(QuestionModel.fromJson(row));
      }


      for (QuestionModel sqliteQuestion in sqliteQuestions) {
        QuestionModel? existingQuestion = firestoreQuestions.firstWhereOrNull((question) {
          return question.id.toString() == sqliteQuestion.id.toString();
        });

        if (existingQuestion != null) {
          // If question exists in Firestore => compare data with Firestore
          if (!areQuestionsEqual(existingQuestion, sqliteQuestion)) {
            // If different => update the Firestore document
            await _db.collection("Questions").doc(existingQuestion.id.toString()).set(sqliteQuestion.toJson(true));
          }
        } else {
          // If question doesn't exist in Firestore => insert it to Firestore
          await _db.collection("Questions").add(sqliteQuestion.toJson(true));
        }
      }

      for (QuestionModel firestoreQuestion in firestoreQuestions) {
        QuestionModel? existingQuestion = sqliteQuestions.firstWhereOrNull((question) => question.id.toString() == firestoreQuestion.id.toString());
        if (existingQuestion == null) {
          // If question doesn't exist in SQLite => insert it to SQLite
          print(firestoreQuestion.toJson(false));
          await DatabaseHelper.instance.insert(DatabaseHelper.table, firestoreQuestion.toJson(false));
        }
      }

      for (QuestionModel sqliteQuestion in sqliteQuestions) {
        if (!firestoreQuestions.any((question) => question.id == sqliteQuestion.id)) {
          await DatabaseHelper.instance.deleteQuestion(sqliteQuestion.id);
        }
      }
    } catch (error) {
      handleErrors(error, "Questions");
    }
  }

  void handleErrors(error, String info){
    // Get.snackbar("Error: $info", "Something went wrong. Try again.",
    //       snackPosition: SnackPosition.BOTTOM,
    //       backgroundColor: Colors.redAccent.withOpacity(0.1),
    //       colorText: Colors.red
    //     );
    print(error.toString());
  }

  bool areQuestionsEqual(QuestionModel question1, QuestionModel question2) {
    // Compare the relevant fields of the QuestionModel class
    return question1.id.toString() == question2.id.toString() &&
        question1.question == question2.question &&
        question1.quizTitle == question2.quizTitle;
  }


}
