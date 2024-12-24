import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kenorider_driver/common/colormanager.dart';
import 'package:kenorider_driver/common/textcontent.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kenorider_driver/views/auth/getvehicleimagepage.dart';
import 'package:kenorider_driver/views/auth/registerdonepage.dart';
import 'package:kenorider_driver/view_models/driver_view_model.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'dart:ui';

import 'package:top_snackbar_flutter/top_snack_bar.dart';

class RegisterVchiclePage extends StatefulWidget {
  const RegisterVchiclePage({super.key});

  @override
  RegisterVchiclePageState createState() => RegisterVchiclePageState();
}

class RegisterVchiclePageState extends State<RegisterVchiclePage> {
  bool isLoading = false;
  final TextEditingController licenceController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController colorController = TextEditingController();

  final FocusNode licenceFocusNode = FocusNode();
  final FocusNode typeFocusNode = FocusNode();
  final FocusNode colorFocusNode = FocusNode();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isLicenceFocused = false;
  bool isTypeFocused = false;
  bool isColoreFocused = false;

  bool isFormValid = false;

  @override
  void initState() {
    super.initState();
    licenceFocusNode.addListener(() {
      setState(() {
        isLicenceFocused = licenceFocusNode.hasFocus;
      });
    });

    typeFocusNode.addListener(() {
      setState(() {
        isTypeFocused = typeFocusNode.hasFocus;
      });
    });

    colorFocusNode.addListener(() {
      setState(() {
        isColoreFocused = colorFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    licenceFocusNode.dispose();
    typeFocusNode.dispose();
    colorFocusNode.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      isFormValid = _formKey.currentState?.validate() ?? false;
    });
  }

  Future<void> _onPressedFinishButton() async {
    context.read<DriverViewModel>().setLienceNo(licenceController.text);
    context.read<DriverViewModel>().setCarNumber(licenceController.text);
    context.read<DriverViewModel>().setCarType(typeController.text);
    context.read<DriverViewModel>().setCarColor(colorController.text);
    final bytes = await _driverImage!.readAsBytes();
    final base64Image = base64Encode(bytes);
    if(!mounted) return;
    context.read<DriverViewModel>().setCarPhoto(base64Image);

    setState(() {
      isLoading = true;
    });

    await context.read<DriverViewModel>().registerDriver();

    setState(() {
      isLoading = false;
    });

    if(!mounted) return;
    if (context.read<DriverViewModel>().isRegistrationSuccessful) {
      showTopSnackBar(
        displayDuration: const Duration(microseconds: 2500),
        // ignore: use_build_context_synchronously
        Overlay.of(context),
        const CustomSnackBar.success(
          message: "Welcome! You have registered in successfully!",
        ),
      );
      Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterDonePage()));
    } else {
        showTopSnackBar(
          padding: const EdgeInsets.all(5),
          displayDuration: const Duration(microseconds: 3000),
            Overlay.of(context),
            const CustomSnackBar.error(
              textStyle: TextStyle(fontSize: 20, color: Colors.amber),
              message:
                  "Your device was already registered!",
            ),
        );      
    }
  }

  XFile? _driverImage;

  Future<void> _navigateToGetDriverImagePage() async {
    final XFile? image = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GetVehicleImagePage()),
    );

    if (image != null) {
      setState(() {
        _driverImage = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final OutlineInputBorder defaultBorder = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.grey, width: 1),
      borderRadius: BorderRadius.circular(20),
    );

    final OutlineInputBorder focusedBorder = OutlineInputBorder(
      borderSide: BorderSide(color: ColorManager.primarycolor, width: 1),
      borderRadius: BorderRadius.circular(20),
    );

    final OutlineInputBorder enabledInputBorder = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.grey, width: 1),
      borderRadius: BorderRadius.circular(20),
    );

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
                      if (isLoading)
                        BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text('Registering...'),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  Transform.translate(
                    offset: const Offset(0, -60),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                          20), // Adjust the border radius as needed
                      child: _driverImage == null
                          ? Image.asset(
                              Apptext
                                  .emptyVehicleImage, // Replace with your asset path
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
                      'Complete your ',
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
                      'Vehicle informations',
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
                    child: Column(
                      children: [
                        SizedBox(
                          width: 200,
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
                                        ? "Capture your Car's"
                                        : "Retake",
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(
                                      width:
                                          8.0), // Space between text and icon
                                  const Icon(
                                    Icons.camera_alt,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Form(
                            key: _formKey,
                            onChanged: _validateForm,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    focusNode: licenceFocusNode,
                                    controller: licenceController,
                                    decoration: InputDecoration(
                                      labelText: 'Licence No.',
                                      labelStyle: TextStyle(
                                        color: isLicenceFocused
                                            ? ColorManager.primarycolor
                                            : Colors.black,
                                      ),
                                      hintText: '098JKL',
                                      border: defaultBorder,
                                      focusedBorder: focusedBorder,
                                      enabledBorder: enabledInputBorder,
                                      suffixIcon: IconButton(
                                        icon: Image.asset(
                                            Apptext.formCloseIconImage),
                                        onPressed: () {
                                          licenceController.clear();
                                        },
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Please enter your Car's License number";
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          focusNode: typeFocusNode,
                                          controller: typeController,
                                          decoration: InputDecoration(
                                            labelText: 'Vehicle Type',
                                            labelStyle: TextStyle(
                                              color: isTypeFocused
                                                  ? ColorManager.primarycolor
                                                  : Colors.black,
                                            ),
                                            hintText: 'Sedan',
                                            border: defaultBorder,
                                            focusedBorder: focusedBorder,
                                            enabledBorder: enabledInputBorder,
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return "Please enter your Car's type";
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: TextFormField(
                                          focusNode: colorFocusNode,
                                          controller: colorController,
                                          decoration: InputDecoration(
                                            labelText: 'Vehicle Color',
                                            labelStyle: TextStyle(
                                              color: isColoreFocused
                                                  ? ColorManager.primarycolor
                                                  : Colors.black,
                                            ),
                                            hintText: 'Red',
                                            border: defaultBorder,
                                            focusedBorder: focusedBorder,
                                            enabledBorder: enabledInputBorder,
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return "Please enter your Car's color";
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  )
                                ]),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
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
                                      padding: EdgeInsets
                                          .zero, // Remove default padding
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        side: BorderSide(
                                            color: _driverImage != null &&
                                                    (_formKey.currentState
                                                            ?.validate() ??
                                                        false)
                                                ? ColorManager.primarycolor
                                                : ColorManager.primary50color,
                                            width:
                                                2), // Set the border color and width
                                      ),
                                    ),
                                    child: Text(
                                      'Save',
                                      style: TextStyle(
                                        color: _driverImage != null &&
                                                (_formKey.currentState
                                                        ?.validate() ??
                                                    false)
                                            ? ColorManager.primarycolor
                                            : ColorManager.primary50color,
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
                                      if (_driverImage != null &&
                                          (_formKey.currentState?.validate() ??
                                              true)) _onPressedFinishButton();
                                      // print("Form is valid and ready to proceed");
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          ColorManager.primary10color,
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: _driverImage != null &&
                                            (_formKey.currentState
                                                    ?.validate() ??
                                                false)
                                        ? Ink(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: <Color>[
                                                  ColorManager
                                                      .darkprimarycolor,
                                                  ColorManager.primarycolor,
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: Container(
                                              alignment: Alignment.center,
                                              child: const Text(
                                                'Finish',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                          )
                                        : const Text(
                                            'Finish',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
