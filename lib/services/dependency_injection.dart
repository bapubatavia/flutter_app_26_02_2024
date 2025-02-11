import 'package:app_with_tabs/features/network/controllers/network_controller_v2.dart';
import 'package:get/get.dart';

class DependencyInjection{

  static void init(){
    Get.put<InternetCheckBar>(InternetCheckBar(), permanent: true);
  }
}