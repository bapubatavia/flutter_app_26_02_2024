import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:app_with_tabs/controller/theme_controller.dart';
import 'package:app_with_tabs/dependency_injection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'pages/login_gateway.dart';

Future<void> main() async{
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'basic_channel', 
        channelName: 'Bsic notifications', 
        channelDescription: 'Notification channel for basic tests',
      )
    ],
    debug: true,
  );
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
  DependencyInjection.init();
}

class MyAppColors{
  static final darkMode = Colors.grey[800];
  static const lightMode = Colors.white;

}

class MyThemes{
  static final darkTheme = ThemeData(
    primaryColor: MyAppColors.darkMode,
    brightness: Brightness.dark,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.white
    ),
    iconTheme: const IconThemeData(color: Colors.white)
  );

  static final lightTheme = ThemeData(
    primaryColor: MyAppColors.lightMode,
    brightness: Brightness.light,
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.green[400]
    ),
    iconTheme: const IconThemeData(color: Colors.black)

  );
}


class MyApp extends StatelessWidget {
  MyApp({super.key});
  final ThemeController themeController = Get.put(ThemeController());

  
  @override
  Widget build(BuildContext context) {
    return Obx(() => GetMaterialApp(
      theme: themeController.currentTheme.value,
      home: const LoginGateway(),
      debugShowCheckedModeBanner: false,
    ));
  }
}
