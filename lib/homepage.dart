import 'package:app_with_tabs/controller/theme_controller.dart';
import 'package:app_with_tabs/pages/about_us.dart';
import 'package:app_with_tabs/pages/calculator.dart';
import 'package:app_with_tabs/pages/home.dart';
import 'package:app_with_tabs/pages/login_gateway.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}



class _HomePageState extends State<HomePage> {
  final ThemeController themeController = Get.find();
  bool newValue = false;

  int selectedTab = 0;
  void navigateTabs(int index){
    setState(() {
      selectedTab = index;
    });
  }

  final List<Widget> pages = [
    const Home(),
    const Calculator(),
    const LoginGateway(),
    const AboutUs()  
  ];

  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      drawer: Drawer(     
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green[400],
              ),
              child: const Center(child: Text('IPSUM-TAB', style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold))),
            ),
            ListTile(
              selectedTileColor: Colors.grey[300],
              selectedColor: Colors.green[400],
              title: const Text('Home'),
              trailing: const Icon(Icons.home),              
              selected: selectedTab == 0,
              onTap: (){
                navigateTabs(0);
                Navigator.pop(context);
              }
            ),
            ListTile(
              selectedTileColor: Colors.grey[300],
              selectedColor: Colors.green[400],              
              title: const Text('Calculator'),
              trailing: const Icon(Icons.calculate),
              selected: selectedTab == 1,
              onTap: (){
                navigateTabs(1);
                Navigator.pop(context);
              }
            ),
            ListTile(
              selectedTileColor: Colors.grey[300],
              selectedColor: Colors.green[400],              
              title: const Text('Login/Register'),
              trailing: const Icon(Icons.login),
              selected: selectedTab == 2,
              onTap: (){
                navigateTabs(2);
                Navigator.pop(context);
              }
            ),            
            ListTile(
              selectedTileColor: Colors.grey[300],
              selectedColor: Colors.green[400],              
              title: const Text('About Us'),
              trailing: const Icon(Icons.info),
              selected: selectedTab == 3,
              onTap: (){
                navigateTabs(3);
                Navigator.pop(context);
              }
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Switch(
                  activeColor: Colors.green[400],
                  inactiveThumbColor: Colors.white,
                  value: themeController.currentTheme.value.brightness == Brightness.light,
                  // value: newValue,
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
                )
              )
            ),
          ],
        ),
      
      ),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black, weight: 30.0),
        title: const Text('IPSUM-TAB', 
        style:TextStyle(color: Colors.white)), 
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.white,
      ),
      body: pages[selectedTab],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.green[400],
        unselectedItemColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
        currentIndex: selectedTab,
        onTap: navigateTabs,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Calculator'),
          BottomNavigationBarItem(icon: Icon(Icons.login), label: 'Login'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'About Us'),
        ]),
    );
  }
}
