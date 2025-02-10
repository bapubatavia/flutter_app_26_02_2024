import 'package:app_with_tabs/theme/themes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  Rx<ThemeData> currentTheme = MyThemes.lightTheme.obs;
  final String _themeKey = 'selected_theme';

  @override
  void onInit() {
    super.onInit();
    // Load the selected theme from shared preferences when the controller is initialized
    loadTheme();
  }

  void toggleTheme() {
    currentTheme.value =
        currentTheme.value == MyThemes.lightTheme ? MyThemes.darkTheme : MyThemes.lightTheme;
    // Save the selected theme to shared preferences
    saveTheme();
  }

  Future<void> saveTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, currentTheme.value == MyThemes.darkTheme);
  }

  Future<void> loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isDarkTheme = prefs.getBool(_themeKey) ?? false;
    currentTheme.value = isDarkTheme ? MyThemes.darkTheme : MyThemes.lightTheme;
  }
}