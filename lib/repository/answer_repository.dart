import 'package:app_with_tabs/database_helper.dart';
import 'package:app_with_tabs/models/answer_model.dart';
import 'package:app_with_tabs/models/question_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class AnswerRepository extends GetxController{
  static AnswerRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  createAnswer(AnswerModel answer) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if(connectivityResult != ConnectivityResult.none){
      try{
        await _db.collection("Answers").add(answer.toJson());
        Get.snackbar("Success", "Answer stored successfully.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green
        );
        }catch(error) {
          Get.snackbar("Error", "Something went wrong. Try again.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent.withOpacity(0.1),
            colorText: Colors.red
          );
          print(error.toString());
        };
    } else{
      print('No internet');
    }
  }

  getAnswersPerQuestion(QuestionModel questionModel) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      try {
        QuerySnapshot querySnapshot = await _db.collection("Answers").where("QuestionId", isEqualTo: questionModel.id).get();
        List<AnswerModel> answers = querySnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;;

          return AnswerModel.fromJson(data);
        }).toList();


        return answers;
      } catch (error) {
        handleErrors(error, "Answers");
      }
    } else {
      print('no connection');
    }
  }

  Future<void> updateAnswer(AnswerModel answer) async {
  try {
    // Update answer in Firestore
    await _db.collection("Answers").doc(answer.id as String?).update(answer.toJson());
  } catch (error) {
    handleErrors(error,"Answers");
  }
  }

  Future<void> deleteAnswer(int id) async {
    try {
      // Delete answer from Firestore
      await _db.collection("Answers").doc(id as String?).delete();
    } catch (error) {
      handleErrors(error,"Answers");
    }
  }

  Future<void> syncAnswersWithFirestore() async {
    try {
      QuerySnapshot querySnapshot = await _db.collection("Answers").get();
      List<AnswerModel> firestoreAnswers = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return AnswerModel.fromJson(data);
      }).toList();

      List<AnswerModel> sqliteAnswers = [];
      List<Map<String, dynamic>> answersRows = await DatabaseHelper.instance.queryAllAnswersRows();
      for (Map<String, dynamic> row in answersRows) {
        sqliteAnswers.add(AnswerModel.fromJson(row));
      }



      for (AnswerModel firestoreAnswer in firestoreAnswers) {
        AnswerModel? existingAnswer = sqliteAnswers.firstWhereOrNull((answer) => answer.id == firestoreAnswer.id);
        if (existingAnswer != null) {
          // If answer exists => compare data with Firestore
          if (!areAnswersEqual(existingAnswer, firestoreAnswer)) {
            // If different => update the SQLite record
            await DatabaseHelper.instance.updateAnswers(firestoreAnswer.toJson(), existingAnswer.id);
          }
        } else {
          // If answer null => insert it to sqlite
          await DatabaseHelper.instance.insert(DatabaseHelper.table2, firestoreAnswer.toJson());
          print("answer data saved");
        }
      }

      for (AnswerModel sqliteAnswer in sqliteAnswers) {
        AnswerModel? existingAnswer = firestoreAnswers.firstWhereOrNull((answer) => answer.id == sqliteAnswer.id);

        if (existingAnswer != null) {
          // If answer in Firestore => compare with the SQLite data
          if (!areAnswersEqual(sqliteAnswer, existingAnswer)) {
            // If difference => update the Firestore document
            print(existingAnswer.id);
            await _db.collection("Answers").doc(existingAnswer.id as String).set(sqliteAnswer.toJson());
            print("Data updated in Firestore");
          }
        } else {
          // If answer null => insert it to firestore
          await _db.collection("Answers").add(sqliteAnswer.toJson());
          print("Data saved to Firestore");
        }
      }

      for (AnswerModel sqliteAnswer in sqliteAnswers) {
        if (!firestoreAnswers.any((answer) => answer.id == sqliteAnswer.id)) {
          await DatabaseHelper.instance.deleteAnswer(sqliteAnswer.id);
        }
      }
    } catch (error) {
      handleErrors(error, "Answers");
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

  bool areAnswersEqual(AnswerModel answer1, AnswerModel answer2) {
    return answer1.id == answer2.id &&
        answer1.questId == answer2.questId &&
        answer1.description == answer2.description;
  }


}