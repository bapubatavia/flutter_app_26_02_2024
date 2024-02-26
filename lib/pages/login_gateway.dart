import 'package:app_with_tabs/pages/login_page.dart';
import 'package:app_with_tabs/pages/signup_page.dart';
import 'package:flutter/material.dart';

class LoginGateway extends StatelessWidget {
  const LoginGateway({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 30, horizontal: 50),
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Column(
                children: <Widget>[
                  const Text("Welcome", style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),),
                  const SizedBox(height: 20,),
                  Text("Identity authentication enables you to have access to more features.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 15,
                  ),),
                ],
              ),
              Container(
                height: MediaQuery.of(context).size.height / 3,
                decoration: const BoxDecoration(
                  image: DecorationImage(image: AssetImage('assets/img/login.png')),
                ),
              ),
              Column(
                children: <Widget>[
                  MaterialButton(
                    minWidth: double.infinity,
                    height: 60,
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) =>  LoginPage()));
                    },
                    shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      color: Colors.black,
                    ),
                    borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Text("Login", style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    )),
                  ),
                  const SizedBox(height: 20),
                  MaterialButton(
                    color: Colors.green[400],
                    elevation: 0,
                    minWidth: double.infinity,
                    height: 60,
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) =>  SignupPage()));
                    },
                    shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      color: Colors.black,
                    ),
                    borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Text("Sign Up", style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    )),
                  ),                  
                ],
              )
            ],
          )
        ), 
      ),
    );
  }
}