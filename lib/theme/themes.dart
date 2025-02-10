import 'package:flutter/material.dart';

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