import 'package:flutter/material.dart';
import 'package:kenorider_driver/common/colormanager.dart';
import 'package:kenorider_driver/common/textcontent.dart';
import 'package:kenorider_driver/views/mainpage.dart';

class RegisterDonePage extends StatefulWidget {
  const RegisterDonePage({super.key});

  @override
  RegisterDonePageState createState() => RegisterDonePageState();
}

class RegisterDonePageState extends State<RegisterDonePage> {
  @override
  void initState() {
    super.initState();
  }

  void _onPressedDoneButton () {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const MainPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 110),
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Container(
                    width: 250,
                    height: 250,
                    color: Colors.grey[200],
                    child: Image.asset(Apptext.registerDoneImage),
                  )
            ),
            const SizedBox(height: 20),
            const Text(
              'Registration Completed!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              "Congratulatoins! You just registered as a",
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54
              ),
            ),
            const Text(
              "Driver just now.",
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity, // Make the button fill the width of the screen
              height: 50, // Set the fixed height of the button
              child: ElevatedButton(
                onPressed: _onPressedDoneButton,
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
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Let the journey begin',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
