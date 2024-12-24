import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kenorider_driver/common/colormanager.dart';
import 'package:kenorider_driver/common/textcontent.dart';
import 'package:kenorider_driver/views/auth/loginpage.dart';
import 'package:kenorider_driver/views/auth/registerpage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  GoogleMapController? mapController;
  late LatLng staticPosition = const LatLng(49.77, -94.48);
  @override
  void initState() {
    super.initState();
  }

  void _onPressedCreateAccountButton () {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage()));
  }
  void _onPressedLoginButton () {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Loginpage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image:AssetImage("assets/images/homepage_background.png"),
                fit: BoxFit.cover,
              )
            ),
          ),
      Positioned(
        top:0,
        left: 0,
        right: 0,
        bottom: 0,
        child:Container(
              color: Colors.black.withOpacity(0.2),
            ),),
          Positioned(
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[
                    Colors.transparent,
                    Colors.white.withOpacity(0.8),
                    Colors.white,
                  ],
                  stops: const [0.0, 0.4, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    Apptext.logoImage,
                    width: 100,
                    height: 100,
                  ),
                  const Text(
                    "Drive smart,",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 45,
                      height: 0.9,
                    ),
                  ),
                  const Text(
                    "earn more",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 45,
                      height: 1,
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        "with",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 45,
                          height: 1,
                        ),
                      ),
                      Text(
                        " KenoRide",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 45,
                          color: ColorManager.primarycolor,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity, // Make the button fill the width of the screen
                    height: 50, // Set the fixed height of the button
                    child: ElevatedButton(
                      onPressed: _onPressedCreateAccountButton,
                      style: ElevatedButton.styleFrom(
                        shadowColor: Colors.transparent,
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
                              ColorManager.primarycolor
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          constraints: const BoxConstraints(maxWidth: double.infinity, minHeight: 50),
                          child: const Text(
                            Apptext.signUpButtonText,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _onPressedLoginButton,
                      style: ElevatedButton.styleFrom(
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          color: ColorManager.primary50color,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          constraints: const BoxConstraints(maxWidth: double.infinity, minHeight: 50),
                          child: Text(
                            Apptext.loginButtonText,
                            style: TextStyle(
                              color: ColorManager.primarycolor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20,)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
