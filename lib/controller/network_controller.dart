
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class NetworkController extends GetxController{
  final Connectivity _connectivity = Connectivity();

  @override
  void onInit(){
    super.onInit();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    
  }

  void _updateConnectionStatus(ConnectivityResult connectivityResult){
    if(connectivityResult == ConnectivityResult.none){
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
    } else{

      if(Get.isSnackbarOpen){
        Get.closeCurrentSnackbar();
      }
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
  }
}