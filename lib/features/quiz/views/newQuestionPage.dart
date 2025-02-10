import 'package:app_with_tabs/features/home/views/homepage.dart';
import 'package:app_with_tabs/features/quiz/models/question_model.dart';
import 'package:app_with_tabs/features/quiz/repositories/answer_repository.dart';
import 'package:app_with_tabs/features/quiz/repositories/question_repository.dart';
import 'package:app_with_tabs/features/quiz/models/answer_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:app_with_tabs/services/database_helper.dart';
import 'package:get/get.dart';

class NewQuestionPage extends StatefulWidget {
  const NewQuestionPage({super.key, this.quizTitle});

  final String? quizTitle;

  @override
  State<NewQuestionPage> createState() => _NewQuestionPageState();
}

class _NewQuestionPageState extends State<NewQuestionPage> {
  String _title = "";
  String _question = '';
  int _numberOfAnswers = 3;
  List<String> _answers = [''];
  List<String> _code = [''];
  List<int> _correct =[];
  List<TextEditingController> _answersControllers = [];

  final _questionController = TextEditingController(); 
  final TextEditingController _numberOfAnswersController = TextEditingController();
  final TextEditingController _quizTitleController = TextEditingController();



  final questionRep = Get.put(QuestionRepository());
  final answerRep = Get.put(AnswerRepository());

  @override
  void dispose() {
    _numberOfAnswersController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeLists();
    _quizTitleController.text = widget.quizTitle ?? "";
    _title = widget.quizTitle ?? "";
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Quiz'),
      ),
      body: 
        Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
              color: Colors.green,
              child: Column(
                children: [
                  makeInput(
                    white: true,
                    clear: false,
                    top: true,
                    center: true,
                    label: "Quiz title",
                    fieldController: _quizTitleController,
                    onChanged: (value){
                      setState(() {
                        _title = value;
                      });
                  }),
              
                  makeInput(
                    white: true,
                    fieldController: _questionController,
                    clear: true,
                    center: true,
                    label: "Question",
                    onChanged: (value){
                      setState(() {
                        _question = value;
                      });
                  }),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _numberOfAnswers + 1,
                itemBuilder: (context, index){
                  String code = String.fromCharCode(65 + index);
                  if(index == _numberOfAnswers){
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: Column(
                        children: [
                          MaterialButton(
                            color: Colors.white,
                            elevation: 0,
                            minWidth: double.infinity,
                            height: 45,
                            onPressed: () async {
                              int qId = await insertQuestion(question: _question, title: _title);
                              
                              final questionModel = QuestionModel(
                                id: qId, 
                                question: _question, 
                                quizTitle: _title
                              );
                              createQuestion(questionModel);
                              print(questionModel);
                              for (var i = 0; i < _numberOfAnswers; i++) { 
                                int aId = await insertAnswers(
                                  answer: _answers[i],
                                  code: _code[i],
                                  questionId: qId,
                                  questionTF: _correct[i]
                                );
                                final answerModel = AnswerModel(
                                  id: aId, 
                                  code: _code[i], 
                                  description: _answers[i], 
                                  questId: qId, 
                                  trueFalse: _correct[i]
                                );
                                createAnswer(answerModel);
                                
                              }
                              for (var i = 0; i < _numberOfAnswers; i++) {
                                _answersControllers[i].clear();
                              }
                              setState(() {
                                _numberOfAnswers = 3;
                              });
                            },
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                color: Colors.black,
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Text("Next question", style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            )),
                          ),
                          const SizedBox(height: 10),
                          MaterialButton(
                            color: Colors.green,
                            elevation: 0,
                            minWidth: double.infinity,
                            height: 45,
                            onPressed: () async {
                              int qId = await insertQuestion(question: _question, title: _title);
                              
                              final questionModel = QuestionModel(
                                id: qId, 
                                question: _question, 
                                quizTitle: _title
                              );
                              createQuestion(questionModel);
                              print(questionModel);
                              for (var i = 0; i < _numberOfAnswers; i++) { 
                                int aId = await insertAnswers(
                                  answer: _answers[i],
                                  code: _code[i],
                                  questionId: qId,
                                  questionTF: _correct[i]
                                );
                                final answerModel = AnswerModel(
                                  id: aId, 
                                  code: _code[i], 
                                  description: _answers[i], 
                                  questId: qId, 
                                  trueFalse: _correct[i]
                                );
                                createAnswer(answerModel);
                              }                              
                              var connectivityResult = await Connectivity().checkConnectivity();
                              if(connectivityResult != ConnectivityResult.none){
                                Get.put(AnswerRepository());
                                Get.put(QuestionRepository());
                                AnswerRepository.instance.syncAnswersWithFirestore();
                                QuestionRepository.instance.syncQuestionsWithFirestore();
                              }
                              Navigator.push(context, MaterialPageRoute(builder: (context) =>  const HomePage()));
                            },
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                color: Colors.black,
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Text("Complete Quiz", style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            )),
                          ),
                        ],
                      ),
                    );
                  }else{
                    return Column(
                      children: [
                        makeInput(
                          white: false,
                          fieldController: _answersControllers[index],
                          clear: true,
                          center: false,
                          label: "Answer $code",
                          onChanged: (value){
                            _answers[index] = value;
                            _code[index] = code;
                          }
                        ),
                      RadioListTile(
                        value: 1, 
                        groupValue: _correct[index],
                        onChanged: (value){
                          setState(() {
                            _correct[index] = value!;
                          });
                        },
                          title: const Text("True"),
                        ),
                        RadioListTile(
                          activeColor: Colors.green,
                          value: 0, 
                          groupValue: _correct[index],
                          onChanged: (value){
                            setState(() {
                              _correct[index] = value!;
                            });
                          },
                          title: const Text("False"),
                        ),
                      ],
                    );
                  }
                }
              ),
            ),
          ],
        ),
    );
  }


  Widget makeInput({label, onChanged, center, clear, top,TextEditingController? fieldController, white}) {
    return Column(
      crossAxisAlignment: center? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: white? Colors.white: Colors.black,
        ),),
        const SizedBox(height: 5,),
        SizedBox(
          width: 350,
          child: TextField(
            style: const TextStyle(color: Colors.black),
            controller: clear || top? fieldController : null,
            onChanged: onChanged,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color.fromRGBO(189, 189, 189, 1))  
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Color.fromRGBO(189, 189, 189, 1))  
              ),  
              filled: true,
              fillColor: Colors.white
            ),
          ),
        ),
        const SizedBox(height: 20,),
      ],
    );
  }

  void _initializeLists() {
    _answers = List<String>.filled(_numberOfAnswers, '');
    _code = List<String>.generate(_numberOfAnswers, (index) => String.fromCharCode(65 + index));
    _correct = List<int>.filled(_numberOfAnswers, 0);
    _answersControllers = List.generate(_numberOfAnswers, (index) => TextEditingController());

  }

  Future<int> insertQuestion({question, title}) async{

    Map<String, dynamic> questions = {
      DatabaseHelper.columnQuestion: question,
      DatabaseHelper.columnQuizTitle: title
    };

    int Qid = await DatabaseHelper.instance.insert('questions', questions);
    print('Inserted question id: $Qid');
    print('Inserted question from quiz: $title');
    return Qid;
  }

  Future<int> insertAnswers({answer, code, questionId, questionTF}) async{

    Map<String, dynamic> answers = {
      DatabaseHelper.columnCode: code,
      DatabaseHelper.columnDescription: answer,
      DatabaseHelper.columnQuesId: questionId,
      DatabaseHelper.columnTrueFalse: questionTF
    };

    int id = await DatabaseHelper.instance.insert('answers', answers);
    print('Inserted answer id: $id');
    print('Inserted answer code: $code');
    print('Inserted answer description: $answer');
    print('Inserted answer question_id: $questionId');
    print('Inserted answer trueOrNot: $questionTF');
    return id;
  }

  Future<void> createQuestion(QuestionModel qModel) async {
     await questionRep.createQuestion(qModel);
  }

  Future<void> createAnswer(AnswerModel aModel) async{
    await answerRep.createAnswer(aModel);
  }

}