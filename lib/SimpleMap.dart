import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dangermap/PanelNothingToShow.dart';
import 'package:dangermap/PanelSearchContainer.dart';
import 'package:dangermap/PanelSettings.dart';
import 'package:dangermap/PanelShowDescContainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'Pair.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

int notificationId = 0;

class SimpleMap extends StatefulWidget{

  bool userFlag = false;

  SimpleMap({required this.userFlag});

  @override
  _SimpleMap createState() => _SimpleMap(userFlag: userFlag);

  static String getImagePathName(int pinModFlag){

    switch (pinModFlag) {
      case 0:                                                             //unidentified
        return 'assets/images/question_icon.png';
      case 1:                                                             //fire
        return 'assets/images/fire_icon.png';
      case 2:                                                             //weather
        return 'assets/images/weather_icon.png';
      case 3:                                                             //crime
        return 'assets/images/crime_icon.png';
      case 4:                                                             //violence
        return 'assets/images/violence_icon.png';
      case 5:                                                             //animal
        return 'assets/images/animal_icon.png';
    }

    return '-';
  }

  static final platform = MethodChannel('com.example.dangermap/channel');

  static Future<Placemark> getUserLocName(LatLng location) async {  //locality
    try {
      List<Placemark> list = await placemarkFromCoordinates(location.latitude, location.longitude);
      if (list.isNotEmpty && list[0].locality != null) {
        return list[0];
      }
      return Future(() => Placemark(locality: '-'));
    } catch (e) {
      return Future(() => Placemark(locality: '-'));
    }
  }

  static Future<LatLng> getUserPosition() async {  //position
    geo.Position position = await geo.Geolocator.getCurrentPosition(desiredAccuracy: geo.LocationAccuracy.high);
    return LatLng(position.latitude, position.longitude);
  }
}

class _SimpleMap extends State<SimpleMap>{

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool userFlag = false;

  _SimpleMap({required this.userFlag});

  static String currentCity = '-';

  bool _locationFetched = false;
  LatLng userLocation = LatLng(0, 0);
  late GoogleMapController _mapController;
  PanelController _panelController = PanelController();

  //Markers

  Set<Pair<Marker, String>> _markerPaired = {};
  static Set<Marker> _marker = {};

  double _zoom = 16.5;

  String unidentifiedImageAsset = '';
  Marker unidentifiedMarker = Marker(markerId: MarkerId(''));
  bool pinningLocationMode = false;

  Set<Circle> _circles = {};

  TextEditingController _controller = TextEditingController();

  int itemCount = 0;

  static List<String> possibleDangers = {'Unidentified', 'Fire', 'Weather', 'Crime', 'Violence', 'Animal'}.toList();
  List<Pair<String, int>> filteredDangers = List.empty(growable: true);

  TextEditingController _descriptionController = TextEditingController();
  var items = ['1', '2', '3', '4'];
  String selectedValue = '1';

  Widget panelContainer = Container();

  bool allowPopBack = false;

  bool isPanelOpened = false;

  Map<String, Map<String, dynamic>> markersFetchedData = {};

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = _SimpleMap._initNotification();

  @override
  void initState() {
    super.initState();
    _initMap();
    _initBackgroundWork();
  }

  void _initBackgroundWork() async {

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    bool notificationEnabled = sharedPreferences.getBool('notificationOnOff') ?? true;

    if(notificationEnabled){
      SimpleMap.platform.invokeMethod('sendNotif');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: (!isPanelOpened && !pinningLocationMode),
      
      onPopInvoked: (didPop) {

        if(pinningLocationMode && _panelController.isPanelOpen){
          pinningLocationMode = false;
          setStatePanelContainer(PanelNothingToShow(width: MediaQuery.of(context).size.width));

          Set<Marker> auxMarker = {};
          Set<Pair<Marker, String>> auxMarkerPaired = {};
          Set<Pair<Marker, String>> copyOfMarkerPaired = Set.from(_markerPaired);

          for(Pair<Marker, String> markerPaired in copyOfMarkerPaired){
            if(markerPaired.first.markerId != unidentifiedMarker.markerId){
              auxMarker.add(markerPaired.first);
              auxMarkerPaired.add(markerPaired);
            }
          }

          setState(() {
            _marker = auxMarker;
            _markerPaired = auxMarkerPaired;
          });
        }

        _panelController.close();
      },

      child: MaterialApp(
        home: Scaffold(
          backgroundColor: Color.fromARGB(255, 58, 64, 78),
          body: ClipRRect(
            child: SlidingUpPanel(
              controller: _panelController,
              minHeight: height * 0.1,
              maxHeight: height * 0.45,
              color: Colors.transparent,
              panel: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(25)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: const [Color.fromARGB(255, 58, 64, 78), Color.fromARGB(255, 59, 65, 79)],
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Container(
                        height: height * 0.01,
                        width: width * 0.25,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 252, 255, 255),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),

                    Expanded(
                      child: panelContainer
                    )
                  ],
                ),
              ),
              body: Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                child: Stack(
                  children: [
                    _locationFetched
                        ? GoogleMap(
                            compassEnabled: false,
                            myLocationEnabled: true,
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: false,
                            markers: _marker,
                            circles: _circles,
                            initialCameraPosition: CameraPosition(target: userLocation, zoom: 16.5),

                            onMapCreated: (GoogleMapController controller) {
                              _mapController = controller;
                              _mapController.setMapStyle('[{"elementType":"geometry","stylers":[{"color":"#212121"}]},{"elementType":"labels.icon","stylers":[{"visibility":"off"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#212121"}]},{"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#757575"}]},{"featureType":"administrative.country","elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]},{"featureType":"administrative.land_parcel","stylers":[{"visibility":"off"}]},{"featureType":"administrative.locality","elementType":"labels.text.fill","stylers":[{"color":"#bdbdbd"}]},{"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#181818"}]},{"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},{"featureType":"poi.park","elementType":"labels.text.stroke","stylers":[{"color":"#1b1b1b"}]},{"featureType":"road","elementType":"geometry.fill","stylers":[{"color":"#2c2c2c"}]},{"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#8a8a8a"}]},{"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#373737"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#3c3c3c"}]},{"featureType":"road.highway.controlled_access","elementType":"geometry","stylers":[{"color":"#4e4e4e"}]},{"featureType":"road.local","elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},{"featureType":"transit","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#000000"}]},{"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#3d3d3d"}]}]');
                            },

                            onTap: (position) {
                              
                              if(userFlag && !pinningLocationMode){
                                _initFilteredDangers();
                                manageAddingPin(position);

                                Widget searchContainer = PanelSearchContainer(
                                  width: width, 
                                  height: height,
                                  selectedValue: selectedValue, 
                                  items: items, 
                                  descriptionController: _descriptionController, 
                                  possibleDangers: possibleDangers, 
                                  filteredDangers: filteredDangers, 
                                  controller: _controller, 
                                  itemCount: itemCount, 
                                  panelContainer: panelContainer,
                                  setStatePanelContainer: setStatePanelContainer,
                                  addMarker: _addMarker,
                                  position : position,
                                  setPinningLocationOnOff : setPinningLocationOnOff,
                                  currentCity : currentCity,
                                  markersFetchedData: markersFetchedData,);

                                setState(() {
                                  panelContainer = searchContainer;
                                });
                              }
                            },

                            onCameraMove: (position) {
                              if(position.zoom != _zoom){
                                setState(() {
                                  _zoom = position.zoom;
                                  updateMarkersSize();
                                });
                              }
                            },
                          )
                        : const Center(child: CircularProgressIndicator()),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: height * 0.075,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: const [Color.fromARGB(255, 58, 64, 78), Color.fromARGB(255, 59, 65, 79)],
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: IconButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                icon: Icon(Icons.arrow_back),
                                color: Color.fromARGB(255, 252, 255, 255),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                currentCity,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.roboto(
                                  textStyle: TextStyle(
                                    fontSize: width * 0.05,
                                    color: Color.fromARGB(255, 252, 255, 255),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: IconButton(
                                onPressed: () {

                                  _panelController.open();
                                  setStatePanelContainer(PanelSettings(width: width, context: context));

                                },
                                icon: Icon(Icons.settings),
                                color: Color.fromARGB(255, 252, 255, 255),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              onPanelClosed: () {
                setState(() {
                  isPanelOpened = false;
                });
              },
              onPanelOpened: () {
                setState(() {
                  isPanelOpened = true;
                });
              }
            ),
          ),
          floatingActionButton: Padding(
            padding: EdgeInsets.only(top: height * (0.075 + 0.025)),
            child: FloatingActionButton.small(
              backgroundColor: Color.fromARGB(255, 87, 103, 255),
              onPressed: () async {
                Future<LatLng> userLocationUpdated = SimpleMap.getUserPosition();
                userLocationUpdated.then((value) => {
                      userLocation = value,
                      _mapController.animateCamera(CameraUpdate.newLatLngZoom(value, 16))
                    });
              },
              child: const Icon(Icons.location_on, color: Color.fromARGB(255, 252, 255, 255)),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
        ),
      ),
    );
  }

  void _initMap() async {
    
    if(mounted && context.mounted){
      userLocation = await SimpleMap.getUserPosition();
      currentCity = (await SimpleMap.getUserLocName(userLocation)).locality ?? '-';

      _fetchNearbyDangers();
      _initFirebaseSnapshot();

      panelContainer = PanelNothingToShow(width: MediaQuery.of(context).size.width);

      setState(() {
        _locationFetched = true;
      });
    }
  }

  void _fetchNearbyDangers() async{
    DocumentSnapshot locations = await _firestore.collection('waypoints').doc(currentCity).get();

    if(locations.exists){

      _marker.clear();
      _markerPaired.clear();
      markersFetchedData.clear();
      _circles.clear();

      Map<String, dynamic> dataFetched = locations.data() as Map<String, dynamic>;

      dataFetched.forEach((key, value) {
        
        List<String> keySplitted = key.split('_');

        double latitude = double.parse('${keySplitted[0]}.${keySplitted[1]}');
        double longitude = double.parse('${keySplitted[2]}.${keySplitted[3]}');

        LatLng position = LatLng(latitude, longitude);

        Map<String, dynamic> item = jsonDecode(value);

        _addMarker(position, item['selectedDangerType'], item['radiusType'], false);

        markersFetchedData[position.toString()] = item;
      });
    }
  }

  void updateMarkersSize() async {
    double iconSize = getUpdatedZoom();

    Set<Marker> updatedMarkers = {};
    Set<Pair<Marker, String>> updatedMarkersPaired = {};

    Set<Pair<Marker, String>> copyMarkerPaired = Set.from(_markerPaired);    

    for (Pair<Marker, String> marker in copyMarkerPaired) {
      Marker updatedMarker = await _getMarker(marker.first.position, marker.second, iconSize);
      updatedMarkers.add(updatedMarker);
      updatedMarkersPaired.add(Pair(updatedMarker, marker.second));
    }

    if(mounted){
      setState(() {
        _marker = updatedMarkers;
        _markerPaired = updatedMarkersPaired;
      });
    }
  }

  Future<Marker> _getMarker(LatLng location, String imagePathName, double iconSize) async {
    Uint8List markerIcon = await getBytesFromAsset(imagePathName, iconSize.toInt());

    String markerId = location.toString();

    Marker marker = Marker(
      markerId: MarkerId(markerId),
      position: location,
      infoWindow: InfoWindow(),
      icon: BitmapDescriptor.fromBytes(markerIcon),
      
      onTap: () {
        
        _panelController.open();        

        if(markersFetchedData[markerId] != null){

          setStatePanelContainer(
            PanelShowDescContainer(
              userFlag: widget.userFlag,
              width: MediaQuery.of(context).size.width, 
              marker: markersFetchedData[markerId]!,
              markerId: markerId,
              firebaseIdentifier: '${location.latitude}_${location.longitude}',
              possibleDangers: possibleDangers,
              deleteMarker: _deleteMarker)
          );
        }
        else{
          print(markerId);
        }
      },
    );

    return marker;
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  Future<String> _addMarker(LatLng location, int pinModFlag, int emergencyLvl, bool closePanelFlag) async {
    String imagePathName = '';

    imagePathName = SimpleMap.getImagePathName(pinModFlag);

    unidentifiedMarker = await _getMarker(location, imagePathName, getUpdatedZoom());

    if(closePanelFlag && mounted){
      _panelController.close();
    }

    if(mounted){
      setState(() {
        _marker.remove(unidentifiedMarker);
        _markerPaired.remove(Pair(unidentifiedMarker, imagePathName));
        _circles.remove(_getCircle(location, pinModFlag, emergencyLvl));

        _marker.add(unidentifiedMarker);
        _markerPaired.add(Pair(unidentifiedMarker, imagePathName));
        _circles.add(_getCircle(location, pinModFlag, emergencyLvl));
      });
    }
    
    return imagePathName;
  }

  void _deleteMarker(String markerId, String firebaseIdentifier)async {

    markersFetchedData.remove(markerId);

    Pair<Marker, String> markerPaired = Pair(Marker(markerId: MarkerId('')), '');

    for(Pair<Marker, String> indexMarkerPaired in _markerPaired){
      if(indexMarkerPaired.first.markerId.value == markerId){
        markerPaired = indexMarkerPaired;
        break;
      }
    }
    
    Circle circle = Circle(circleId: CircleId(''));

    for(Circle indexCircle in _circles){
      if(indexCircle.circleId.value == markerId){
        circle = indexCircle;
        break;
      }
    }

    _marker.remove(markerPaired.first);
    _markerPaired.remove(markerPaired);
    _circles.remove(circle);

    _firestore.collection('waypoints').doc(currentCity).update({
      firebaseIdentifier : FieldValue.delete()
    });

    setState(() {});
  }

  Circle _getCircle(LatLng location, int pinModFlag, int emergencyLvl){
    
    double radius = 0.0;

    switch(emergencyLvl){
      case 1 : 
        radius = 50.0;    //meters
        break;

      case 2 :
        radius = 100.0;
        break;

      case 3 : 
        radius = 150.0;
        break;

      case 4 :
        radius = 200.0;
        break;
    }

    Color color = Colors.transparent;

    switch(pinModFlag){
      case 0:
        color = Color.fromARGB(255, 252, 255, 255);
        break;

      case 1:
        color = Color.fromARGB(255, 255, 125, 67);
        break;

      case 2:
        color = Color.fromARGB(255, 58, 171, 253);
        break;

      case 3:
        color = Color.fromARGB(255, 250, 0, 0);
        break;

      case 4:
        color = Color.fromARGB(255, 197, 75, 255);
        break;

      case 5:
        color = Color.fromARGB(255, 255, 245, 39);
        break;
    }

    Circle circle = Circle(
      circleId: CircleId(location.toString()),
      center: location,
      radius: radius,
      fillColor: color.withOpacity(0.5),
      strokeColor: Colors.transparent
    );

    return circle;
  }

  void manageAddingPin(LatLng position){

    setPinningLocationOnOff(true);

    _addMarker(position, 0, 0, false).then((value) => unidentifiedImageAsset = value);

    _mapController.animateCamera(CameraUpdate.newLatLngZoom(position, 16.5));
    
     _panelController.open();
  }

  double getUpdatedZoom() {
    return max(50, 50000 / pow(_zoom, 2));
  }

  void _initFilteredDangers(){
    filteredDangers.clear();

    for(int i = 0; i < possibleDangers.length; i++){
      filteredDangers.add(Pair(possibleDangers[i], i));
    }

    filteredDangers.sort((a, b) => a.first.compareTo(b.first));

    itemCount = filteredDangers.length;
  }

  void setStatePanelContainer(Widget widget){
    setState(() {
      panelContainer = widget;
    });
  }

  void setPinningLocationOnOff(bool pinningLocationMode){
    this.pinningLocationMode = pinningLocationMode;
  }

  void _initFirebaseSnapshot() {
    
    _firestore.collection('waypoints').doc(currentCity).snapshots().listen((snapshot) async { 
      if(snapshot.exists){
        _fetchNearbyDangers();
        List<Map<String, dynamic>> dangersInRadius = await _sendNotificationCheck(userLocation, currentCity);

        for(Map<String, dynamic> danger in dangersInRadius){
          SimpleMap.platform.invokeMethod('pushNotif', {'dangerName' : possibleDangers[danger['selectedDangerType']]});
        }
      }
    });
  }

  static Future<List<Map<String, dynamic>>> _sendNotificationCheck(LatLng updatedUserPosition, String updatedCurrentCity) async{

    List<Map<String, dynamic>> dangersInRadius = List.empty(growable: true);

    DocumentSnapshot? documentSnapshot = await _firestore.collection("waypoints").doc(updatedCurrentCity).get();

    if(documentSnapshot.exists){

      Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;

      data.forEach((key, value) {

        List<String> keySplitted = key.split('_');

        double latitude = double.parse('${keySplitted[0]}.${keySplitted[1]}');
        double longitude = double.parse('${keySplitted[2]}.${keySplitted[3]}');

        LatLng position = LatLng(latitude, longitude);

        double distance = _calculateDistance(updatedUserPosition, position);

        Map<String, dynamic> item = jsonDecode(value);

        if(distance <= item['radiusType'] * 50){
          dangersInRadius.add(item);
        }
      });
    }

    return dangersInRadius;
  }

  static double _calculateDistance(LatLng position1, LatLng position2){
    return geo.Geolocator.distanceBetween(position1.latitude, position1.longitude, position2.latitude, position2.longitude);
  }

  static FlutterLocalNotificationsPlugin _initNotification(){
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializeSetAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializeSet = InitializationSettings(
      android: initializeSetAndroid
    );

    flutterLocalNotificationsPlugin.initialize(initializeSet);

    return flutterLocalNotificationsPlugin;
  }
}