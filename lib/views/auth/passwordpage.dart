import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kenorider_driver/common/colormanager.dart';
import 'package:kenorider_driver/common/textcontent.dart';
import 'package:kenorider_driver/common/styles.dart';
import 'package:kenorider_driver/services/api_servies.dart';
import 'package:kenorider_driver/view_models/driver_view_model.dart';
import 'package:kenorider_driver/views/mainpage.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class PasswordPage extends StatefulWidget {
  final String loginMethod;
  const PasswordPage({super.key, required this.loginMethod});

  @override
  PasswordPageState createState() => PasswordPageState();
}

class PasswordPageState extends State<PasswordPage> {
  final TextEditingController passwordController = TextEditingController();
  final FocusNode passwordFocusNode = FocusNode();
  bool isPasswordVisible = false;
  bool isFocused = false;
  bool isNext = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    passwordFocusNode.addListener(() {
      setState(() {
        isFocused = passwordFocusNode.hasFocus;
      });
    });

    passwordController.addListener(() {
      setState(() {
        isNext = passwordController.text.isNotEmpty;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(passwordFocusNode);
    });
  }

  void onForgotPasswordPressed() {}
  Future<void> onNextButtonPressed(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    final driverViewModel = context.read<DriverViewModel>();
    driverViewModel.setPassword(passwordController.text);
    String? credential;
    if (widget.loginMethod == 'email') {
      credential = driverViewModel.driver.email;
    } else {
      credential = driverViewModel.driver.phoneNumber;
    }

    if (credential == null || credential.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a valid email or phone number')),
      );
      return;
    }

    final result = await ApiService.loginDriver(
      credential,
      passwordController.text,
      widget.loginMethod,
    );

    if (result == 200) {
      setState(() {
        isLoading = false;
      });
      showTopSnackBar(
        displayDuration: const Duration(microseconds: 2500),
        // ignore: use_build_context_synchronously
        Overlay.of(context),
        const CustomSnackBar.success(
          message: "Welcome! You have logged in successfully!",
        ),
      );
      
      Navigator.push( 
        // ignore: use_build_context_synchronously
        context, MaterialPageRoute(builder: (context) => const MainPage()),
      );
    } else {
      setState(() {
        isLoading = false;
      });
      showTopSnackBar(
        padding: const EdgeInsets.all(5),
        displayDuration: const Duration(microseconds: 3000), 
        Overlay.of(context),
        const CustomSnackBar.error(
          textStyle: TextStyle(fontSize: 20, color: Colors.amber),
          message: "Invalid credentials!",
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final OutlineInputBorder defaultBorder = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.circular(20),
    );

    final OutlineInputBorder focusedBorder = OutlineInputBorder(
      borderSide:
          BorderSide(color: ColorManager.buttonMainuserLeftColor, width: 1),
      borderRadius: BorderRadius.circular(20),
    );

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Image.asset(Apptext.backIconImage),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          automaticallyImplyLeading: false,
        ),
        body: Stack(
          children: [
            if (isLoading)
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Please wait...'),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    Apptext.passwordpagetitletext,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: passwordController,
                    focusNode: passwordFocusNode,
                    obscureText: !isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: TextStyle(
                        color: isFocused
                            ? ColorManager.buttonLoginBackgroundColor
                            : Colors.black,
                      ),
                      border: defaultBorder,
                      focusedBorder: focusedBorder,
                      suffixIcon: IconButton(
                        icon: Image.asset(
                          isPasswordVisible
                              ? 'assets/images/password_icon.png' // Change this to an 'eye' open icon if you have one
                              : 'assets/images/password_icon.png', // 'eye' closed icon
                        ),
                        padding: const EdgeInsets.only(right: 15),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: onForgotPasswordPressed,
                      child: Text(
                        Apptext.forgotbuttontext,
                        style: TextStyle(
                          color: ColorManager.buttonLoginBackgroundColor,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity, // Make the button fill the width of the screen
                    height: 50, // Set the fixed height of the button
                    child: ElevatedButton(
                      onPressed: () async {
                        await onNextButtonPressed(context);
                      },
                      style: continueButtonStyle(),
                      child: Ink(
                        decoration: isNext
                            ? continueButtonGradientDecoration()
                            : nocontinueButtonGradientDecoration(),
                        child: Container(
                          alignment: Alignment.center,
                          constraints: const BoxConstraints(
                              maxWidth: double.infinity, minHeight: 50),
                          child: Text(
                            Apptext.nextbuttontext,
                            style: continueButtonTextStyle(),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
