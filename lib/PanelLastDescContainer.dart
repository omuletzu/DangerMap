import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dangermap/PanelNothingToShow.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'Pair.dart';
import 'SimpleMap.dart';

class PanelLastDescContainer extends StatefulWidget{

  final double width;
  final double height;
  String selectedValue;
  final List<String> items;
  final TextEditingController descriptionController;
  final Pair<String, int> selectedDanger;
  void Function(LatLng, int, int, bool) addMarker;
  LatLng position;
  void Function(Widget) setStatePanelContainer;
  void Function(bool) setPinningLocationOnOff;
  final String currentCity;
  Map<String, Map<String, dynamic>> markersFetchedData;

  PanelLastDescContainer({
    required this.width,
    required this.height,
    required this.selectedValue,
    required this.items,
    required this.descriptionController,
    required this.selectedDanger,
    required this.addMarker,
    required this.position,
    required this.setStatePanelContainer,
    required this.setPinningLocationOnOff,
    required this.currentCity,
    required this.markersFetchedData
  });

  @override
  _PanelLastDescContainer createState() => _PanelLastDescContainer();
}

class _PanelLastDescContainer extends State<PanelLastDescContainer>{

  @override
  Widget build(BuildContext context){
    
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    children: [
                          Padding(padding: EdgeInsets.all(10),
                            child: Text(
                                'Radius type',
                                style: GoogleFonts.roboto(
                                textStyle: TextStyle(
                                  fontSize: widget.width * 0.05,
                                  color: Color.fromARGB(255, 252, 255, 255),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          Padding(padding: EdgeInsets.all(10),
                            child: DropdownButton(dropdownColor: Colors.transparent, items: widget.items.map((String str) {
                              return DropdownMenuItem(value: str, child: Text(str));
                            }).toList(), 

                              style: TextStyle(
                                fontSize: widget.width * 0.05,
                                color: Color.fromARGB(255, 252, 255, 255),
                                fontWeight: FontWeight.bold,
                              ),

                              onChanged: (String? value) {
                                setState(() {
                                  widget.selectedValue = value ?? '1';
                                });
                              },

                              value: widget.selectedValue
                            )
                          ),
                    ],
                  ),
                ),

                Expanded(
                  child: IconButton(onPressed: () {

                      String description = widget.descriptionController.text;
                      int radiusType = int.parse(widget.selectedValue);

                      widget.addMarker(widget.position, widget.selectedDanger.second, radiusType, true);
                      widget.setStatePanelContainer(PanelNothingToShow(width: widget.width));
                      widget.setPinningLocationOnOff(false);
                      
                      _addDangerInFirebase(widget.position, widget.selectedDanger.second, radiusType, widget.markersFetchedData);
                    },
                    
                    icon: Icon(Icons.check, color: Color.fromARGB(255, 252, 255, 255), size: widget.width * 0.1)
                  ),
                )
              ],
            ),

            SizedBox(height: 5),

            Padding(padding: EdgeInsets.all(10),
              child: Container(
                height: widget.height * 0.25,
                child: TextField(
                    controller: widget.descriptionController,
                    expands: true,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: 'Danger description',
                      prefixIcon: Icon(Icons.info),
                      prefixIconColor: Colors.white,
                      labelStyle: TextStyle(
                        fontSize: widget.width * 0.05,
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
                      fontSize: widget.width * 0.05,
                      color: Color.fromARGB(255, 252, 255, 255),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _addDangerInFirebase(LatLng position, int selectedDangerType, int radiusType, Map<String, Map<String, dynamic>> markersFetchedData) async {

    String latitude = position.latitude.toString().replaceAll('.', '_');
    String longitude = position.longitude.toString().replaceAll('.', '_');
    
    String key = '${latitude}_${longitude}';

    String dangerStreet = (await SimpleMap.getUserLocName(position)).street ?? 'Error';

    Map<String, dynamic> value = {
      'selectedDangerType' : selectedDangerType,
      'radiusType' : radiusType,
      'description' : widget.descriptionController.text,
      'timeReported' : DateTime.now().toString(),
      'dangerStreet' : dangerStreet
    };

    markersFetchedData[position.toString()] = value;

    String valueJson = jsonEncode(value);

    FirebaseFirestore.instance.collection('waypoints').doc(widget.currentCity).update({
      key : valueJson
    });
  }
}


