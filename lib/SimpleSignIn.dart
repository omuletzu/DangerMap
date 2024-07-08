import 'package:dangermap/SimpleSignUp.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dangermap/SimpleMap.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SimpleSignIn extends StatefulWidget{

  const SimpleSignIn({super.key});

  @override
  _SimpleSignIn createState() => _SimpleSignIn();
}

class _SimpleSignIn extends State<SimpleSignIn>{

  final TextEditingController _controllerMail = TextEditingController();
  final TextEditingController _controllerPass = TextEditingController(); 

  String warningMsg = '';

  @override
  void initState(){
    super.initState();
    _checkCurrentUser();
  }

  void _checkCurrentUser() async {

    if(FirebaseAuth.instance.currentUser != null){

      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

      bool flagSimpleSigned = sharedPreferences.getBool('simpleSigned') ?? false;

      if(flagSimpleSigned){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SimpleMap(userFlag: false)));
      }
      else{
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context){

    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color.fromARGB(255, 58, 64, 78), Color.fromARGB(255, 59, 65, 79)])
            ),

            child: Center(
              child: Padding(padding: EdgeInsets.only(top: height * 0.15, left: width * 0.1, right: width * 0.1),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: const [Color.fromARGB(255, 58, 64, 78), Color.fromARGB(255, 59, 65, 79)]
                    ),
                  ),

                  child: Column( 
                    children: [
                      RichText(
                        text: TextSpan(
                              text: 'Simple\n',
                              style: GoogleFonts.roboto(
                              textStyle: TextStyle(
                              fontSize: width * 0.1,
                              color: Color.fromARGB(255, 252, 255, 255),
                            ),
                          ),

                          children: <TextSpan>[
                            TextSpan(
                                  text: 'Sign-In',
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

                      SizedBox(height: height * 0.05),

                      TextField(
                        controller: _controllerMail,
                        decoration: InputDecoration(
                          labelText: 'E-mail',
                          prefixIcon: Icon(Icons.mail),
                          prefixIconColor: Colors.white,
                          labelStyle: TextStyle(
                            fontSize: width * 0.05,
                            color: Color.fromARGB(184, 189, 200, 255),
                            fontWeight: FontWeight.bold
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)
                          ),

                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Color.fromARGB(255, 255, 184, 45))
                          )
                        ),
                        style: GoogleFonts.roboto(
                            textStyle: TextStyle(
                            fontSize: width * 0.05,
                            color: Color.fromARGB(255, 252, 255, 255),
                          ),
                        ),
                      ),

                      SizedBox(height: height * 0.05),

                      TextField(
                        controller: _controllerPass,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          prefixIconColor: Colors.white,
                          labelStyle: TextStyle(
                            fontSize: width * 0.05,
                            color: Color.fromARGB(184, 189, 200, 255),
                            fontWeight: FontWeight.bold
                          ),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)
                          ),

                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Color.fromARGB(255, 255, 184, 45))
                          )
                        ),

                        style: GoogleFonts.roboto(
                            textStyle: TextStyle(
                            fontSize: width * 0.05,
                            color: Color.fromARGB(255, 252, 255, 255),
                          ),
                        ),
                      ),

                      SizedBox(height: height * 0.025),

                      Text(warningMsg, style: GoogleFonts.roboto(
                            textStyle: TextStyle(
                            fontSize: width * 0.04,
                            color: Color.fromARGB(255, 255, 87, 87),
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),

                      SizedBox(height: height * 0.05),

                      ElevatedButton(onPressed: () => _signUserIn(_controllerMail.text.toString(), _controllerPass.text.toString()), 

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
                          Padding(padding: EdgeInsets.all(10),
                          child: Text('Sign In', style: GoogleFonts.roboto(
                                  textStyle: TextStyle(
                                  fontSize: width * 0.075,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                          )
                      ),

                      SizedBox(height: height * 0.05),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Don\'t have an account?', style: GoogleFonts.roboto(
                                textStyle: TextStyle(
                                fontSize: width * 0.04,
                                color: Color.fromARGB(255, 252, 255, 255),
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),

                          TextButton(onPressed: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const SimpleSignUp())
                              ),
                              child: Text('Sign up', style: GoogleFonts.roboto(
                                  textStyle: TextStyle(
                                  fontSize: width * 0.04,
                                  color: Color.fromARGB(184, 189, 200, 255),
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                )
              ),
            )
          )
      ),
    );
  }

  void _signUserIn(String mail, String password) async {

    if(mail.isEmpty){
      setState(() {
        warningMsg = 'Empty mail';
      });
    }
    else if(password.isEmpty){
      setState(() {
        warningMsg = 'Empty password';
      });
    }
    else{
      
      try{
        
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: mail, password: password);

        setState(() {
          warningMsg = 'Succesfully signed-in';
        });

        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        
        sharedPreferences.setBool('simpleSigned', true);

        Fluttertoast.showToast(msg: 'Succesfully signed-in');

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SimpleMap(userFlag: false)));

      } on FirebaseAuthException catch(e){
        if(e == 'user_not_found'){
          setState(() {
            warningMsg = 'Wrong mail or password';
          });

          Fluttertoast.showToast(msg: 'Wrong mail or password');
        }
        else{
          setState(() {
            warningMsg = 'An error occured';
          });

          Fluttertoast.showToast(msg: 'An error occured');
        }
      }
    }
  }
}