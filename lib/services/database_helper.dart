import 'package:app_with_tabs/features/quiz/models/answer_model.dart';
import 'package:app_with_tabs/features/quiz/models/question_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "quizzTest.db";
  static const _databaseVersion = 10;

  static const table = 'questions';

  static const columnId = 'id';
  static const columnQuestion = 'question';
  static const columnQuizTitle = 'title';
 

  static const table2 = 'answers';

  static const columnId2 = '_id';
  static const columnCode = 'code';
  static const columnDescription = 'description';
  static const columnQuesId = 'question_id';
  static const columnTrueFalse = 'correct';

  static const table3 = 'quizScore';

  static const columnId3 = 'id';
  static const columnEmail = 'user_email';
  static const columnQuizTitle1 = 'quiz_title';
  static const columnScore = 'score';
  static const columnTotal = 'total';

  static const table4 = 'questionsAnswered';

  //same columns as questions table plus an email column for user

  static const table5 = 'answersPicked';

  //same columns as answers table plus add an email column for user





  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();


 
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }


  _initDatabase() async {
    var documentsDirectory = await getDatabasesPath();
    var path = join(documentsDirectory, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }


  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE IF NOT EXISTS $table (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnQuestion TEXT NOT NULL,
            $columnQuizTitle TEXT NOT NULL

          );
          ''');
    print('Database table1 created');
    await db.execute('''
          CREATE TABLE $table2 (
            $columnId2 INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnCode TEXT NOT NULL,
            $columnDescription TEXT NOT NULL,
            $columnQuesId TEXT NOT NULL,
            $columnTrueFalse INTEGER NOT NULL,
            FOREIGN KEY($columnQuesId) REFERENCES $table ($columnId)
          );
          ''');
    print('Database table2 created');
    await db.execute('''
          CREATE TABLE $table3 (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnEmail TEXT NOT NULL,
            $columnQuizTitle1 TEXT NOT NULL,
            $columnScore INTEGER NOT NULL,
            $columnTotal INTEGER NOT NULL
          );
          ''');
    print('Database table3 created');

    print("this is oncreate");
    await db.execute('''
          CREATE TABLE $table4 (
            $columnId INTEGER PRIMARY KEY,
            $columnEmail TEXT NOT NULL,
            $columnQuizTitle1 TEXT NOT NULL
          );
          ''');
    print('Database table4 created');


    await db.execute('''
          CREATE TABLE $table5 (
            $columnId INTEGER PRIMARY KEY,
            $columnCode INTEGER NOT NULL,
            $columnDescription STRING NOT NULL,
            $columnTrueFalse INTEGER NOT NULL,
            $columnQuesId INTEGER NOT NULL,
            FOREIGN KEY($columnQuesId) REFERENCES $table4 ($columnId)
          );
          ''');
    print('Database table5 created');
  }
  // Database upgrade 
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
   if (oldVersion < 10) {
    await db.execute('DROP TABLE IF EXISTS $table4');
    await db.execute('DROP TABLE IF EXISTS $table5');

    print("this is onupgrade");

    await db.execute('''
          CREATE TABLE $table4 (
            $columnId INTEGER PRIMARY KEY,
            $columnEmail TEXT NOT NULL,
            $columnQuizTitle1 TEXT NOT NULL
          );
          ''');
    print('Database table4 created');


    await db.execute('''
          CREATE TABLE $table5 (
            $columnId INTEGER PRIMARY KEY,
            $columnCode INTEGER NOT NULL,
            $columnDescription STRING NOT NULL,
            $columnTrueFalse INTEGER NOT NULL,
            $columnQuesId INTEGER NOT NULL,
            FOREIGN KEY($columnQuesId) REFERENCES $table4 ($columnId)
          );
          ''');
    print('Database table5 created');

  }
  }

  // Database operations
  Future<int> insert(String tablePicked, Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(tablePicked, row);
  
  }

  Future<List<Map<String, dynamic>>> queryAllQuestionsRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  Future<List<Map<String, dynamic>>> queryAllAnswersRows() async {
    Database db = await instance.database;
    return await db.query(table2);
  }

  //For admin side fetching
  Future<List<Map<String, dynamic>>> queryQuizAnswers(int questId) async {
    Database db = await instance.database;
    return await db.query(table2, where: '$columnQuesId = ?', whereArgs: [questId]);
  }

  //For user side fetching
  Future<List<AnswerModel>> queryQuizAnswersAM(int questId) async {
    // Database db = await instance.database;
    // List<Map<String, dynamic>> result = await db.query(table2, where: '$columnQuesId = ?', whereArgs: [questId]);
    List<Map<String, dynamic>> result = await queryQuizAnswers(questId);
    List<AnswerModel> answers = result.map((row) => AnswerModel.fromJson(row)).toList();

    return answers;
  }

  //For admin side fetching
  Future<List<Map<String, dynamic>>> queryQuizQuestions(String quizTitle) async {
    Database db = await instance.database;
    return await db.query(table, where: '$columnQuizTitle = ?', whereArgs: [quizTitle]);
  }

  //For user side fetching
  Future<List<QuestionModel>> queryQuizQuestionsQM(String quizTitle) async {
    // Database db = await instance.database;
    // List<Map<String, dynamic>> result = await db.query(table, where: '$columnQuizTitle = ?', whereArgs: [quizTitle]);
    List<Map<String, dynamic>> result = await queryQuizQuestions(quizTitle);
    List<QuestionModel> questions = result.map((row) => QuestionModel.fromJson(row)).toList();

    return questions;
  }  

  Future<List<Map<String, dynamic>>> queryDistinctQuizTitles() async {
    Database db = await instance.database;
    return await db.rawQuery('SELECT DISTINCT $columnQuizTitle FROM $table');
  }
  

  Future<List<String>> getQuizTitles() async {
    final db0 = FirebaseFirestore.instance;
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      try {
        QuerySnapshot querySnapshot = 
          await db0.collection("Questions").get();
        List<QuestionModel> questions = querySnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          return QuestionModel.fromJson(data);
        }).toList();
        

        List<String> titles = questions.map((question) => question.quizTitle).toList();
        titles = titles.toSet().toList();
        

        List<String> filteredTitles = [];
        for (var title in titles) {
          bool isNotInDb = await DatabaseHelper.instance.quizTitleNotInDb(title, 'quizScore');
          if (isNotInDb) {
            filteredTitles.add(title);
          }
        }


        return filteredTitles;
      } catch (error) {
        handleErrors(error);
        return [];
      }
    } else {
      Database db = await instance.database;
      List<Map<String, dynamic>> result = await db.rawQuery('SELECT DISTINCT $columnQuizTitle FROM $table');
      

      List<String> titles = result.map((row) => row[columnQuizTitle] as String).toList();

      List<String> filteredTitles = [];
      for (var title in titles) {
        bool isInDb = await DatabaseHelper.instance.quizTitleNotInDb(title, 'quizScore');
        if (isInDb) {
          filteredTitles.add(title);
        }
      }

      return filteredTitles;

    }
  }


  Future<List<Map<String, dynamic>>> queryAnsweredQuizTitles() async {
    Database db = await instance.database;
    return await db.query(table3);
  }

  Future<List<Map<String, dynamic>>> queryAnsweredQuestions(String email, String quizTitle) async {
    Database db = await instance.database;
    return await db.query(table4, where: '$columnEmail = ? AND $columnQuizTitle1 =?', whereArgs: [email, quizTitle]);
  }

  Future<bool> quizTitleNotInDb(String quizTitle, String tablePicked) async{
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query(tablePicked, where: '$columnQuizTitle1 = ?', whereArgs: [quizTitle]);
    return result.isEmpty;
  }
  
  Future<int> updateQuestion(String tablePicked,Map<String, dynamic> row) async {
    Database db = await instance.database;
    print(row);
    int id = row[columnId];
    return await db.update(tablePicked, row, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> updateAnswers(Map<String, dynamic> answers, int questionId) async{
    DatabaseHelper helper = DatabaseHelper.instance;
    Database db = await helper.database;

    int rowsAffected = await db.update(
      'answers',
      answers,
      where: '${DatabaseHelper.columnCode} = ? AND ${DatabaseHelper.columnQuesId} = ?',
      whereArgs: [answers['code'], questionId],
    );
    print('Rows updated: $rowsAffected');
    return rowsAffected;
  }


  Future<int> deleteQuestion(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> deleteAnswer(int id) async {
    Database db = await instance.database;
    return await db.delete(table2, where: '$columnId2 = ?', whereArgs: [id]);
  }

  Future<int> deleteQuiz(String tablePicked, String title) async{
    Database db = await instance.database;
    return await db.delete(tablePicked, where: '$columnQuizTitle = ?', whereArgs: [title]);
  }

  Future<int> clearTable(String tableName) async {
    Database db = await instance.database;
    return await db.delete(tableName);
  }
  
  // Future<int> deleteQuizQuestions() async {
  //   Database db = await instance.database;
  //   return await db.delete(table);
  // }
  //
  // Future<int> deleteQuizAnswers() async {
  //   Database db = await instance.database;
  //   return await db.delete(table2);
  // }

  // Future<int> deleteQuizScore() async {
  //   Database db = await instance.database;
  //   return await db.delete(table3);
  // }

  // Future<int> deleteQuestionAnswered() async {
  //   Database db = await instance.database;
  //   return await db.delete(table4);
  // }
  //
  // Future<int> deleteAnswersPicked() async {
  //   Database db = await instance.database;
  //   return await db.delete(table5);
  // }

  Future<List<Map<String, dynamic>>?> queryAllRows(String tableName, {bool printResult=false}) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> results = await db.query(tableName);

    if(printResult){
      print(results);
      return null;
    } else {
      return results;
    }

  }


  // Future<void> queryAllRowsforQuizQuestions() async {
  //   Database db = await instance.database;
  //   List<Map<String, dynamic>> questions = await db.query(table);
  //
  //   print(questions);
  // }

  // Future<void> queryAllRowsforQuizAnswers() async {
  //   Database db = await instance.database;
  //   List<Map<String, dynamic>> answers = await db.query(table2);
  //
  //   print(answers);
  // }


  // Future<void> queryAllRowsforQuizScore() async {
  //   Database db = await instance.database;
  //   List<Map<String, dynamic>> quizScores = await db.query(table3);
  //
  //   print(quizScores);
  // }
  //
  // Future<void> queryAllRowsforQuestion() async {
  //   Database db = await instance.database;
  //   List<Map<String, dynamic>> questions = await db.query(table4);
  //
  //   print(questions);
  // }
  //
  // Future<void> queryAllRowsforAnswers() async {
  //   Database db = await instance.database;
  //   List<Map<String, dynamic>> answers = await db.query(table5);
  //
  //   print(answers);
  // }


  Future<List<Map<String, dynamic>>> getQuestionsAndAnswersPicked() async {
    Database db = await instance.database;
    return await db.rawQuery('''
      SELECT
        q.$columnQuestion AS question,
        a.$columnCode AS answerCode,
        a.$columnDescription AS pickedAnswer,
        a.$columnTrueFalse = 1 AS isCorrect
      FROM
        $table4 qa
        INNER JOIN $table5 ap ON qa.$columnId = ap.$columnQuesId
        INNER JOIN $table2 a ON ap.$columnId = a.$columnId2
        INNER JOIN $table q ON qa.$columnId = q.$columnId
    ''');
  }

  Future<List<Map<String, dynamic>>> queryDistinctQuizTitlesFromOnGoing() async {
    Database db = await instance.database;
    return await db.rawQuery('SELECT DISTINCT $columnQuizTitle FROM $table4');
  }

  void handleErrors(error){
    Get.snackbar("Error", "Something went wrong. Try again.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.1),
          colorText: Colors.red
        );
    print(error.toString());
  }


}

