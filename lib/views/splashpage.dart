import 'package:flutter/material.dart';
import 'package:kenorider_driver/views/homepage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 2), () {});
    
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:const Color(0xFFF5F5F5), // Background color
      body: Center(
        child: Image.asset(
          'assets/images/logo.png', // Your splash screen image
          width: 200, // Adjust width and height as needed
          height: 200,
        ),
      ),
    );
  }
}
