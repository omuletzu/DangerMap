import 'package:dangermap/SimpleSignIn.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SimpleSignUp extends StatefulWidget{

  const SimpleSignUp({super.key});

  @override
  _SimpleSignUp createState() => _SimpleSignUp();
}

class _SimpleSignUp extends State<SimpleSignUp>{

  final TextEditingController _controllerMail = TextEditingController();
  final TextEditingController _controllerPass = TextEditingController(); 
  final TextEditingController _controllerPassConf = TextEditingController();

  String warningMsg = '';

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
                                  text: 'Sign-Up',
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

                      SizedBox(height: height * 0.05),

                      TextField(
                        controller: _controllerPassConf,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Confirm password',
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

                      ElevatedButton(onPressed: () => _signUserIn(_controllerMail.text.toString(), _controllerPass.text.toString(), _controllerPassConf.text.toString()), 

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
                          child: Text('Sign Up', style: GoogleFonts.roboto(
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
                          Text('Already have an account?', style: GoogleFonts.roboto(
                                textStyle: TextStyle(
                                fontSize: width * 0.04,
                                color: Color.fromARGB(255, 252, 255, 255),
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),

                          TextButton(onPressed: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const SimpleSignIn())
                              ),
                              child: Text('Sign in', style: GoogleFonts.roboto(
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

  void _signUserIn(String mail, String password, String passwordConf) async {
    
    print('object');

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
    else if(password != passwordConf){
      setState(() {
        warningMsg = 'Passwords don\'t match';
      });
    }
    else{

      try{
        
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: mail, password: password);

        setState(() {
          warningMsg = 'Succesfully signed-up';
        });

        Fluttertoast.showToast(msg: 'Succesfully signed-up');

        Navigator.push(context, MaterialPageRoute(builder: (context) => SimpleSignIn()));

      } on FirebaseAuthException catch(e){

        print(e);

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