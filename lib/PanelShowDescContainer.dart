import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PanelShowDescContainer extends StatefulWidget{

  final bool userFlag;
  final double width;
  final Map<String, dynamic> marker;
  final String markerId;
  String firebaseIdentifier;
  final List<String> possibleDangers;
  void Function(String, String) deleteMarker;

  PanelShowDescContainer({
    required this.userFlag,
    required this.width,
    required this.marker,
    required this.markerId,
    required this.firebaseIdentifier,
    required this.possibleDangers,
    required this.deleteMarker
  });

  @override
  _PanelShowDescContainer createState() => _PanelShowDescContainer();
}

class _PanelShowDescContainer extends State<PanelShowDescContainer>{

  @override
  Widget build(BuildContext context){

    String emergencyLvlTranslated = '';
    String description = 'No description';

    switch(widget.marker['radiusType']){
      case 1 : emergencyLvlTranslated = 'Low';
      case 2 : emergencyLvlTranslated = 'Medium';
      case 3 : emergencyLvlTranslated = 'High';
      case 4 : emergencyLvlTranslated = 'Extreme';
    }

    if(widget.marker['description'].isEmpty){
      description = 'No description';
    }

    return SingleChildScrollView(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Padding(padding: EdgeInsets.all(widget.width * 0.1),
                  child: Icon(Icons.dangerous, color: Color.fromARGB(255, 252, 255, 255)),
                ),

                Expanded(
                  child: Text(
                    widget.possibleDangers[widget.marker['selectedDangerType']],
                      style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                          fontSize: widget.width * 0.05,
                          color: Color.fromARGB(255, 252, 255, 255),
                        ),
                      ),
                  ),
                )
              ],
            ),

            Row(
              children: [
                Padding(padding: EdgeInsets.all(widget.width * 0.1),
                  child: Icon(Icons.roundabout_left, color: Color.fromARGB(255, 252, 255, 255)),
                ),

                Expanded(
                  child: Text(
                    widget.marker['dangerStreet'],
                      style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                          fontSize: widget.width * 0.05,
                          color: Color.fromARGB(255, 252, 255, 255),
                        ),
                      ),
                  ),
                )
              ],
            ),

            Row(
              children: [
                Padding(padding: EdgeInsets.all(widget.width * 0.1),
                  child: Icon(Icons.timer, color: Color.fromARGB(255, 252, 255, 255)),
                ),

                Expanded(
                  child: Text(
                    widget.marker['timeReported'],
                      style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                          fontSize: widget.width * 0.05,
                          color: Color.fromARGB(255, 252, 255, 255),
                        ),
                      ),
                  ),
                )
              ],
            ),

            Row(
              children: [
                Padding(padding: EdgeInsets.all(widget.width * 0.1),
                  child: Icon(Icons.emergency, color: Color.fromARGB(255, 252, 255, 255)),
                ),

                Expanded(
                  child: Text(
                      emergencyLvlTranslated,
                      style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                          fontSize: widget.width * 0.05,
                          color: Color.fromARGB(255, 252, 255, 255),
                        ),
                      ),
                  ),
                )
              ],
            ),

            Row(
              children: [
                Padding(padding: EdgeInsets.all(widget.width * 0.1),
                  child: Icon(Icons.description, color: Color.fromARGB(255, 252, 255, 255)),
                ),

                Expanded(
                  child: Text(
                    description,
                      style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                          fontSize: widget.width * 0.05,
                          color: Color.fromARGB(255, 252, 255, 255),
                        ),
                      ),
                  ),
                )
              ],
            ),

            widget.userFlag ? Padding(padding: EdgeInsets.all(15),
              child: ElevatedButton(onPressed: () {

                widget.firebaseIdentifier = widget.firebaseIdentifier.replaceAll('.', '_');
                widget.deleteMarker(widget.markerId, widget.firebaseIdentifier);

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

                child: 
                  Padding(padding: EdgeInsets.all(10),
                  child: Text('Delete', style: GoogleFonts.roboto(
                          textStyle: TextStyle(
                          fontSize: widget.width * 0.05,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  )
              ),
            ) : Container()
          ],
        ),
      ),
    );
  }
}