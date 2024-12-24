import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
import 'dart:async';
class TrackingLocationPage extends StatefulWidget {
  @override
  _TrackingLocationPageState createState() => _TrackingLocationPageState();
}

class _TrackingLocationPageState extends State<TrackingLocationPage> {
  late GoogleMapController mapController;
  // ignore: prefer_const_constructors
  LatLng _currentPosition = LatLng(0, 0);
  late Marker _currentLocationMarker;
  late bool _locationInitialized = false;
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _startLocationUpdates();

  }
  void _startLocationUpdates() {
    _determinePosition().then((position) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        print(_currentPosition);
        _currentLocationMarker = Marker(
          markerId: const MarkerId("current_location"),
          position: _currentPosition,
          icon: google_maps.BitmapDescriptor.defaultMarkerWithHue(
              google_maps.BitmapDescriptor.hueBlue),
        );
        _locationInitialized = true;
      });
    }).catchError((e) {
      // ignore: avoid_print
      print("Error getting location: $e");
    });
    _timer = Timer.periodic(const Duration(seconds: 15), (Timer t) => _updateLocation());
  }
  Future<void> _updateLocation() async{
    try {
      Position position = await _determinePosition();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _currentLocationMarker = Marker(
          markerId: const MarkerId("current_location"),
          position: _currentPosition,
          icon: google_maps.BitmapDescriptor.defaultMarkerWithHue(
              google_maps.BitmapDescriptor.hueBlue),
        );
        if (_locationInitialized) {
          mapController.animateCamera(CameraUpdate.newLatLngZoom(_currentPosition, 13.0));
        }
      });
    } catch (e) {
      // ignore: avoid_print
      print("Error updating location: $e");
    }
  }
  @override
  void dispose() {
    _timer?.cancel();
    mapController.dispose();
    super.dispose();
  }
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController
        .animateCamera(CameraUpdate.newLatLngZoom(_currentPosition, 13.0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_locationInitialized)
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _currentPosition,
                zoom: 13.0,
              ),
              markers: {_currentLocationMarker},
            ),
        ],
      ),
    );
  }
}
