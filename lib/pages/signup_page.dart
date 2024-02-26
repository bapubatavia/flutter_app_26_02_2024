import 'package:app_with_tabs/pages/login_page.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          }, 
          icon: Icon(Icons.arrow_back_ios, size: 25, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,)
          ),
      ),
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    const Column(
                      children: <Widget>[
                        Text('Sign Up', style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        ),), 
                        SizedBox(height: 20,),
                        Text("Create an account, it's free", style: TextStyle(
                          fontSize: 15,
                        ),),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        children: <Widget>[
                          makeInput(label: "Email"),
                          makeInput(label: "Password", obscureText: true),
                          makeInput(label: "Confirm Password", obscureText: true)
                        ]),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: MaterialButton(
                        color: Colors.green[400],
                        elevation: 0,
                        minWidth: double.infinity,
                        height: 60,
                        onPressed: () {},
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
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text("Already have an account?"),
                        InkWell(
                          child: const Text(
                            " Login", 
                            style: TextStyle( 
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                          ),),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) =>  const LoginPage()));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          )
        ),
      )
    );
  }

  Widget makeInput({label, obscureText = false}) {
    return Column(
      children: <Widget>[
        Text(label, style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),),
        const SizedBox(height: 5,),
        TextField(
          obscureText: obscureText,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color.fromRGBO(189, 189, 189, 1))  
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Color.fromRGBO(189, 189, 189, 1))  
            ),            
          ),
        ),
        const SizedBox(height: 30,),
      ],
    );
  }
}