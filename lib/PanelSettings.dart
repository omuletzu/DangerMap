import 'package:dangermap/SimpleMap.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:background_locator_2/background_locator.dart';

class PanelSettings extends StatefulWidget{

  final double width;
  final BuildContext context;

  PanelSettings({required this.width, required this.context});

  @override
  _PanelSettings createState() => _PanelSettings();
}

class _PanelSettings extends State<PanelSettings>{

  @override
  void initState(){
    super.initState();
    initOnOffNotif();
  }

  void initOnOffNotif() async {

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    setState(() {
      notificationEnable = sharedPreferences.getBool('notificationOnOff') ?? true; 
    });
  }

  bool notificationEnable = true;

  @override
  Widget build(BuildContext context){
    
    return SingleChildScrollView(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(widget.width * 0.075),
              child: Row(
                children: [
                  Expanded(
                    child: SwitchListTile(
                      title: Text(
                        'Notifications',
                        style: GoogleFonts.roboto(
                            textStyle: TextStyle(
                              fontSize: widget.width * 0.05,
                              color: Color.fromARGB(255, 252, 255, 255),
                            ),
                          )
                      ),
                      activeColor: Color.fromARGB(255, 87, 103, 255),
                      value: notificationEnable, 
                      onChanged: (bool value) async {

                        if(value == false){
                          SimpleMap.platform.invokeMethod('stopNotif');
                        }
                        else{
                          SimpleMap.platform.invokeMethod('sendNotif');
                        }

                        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                        sharedPreferences.setBool('notificationOnOff', value);

                        setState(() {
                          notificationEnable = value;
                        });
                      })
                    )
                ],
              )
            ),

            Padding(padding: EdgeInsets.all(15),
              child: ElevatedButton(onPressed: () async {

                    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                    sharedPreferences.setBool('simpleSigned', false);

                    FirebaseAuth.instance.signOut();
                    Navigator.of(widget.context).pop();
                  },

                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color.fromARGB(255, 252, 255, 255),
                    backgroundColor: Color.fromARGB(255, 33, 36, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)
                    ),
                    shadowColor: Color.fromARGB(184, 189, 200, 255),
                    elevation: 3
                  ),

                  child: Padding(padding: EdgeInsets.all(10),
                    child: Text('Log out', style: GoogleFonts.roboto(
                          textStyle: TextStyle(
                          fontSize: widget.width * 0.05,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  )
              ),
            )
          ],
        ),
      ),
    );
  }
}