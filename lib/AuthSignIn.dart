import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dangermap/SimpleMap.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dangermap/AuthMap.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthSignIn extends StatefulWidget{

  const AuthSignIn({super.key});

  @override
  _AuthSignIn createState() => _AuthSignIn();
}

class _AuthSignIn extends State<AuthSignIn>{

  final TextEditingController _controllerID = TextEditingController();
  final TextEditingController _controllerPass = TextEditingController(); 

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
                              text: 'Authorized\n',
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
                        controller: _controllerID,
                        decoration: InputDecoration(
                          labelText: 'ID',
                          prefixIcon: Icon(Icons.data_array),
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

                      ElevatedButton(onPressed: () => _signUserIn(_controllerID.text.toString(), _controllerPass.text.toString()), 

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
                    ],
                  ),
                )
              ),
            )
          )
      ),
    );
  }

  void _signUserIn(String id, String password) async {
    
    print('object');

    if(id.isEmpty){
      setState(() {
        warningMsg = 'Empty ID';
      });
    }
    else if(password.isEmpty){
      setState(() {
        warningMsg = 'Empty password';
      });
    }
    else{
        
      List<int> bytes = utf8.encode(password);
      Digest digest = sha256.convert(bytes);
      String hash = digest.toString();

      try{
        DocumentSnapshot document = await FirebaseFirestore.instance.collection('authAcc').doc(id).get();

        if(document.exists){
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;

          if(data['passHash'] == hash){
              
            setState(() {
              warningMsg = 'Succesfully signed-in';
            });

            Fluttertoast.showToast(msg: 'Succesfully signed-in');

            Navigator.push(context, MaterialPageRoute(builder: (context) => SimpleMap(userFlag: true)));
          }
          else{
            setState(() {
              warningMsg = 'An error occured';
            });

            Fluttertoast.showToast(msg: 'An error occured');
          }
        }
      }
      on FirebaseFirestore catch(e){
        if(e == 'non_existent_document_id'){
          setState(() {
            warningMsg = 'Non-existing ID';
          });
        }
      }
    }
  }
}