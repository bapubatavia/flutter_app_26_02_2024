import 'package:flutter/material.dart';


class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  State<Calculator> createState() => _CalculatorState();
}


class _CalculatorState extends State<Calculator> {
  int selectIndex = 0;

  void navigateBottomBar(int index){
    setState(() {
      selectIndex = index;
    });
  }

  final List<Widget> pages = [

  ];

  Widget calculatorBtn(String btntxt, Color btncolor, Color txtcolor, double fntSize) {
    return ButtonTheme(
      child: ElevatedButton(
        onPressed: (){
          calculation(btntxt);
        },

        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: btncolor,
          padding: const EdgeInsets.all(16),
        ),
        child: Text(btntxt,
          style: TextStyle(
            fontSize: fntSize,
            color: txtcolor,
          ),
        ),        
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding( 
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Column(
            mainAxisAlignment:  MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(text,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                      fontSize: 100
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment:  MainAxisAlignment.spaceEvenly,
                children: [
                  calculatorBtn('AC', Colors.grey, Colors.white, 28),
                  calculatorBtn('⌫', Colors.grey, Colors.white, 32),
                  calculatorBtn('%', Colors.grey, Colors.white, 35),
                  calculatorBtn('/', (Colors.green[400])!, Colors.white, 35),
                ],
              ),
              const SizedBox(height: 10),
              //copy paste rows
              Row(
                mainAxisAlignment:  MainAxisAlignment.spaceEvenly,
                children: [
                  calculatorBtn('7', (Colors.grey[850])!, Colors.white, 35),
                  calculatorBtn('8', (Colors.grey[850])!, Colors.white, 35),
                  calculatorBtn('9', (Colors.grey[850])!, Colors.white, 35),
                  calculatorBtn('x', (Colors.green[400])!, Colors.white, 35),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment:  MainAxisAlignment.spaceEvenly,
                children: [
                  calculatorBtn('4', (Colors.grey[850])!, Colors.white, 35),
                  calculatorBtn('5', (Colors.grey[850])!, Colors.white, 35),
                  calculatorBtn('6', (Colors.grey[850])!, Colors.white, 35),
                  calculatorBtn('-', (Colors.green[400])!, Colors.white, 35),
                ],
              ),
              const SizedBox(height: 10),  
              Row(
                mainAxisAlignment:  MainAxisAlignment.spaceEvenly,
                children: [
                  calculatorBtn('1', (Colors.grey[850])!, Colors.white, 35),
                  calculatorBtn('2', (Colors.grey[850])!, Colors.white, 35),
                  calculatorBtn('3', (Colors.grey[850])!, Colors.white, 35),
                  calculatorBtn('+', (Colors.green[400])!, Colors.white, 35),
                ],
              ),
              const SizedBox(height: 10),                      
              // last row with the 0 button
              Row (
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: (){
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.fromLTRB(34, 15, 100, 15),
                      shape: const StadiumBorder(),
                      backgroundColor: (Colors.grey[850])!
                    ),
                    child: const Text("0",
                      style: TextStyle(
                        fontSize: 35,
                        color: Colors.white
                      ),
                    ),
                  ),
                  calculatorBtn('.',(Colors.grey[850])!, Colors.white, 35),
                  calculatorBtn('=',(Colors.green[400])!, Colors.white, 35),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
  
  dynamic text ='0';
  double numOne = 0;
  double numTwo = 0;

  dynamic result = '';
  dynamic finalResult = '';
  dynamic opr = '';
  dynamic prevOpr = '';
   void calculation(btnText) {


    if(btnText  == 'AC') {
      text ='0';
      numOne = 0;
      numTwo = 0;
      result = '';
      finalResult = '0';
      opr = '';
      prevOpr = '';
    
    } else if( opr == '=' && btnText == '=') {

      if(prevOpr == '+') {
         finalResult = add();
      } else if( prevOpr == '-') {
          finalResult = sub();
      } else if( prevOpr == 'x') {
          finalResult = mul();
      } else if( prevOpr == '/') {
          finalResult = div();
      } 

    } else if(btnText == '+' || btnText == '-' || btnText == 'x' || btnText == '/' || btnText == '=') {

      if(numOne == 0) {
          numOne = double.parse(result);
      } else {
        // To handle the case where numTwo might not have a decimal part
        try {
          numTwo = double.parse(result);
        } catch (e) {
          numTwo = 0; // Set to 0 if parsing fails
        }
      }
  
      if(opr == '+') {
          finalResult = add();
      } else if( opr == '-') {
          finalResult = sub();
      } else if( opr == 'x') {
          finalResult = mul();
      } else if( opr == '/') {
          finalResult = div();
      } 
      prevOpr = opr;
      opr = btnText;
      result = '';
    }
    else if(btnText == '%') {
     result = numOne / 100;
     finalResult = decimalCheck(result);
    } else if(btnText == '.') {
      if(!result.toString().contains('.')) {
        // ignore: prefer_interpolation_to_compose_strings
        result = result.toString()+'.';
      }
      finalResult = result;
    }
    
    else if (btnText == '⌫') {
      if (result.length > 1) {
        result = result.substring(0, result.length - 1);
      } else {
        result = '0';
      }
      finalResult = result;
    }
 
    
    else {
        result = result + btnText;
        finalResult = result;        
    }


    setState(() {
          text = finalResult;
        });

  }


  String add() {
         result = (numOne + numTwo).toString();
         numOne = double.parse(result);           
         return decimalCheck(result);
  }

  String sub() {
         result = (numOne - numTwo).toString();
         numOne = double.parse(result);
         return decimalCheck(result);
  }
  String mul() {
         result = (numOne * numTwo).toString();
         numOne = double.parse(result);
         return decimalCheck(result);
  }
  String div() {
          result = (numOne / numTwo).toString();
          numOne = double.parse(result);
          return decimalCheck(result);
  }


  String decimalCheck(dynamic result) {
    
    if(result.toString().contains('.')) {
        List<String> splitDecimal = result.toString().split('.');
        if(int.parse(splitDecimal[1]) == 0) {
          return result = splitDecimal[0].toString();
        }
    }
    return result; 
  }
}