import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kenorider_driver/common/colormanager.dart';
import 'package:kenorider_driver/common/textcontent.dart';
import 'package:kenorider_driver/views/auth/getdriverimagepage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kenorider_driver/views/auth/registerlicencepage.dart';
import 'package:kenorider_driver/view_models/driver_view_model.dart';
import 'package:provider/provider.dart';

class RegisterHomePage extends StatefulWidget {
  const RegisterHomePage({super.key});

  @override
  RegisterHomePageState createState() => RegisterHomePageState();
}

class RegisterHomePageState extends State<RegisterHomePage> {
  XFile? _driverImage;

  Future<void> _navigateToGetDriverImagePage() async {
    final XFile? image = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GetDriverImagePage()),
    );

    if (image != null) {
      setState(() {
        _driverImage = image;
      });
    }
  }

  Future<void> _onPressedNextButton() async {
    final bytes = await _driverImage!.readAsBytes();
    final base64Image = base64Encode(bytes);
    if(!mounted) return;
    context.read<DriverViewModel>().setDriverPhoto(base64Image);
    Navigator.push( context, MaterialPageRoute(builder: (context) => RegisterLicencePage(driverImage: _driverImage)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 300,
                        decoration: BoxDecoration(
                          color: ColorManager.primarycolor,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(130),
                            bottomRight: Radius.circular(130),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            AppBar(
                              backgroundColor: Colors
                                  .transparent, // Make AppBar transparent
                              elevation: 0, // Remove AppBar shadow
                              leading: IconButton(
                                icon: Image.asset(Apptext.backWhiteIconImage),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              title: const Center(
                                child: Text(
                                  Apptext.registerPageTitleText,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              automaticallyImplyLeading: false,
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(40),
                              child: Image.asset(
                                'assets/images/registration_back.png',
                                width: 300,
                                height: 180,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Transform.translate(
                    offset: const Offset(0, -60),
                    child: ClipOval(
                      child: _driverImage == null
                          ? Image.asset(
                              Apptext.emptyProfileImage, // Replace with your asset path
                              width: 160,
                              height: 160,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(_driverImage!.path),
                              width: 160,
                              height: 160,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -60),
                    child: const Text(
                      'Show Your Best Smile',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -60),
                    child: const Text(
                      'For your Driver Profile!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -40),
                    child: SizedBox(
                      width: 180,
                      child: Center(
                        child: ElevatedButton(
                          onPressed: _navigateToGetDriverImagePage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: const BorderSide(color: Colors.grey),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _driverImage == null
                                    ? 'Take a Selfie'
                                    : "Retake",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 8.0), // Space between text and icon
                              const Icon(
                                Icons.camera_alt,
                                color: Colors.black,
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
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50, // Set the fixed height of the button
                      child: ElevatedButton(
                        onPressed: () {
                          // Implement save functionality here
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero, // Remove default padding
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: BorderSide(
                                color: _driverImage == null
                                    ? ColorManager.primary50color
                                    : ColorManager.primarycolor,
                                width: 2), // Set the border color and width
                          ),
                        ),
                        child: Text(
                          'Save',
                          style: TextStyle(
                            color: _driverImage == null
                                ? ColorManager.primary50color
                                : ColorManager.primarycolor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 50, // Set the fixed height of the button
                      child: ElevatedButton(
                        onPressed: () {
                          if (_driverImage != null) _onPressedNextButton();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorManager.primary10color,
                          padding: EdgeInsets.zero, // Remove default padding
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _driverImage == null
                            ? const Text(
                                'Next',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              )
                            : Ink(
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
                                  child: const Text(
                                    'Next',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
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
        ],
      ),
    );
  }
}
