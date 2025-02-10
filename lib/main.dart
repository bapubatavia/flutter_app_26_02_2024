import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:app_with_tabs/theme/theme_controller.dart';
import 'package:app_with_tabs/services/dependency_injection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'features/auth/views/login_gateway.dart';

Future<void> main() async{
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'basic_channel', 
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel 1',
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
