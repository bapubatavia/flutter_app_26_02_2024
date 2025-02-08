import 'package:app_with_tabs/database_helper.dart';
import 'package:flutter/material.dart';

class QuizResultPage extends StatelessWidget {
  final int score;
  final int totalQuestions;

  const QuizResultPage({Key? key, required this.score, required this.totalQuestions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool aboveAverage = score >= (totalQuestions / 2);

    Widget messageWidget = aboveAverage
        ? Column(
            children: [
              const Text('Congratulations!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Image.asset('assets/img/won.png'),
            ],
          )
        : Column(
            children: [
              const Text('Failed!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Image.asset('assets/img/lost.png'), 
            ],
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Result'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              messageWidget,
              const SizedBox(height: 20),
              Text('Your Score: $score / $totalQuestions', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              MaterialButton(
                elevation: 0,
                height: 40,
                color: Colors.green,
                onPressed: () {
                  Navigator.pop(context); 
                },
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    color: Colors.black,
                    ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Text('Back to Home'),
              ),
              const SizedBox(height: 20),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: getQuestionsAndAnswersPicked(), 
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('Error loading data: ${snapshot.error}');
                  }
                  List<Map<String, dynamic>> data = snapshot.data!;
                  return Column(
                    children: data.map((entry) {
                      return ListTile(
                        title: Text(entry['question'] +"?"),
                        subtitle: Text('Your Answer: ${entry['pickedAnswer']} ${entry['isCorrect'] == 1 ? '(Correct)' : '(Incorrect)'}'),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> getQuestionsAndAnswersPicked() async {
    // Retrieve questions and answers picked from the database
    return await DatabaseHelper.instance.getQuestionsAndAnswersPicked();
  }
}
