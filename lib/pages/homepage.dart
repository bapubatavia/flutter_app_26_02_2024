import 'package:app_with_tabs/controller/authentication_controller.dart';
import 'package:app_with_tabs/controller/theme_controller.dart';
import 'package:app_with_tabs/database_helper.dart';
import 'package:app_with_tabs/pages/about_us.dart';
import 'package:app_with_tabs/pages/admin_quiz_main_page.dart';
import 'package:app_with_tabs/pages/calculator.dart';
import 'package:app_with_tabs/pages/contacts.dart';
import 'package:app_with_tabs/pages/home.dart';
import 'package:app_with_tabs/pages/home_location.dart';
import 'package:app_with_tabs/pages/login_gateway.dart';
import 'package:app_with_tabs/pages/user_quiz_main_page.dart';
import 'package:app_with_tabs/repository/answer_repository.dart';
import 'package:app_with_tabs/repository/question_repository.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState(){
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) { 
      if(!isAllowed){
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    triggerNotification();
    super.initState();
  }

  final ThemeController themeController = Get.find();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthController authController = AuthController();

  void _signOut() async {
    authController.checkUserRole();
    if(authController.isAdmin()){
      try {
        Get.put(AnswerRepository());
        Get.put(QuestionRepository());
        await AnswerRepository.instance.syncAnswersWithFirestore();
        await QuestionRepository.instance.syncQuestionsWithFirestore();
        await _auth.signOut();
        Navigator.push(context, MaterialPageRoute(builder: (context) =>  const LoginGateway()));
      } catch(e) {
        print('Error signing out: $e');
      }
    }else{
        await _auth.signOut();
        Navigator.push(context, MaterialPageRoute(builder: (context) =>  const LoginGateway()));
    }
  }

  int selectedTab = 0;

  final List<String> tabTitles = ['Home', 'Calculator', 'Quiz', 'Contacts', 'Home Location', 'About Us'];

  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      drawer: Drawer(     
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF66BB6A),
              ),
              child: Center(child: Text('IPSUM-TAB', style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold))),
            ),
            for (int index = 0; index < tabTitles.length; index++)
              ListTile(
                selectedTileColor: Colors.grey[300],
                selectedColor: Colors.green[400],
                title: Text(tabTitles[index]),
                trailing: icons[index],              
                selected: selectedTab == index,
                onTap: () {
                  setState(() {
                    selectedTab = index;
                  });
                  Navigator.pop(context);
                }
              ),
            Expanded(
              child: Container(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Switch(
                      activeColor: Colors.green[400],
                      inactiveThumbColor: Colors.white,
                      value: themeController.currentTheme.value.brightness == Brightness.light,
                      onChanged: (value){
                        setState(() {
                          if(value){
                            value = false;
                          } else{
                            value = true;
                          }                  
                        });
                        themeController.toggleTheme();
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: MaterialButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          side: const BorderSide(
                            color: Colors.black,
                          ),
                        ),
                        onPressed: () {
                          _signOut();
                        },
                        child: const Text('Log Out', style: TextStyle(color: Colors.black)),
                      ),
                    ),
                  ],
                ),
              )
            )
          ],
      ),
    ),
    appBar: AppBar(
      iconTheme: IconThemeData(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black, weight: 30.0),
      title: Text(tabTitles[selectedTab], style: const TextStyle(color: Colors.white)), 
      centerTitle: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.white,
    ),
    body: _buildBody(selectedTab),
    bottomNavigationBar: BottomNavigationBar(
      selectedItemColor: Colors.green[400],
      unselectedItemColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
      currentIndex: selectedTab,
      onTap: (index) {
          setState(() {
            selectedTab = index;
          });
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Calculator'),
        BottomNavigationBarItem(icon: Icon(Icons.question_mark), label: 'Quiz'),
        BottomNavigationBarItem(icon: Icon(Icons.contact_phone), label: 'Contacts'),
        BottomNavigationBarItem(icon: Icon(Icons.location_on_outlined), label: 'My Home'),
        BottomNavigationBarItem(icon: Icon(Icons.info), label: 'About Us'),
      ],
    ),
  );
}

  List<Icon> icons = [const Icon(Icons.home), const Icon(Icons.calculate), const Icon(Icons.question_mark), const Icon(Icons.contact_phone), const Icon(Icons.location_on_outlined), const Icon(Icons.info)];
  Widget _buildBody(int index) {
    switch (index) {
      case 0:
        return const Home();
      case 1:
        return const Calculator();
      case 2:
        authController.checkUserRole();
        return authController.isAdmin() ? const AdminQuizMainPage() : UserQuizMainPage();
      case 3:
        return const ContactPage();
      case 4:
        return const MyHomeLocation();
      case 5:
        return const AboutUs();  
      default:
        return Container();
    }
  }
  
  Future<void> triggerNotification() async {
    List<String> titles = await DatabaseHelper.instance.getQuizTitles();

    if(titles.isNotEmpty){
      List<String> filteredTitles = [];
      for (var title in titles) {
        bool isInDb = await DatabaseHelper.instance.quizTitleNotInDb(title, 'questionsAnswered');
        if (isInDb) {
          filteredTitles.add(title);
        }
      }

      if(filteredTitles.isNotEmpty){
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 10, 
            channelKey: 'basic_channel',
            title: 'Quizzes available',
            body: "🚀 Exciting news! New quizzes have just landed in the game! 🎉 Put your skills to the test and discover fresh challenges waiting for you! 🔍 Don't miss out - jump back in now! 🎮 #NewQuizzes #ChallengeAccepted",
          )
        );
      }else{
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 10, 
            channelKey: 'basic_channel',
            title: 'Quizzes available',
            body: "🎮 Don't miss out on the fun! Dive back into the game and challenge yourself with our exciting quizzes! 🧠 Test your knowledge and earn rewards now! 🏆 #GameOn #TriviaTime",
          )
        );        
      }
    }
  }

}
