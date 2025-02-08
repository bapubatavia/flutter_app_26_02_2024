import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController extends GetxController {
  RxBool isAdmin = false.obs;

  void checkUserRole() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      isAdmin.value = (user.email == "michaelvie97@gmail.com" || user.email =='mastayoda98@gmail.com');
    } else {
      print('No user signed in');
    }
  }
}
