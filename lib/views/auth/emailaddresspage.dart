import 'package:flutter/material.dart';
import 'package:kenorider_driver/common/colormanager.dart';
import 'package:kenorider_driver/common/styles.dart';
import 'package:kenorider_driver/common/textcontent.dart';
import 'package:kenorider_driver/view_models/driver_view_model.dart';
import 'package:kenorider_driver/views/auth/passwordpage.dart';
import 'package:provider/provider.dart';

class EmailAddressPage extends StatefulWidget {

  final String beforePageValue;

  const EmailAddressPage({super.key, required this.beforePageValue});

  @override
  EmailAddressPageState createState() => EmailAddressPageState();
}

class EmailAddressPageState extends State<EmailAddressPage> {
  final TextEditingController emailController = TextEditingController();
  bool isEmailValid = false;
  final FocusNode _focusNode = FocusNode();
  bool isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        isFocused = _focusNode.hasFocus;
      });
    });

    // Request focus for the text field when the page is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
    emailController.dispose();
  }

  void validateEmail(String email) {
    setState(() {
      isEmailValid = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
      ).hasMatch(email);
    });
  }

  void onNextButtonPressed(String isGopage) {
    context.read<DriverViewModel>().setEmail(emailController.text);
    if (isGopage == "signup") {
      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => UserNamePage()));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => PasswordPage(loginMethod: "email",)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset(Apptext.backIconImage),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Center(
          child: Text(
            Apptext.loginWithEmailDescriptionText,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24, // Set text to bold
            ),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        height: screenHeight,
        child: Column(
          children: [
            const SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.all(1.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Enter your email address",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: emailController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      labelText: Apptext.loginDescriptionText,
                      labelStyle:
                          TextStyle(color: ColorManager.primaryGeryColor),
                      hintText: Apptext.emailtextfilehinttext,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: ColorManager
                              .primaryGeryColor, // Set the border color here
                          width: 2.0, // Set the border width if needed
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: ColorManager
                              .primaryGeryColor, // Set the focused border color here
                          width: 2.0, // Set the border width if needed
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: validateEmail,
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double
                  .infinity, // Make the button fill the width of the screen
              height: 50, // Set the fixed height of the button
              child: ElevatedButton(
                onPressed: isEmailValid
                    ? () => onNextButtonPressed(widget.beforePageValue)
                    : null,
                style: continueButtonStyle(),
                child: Ink(
                  decoration: isEmailValid
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
    );
  }
}
