import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:kenorider_driver/common/colormanager.dart';
import 'package:kenorider_driver/common/textcontent.dart';
import 'package:kenorider_driver/common/styles.dart';
import 'package:kenorider_driver/services/api_servies.dart';
import 'package:kenorider_driver/view_models/driver_view_model.dart';
import 'package:kenorider_driver/views/auth/verificationpage.dart';
import 'package:kenorider_driver/views/auth/emailaddresspage.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:logger/logger.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  LoginpageState createState() => LoginpageState();
}

class LoginpageState extends State<Loginpage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController phoneNumberController = TextEditingController();
  final logger = Logger();
  PhoneNumber number = PhoneNumber(isoCode: 'CA');
  String? errorMessage;
  bool isValid = false;
  bool showError = false;
  bool emptyError = false;
  bool isPending = false;
  String? emptyerrorMessage;
  String verificationIDReceived = "";
  FirebaseAuth auth = FirebaseAuth.instance;
  bool otpCodeVisible = false;

  void checkPhoneNumber(String value) {
    if (RegExp(r'^\d{10}$').hasMatch(value)) {
      setState(() {
        isValid = true;
        showError = false;
        emptyError = false;
      });
    } else {
      setState(() {
        isValid = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Add listener to controller to handle phone number changes
    phoneNumberController.addListener(() {
      checkPhoneNumber(phoneNumberController.text);
    });
  }


  void onContinueButtonPressed() async{
    setState(() {
      isPending = true;
    });
    if (isValid) {
      String numbers = '+1${phoneNumberController.text}';
      context.read<DriverViewModel>().setPhoneNumber(phoneNumberController.text);
      final response =await ApiService.loginDriverByphone(numbers, "phone");
      if(response == 200) {
        final result = await ApiService.sendVerifyCode(numbers, 'driver');
        setState((){
          isPending = false;
        });
        if (result == 200) {
          showTopSnackBar(Overlay.of(context), const CustomSnackBar.success(message: "Received OTP code successfully"));
          Navigator.push(
            context,
            MaterialPageRoute( builder: (context) => Verificationpage(
                      phoneNumber: phoneNumberController.text,
                      flag: 'driver',
                      tmpId: 0,
                      beforevalue: "login",
                    )));
        } else if (result == 400) {
          showTopSnackBar(Overlay.of(context), const CustomSnackBar.error(message: "Failed to send SMS. Please try again!"));
        } else if (result == 401) {
          showTopSnackBar(Overlay.of(context), const CustomSnackBar.error(message: "Unregistered phone number."));
        }
      // await auth.verifyPhoneNumber(
      //   phoneNumber: numbers,
      //   verificationCompleted: (PhoneAuthCredential credential) async {
      //     try {
      //       await auth.signInWithCredential(credential).then((value) {
      //         logger.i("You are logged in successfully");
      //       });
      //     } catch (e) {
      //       logger.i("Failed to sign in with credential: ${e.toString()}");
      //     }
      //   },
      //   verificationFailed: (FirebaseAuthException exception) {
      //     setState((){
      //       isPending = false;
      //     });
      //     showTopSnackBar(
      //       Overlay.of(context),
      //       CustomSnackBar.error(
      //         message: ("Verification failed: ${exception.message}"),
      //       ),
      //     );
      //     logger.i("Verification failed: ${exception.message}");
      //   },

      //   codeSent: (String verificationID, int? resendToken) async {
      //     // Handle when the code is sent successfully
      //     logger.i("Verification code sent.");
      //     verificationIDReceived = verificationID;
      //     otpCodeVisible = true;
      //     logger.i(numbers);
      //     if (otpCodeVisible) {
            
      //     }
      //   },
      //   codeAutoRetrievalTimeout: (String verificationId) {
      //     // Handle when the auto-retrieval timeout occurs
      //     logger.i("Code auto-retrieval timeout.");
      //   },
      // );

      if (!mounted) return;

      showTopSnackBar(
        displayDuration: const Duration(microseconds: 2500),
        Overlay.of(context),
        const CustomSnackBar.success(
          message: "Welcome! Please enter your verification code!",
        ),
      );        
    } else {
        setState((){
          isPending = false;
        });
        if (!mounted) return;
        showTopSnackBar(
          padding: const EdgeInsets.all(5),
          displayDuration: const Duration(microseconds: 3000),
          Overlay.of(context),
          const CustomSnackBar.error(
            textStyle: TextStyle(fontSize: 20, color: Colors.amber),
            message:
                "This phone number was not registered!",
          ),
        );        
      }
    } else if (phoneNumberController.text.isEmpty) {
      setState(() {
        emptyError = true;
        showError = false;
        emptyerrorMessage = 'Please enter your phone number!';
      });
    } else {
      setState(() {
        showError = true;
        emptyError = false;
        errorMessage =
            'Double-check the number for any missing or extra digits.';
      });
    }
  }

  void onWithMailButtonPressed() {
    Navigator.push(context, MaterialPageRoute( builder: (context) => const EmailAddressPage(beforePageValue: 'login')));
  }

  @override
  void dispose() {
    phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    InputDecoration inputDecoration = InputDecoration(
      labelText: Apptext.phoneLabelText,
      labelStyle: const TextStyle(
        color: Colors.black, // Set the initial label text color here
      ),
      floatingLabelStyle: TextStyle(
        color:
            ColorManager.primarycolor, // Set the label text color when focused
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color:
              ColorManager.primarycolor, // Set the focused border color here
          width: 1.0, // Set the border width if needed
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: showError || emptyError
              ? Colors.red
              : Colors.transparent, // Conditionally set the error border color
          width: 1.0, // Set the border width if needed
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: showError || emptyError
              ? Colors.red
              : Colors
                  .transparent, // Conditionally set the focused error border color
          width: 1.0, // Set the border width if needed
        ),
      ),
    );
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
            'Login',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 26, // Set text to bold
            ),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            const Text(
              Apptext.loginDescriptionText,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 20),
            InternationalPhoneNumberInput(
              onInputChanged: (PhoneNumber value) {
                setState(() {
                  number = value;
                });
              },
              onInputValidated: (bool value) {
                // print(value ? 'Valid' : 'Invalid');
              },
              selectorConfig: const SelectorConfig(
                selectorType: PhoneInputSelectorType.DROPDOWN,
                showFlags: true,
                leadingPadding: 16.0,
                trailingSpace: false,
                setSelectorButtonAsPrefixIcon: false,
              ),
              ignoreBlank: false,
              autoValidateMode: AutovalidateMode.disabled,
              selectorTextStyle: const TextStyle(color: Colors.black),
              initialValue: number,
              textFieldController: phoneNumberController,
              formatInput: false,
              maxLength:
                  15, // Limit overall length if no country code is considered
              keyboardType:
                  const TextInputType.numberWithOptions(signed: true, decimal: true),
              inputDecoration: inputDecoration,
              onSaved: (PhoneNumber value) {
                logger.i('login page On Saved: $value');
              },
            ),
            if (showError)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 140),
                child: Text(
                  errorMessage ?? '',
                  style: const TextStyle(
                    color: Colors.red, // Set the error text color here
                    fontSize: 13,
                  ),
                ),
              ),
            if (emptyError)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 140),
                child: Text(
                  emptyerrorMessage ?? '',
                  style: const TextStyle(
                    color: Colors.red, // Set the error text color here
                    fontSize: 13,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double
                  .infinity, // Make the button fill the width of the screen
              height: 50, // Set the fixed height of the button
              child: ElevatedButton(
                onPressed: () => onContinueButtonPressed(),
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
                    constraints: const BoxConstraints(
                        maxWidth: double.infinity, minHeight: 50),
                    child: isPending? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Please wait...', style: TextStyle(fontSize: 16, color:Colors.grey),),
                  SizedBox(width: 10,),
                   CircularProgressIndicator(color: Colors.grey,),
                ],
              ) : const Text('Continue',style: TextStyle(fontSize: 19, color:Colors.white,)),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(
                  vertical:
                      20.0), // Add some vertical space before and after the divider
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Divider(
                      color: Colors.grey,
                      thickness: 1.5,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 8.0), // Add space around the "or" text
                    child: Text(
                      'or',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.grey,
                      thickness: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 50.0,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorManager
                      .primaryGeryColor, // Background color of the button
                  foregroundColor: Colors.black, // Text and icon color
                  shape: RoundedRectangleBorder(
                    // Rounded Rectangle Border
                    borderRadius:
                        BorderRadius.circular(30), // Custom radius size
                  ),
                ),
                onPressed: () => onContinueButtonPressed(),
                icon: Image.asset(
                  Apptext.facebookIconImage, // The icon data
                  width: 20.0,
                  height: 20.0,
                ),
                // The icon data
                label: const Text(Apptext.facebookButtontext,
                    style: TextStyle(fontSize: 18)), // The text label
              ),
            ),
            const SizedBox(
              height: 15.0,
            ),
            SizedBox(
              width: double.infinity, // Make the button fill the width
              height: 50.0,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorManager
                      .primaryGeryColor, // Background color of the button
                  foregroundColor: Colors.black, // Text and icon color
                  shape: RoundedRectangleBorder(
                    // Rounded Rectangle Border
                    borderRadius:
                        BorderRadius.circular(30), // Custom radius size
                  ),
                ),
                onPressed: () => onWithMailButtonPressed(),
                icon: Image.asset(
                  Apptext.mailIconImage, // The icon data
                  width: 20.0,
                  height: 20.0,
                ),
                // The icon data
                label: const Text(Apptext.mailButtontext,
                    style: TextStyle(fontSize: 18)), // The text label
              ),
            ),
            Padding(
              padding:
                  dividerPadding(), // Add some vertical space before and after the divider
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: dividerStyle(),
                  ),
                  Padding(
                    padding:
                        dividerTextPadding(), // Add space around the "or" text
                    child: Text(
                      'or',
                      style: dividerTextStyle(),
                    ),
                  ),
                  Expanded(
                    child: dividerStyle(),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10), // Add padding around the container
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.search,
                    color: ColorManager.primarycolor,
                  ),
                  const SizedBox(width: 8), // Spacing between the icon and text
                  Text(
                    Apptext.findAccountText,
                    style: TextStyle(
                        fontSize: 18, color: ColorManager.primarycolor),
                  ),
                ],
              ),
            ),
            const Text(
              Apptext.findAccountDecsription,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
