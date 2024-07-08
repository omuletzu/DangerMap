import 'package:dangermap/SignMethod.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget{
  @override
  _SplashScreen createState() => _SplashScreen();
}

class _SplashScreen extends State<SplashScreen>{

  @override
  void initState() {
    super.initState();
    _delayTime();
  }

  _delayTime() async {
    await Future.delayed(const Duration(seconds: 3));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignMethod())
    );
  }

  @override 
  Widget build(BuildContext context){

    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/attention.png',
              width: width * 0.75,
              height: height * 0.75),

              Text(
                'DangerMap',
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  textStyle: TextStyle(
                    fontSize: width * 0.1,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Text(
                '©Copyright omuletzu',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: width * 0.04
                ),
              )
          ],
        ),
      )
    );
  }
}