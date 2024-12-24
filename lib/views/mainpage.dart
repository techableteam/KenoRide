import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
import 'package:kenorider_driver/common/Global_variable.dart';
import 'package:kenorider_driver/common/colormanager.dart';
import 'package:kenorider_driver/common/textcontent.dart';
import 'package:kenorider_driver/services/useDio.dart';
import 'package:kenorider_driver/view_models/driver_view_model.dart';
import 'package:kenorider_driver/view_models/request_view_model.dart';
import 'package:kenorider_driver/views/arriveddestinationpage.dart';
import 'package:kenorider_driver/views/arrivedpickuppage.dart';
import 'package:kenorider_driver/views/earninghistorypage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:kenorider_driver/views/homepage.dart';
import 'package:kenorider_driver/views/payment_gateway/payment_menu.dart';
import 'package:kenorider_driver/views/starttrippage.dart';
import '../dialogs/requestdialog.dart';
import 'package:logger/logger.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import '../services/api_servies.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  final logger = Logger();
  late GoogleMapController mapController;
  LatLng _currentPosition = const LatLng(0, 0);
  late Marker _currentLocationMarker;
  bool _locationInitialized = false;
  bool _isOnline = false;
  final bool _isReqest = false;
  String hasRider = '0';
  String creditBalance = '0';
  String driverPhoto = "";
  String review = '0';
  bool isBoxVisible = true;
  BitmapDescriptor? _currentLocationIcon;

  @override
  void initState() {
    super.initState();
    logger.i("Driver ID : ${localStorage.getItem('driverID')}");

    if (GlobalVariables.progress != 0) {
      hasRider = '1';
    }

    _loadCustomMarkerIcons();
    _getAndSetPosition();
    getFCMToken();
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  Future<void> getFCMToken() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      // String? newToken = await FirebaseAuthentication.generateToken();
      String? newToken = await messaging.getToken();
      String? driverID = localStorage.getItem('driverID');
      final result = await ApiService.updateToken(driverID, newToken, 'driver');
      if (result == 200) {
        logger.i("Updated Token !!!");
      } else {
        logger.i("Not Updated");
      }
    } catch (e) {
      logger.i("Error regenerating FCM token: $e");
    }
  }

  Future<void> _getAndSetPosition() async {
    try {
      final position = await _determinePosition();

      if (!mounted) return;

      setState(() {
        getInform();
        _currentPosition = LatLng(position.latitude, position.longitude);
        GlobalVariables.driverLat = position.latitude;
        GlobalVariables.driverLng = position.longitude;
        _currentLocationMarker = Marker(
          markerId: const MarkerId("current_location"),
          position: _currentPosition,
          icon: _currentLocationIcon!,
        );
        _locationInitialized = true;
      });
      // Send the location to the backend
      // await ApiService.sendLocationToBackend(position.latitude, position.longitude, 0);
    } catch (e) {
      logger.i("Error getting location: $e");
    }
  }

  Future<void> _loadCustomMarkerIcons() async {
    _currentLocationIcon = await google_maps.BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(40, 35)),
      'assets/images/car_icon.png',
    );
  }

  Future<void> getInform () async{
    final DioService dioService = DioService(); 
    final data = {"driver_id": int.parse(localStorage.getItem('driverID')!)};

    final response = await dioService.postRequest('/getReview', data: data);
    logger.i("Get Driver info : $response");
    if(response.statusCode == 200){
      GlobalVariables.driverPhoto = response.data['driverPhoto'];
      setState(() {
        creditBalance = response.data['credit'].toString();
        driverPhoto = response.data['driverPhoto'];
        GlobalVariables.totalEarning = creditBalance;
        double reviewValue = double.parse(response.data['review'].toString());
        review = reviewValue.toStringAsFixed(2);        
      });
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Check for permissions
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

    // Return the current position
    return await Geolocator.getCurrentPosition();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController
        .animateCamera(CameraUpdate.newLatLngZoom(_currentPosition, 13.0));
  }

  void _onPressedOnlineButton() {
    context.read<DriverViewModel>().setFlag(true);
    GlobalVariables.flag = !GlobalVariables.flag;
    setState(() {
      _isOnline = !_isOnline;
      // _isReqest = true;
    });
  }

  void _onPressedHistoryButton() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const EarningHistoryPage()));
  }

  @override
  Widget build(BuildContext context) {
    // const rating = 4.5;
    return Scaffold(
      body: Stack(
        children: [
          if (_locationInitialized)
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _currentPosition,
                zoom: 14.0,
              ),
              markers: {_currentLocationMarker},
            ),
          Consumer<RequestViewModel>(builder: (context, flagProvider, child) {
            if (flagProvider.status == "requested") {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showDialog(
                  context: context,
                  builder: (context) => const RideRequestDialog(),
                ).then((_) {
                  flagProvider.setStatus('');
                  GlobalVariables.flag = false;
                });
              });
            }
            if (flagProvider.status == 'NOTA') {
              GlobalVariables.flag = false;
              Navigator.of(context).pop();
            }
            return Container(); // Empty container when flag is false
          }),
          if (_isReqest)
            Container(
              color: Colors.black.withOpacity(0.4),
            ),
          Stack(
            children:[
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: RefreshIndicator(
                  onRefresh: () async {
                    await getInform();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(), // Ensure scrolling is enabled even if the content doesn't overflow
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      color: Colors.white,
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 40,
                            ),
                            Row(
                              children: [
                                const SizedBox(width: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Credit Balance',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      '\$ $creditBalance',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Column(
                                  children: [
                                    CircleAvatarDropdown(photoUrl: driverPhoto),
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 1, // Set the border color and width
                                        ),
                                        borderRadius: BorderRadius.circular(20), // Set the border radius
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            color: Colors.yellow,
                                            size: 20,
                                          ),
                                          const SizedBox(
                                            width: 4,
                                          ),
                                          Text(
                                            review,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ]
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black
                    .withOpacity(0.2), // Semi-transparent background
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30)),
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _onPressedOnlineButton,
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _isOnline ? 'Go Online' : "Off line",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(
                                    width:
                                        8), // Space between text and icon
                                Image.asset(
                                  Apptext.powerIconImage,
                                  width: 24,
                                  height: 24,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _onPressedHistoryButton,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        backgroundColor: Colors.grey[200],
                      ),
                      child: const Text(
                        'History',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!_isReqest)
            Positioned(
              right: 16,
              bottom: 100,
              child: Column(
                children: [
                  FloatingActionButton(
                    onPressed: () {
                      mapController.animateCamera(
                        CameraUpdate.zoomIn(),
                      );
                    },
                    heroTag: "btnZoomIn",
                    child: const Icon(Icons.zoom_in),
                  ),
                  const SizedBox(height: 5),
                  FloatingActionButton(
                    onPressed: () {
                      mapController.animateCamera(
                        google_maps.CameraUpdate.zoomOut(),
                      );
                    },
                    heroTag: "btnZoomOut",
                    child: const Icon(Icons.zoom_out),
                  ),
                ],
              ),
            ),
          Positioned(
            right: 0,
            top: 200,
            child: Container(
              padding: isBoxVisible
                    ? const EdgeInsets.fromLTRB(0, 10, 15, 10)
                    : EdgeInsets.zero, // Conditional paddingl: add padding inside the container
              decoration: isBoxVisible? BoxDecoration(
                color: Colors.white, // Set background color
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color.fromARGB(
                      255, 138, 210, 203), // Set border color
                  width: 1, // Set border width
                ), // Rounded corners
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ): null,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(isBoxVisible
                        ? Icons.arrow_forward_ios
                        : Icons.arrow_drop_down_circle),
                    color:isBoxVisible? Colors.teal[300]:Colors.amber,
                    iconSize: isBoxVisible? 15: 25,
                    onPressed: () {
                      setState(() {
                        isBoxVisible =
                            !isBoxVisible; // Toggle the visibility state
                      });
                    },
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // First Button
                      if (isBoxVisible)
                        SizedBox(
                          width: 150, // Set the desired width for the buttons
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 1, horizontal: 5),
                              side: const BorderSide(
                                  color: Colors.teal,
                                  width: 1), // Button border color and width
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    8), // Button border radius
                              ),
                            ),
                            onPressed: () {
                              if (GlobalVariables.progress == 4) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ArrivePickupPointPage(),
                                  ),
                                );
                              }
                              if (GlobalVariables.progress == 1) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const StartTripPage(),
                                  ),
                                );
                              }
                              if (GlobalVariables.progress == 2) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ArriveDestinationPage(),
                                  ),
                                );                              
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const Text(
                                  "Ongoing Ride ",
                                  style: TextStyle(color: Colors.black),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(
                                      8), // Padding inside the circle
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color:
                                        Colors.green, // Circle background color
                                  ),
                                  child: Text(
                                    hasRider,
                                    style: const TextStyle(
                                      color: Colors
                                          .white, // Text color inside the circle
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 4), // Add spacing between buttons
                      // Second Button
                      if (isBoxVisible)
                        SizedBox(
                          width: 150, // Ensure the same width for both buttons
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 1),
                              side: const BorderSide(
                                  color: Colors.teal,
                                  width: 1), // Button border color and width
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    8), // Button border radius
                              ),
                            ),
                            onPressed: () {
                              // Navigation logic
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const Text(
                                  "Parcel Delivery",
                                  style: TextStyle(color: Colors.black),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(
                                      8), // Padding inside the circle
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color:
                                        Colors.green, // Circle background color
                                  ),
                                  child: Text(
                                    hasRider,
                                    style: const TextStyle(
                                      color: Colors
                                          .white, // Text color inside the circle
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (!_locationInitialized)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Fetching current location...'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
class CircleAvatarDropdown extends StatelessWidget {
  final String? photoUrl;

  const CircleAvatarDropdown({super.key, required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      onSelected: (item) => onSelected(context, item),
      itemBuilder: (context) => [
        const PopupMenuItem<int>(
          value: 0,
          child: Text('Profile'),
        ),
        const PopupMenuItem<int>(
          value: 1,
          child: Text('Settings'),
        ),
        const PopupMenuItem<int>(
          value: 2,
          child: Text('Logout'),
        ),
      ],
      // Wrap FadeInImage with ClipOval to make the image circular
      child: ClipOval(
        child: photoUrl != null && photoUrl!.isNotEmpty
            ? FadeInImage(
                image: NetworkImage(photoUrl!),
                placeholder:
                    const AssetImage('assets/images/empty_profile_image.png'),
                imageErrorBuilder: (context, error, stackTrace) {
                  // Handle errors such as broken URL or failed loading
                  return const CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        AssetImage('assets/images/empty_profile_image.png'),
                  );
                },
                fit: BoxFit.cover, // Ensures the image covers the circular area
                width: 60.0, // Adjust the width as needed
                height: 60.0, // Adjust the height as needed
              )
            : const CircleAvatar(
                radius: 30,
                backgroundImage:
                    AssetImage('assets/images/empty_profile_image.png'),
              ),
      ),
    );
  }
  void onSelected(BuildContext context, int item) {
    switch (item) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PaymentMenuScreen(),
          ),
        );
        break;
      case 1:
        // Navigate to Settings Page
        break;
      case 2:
        // Perform Logout
        initLocalStorage();
        localStorage.clear();
        GlobalVariables.progress = 0;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
        break;
    }
  }
}
