import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:kenorider_driver/common/colormanager.dart';
import 'package:kenorider_driver/common/textcontent.dart';
import 'package:kenorider_driver/services/useDio.dart';
import 'package:kenorider_driver/views/auth/verificationpage.dart';
import 'package:kenorider_driver/view_models/driver_view_model.dart';
import 'package:provider/provider.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:logger/logger.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  final FocusNode emailFocusNode = FocusNode();
  final FocusNode nameFocusNode = FocusNode();
  final FocusNode phoneFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmFocusNode = FocusNode();

  final logger = Logger();

  PhoneNumber number = PhoneNumber(isoCode: 'CA');
  final List<String> cities = [
    'Kenora',
  ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? selectedCity;
  bool isEmailFocused = false;
  bool isNameFocused = false;
  bool isPhoneFocused = false;
  bool isPasswordFocused = false;
  bool isConfirmFocused = false;
  bool isChecked = false;
  bool isFormValid = false;
  bool isPending = false;
  String verificationIDReceived = "";
  // FirebaseAuth auth = FirebaseAuth.instance;
  bool otpCodeVisible = false;
  @override
  void initState() {
    super.initState();
    emailFocusNode.addListener(() {
      setState(() {
        isEmailFocused = emailFocusNode.hasFocus;
      });
    });

    nameFocusNode.addListener(() {
      setState(() {
        isNameFocused = nameFocusNode.hasFocus;
      });
    });

    phoneFocusNode.addListener(() {
      setState(() {
        isPhoneFocused = phoneFocusNode.hasFocus;
      });
    });

    passwordFocusNode.addListener(() {
      setState(() {
        isPasswordFocused = passwordFocusNode.hasFocus;
      });
    });

    confirmFocusNode.addListener(() {
      setState(() {
        isConfirmFocused = confirmFocusNode.hasFocus;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(emailFocusNode);
    });
  }

  @override
  void dispose() {
    emailFocusNode.dispose();
    nameFocusNode.dispose();
    phoneFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmFocusNode.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      isFormValid = _formKey.currentState?.validate() ?? false;
    });
  }

 void _onPressedNextButton() async{
    setState((){
      isPending = true;
    });
    String numbers = '+1${phoneNumberController.text}';
    context.read<DriverViewModel>().setEmail(emailController.text);
    context.read<DriverViewModel>().setFullName(nameController.text);
    context.read<DriverViewModel>().setPhoneNumber(numbers);
    context.read<DriverViewModel>().setPassword(passwordController.text);
    context
        .read<DriverViewModel>()
        .setPasswordConfirmation(confirmController.text);
    context.read<DriverViewModel>().setCity(selectedCity!);
    final DioService dioService = DioService();
    final data = {
      "phone_number":numbers
    };
    final response = await dioService.postRequest("/checkDriverPhoneNumber", data: data);
    if(response.data['status'] == "success") {
      final requestData = {'method': 'temp', 'phone_number': numbers};
      final result = await dioService.postRequest("/sendVerificationCode", data: requestData);
      setState((){
        isPending = false;
      });
      final tmpId = result.data['tmpId'];
      logger.i(result.data);
      if (result.statusCode == 200) {
        showTopSnackBar(Overlay.of(context), const CustomSnackBar.success(message: "Received OTP code successfully"));
        Navigator.push(
          context,
          MaterialPageRoute(
                  builder: (context) => Verificationpage(
                    phoneNumber: phoneNumberController.text,
                    tmpId: tmpId,
                    flag: 'temp',
                    beforevalue: "register",
                  )));
      } else if (result.statusCode == 400) {
        showTopSnackBar(Overlay.of(context), const CustomSnackBar.error(message: "Failed to send SMS. Please try again!"));
      } else if (result.statusCode == 401) {
        showTopSnackBar(Overlay.of(context), const CustomSnackBar.error(message: "Unregistered phone number."));
      }

    // await auth.verifyPhoneNumber(
    //     phoneNumber: numbers,
    //     verificationCompleted: (PhoneAuthCredential credential) async {
    //       // Auto-completion of the SMS verification code
    //       try {
    //         await auth.signInWithCredential(credential).then((value) {
    //           logger.i("You are logged in successfully");
    //         });
    //       } catch (e) {
    //         logger.e("Failed to sign in with credential: ${e.toString()}");
    //       }
    //     },
    //     verificationFailed: (FirebaseAuthException exception) {
    //       setState((){
    //         isPending = false;
    //       });
    //       showTopSnackBar(
    //         Overlay.of(context),
    //         CustomSnackBar.error(
    //           message: ("Verification failed: ${exception.message}"),
    //         ),
    //       );
    //     },
    //     codeSent: (String verificationID, int? resendToken) async {
    //       // Handle when the code is sent successfully
    //       logger.i("Verification code sent.");
    //       verificationIDReceived = verificationID;
    //       logger.i(verificationID);
    //       otpCodeVisible = true;
    //       logger.i(numbers);
    //       if (otpCodeVisible) {
    //       setState((){
    //         isPending = false;
    //       });
    //         showTopSnackBar(
    //           Overlay.of(context),
    //           const CustomSnackBar.success(
    //             message: "Received OTP code successfully",
    //           ),
    //         );
    //       Navigator.push(
    //           context,
    //           MaterialPageRoute(
    //               builder: (context) => Verificationpage(
    //                     phoneNumber: numbers,
    //                     tmpId: 0,
    //                     flag: 'temp',
    //                     beforevalue: "register",
    //                   )));
    //             }
    //           },
    //     codeAutoRetrievalTimeout: (String verificationId) {
    //       logger.i("Code auto-retrieval timeout.");
    //     },
    //   );
    } else {
      setState(() {
        isPending = false;
      });
      if(!mounted) return;
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: ("This number was already registered"),
        ),
      );
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
      appBar: AppBar(
        title: const Text(Apptext.registerPageTitleText),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(Apptext.backIconImage),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          onChanged: _validateForm,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tell us about yourself.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                focusNode: emailFocusNode,
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  labelStyle: TextStyle(
                    color: isEmailFocused
                        ? ColorManager.primarycolor
                        : Colors.black,
                  ),
                  hintText: 'name@example.com',
                  border: defaultBorder,
                  focusedBorder: focusedBorder,
                  enabledBorder: enabledInputBorder,
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email address';
                  }
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      focusNode: passwordFocusNode,
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(
                            color: isPasswordFocused
                                ? ColorManager.primarycolor
                                : Colors.black),
                        hintText: 'Input your password',
                        border: defaultBorder,
                        focusedBorder: focusedBorder,
                        enabledBorder: enabledInputBorder,
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16), // Spacing between the two fields
                  Expanded(
                    child: TextFormField(
                      focusNode: confirmFocusNode,
                      controller: confirmController,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        labelStyle: TextStyle(
                            color: isConfirmFocused
                                ? ColorManager.primarycolor
                                : Colors.black),
                        hintText: 'Input your confirm password',
                        border: defaultBorder,
                        focusedBorder: focusedBorder,
                        enabledBorder: enabledInputBorder,
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your confirm password';
                        }
                        if (value != passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                focusNode: nameFocusNode,
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: TextStyle(
                    color: isNameFocused
                        ? ColorManager.primarycolor
                        : Colors.black,
                  ),
                  hintText: 'Input your full name',
                  border: defaultBorder,
                  focusedBorder: focusedBorder,
                  enabledBorder: enabledInputBorder,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InternationalPhoneNumberInput(
                focusNode: phoneFocusNode,
                onInputChanged: (PhoneNumber value) {
                  setState(() {
                    number = value;
                  });
                },
                onInputValidated: (bool value) {
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
                maxLength: 15,
                keyboardType: const TextInputType.numberWithOptions(
                    signed: true, decimal: true),
                inputDecoration: InputDecoration(
                  labelText: "Phone Number",
                  labelStyle: const TextStyle(color: Colors.black),
                  floatingLabelStyle: TextStyle(
                    color: ColorManager.primarycolor,
                  ),
                  border: defaultBorder,
                  focusedBorder: focusedBorder,
                  enabledBorder: enabledInputBorder,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  } 
                  // else if (value.length != 10) {
                  //   return 'Phone number must be 10 digits long';
                  // }
                  return null;
                },
                onSaved: (PhoneNumber value) {
                  logger.i('On Saved: $value');
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                items: cities.map((String city) {
                  return DropdownMenuItem<String>(
                    value: city,
                    child: Text(city),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCity = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your city';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: isChecked,
                    onChanged: (bool? newValue) {
                      setState(() {
                        isChecked = newValue ?? false;
                      });
                      _validateForm();
                    },
                    activeColor: ColorManager
                        .primarycolor, // Customize the active color here
                    checkColor: Colors.white, // Customize the check color here
                  ),
                  const Expanded(
                    child: Text(
                      'By proceeding, I agree that KenoRide can collect, use and disclose the information provided by me in accordance with the Privacy Policy and Terms & Condition.',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isChecked && isFormValid
                      ? () {
                          if (_formKey.currentState?.validate() ?? false) {
                            // Form is valid, proceed to the next step
                            // print("Form is valid and ready to proceed");
                            _onPressedNextButton();
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor:
                        isChecked ? ColorManager.primarycolor : Colors.grey,
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isFormValid && isChecked
                            ? [
                                ColorManager.darkprimarycolor,
                                ColorManager.primarycolor
                              ]
                            : [
                                ColorManager.primary10color,
                                ColorManager.primary10color
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
                      child:  isPending? const Row(
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
            ],
          ),
        ),
      ),
    );
  }
}
