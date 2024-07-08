import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'SimpleMap.dart';
import 'Pair.dart';
import 'PanelLastDescContainer.dart';

class PanelSearchContainer extends StatefulWidget{

  final double width;
  final double height;
  String selectedValue;
  final List<String> items;
  final TextEditingController descriptionController;
  List<String> possibleDangers;
  List<Pair<String, int>> filteredDangers;
  final TextEditingController controller;
  int itemCount;
  Widget panelContainer;
  void Function(Widget) setStatePanelContainer;
  void Function(LatLng, int, int, bool) addMarker;
  LatLng position;
  void Function(bool) setPinningLocationOnOff;
  final String currentCity;
  Map<String, Map<String, dynamic>> markersFetchedData;

  PanelSearchContainer({
    required this.width,
    required this.height,
    required this.selectedValue,
    required this.items,
    required this.descriptionController,
    required this.possibleDangers,
    required this.filteredDangers,
    required this.controller,
    required this.itemCount,
    required this.panelContainer,
    required this.setStatePanelContainer,
    required this.addMarker,
    required this.position,
    required this.setPinningLocationOnOff,
    required this.currentCity,
    required this.markersFetchedData
  });

  @override
  _PanelSearchContainer createState() => _PanelSearchContainer();
}

class _PanelSearchContainer extends State<PanelSearchContainer>{

  Pair<String, int> selectedDanger = Pair('', 0);

    @override
    Widget build(BuildContext context){
      
      return Container(
        child: Padding(padding: EdgeInsets.all(widget.width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                    controller: widget.controller,
                    decoration: InputDecoration(
                      labelText: 'Danger type',
                      prefixIcon: Icon(Icons.dangerous),
                      prefixIconColor: Color.fromARGB(255, 252, 255, 255),
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

                    onChanged: (changedText) {

                        widget.filteredDangers.clear();

                        String searchInput = widget.controller.text.toLowerCase();

                        for(int i = 0; i < widget.possibleDangers.length; i++){
                          if(widget.possibleDangers[i].toLowerCase().contains(searchInput)){
                            widget.filteredDangers.add(Pair(widget.possibleDangers[i], i));
                          }
                        }

                        widget.filteredDangers.sort((a, b) => a.first.compareTo(b.first));

                        setState(() {
                          widget.itemCount = widget.filteredDangers.length;
                        });
                    },
                  ),

                  SizedBox(height: 2.5),

                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.itemCount,
                      itemBuilder: (context, index) {
                        
                        return ElevatedButton(onPressed: () {

                            selectedDanger = widget.filteredDangers[index];

                            widget.setStatePanelContainer(
                              PanelLastDescContainer(
                                width: widget.width, 
                                height: widget.height,
                                selectedValue: widget.selectedValue, 
                                items: widget.items, 
                                descriptionController: widget.descriptionController,
                                selectedDanger: selectedDanger,
                                addMarker: widget.addMarker,
                                position: widget.position,
                                setStatePanelContainer: widget.setStatePanelContainer,
                                setPinningLocationOnOff: widget.setPinningLocationOnOff,
                                currentCity : widget.currentCity,
                                markersFetchedData: widget.markersFetchedData)
                            );
                          }, 
                          
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent
                          ),

                          child: Wrap(
                            children: [
                              Image.asset(SimpleMap.getImagePathName(widget.filteredDangers[index].second), width: widget.width * 0.1, height: widget.width * 0.1),

                              SizedBox(width: widget.width * 0.1),

                              Text(
                                widget.filteredDangers[index].first,
                                style: GoogleFonts.roboto(
                                  textStyle: TextStyle(
                                    fontSize: widget.width * 0.05,
                                    color: Color.fromARGB(255, 252, 255, 255),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          )
                        );
                      },
                    ),
                  )
            ],
          ),
        )
      );
  }
}

