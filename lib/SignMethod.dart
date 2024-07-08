import 'package:dangermap/AuthSignIn.dart';
import 'package:dangermap/SimpleSignIn.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

class SignMethod extends StatelessWidget{

  const SignMethod({super.key});

  @override 
  Widget build(BuildContext context){

    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return MaterialApp(
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color.fromARGB(255, 58, 64, 78), Color.fromARGB(255, 59, 65, 79)])
            ),

            child: Center(
              child: Padding(padding: EdgeInsets.only(top: height * 0.15, left: width * 0.1, right: width * 0.1),
                child: Column(
                  children: [
                    RichText(
                        text: TextSpan(
                              text: 'You\n',
                              style: GoogleFonts.roboto(
                              textStyle: TextStyle(
                              fontSize: width * 0.1,
                              color: Color.fromARGB(255, 252, 255, 255),
                            ),
                          ),

                          children: <TextSpan>[
                            TextSpan(
                                  text: 'are signing as',
                                  style: GoogleFonts.roboto(
                                  textStyle: TextStyle(
                                  fontSize: width * 0.1,
                                  color: Color.fromARGB(255, 252, 255, 255),
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            )
                          ]
                        ),
                      ),

                    SizedBox(height: height * 0.075),

                    ElevatedButton(onPressed: () => _checkPermissionAndContinue(true, context), 

                        style: ElevatedButton.styleFrom(
                          foregroundColor: Color.fromARGB(255, 252, 255, 255),
                          backgroundColor: Color.fromARGB(255, 33, 36, 45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)
                          ),
                          shadowColor: Color.fromARGB(184, 189, 200, 255),
                          elevation: 3
                        ),
      
                        child: 
                          Column(
                            
                            children: [

                              Padding(padding: EdgeInsets.all(10),
                                child: Icon(Icons.key_rounded, size: width * 0.2)
                              ),

                              Padding(padding: EdgeInsets.all(10),
                              child: Text('An authorized person', style: GoogleFonts.roboto(
                                      textStyle: TextStyle(
                                      fontSize: width * 0.06,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      ),

                      SizedBox(height: height * 0.075),

                      ElevatedButton(onPressed: () => _checkPermissionAndContinue(false, context), 

                        style: ElevatedButton.styleFrom(
                          foregroundColor: Color.fromARGB(255, 252, 255, 255),
                          backgroundColor: Color.fromARGB(255, 33, 36, 45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)
                          ),
                          shadowColor: Color.fromARGB(184, 189, 200, 255),
                          elevation: 3
                        ),
      
                        child: 
                          Column(
                            children: [

                              Padding(padding: EdgeInsets.all(10),
                                child: Icon(Icons.key_off_rounded, size: width * 0.2)
                              ),

                              Padding(padding: EdgeInsets.all(10),
                              child: Text('A simple person', style: GoogleFonts.roboto(
                                      textStyle: TextStyle(
                                      fontSize: width * 0.06,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      ),
                  ],
                ),
              ),
            ),
        ),
      ),
    );
  }

  void _checkPermissionAndContinue(bool userFlag, BuildContext context) async {

    final double width = MediaQuery.of(context).size.width;

    PermissionStatus status = await Permission.location.status;
    
    if(status == PermissionStatus.denied){
      
      status = await Permission.location.request();

      if(status == PermissionStatus.denied){

        showDialog(
          context: context, 
          builder: (BuildContext context) => AlertDialog(
            title: Text(
              'Location permission',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                textStyle: TextStyle(
                  fontSize: width * 0.05,
                  color: Color.fromARGB(255, 59, 65, 79),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            content: Text(
              'Please grant permission for location',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                textStyle: TextStyle(
                  fontSize: width * 0.025,
                  color: Color.fromARGB(255, 59, 65, 79),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            actions: [
              TextButton(onPressed: () {
                Navigator.of(context).pop();
              }, child: Text('OK'))
            ],
          )
        );
      }
    }

    if(status == PermissionStatus.granted){
      if(userFlag){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AuthSignIn())
        );
      }
      else{
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SimpleSignIn())
        );
      }
    }
  }
}