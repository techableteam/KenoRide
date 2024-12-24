import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'dart:ui' as ui;
import 'package:google_maps_webservice/directions.dart'as webservice_directions;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
import 'package:kenorider_driver/common/Global_variable.dart';
import 'package:kenorider_driver/common/colormanager.dart';
import 'package:kenorider_driver/common/textcontent.dart';
import 'package:kenorider_driver/view_models/request_view_model.dart';
import 'package:kenorider_driver/views/ratepage.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import '../services/api_servies.dart';

class ArriveDestinationPage extends StatefulWidget {
  const ArriveDestinationPage({super.key});
  @override
  ArriveDestinationPageState createState() => ArriveDestinationPageState();
}

class ArriveDestinationPageState extends State<ArriveDestinationPage> {
  
  final logger = Logger();
  final geocoding = GoogleMapsGeocoding(apiKey: 'AIzaSyDSrCWuiGHc7LOyI5ZDLTDmanGNPmVDvk4');
  final directions = webservice_directions.GoogleMapsDirections(apiKey: 'AIzaSyDSrCWuiGHc7LOyI5ZDLTDmanGNPmVDvk4');
  final Set<Marker> _markers = {};
  final String apiKey = 'AIzaSyDSrCWuiGHc7LOyI5ZDLTDmanGNPmVDvk4';
  final List<google_maps.Marker> _stopMarkers = [];

  late bool _locationInitialized = false;
  late GoogleMapController mapController;
  String driverDistance = "";
  String driverTime = "";
  String _estimatedTime = "";
  // String _estimatedDistance = "";
  google_maps.Polyline _routePolyline = const google_maps.Polyline(polylineId: PolylineId('route'));
  BitmapDescriptor? _currentLocationIcon;
  BitmapDescriptor? _destinationIcon;
  LatLng _startRiderLocation = const LatLng(0, 0);
  LatLng _endRiderLocation = const LatLng(0, 0);
  late StreamSubscription<Position> _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    covertToAddress();
    _startPositionStream();
    _addMarkersAndCalculateRoute();
  }
  
  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
    _positionStreamSubscription.cancel();
  }

  Future<void> covertToAddress() async{
    String startRiderAddress = localStorage.getItem("startLocation")!;
    String endRiderAddress = localStorage.getItem("endLocation")!;

    try {
      // Use geocoding to get the latitude and longitude for the address
      final response = await geocoding.searchByAddress(startRiderAddress);

      final response1 = await geocoding.searchByAddress(endRiderAddress);

      if (response.isOkay && response.results.isNotEmpty) {
        final double latitude = response.results.first.geometry.location.lat;
        final double longitude = response.results.first.geometry.location.lng;

        LatLng position = LatLng(latitude, longitude);

        setState(() {
          _startRiderLocation = position;
          GlobalVariables.riderLat = latitude;
          GlobalVariables.riderLng = longitude;
        });
        
      }

      if (response1.isOkay && response1.results.isNotEmpty) {
        final double latitude1 = response1.results.first.geometry.location.lat;
        final double longitude1 = response1.results.first.geometry.location.lng;

        LatLng position1 = LatLng(latitude1, longitude1);

        setState(() {
          _endRiderLocation = position1;
          GlobalVariables.desLat = latitude1;
          GlobalVariables.desLng = longitude1;
          if (_startRiderLocation != const LatLng(0, 0) && _endRiderLocation != const LatLng(0, 0)) {
            _addMarkersAndCalculateRoute();
          }
        });
      }
    } catch (e) {
      logger.i('Error getting location for address : $e');
    }
  }

  void _startPositionStream() {
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 50, // Update location only after moving 50 meters
      ),
    ).listen(
      (Position position) {
        LatLng newLocation = LatLng(position.latitude, position.longitude);
        ApiService.sendLocationToBackend(position.latitude, position.longitude, 2);
        setState(() {
          _startRiderLocation = newLocation; // Update current rider's location
          _updateStartMarker(newLocation); // Update marker position
          _calculateRoute(newLocation); // Recalculate the route
        });
      },
    );
  }

  // Method to update the start location marker
  void _updateStartMarker(LatLng newLocation) {
    setState(() {
      _markers.removeWhere((marker) => marker.markerId == const MarkerId('start_location'));
      _markers.add(
        Marker(
          markerId: const MarkerId('start_location'),
          position: newLocation,
          icon: _currentLocationIcon!,
        ),
      );
    });
  }

  Future<void> _addMarkersAndCalculateRoute() async {
    if (_startRiderLocation != const LatLng(0, 0) && _endRiderLocation != const LatLng(0, 0)) {
      // Ensure custom marker icons are loaded
      await _loadCustomMarkerIcons();

      setState(() {

        // Add the current location marker
        _markers.add(
          Marker(
            markerId: const MarkerId('start_location'),
            position: _startRiderLocation,
            icon: _currentLocationIcon!,
          ),
        );

        // Add the destination marker
        _markers.add(
          Marker(
            markerId: const MarkerId('end_location'),
            position: _endRiderLocation,
            icon: _destinationIcon!,
          ),
        );
        _locationInitialized = true;
      });
      // After adding markers, calculate the route
      await _calculateRoute(_startRiderLocation);
    }
  }

  Future<void> _calculateRoute(LatLng userLocation) async {
    List<webservice_directions.Waypoint> waypoints = [];

    String? stoppositions = localStorage.getItem("stop_positions");
    logger.i(" destination page stop_positions : $stoppositions");
    
    if (stoppositions != null && stoppositions.isNotEmpty) {
      logger.i("in stoppositions");
      try {
        List<dynamic> decodedStops = jsonDecode(stoppositions);
        for (int i = 0; i < decodedStops.length; i++) {
          var stop = decodedStops[i];
          if (stop != null && stop['position'] != null) {
            String latLngString = stop['position'];
            String cleanedLatLng = latLngString.replaceAll('LatLng(', '').replaceAll(')', '');
            List<String> latLngValues = cleanedLatLng.split(',');
            double latitude = double.parse(latLngValues[0].trim());
            double longitude = double.parse(latLngValues[1].trim());

            LatLng stopLatLng = LatLng(latitude, longitude);

            // Skip waypoints the driver has already passed
            final distance = Geolocator.distanceBetween(
              userLocation.latitude,
              userLocation.longitude,
              latitude,
              longitude,
            );
            if (distance > 50) {
              waypoints.add(webservice_directions.Waypoint(value: '$latitude,$longitude'));
              setState(() {
                _createStopMarker(stopLatLng, i + 1);
              });
            }
          }
        }
      } catch (e) {
        logger.e("Failed to parse stop positions: $e");
      }
    }
    

    final directionsResponse = await directions.directionsWithLocation(
      webservice_directions.Location(
          lat: _startRiderLocation.latitude,
          lng: _startRiderLocation.longitude),
      webservice_directions.Location(
          lat: _endRiderLocation.latitude, 
          lng: _endRiderLocation.longitude),
      travelMode: webservice_directions.TravelMode.driving,
      waypoints: waypoints.isNotEmpty ? waypoints : [],
    );

    if (directionsResponse.isOkay) {
      final route = directionsResponse.routes[0];
      final polylinePoints = _decodePolyline(route.overviewPolyline.points);
      logger.i("Polyline Points: ${_routePolyline.points}");

      if (mounted) {
        setState(() {
          _routePolyline = google_maps.Polyline(
            polylineId: const PolylineId('route'),
            points: polylinePoints,
            color: Colors.blue,
            width: 5,
          );
          // Calculate total distance and duration
          double totalDistance = 0.0; // in meters
          int totalDuration = 0; // in seconds

          for (var leg in route.legs) {
            // Parse distance and duration for each leg
            final legDistance = leg.distance.value as num; // num type
            final legDuration = leg.duration.value as num; // num type

            totalDistance += legDistance.toDouble(); // Ensure double type for distance
            totalDuration += legDuration.toInt(); // Explicit cast to int
          }

          // Convert total distance to kilometers (or miles, if needed)
          driverDistance = "${(totalDistance / 1000).toStringAsFixed(2)} km"; // kilometers

          // Convert total duration to hours and minutes
          final durationHours = totalDuration ~/ 3600;
          final durationMinutes = (totalDuration % 3600) ~/ 60;

          _estimatedTime = durationHours > 0
              ? "$durationHours h $durationMinutes min"
              : "$durationMinutes min";
        });
      }
    } else {
      logger.i('Error: ${directionsResponse.errorMessage}');
    }
  }

  Future<void> _loadCustomMarkerIcons() async {
    _currentLocationIcon = await google_maps.BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(40, 35)),
      'assets/images/car_icon.png',
    );
    _destinationIcon = await google_maps.BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(30, 30)),
      'assets/images/to_location_icon.png',
    );
  }

  Future<void> _createStopMarker(google_maps.LatLng position, int index) async {
    final icon = await _createCustomMarkerBitmap('Stop $index');
    setState(() {
      _stopMarkers.add(
        google_maps.Marker(
          markerId: google_maps.MarkerId('stop_$index'),
          position: position,
          icon: icon,
          infoWindow: google_maps.InfoWindow(title: 'Stop $index'),
        ),
      );
    });
  }

  Future<google_maps.BitmapDescriptor> _createCustomMarkerBitmap(String text) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint()..color = Colors.red;
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    );
    final textSpan = TextSpan(
      text: text,
      style: textStyle,
    );

    textPainter.text = textSpan;
    textPainter.layout();
    final textWidth = textPainter.width;
    final textHeight = textPainter.height;

    // Add padding around the text
    const padding = 3.0;
    final width = textWidth + padding * 2;
    final height = textHeight + padding * 2;

    // Draw rounded rectangle
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, width, height),
        const Radius.circular(10),
      ),
      paint,
    );

    // Calculate offset to center the text
    final textOffset = Offset(
      (width - textWidth) / 2,
      (height - textHeight) / 2,
    );

    // Paint the text
    textPainter.paint(canvas, textOffset);

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final uint8List = byteData!.buffer.asUint8List();

    return google_maps.BitmapDescriptor.bytes(uint8List);
  }


  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return polyline;
  }

  void _onPressedArrivedButton() async{
    final response = await context.read<RequestViewModel>().finishRequest();
    if(response == 200) {
      mapController.dispose();
      GlobalVariables.progress = 3;
      Navigator.push(
        // ignore: use_build_context_synchronously
        context, MaterialPageRoute(builder: (context) => RatePage()));
    } else if (response == 404) {
      logger.i("This is not found request");
    } else {
      logger.i('Internal server error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final requestmodel = Provider.of<RequestViewModel>(context);
    String? riderName = requestmodel.request.riderName;
    String? cost = requestmodel.request.cost;
    String? startLocation = requestmodel.request.startLocation;
    String? endLocation = requestmodel.request.endLocation;
    String? stopPositions = localStorage.getItem('stop_positions');
    List<String> stopAddresses = [];

    if (stopPositions != null) {
      try {
        // Parse stop_positions if available
        List<dynamic> decodedStops = jsonDecode(stopPositions);
        for (var stop in decodedStops) {
          if (stop != null && stop['address'] != null) {
            stopAddresses.add(stop['address']);
          }
        }
      } catch (e) {
        logger.i('Error parsing stop positions: $e');
      }
    }
    return Scaffold(
      body: Stack(
        children: [
          if (_locationInitialized)
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _startRiderLocation,
                zoom: 13.0,
              ),
              markers: {
                ..._markers,
                ..._stopMarkers,
              },
              polylines: {_routePolyline},
            ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
              color: ColorManager.primaryWhiteColor,
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child : Column(
                  children: [
                    const SizedBox(height: 25,),
                    Row(
                      children: [
                        Image.asset(Apptext.fromLocationIconImage),
                        const SizedBox(width: 10),
                        Expanded(
                          child:Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            const Text(
                            'From',
                            style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '$startLocation',
                                style: const TextStyle(
                                    fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Add stop positions if available
                    if (stopAddresses.isNotEmpty)
                      Column(
                        children: stopAddresses.asMap().entries.map((entry) {
                          int index = entry.key; // Get the index
                          String stopAddress = entry.value; // Get the stop address
                          return Row(
                            children: [
                              const SizedBox(width: 40),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Stop ${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      stopAddress,
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        // const SizedBox(width: 40),
                        Image.asset(Apptext.toLocationIconImage),
                        const SizedBox(width: 10),
                        Expanded(
                          child:Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            const Text(
                            'To',
                            style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold),
                              ),                            
                              Text(
                                '$endLocation',
                                style: const TextStyle(
                                    fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 5,
            left: 5,
            right: 5,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
                side: const BorderSide(color: Colors.grey, width: 1.0),
              ),
              color: ColorManager.primaryWhiteColor,
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundImage: AssetImage(Apptext.riderAvatarImage),
                          radius: 25,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$riderName',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                Text(_estimatedTime, style: const TextStyle(fontSize: 15, color: Colors.black54),),
                                Text(" $driverDistance", style: TextStyle(fontSize: 15, color: ColorManager.primarycolor, fontWeight: FontWeight.bold),)
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                            flex: 4,
                            child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Add padding for spacing
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min, // Wrap content
                              children: [
                                const Text(
                                  'Text your passenger',
                                  style: TextStyle(color: Colors.black, fontSize: 14),
                                ),
                                const SizedBox(width: 8), // Space between text and icon
                                Image.asset(Apptext.messageIconImage),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 20,),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorManager.primarycolor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0), // Add padding for spacing
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min, // Wrap content
                                children: [
                                  Text(
                                    'Call',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  SizedBox(width: 8), // Space between text and icon
                                  Icon(Icons.call, color: Colors.white,),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.grey, width: 1),
                          color: Colors.white
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Payment Type',
                                style: TextStyle(fontSize: 14, color: Colors.black54),
                              ),
                              const Spacer(),
                              Image.asset(Apptext.creditCardIconImage),
                              const SizedBox(width: 5,),
                              const Text(
                                'CREDIT',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10,),
                          Row(
                            children: [
                              const Text(
                                'Fare Total',
                                style: TextStyle(fontSize: 14, color: Colors.black54),
                              ),
                              const Spacer(),
                              Text(
                                '\$$cost',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(
                        onPressed:_onPressedArrivedButton,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: <Color>[
                                ColorManager.darkprimarycolor,
                                ColorManager.primarycolor,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            constraints: const BoxConstraints(
                              maxHeight: 50,
                              minHeight: 50,
                              maxWidth: double.infinity,
                            ),
                            child: const Text(
                              'Arrived at Destination',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),                    
          Positioned(
            right: 16,
            bottom: 400,
            child: Column(  
              children: [
                FloatingActionButton(
                  onPressed: () {
                    mapController.animateCamera(
                      google_maps.CameraUpdate.zoomIn(),
                    );
                  },
                   heroTag: "arrived_destination_btn_1",
                  child: const Icon(Icons.zoom_in),
                ),
                const SizedBox(height: 5),
                FloatingActionButton(
                  onPressed: () {
                    mapController.animateCamera(
                      google_maps.CameraUpdate.zoomOut(),
                    );
                  },
                  heroTag: "arrived_destination_btn_2",
                  child: const Icon(Icons.zoom_out),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
