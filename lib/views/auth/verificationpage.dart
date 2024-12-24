import 'dart:async';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kenorider_driver/common/colormanager.dart';
import 'dart:ui';
import 'package:kenorider_driver/common/textcontent.dart';
import 'package:kenorider_driver/services/useDio.dart';
import 'package:kenorider_driver/services/api_servies.dart';
import 'package:kenorider_driver/services/firebase.dart';
import 'package:localstorage/localstorage.dart';
import 'package:kenorider_driver/views/auth/registerhomepage.dart';
import 'package:kenorider_driver/views/mainpage.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:logger/logger.dart';

class Verificationpage extends StatefulWidget {
  final String phoneNumber;
  final String beforevalue;
  final String flag;
  final int tmpId;

  const Verificationpage({super.key, required this.phoneNumber, required this.beforevalue, required this.flag, required this.tmpId});

  @override
  VerificationpageState createState() => VerificationpageState();
}

class VerificationpageState extends State<Verificationpage> {
  bool isCheckCode = false;
  late String enteredCode;
  final TextEditingController verificationController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final logger = Logger();
  int curTmpId = 0;
  bool isFocused = false;
  bool isLoading = false;

  int _start = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startTimer();
    _focusNode.addListener(() {
      setState(() {
        isFocused = _focusNode.hasFocus;
        curTmpId = widget.tmpId;
      });
    });

    verificationController.addListener(() {
      if (verificationController.text.length == 6) {
        setState(() {
          isLoading = true;
        });
        verifyOtp(verificationController.text);
      }
    });

    // Request focus for the text field when the page is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  void verifyOtp(String smsCode) async {
    final number = widget.phoneNumber;
    final phoneNumber = "+1$number";
    print("curTmpId: $curTmpId");
    final result = await ApiService.confirmVerifyCode(phoneNumber, smsCode, widget.flag, curTmpId);
    logger.i(result);
    if (result == 200) {
      if (widget.beforevalue == "login") {
        getFCMToken();
      }
      _onNextPage();
    } else if (result == 401) {
      setState(() {
        isLoading = false;
      });
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: "This verification code has expired. Please regenerate the code!",
        ),
      );
    } else if (result == 402) {
      setState(() {
        isLoading = false;
      });
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: "Invalid verification code.",
        ),
      );
    } else if (result == 403) {
      setState(() {
        isLoading = false;
      });
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: "Unregistered phone number",
        ),
      );
    } else {
      setState(() {
        isLoading = false;
      });
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: "Network Error!",
        ),
      );
    }
    // PhoneAuthCredential credential = PhoneAuthProvider.credential(
    //   verificationId: widget.verificationID,
    //   smsCode: smsCode,
    // );

    // try {
    //   await FirebaseAuth.instance.signInWithCredential(credential).then((value)=>{
    //     _onNextPage()
    //   });
      
    // } catch (e) {
    //   logger.e('Failed to sign in: $e');
    //   setState(() {
    //     isLoading = false;
    //     showTopSnackBar(
    //       // ignore: use_build_context_synchronously
    //       Overlay.of(context),
    //       const CustomSnackBar.error(
    //         message: "Received OTP code successfully",
    //       ),
    //     );
    //   });
    // }
  }

  void getFCMToken() async {
    try {
      String? newToken = await FirebaseAuthentication.generateToken();
      String? driverID = localStorage.getItem('driverID');
      final result = await ApiService.updateToken(driverID, newToken, 'driver');
      if (result == 200) {
        print("Updated Token !!!");
      } else {
        print("Not Updated");
      }
    } catch (e) {
      print("Error regenerating FCM token: $e");
      return null;
    }
  }

  void _onNextPage() {
    if (widget.beforevalue == "login") {
      Navigator.push(context,MaterialPageRoute( builder: (context) => const MainPage()));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterHomePage()));
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    verificationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  void resendCode() {
    // Reset the timer
    setState(() {
      _start = 60;
    });
    startTimer();

    sendOtp();
  }

  void sendOtp() async {
    final DioService useDioService = DioService();
    final number = widget.phoneNumber;
    final phoneNumber = "+1$number";
    final requestData = {'method': widget.flag, 'phone_number': phoneNumber};
    final result = await useDioService.postRequest("/sendVerificationCode", data: requestData);

    logger.i(result.data);
    if (result.statusCode != 404) {
      if (result.statusCode == 200) {
        setState(() {
          isLoading = false;
        });
        if (widget.flag == "temp") {
          setState(() {
            curTmpId = result.data['tmpId'];
          });
        }
      } else if (result.statusCode == 400) {
        setState(() {
          isLoading = false;
        });
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.error(
            message: "Failed to send SMS. Please try again!",
          ),
        );
      } else if (result.statusCode == 401) {
        setState(() {
          isLoading = false;
        });
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.error(
            message: "Unregistered phone number.",
          ),
        );
      }
    } else {
      setState(() {
        isLoading = false;
      });
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: "An error occurred while sending OTP. Please try again.",
        ),
      );
    }
    // try {
    //   String cleanPhoneNumber = formatAndSanitizePhoneNumber(widget.phoneNumber);

    //   await FirebaseAuth.instance.verifyPhoneNumber(
    //     phoneNumber: cleanPhoneNumber,
    //     verificationCompleted: (PhoneAuthCredential credential) async {
    //       try {
    //         await FirebaseAuth.instance.signInWithCredential(credential);
    //         onNextButtonPressed(widget.frompage);
    //       } catch (e) {
    //         logger.e('Sign in failed: $e');
    //         setState(() {
    //           isLoading = false;
    //           errorMessage = 'Sign in failed. Please try again.';
    //         });
    //       }
    //     },
    //     verificationFailed: (FirebaseAuthException e) {
    //       String message;
    //       if (e.code == 'invalid-phone-number') {
    //         message = 'The provided phone number is not valid.';
    //       } else {
    //         message = 'Verification failed: ${e.message}';
    //       }
    //       logger.i(message);
    //       setState(() {
    //         isLoading = false;
    //         // errorMessage = message; // Update error message
    //       });
    //     },
    //     codeSent: (String verificationId, int? resendToken) {
    //       setState(() {
    //         this.verificationId = verificationId;
    //         isLoading = false;
    //       });
    //     },
    //     codeAutoRetrievalTimeout: (String verificationId) {
    //       setState(() {
    //         this.verificationId = verificationId;
    //         isLoading = false;
    //       });
    //     },
    //   );
    // } catch (e) {
    //   logger.i('Error sending OTP: $e');
    //   setState(() {
    //     isLoading = false;
    //     errorMessage = 'An error occurred while sending OTP. Please try again.';
    //   });
    // }
  }

  String formatAndSanitizePhoneNumber(String rawNumber) {
    String sanitizedNumber = rawNumber.replaceAll(RegExp(r'\D'), '');

    // Assuming the sanitized number is for US/Canada and should be 10 digits long
    if (sanitizedNumber.length != 10) {
      return 'Invalid phone number length'; // Handle as appropriate
    }

    // Split the number into its components
    String countryCode = '+1';
    String areaCode = sanitizedNumber.substring(0, 3);
    String prefix = sanitizedNumber.substring(3, 6);
    String lineNum = sanitizedNumber.substring(6);

    // Return the formatted phone number
    return '$countryCode ($areaCode) $prefix-$lineNum';
  }

  @override
  Widget build(BuildContext context) {
    String cleanPhoneNumber = formatAndSanitizePhoneNumber(widget.phoneNumber);
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
            Apptext.verificationPageTitleText,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24, // Set text to bold
            ),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        Apptext.verificationPageDescriptionText,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        cleanPhoneNumber,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          const Text(
                            "by ",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "SMS Services",
                            style: TextStyle(
                              fontSize: 16,
                              color: ColorManager.primarycolor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: verificationController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    labelText: Apptext.verificationTextFieldLabeltext,
                    labelStyle: TextStyle(
                      color:
                          isFocused ? ColorManager.primarycolor : Colors.black,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: ColorManager.primarycolor,
                        width: 2.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: ColorManager.primarycolor,
                        width: 2.0,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 20),
                const Spacer(),
                const Center(
                  child: Text(
                    Apptext.receiveButtonText,
                    style: TextStyle(
                      fontSize: 17,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _start == 0 ? resendCode : null,
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
                        constraints: const BoxConstraints(
                            maxWidth: double.infinity, minHeight: 50),
                        child: Text(
                          _start > 0
                              ? 'Resend the Code in ($_start) s'
                              : 'Resend the Code',
                          style: TextStyle(
                            color: ColorManager.primarycolor,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
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
                    Text('Loading...'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
