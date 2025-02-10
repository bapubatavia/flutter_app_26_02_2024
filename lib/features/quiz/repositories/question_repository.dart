import 'package:app_with_tabs/features/quiz/models/question_model.dart';
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
        await _db.collection("Questions").add(question.toJson());
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

  getQuestionsByTitle(String quizTitle) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      try {
        QuerySnapshot querySnapshot = await _db.collection("Questions").where("QuizTitle", isEqualTo: quizTitle).get();
        List<QuestionModel> questions = querySnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          return QuestionModel.fromJson(data);
        }).toList();
        
        return questions;
      } catch (error) {
        handleErrors(error,"Questions");
      }
    } else {
      print('no connection');
    }
  }

  Future<void> updateQuestion(QuestionModel question) async {
    try {
      // Update question in Firestore
      await _db.collection("Questions").doc(question.id as String?).update(question.toJson());
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


  Future<void> syncQuestionsWithFirestore() async {
    try {
      QuerySnapshot querySnapshot = await _db.collection("Questions").get();
      List<QuestionModel> firestoreQuestions = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return QuestionModel.fromJson(data);
      }).toList();

      List<QuestionModel> sqliteQuestions = [];
      List<Map<String, dynamic>> questionRows = (await DatabaseHelper.instance.queryAllRows(DatabaseHelper.table, printResult: false)) ?? [];
      for (Map<String, dynamic> row in questionRows) {
        sqliteQuestions.add(QuestionModel.fromJson(row));
      }


      for (QuestionModel sqliteQuestion in sqliteQuestions) {
        QuestionModel? existingQuestion = firestoreQuestions.firstWhereOrNull((question) => question.id == sqliteQuestion.id);
        if (existingQuestion != null) {
          // If question exists in Firestore => compare data with Firestore
          if (!areQuestionsEqual(existingQuestion, sqliteQuestion)) {
            // If different => update the Firestore document
            await _db.collection("Questions").doc(existingQuestion.id as String?).set(sqliteQuestion.toJson());
            print("Question data updated in Firestore");
          }
        } else {
          // If question doesn't exist in Firestore => insert it to Firestore
          await _db.collection("Questions").add(sqliteQuestion.toJson());
          print("Question data added to Firestore");
        }
      }

      for (QuestionModel firestoreQuestion in firestoreQuestions) {
        QuestionModel? existingQuestion = sqliteQuestions.firstWhereOrNull((question) => question.id == firestoreQuestion.id);
        if (existingQuestion == null) {
          // If question doesn't exist in SQLite => insert it to SQLite
          await DatabaseHelper.instance.insert(DatabaseHelper.table, firestoreQuestion.toJson());
          print("Question data added to SQLite");
        }
      }

      for (QuestionModel sqliteQuestion in sqliteQuestions) {
        if (!firestoreQuestions.any((question) => question.id == sqliteQuestion.id)) {
          await DatabaseHelper.instance.deleteQuestion(sqliteQuestion.id);
        }
      }


      for (QuestionModel sqliteQuestion in sqliteQuestions) {
        if (!firestoreQuestions.any((question) => question.id == sqliteQuestion.id)) {
          await DatabaseHelper.instance.deleteQuestion(sqliteQuestion.id);
          print("Question data deleted from SQLite");
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
    return question1.id == question2.id &&
        question1.question == question2.question &&
        question1.quizTitle == question2.quizTitle;
  }


}
