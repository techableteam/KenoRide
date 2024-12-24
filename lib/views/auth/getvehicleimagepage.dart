import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kenorider_driver/common/colormanager.dart';
import 'package:kenorider_driver/common/textcontent.dart';
import 'package:logger/logger.dart';

class GetVehicleImagePage extends StatefulWidget {
  const GetVehicleImagePage({super.key});

  @override
  GetVehicleImagePageState createState() => GetVehicleImagePageState();
}

class GetVehicleImagePageState extends State<GetVehicleImagePage> {
  XFile? _image;
  final ImagePicker _picker = ImagePicker();
  final logger = Logger();

  @override
  void initState() {
    super.initState();
    _takePicture();
  }

  Future<void> _takePicture() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _image = image;
        });
      }
    } catch (e) {
      logger.e('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(Apptext.backIconImage),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            ClipRRect(
              borderRadius: BorderRadius.circular(40), // Adjust the border radius as needed
              child: _image == null
                ? Container(
                    width: 160,
                    height: 160,
                    color: Colors.grey[200], // Background color when no image is present
                    child: const Icon(
                      Icons.person, // Replace with your preferred icon or asset
                      size: 100,
                      color: Colors.grey,
                    ),
                  )
                : Image.file(
                    File(_image!.path),
                    width: 250,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Fit your Car in the frame for the \nBest Shot!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity, // Make the button fill the width of the screen
              height: 50, // Set the fixed height of the button
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, _image);
                },
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
                          'Ready, Set, Snap!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.camera_alt,
                          color: Colors.white,
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
