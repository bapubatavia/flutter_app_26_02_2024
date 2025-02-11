import 'dart:async';

import 'package:app_with_tabs/features/auth/controllers/authentication_controller.dart';
import 'package:app_with_tabs/features/quiz/repositories/answer_repository.dart';
import 'package:app_with_tabs/features/quiz/repositories/question_repository.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InternetCheckBar extends GetxController {
  final Connectivity _connectivity = Connectivity();

  StreamSubscription? _connectivitySubscription;
  final AuthController authController = AuthController();

  final RxBool isConnected = true.obs;
  int count = 0;
  @override
  void onInit() {
    super.onInit();
    _initConnectivityListeners();
    authController.checkUserRole();
  }

  void _initConnectivityListeners() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> result) async {
      final hasConnection = result.isNotEmpty && result.any((r) => r == ConnectivityResult.wifi || r == ConnectivityResult.mobile);
      isConnected.value = hasConnection;
      await _checkInternetConnection();
    });
  }


  Future<void> _checkInternetConnection() async {
    if (isConnected.value) {
        count ++;
        print("count is $count");
        if(count > 1) {
          _showOnlineSnackbar();
          if (authController.isAdmin()) {
            try {
              await AnswerRepository.instance.syncAnswersWithFirestore();
              await QuestionRepository.instance.syncQuestionsWithFirestore();
            } catch (e) {
              print('Error signing out: $e');
            }
          }
        }
    } else {
      _showOfflineSnackbar();
    }
  }

  void _showOnlineSnackbar() {
    Get.closeCurrentSnackbar();
    Get.rawSnackbar(
      messageText: const Text(
        'Back online',
        style: TextStyle(
            color: Colors.white,
            fontSize: 13
        ),
      ),
      isDismissible: false,
      duration: const Duration(seconds: 5),
      backgroundColor: Colors.green[400]!,
      icon: const Icon(Icons.wifi_outlined, color: Colors.white, size: 15,),
      margin: const EdgeInsets.symmetric(vertical: 60),
      padding: const EdgeInsets.all(3),
      // margin: EdgeInsets.zero,
      snackStyle: SnackStyle.GROUNDED,
    );
  }

  void _showOfflineSnackbar() {
    Get.closeCurrentSnackbar();
    Get.rawSnackbar(
      messageText: const Text(
        'No internet connection',
        style: TextStyle(
            color: Colors.white,
            fontSize: 13
        ),
      ),
      isDismissible: false,
      duration: const Duration(days: 1),
      backgroundColor: Colors.red[400]!,
      icon: const Icon(Icons.wifi_off, color: Colors.white, size: 15,),
      margin: const EdgeInsets.symmetric(vertical: 60),
      padding: const EdgeInsets.all(3),
      snackStyle: SnackStyle.GROUNDED,
    );
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }
}

