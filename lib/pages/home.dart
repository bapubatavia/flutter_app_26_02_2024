import 'package:flutter/material.dart';
import 'package:app_with_tabs/slide_items.dart';


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {


  List<Widget> slides = slideItems
  .map((item) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18.0),
    child: Column(
      children: <Widget>[
        Flexible(
          flex: 1,
          fit: FlexFit.tight,
          child: Image.asset(
            item['image'],
            fit: BoxFit.fitWidth,
            width: 220.0,
            alignment: Alignment.bottomCenter,
          )
        ),
        Flexible(
          flex: 1,
          fit: FlexFit.tight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              children: <Widget>[
                Text(item['header'],
                  style: const TextStyle(
                    fontSize: 50.0,
                    fontWeight: FontWeight.w300,
                    color: Color(0XFF3F3D56),
                    height: 2.0
                  ),
                ),
                Text(item['description'],
                  style: const TextStyle(
                    color: Colors.grey,
                    letterSpacing: 1.2,
                    fontSize: 16.0,
                    height: 1.3
                  ),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          )
        )
      ],
    ),
  )).toList();

  List<Widget> indicator() => List<Widget>.generate(
    slides.length,
    (index) => Container(
      margin: const EdgeInsets.symmetric(horizontal: 3.0),
      height: 10.0,
      width: 10.0,
      decoration: BoxDecoration(
        color: currentPage.round() == index
          ? const Color(0XFF256075)
          : const Color(0XFF256075).withOpacity(0.2),
        borderRadius: BorderRadius.circular(10.0)
      ),
    )
  );

  double currentPage = 0.0;
  final pageViewController = PageController();

  @override
  void initState() {
    super.initState();
    pageViewController.addListener(() {
      setState(() {
        currentPage = pageViewController.page!;
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          PageView.builder(
            controller: pageViewController,
            itemCount: slides.length,
            itemBuilder: (BuildContext context, int index){
              return slides[index];
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 70.0),
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: indicator(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}