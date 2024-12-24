import 'dart:convert';
import 'package:google_maps_webservice/directions.dart' as webservice_directions;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
import 'package:google_maps_webservice/geocoding.dart';
import 'package:kenorider_driver/common/Global_variable.dart';
import 'package:kenorider_driver/common/colormanager.dart';
import 'package:kenorider_driver/common/textcontent.dart';
import 'package:kenorider_driver/services/useDio.dart';
import 'package:kenorider_driver/view_models/request_view_model.dart';
import 'package:kenorider_driver/views/starttrippage.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:logger/logger.dart';
import '../services/api_servies.dart';

class ArrivePickupPointPage extends StatefulWidget {
  const ArrivePickupPointPage({super.key});

  @override
  ArrivePickupPointPageState createState() => ArrivePickupPointPageState();
}

class ArrivePickupPointPageState extends State<ArrivePickupPointPage> {
  late GoogleMapController mapController;
  // ignore: prefer_const_constructors
  LatLng _currentPosition = LatLng(0, 0);
  // LatLng _destinationPosition = const LatLng(0, 0);
  late Marker _currentLocationMarker;
  late bool _locationInitialized = false;
  late Marker _destinationLocationMarker;
  bool hasNavigated = false;
  google_maps.Polyline? _routePolyline;
  String _estimatedTime = "";
  String _estimatedDistance = "";
  StreamSubscription<Position>? _positionStreamSubscription;
  final String apiKey = 'AIzaSyDSrCWuiGHc7LOyI5ZDLTDmanGNPmVDvk4';
  final geocoding = GoogleMapsGeocoding(apiKey: 'AIzaSyDSrCWuiGHc7LOyI5ZDLTDmanGNPmVDvk4');
  final directions = webservice_directions.GoogleMapsDirections(apiKey: 'AIzaSyDSrCWuiGHc7LOyI5ZDLTDmanGNPmVDvk4');
  final logger = Logger();
  Timer? _timer;
  BitmapDescriptor? _currentLocationIcon;
  BitmapDescriptor? _destinationIcon;
  String? _currentRiderAddress;
  LatLng? _currentRiderLocation;
  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
    _currentRiderAddress = localStorage.getItem("startLocation");
    covertToAddress(_currentRiderAddress);
    _startLocationUpdates();
    _loadCustomMarkerIcons();
 
  }
  
  void _startLocationUpdates() async {
    // Step 1: Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, show an error or prompt the user to enable them
      logger.i('Location services are disabled.');
      return;
    }

    // Step 2: Check and request location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, show an error or handle accordingly
        logger.i('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied, handle appropriately
      logger.i('Location permissions are permanently denied, we cannot request permissions.');
      return;
    }

    // Step 3: Start listening for location updates after permissions and services are confirmed
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 50, // Update location only after moving 50 meters
      ),
    ).listen(
      (Position position) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          ApiService.sendLocationToBackend(position.latitude, position.longitude, 1);
          _routePoints.add(_currentPosition);

          // Update current location marker
          _currentLocationMarker = Marker(
            markerId: const MarkerId("current_location"),
            position: _currentPosition,
            icon: _currentLocationIcon!,
          );

          // Draw destination marker if available
          _destinationLocationMarker = Marker(
            markerId: const MarkerId("Rider location"),
            position: LatLng(GlobalVariables.riderLat, GlobalVariables.riderLng),
            icon: _destinationIcon!,
          );

          _locationInitialized = true;
          _calculateRoute(); // Calculate route to the destination
        });

        _sendLocationToBackend(); // Send the updated location to the backend
      },
      onError: (error) {
        // Handle error without returning a value
        logger.i("Error getting location: $error");
      },
    );

  }


  Future<void> _sendLocationToBackend() async {
    _calculateRoute();
    final DioService dioService = DioService();
    final requestModel = Provider.of<RequestViewModel>(context, listen:false);
    final riderID = requestModel.request.riderID;
    final data = {
      "latitude":_currentPosition.latitude,
      "longitude":_currentPosition.longitude,
      "driverID":int.parse(localStorage.getItem("driverID")!),
      "riderID": riderID,
    };
    final response = await dioService.postRequest('/sendLocation', data:data);
    if(response.statusCode == 200){
      logger.i("Location updated successfullssy");
    } else {
      logger.i("Failed to update location");
    }
  }

  Future<void> covertToAddress(address) async{
    try {
      // Use geocoding to get the latitude and longitude for the address
      final response = await geocoding.searchByAddress(_currentRiderAddress!);

      if (response.isOkay && response.results.isNotEmpty) {
        final double latitude = response.results.first.geometry.location.lat;
        final double longitude = response.results.first.geometry.location.lng;

        LatLng position = LatLng(latitude, longitude);

        _currentRiderLocation = position;
        setState(() {
          _currentRiderLocation = position;
          GlobalVariables.riderLat = latitude;
          GlobalVariables.riderLng = longitude;

          // Update the destination marker only after setting _currentRiderLocation
          _destinationLocationMarker = Marker(
            markerId: const MarkerId("Rider location"),
            position: _currentRiderLocation!,
            icon: _destinationIcon!,
          );
          _calculateRoute(); // Ensure the polyline is drawn after updating the destination
        });
        
      }
    } catch (e) {
      logger.i('Error getting location for address $address: $e');
    }
  }

  Future<void> _loadCustomMarkerIcons() async {
    _currentLocationIcon = await google_maps.BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(40, 35)),
      'assets/images/car_icon.png',
    );
    _destinationIcon = await google_maps.BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(35, 40)),
      'assets/images/person_icon.png',
    );

    // Once the icons are loaded, refresh the state to update markers
    setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    mapController.dispose();
    _positionStreamSubscription?.cancel();
    super.dispose();
  }
  List<google_maps.LatLng> _decodePolyline(String encoded) {
    List<google_maps.LatLng> polyline = [];
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

      polyline.add(google_maps.LatLng(lat / 1E5, lng / 1E5));
    }

    return polyline;
  }

  Future<void> _calculateRoute() async {
      List<webservice_directions.Waypoint> waypoints = [];
      logger.i(GlobalVariables.riderLat);
      final directionsResponse = await directions.directionsWithLocation(
        webservice_directions.Location(
            lat: _currentPosition.latitude,
            lng: _currentPosition.longitude),
        webservice_directions.Location(
            lat: GlobalVariables.riderLat, lng: GlobalVariables.riderLng),
        travelMode: webservice_directions.TravelMode.driving,
        waypoints: waypoints.isNotEmpty ? waypoints : [],
      );

      if (directionsResponse.isOkay) {
        final route = directionsResponse.routes[0];
        final polylinePoints = _decodePolyline(route.overviewPolyline.points);

        setState(() {
          _routePolyline = google_maps.Polyline(
          polylineId: const google_maps.PolylineId('route'),
          points: polylinePoints,
          color: Colors.blue,
          width: 5,
        );
        // Extract distance text
        String distanceText = route.legs[0].distance.text;
        double distanceInKilometers;

        distanceText = distanceText.replaceAll(',', '');

        if (distanceText.contains('mi')) {
          double distanceInMiles = double.parse(distanceText.split(' ')[0]);
          distanceInKilometers = distanceInMiles * 1.60934;
          _estimatedDistance = "${distanceInKilometers.toStringAsFixed(2)} km";
        } else if (distanceText.contains('ft')) {
          double distanceInFeet = double.parse(distanceText.split(' ')[0]);
          double distanceInMeters = distanceInFeet * 0.3048;
          _estimatedDistance = "${distanceInMeters.toStringAsFixed(2)} m";
        }

        _estimatedTime = route.legs[0].duration.text;
        _routePoints = polylinePoints; 
        });
      }
  }
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController
        .animateCamera(CameraUpdate.newLatLngZoom(_currentPosition, 15.0));
  }
  void _onPressedArrivedButton() async{
    final response = await context.read<RequestViewModel>().arrivedRequest();
    if(response == 200) {
      GlobalVariables.progress = 2;
      Navigator.push(
        // ignore: use_build_context_synchronously
        context, MaterialPageRoute(builder: (context) => const StartTripPage()));
    } else if (response == 404) {
      logger.i("This is not found request");
    } else {
      logger.i('Internal server error');
    }
  }

 @override
  Widget build(BuildContext context) {
    final requestmodel = Provider.of<RequestViewModel>(context);
    String? cost = requestmodel.request.cost;
    String? riderName = requestmodel.request.riderName;
    String? startLocation = requestmodel.request.startLocation;
    String? endLocation = requestmodel.request.endLocation;
    // String? period = requestmodel.request.period;
    logger.i("arrived pickup page current driver positoin : $_currentPosition");
    logger.i("arrived pickup page current rider position : $_currentRiderLocation");
    // Get stop positions from local storage
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
                target: _currentPosition,
                zoom: 16.0,
              ),
              markers: {_currentLocationMarker, _destinationLocationMarker},
              polylines: _routePolyline != null ? {_routePolyline!} : {},
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
                child: Column(
                  children: [
                    const SizedBox(height: 40),
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
                                      style: const TextStyle(fontSize: 16),
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
                        Image.asset(Apptext.fromLocationIconImage),
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
                padding: const EdgeInsets.all(15.0),
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
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                Text(
                                  "On the way - $_estimatedTime",
                                  style: const TextStyle(
                                      fontSize: 15, color: Colors.black54),
                                ),
                                Text(
                                  " ($_estimatedDistance)",
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: ColorManager.primarycolor,
                                      fontWeight: FontWeight.bold),
                                )
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5.0,
                                  vertical: 5.0), // Add padding for spacing
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min, // Wrap content
                              children: [
                                const Text(
                                  'Text your passenger',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 14),
                                ),
                                const SizedBox(
                                    width: 8), // Space between text and icon
                                Image.asset(Apptext.messageIconImage),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorManager.primarycolor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5.0,
                                  vertical: 5.0), // Add padding for spacing
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min, // Wrap content
                              children: [
                                Text(
                                  'Call',
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(
                                    width: 8), // Space between text and icon
                                Icon(
                                  Icons.call,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.grey, width: 1),
                          color: Colors.white),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Payment Type',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black54),
                              ),
                              const Spacer(),
                              Image.asset(Apptext.creditCardIconImage),
                              const SizedBox(
                                width: 5,
                              ),
                              const Text(
                                'CREDIT',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              const Text(
                                'Fare Total',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black54),
                              ),
                              const Spacer(),
                              Text(
                                '\$$cost',
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    ElevatedButton(
                        onPressed: _onPressedArrivedButton,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorManager.primaryWhiteColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: BorderSide( color: ColorManager.primarycolor,
                                width: 1),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: Center(
                          child: Text('Arrived at Pickup Point',
                            style: TextStyle(
                                fontSize: 16,
                                color:ColorManager.primarycolor,
                          ),
                        ),
                      )
                    )
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
                   heroTag: "arrived_pickup_btn_1",
                  child: const Icon(Icons.zoom_in),
                ),
                const SizedBox(height: 5),
                FloatingActionButton(
                  onPressed: () {
                    mapController.animateCamera(
                      google_maps.CameraUpdate.zoomOut(),
                    );
                  },
                  heroTag: "arrived_pickup_btn_2",
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
