// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:moniback/modules/signup/password.dart';
import 'package:moniback/modules/signup/signup.dart';
import 'package:moniback/providers/auth_providers.dart';
import 'package:moniback/utils/constants/app_colors.dart';
import 'package:moniback/utils/styles/text_style.dart';
import 'package:moniback/utils/widget/app_button.dart';
import 'package:moniback/utils/widget/custom_snackbar.dart';
import 'package:moniback/utils/widget/refresh.dart';
import 'package:provider/provider.dart';

class VerificationCode extends StatefulWidget {
  final String emailOrPhone;
  final String password;
  const VerificationCode({
    super.key,
    required this.emailOrPhone,
    required this.password,
  });

  @override
  State<VerificationCode> createState() => _VerificationCodeState();
}

class _VerificationCodeState extends State<VerificationCode> {
  //
  late Timer _timer;
  int _remainingSeconds = 240;
  bool _isFormEnabled = true;
  // List of controllers for each TextField
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());

  // List of focus nodes for each TextField
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  String pin = "";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        setState(() {
          _isFormEnabled = false;
        });
        _timer.cancel();
      }
    });
  }

  Future<void> verifyUser(AuthProvider authProvider) async {
    if (pin.length != 6) return;

    try {
      setState(() {
        isLoading = true;
      });

      final response =
          await authProvider.verifyOtp(email: widget.emailOrPhone, otp: pin);

      setState(() {
        isLoading = false;
      });
      if (response["data"] == "OTP verification successfully!") {
        CustomSnackbar.showSuccess(context, response["data"]);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Refresh(email: widget.emailOrPhone,password: widget.password,)));
      } else {
        CustomSnackbar.showError(context, response["data"]);
      }

      // final response =
      //     await authProvider.verifyAccount(token: pin, userId: "widget.userId");
      // if (response['success']) {
      //   //log("Signup successful: ${response['data']}");
      //   // Navigate to another screen or show success message
      //   //   final secQuestions = await authProvider.fetchSecQue();

      //   //     // Navigate to the next page and pass the questions data
      //   //     List<dynamic> questions = secQuestions["data"];
      //   //     setState(() {
      //   //       isLoading = false;
      //   //     });
      //   //     Navigator.push(
      //   //         context,
      //   //         MaterialPageRoute(
      //   //             builder: (context) =>
      //   //                 SecurityQuestion(questions: questions,userId: widget.userId,)));

      //   // } else {
      //   //   print("Signup failed: ${response['message']}");
      //   //   CustomSnackbar.showError(context,
      //   //       "Error ${response['data']["message"] ?? response['message']}");
      //   //   // Show error message
      // }
    } catch (e) {
      print("Error: $e");
      CustomSnackbar.showError(context, "An unexpected error occurred.");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> resendOtp(AuthProvider authProvider) async {
    setState(() {
      isLoading = true;
    });
    final resp = await authProvider.otp(email: widget.emailOrPhone);
    setState(() {
      isLoading = false;
    });
    CustomSnackbar.showSuccess(context, resp["data"]);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final size = MediaQuery.of(context).size;

    return Scaffold(
        backgroundColor: AppColor.white,
        body: Stack(
            //overflow: Overflow.visible,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50),
                    // const GoBackButtton(
                    //   iconColor: AppColor.black,
                    // ),
                    Container(
                      width: size.width * 0.7,
                      child: Text.rich(
                        textAlign: TextAlign.start,
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Let’s verify its you\n\n",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: AppColor.black,
                              ),
                            ),
                            TextSpan(
                              text:
                                  "A 6-digit code has been sent to ${widget.emailOrPhone}",
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColor.black,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                        width: size.width * 0.8,
                        child: const Text(
                          "Code",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColor.black,
                            fontWeight: FontWeight.w500,
                          ),
                        )),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List.generate(6, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          width: 50,
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "All fields are required";
                              } else {
                                return null;
                              }
                            },
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            style: const TextStyle(
                              color: Colors.black, // Ensures text is black
                              fontSize: 18,
                            ),
                            decoration: InputDecoration(
                              counterText: "",
                              filled: true,
                              fillColor: Colors
                                  .white, // Sets the background color to white
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: AppColor.primaryColor),
                              ),
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty && index < 5) {
                                // Move to the next field
                                FocusScope.of(context)
                                    .requestFocus(_focusNodes[index + 1]);
                              } else if (value.isEmpty && index > 0) {
                                // Move to the previous field if the current is cleared
                                FocusScope.of(context)
                                    .requestFocus(_focusNodes[index - 1]);
                              }
                              setState(() {
                                pin = _controllers
                                    .map((controller) => controller.text)
                                    .join();
                                print("Entered PIN: $pin");
                              });
                            },
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    Text.rich(TextSpan(children: [
                      TextSpan(
                        text: 'The code will arrive within ',
                        style: AppTextStyle.body(size: 14),
                      ),
                      TextSpan(
                        text: '$_remainingSeconds ',
                        style: AppTextStyle.body(
                            size: 14, fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text: ' sec. You might need to check your junk folder',
                        style: AppTextStyle.body(size: 14),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            startTimer();

                            setState(() {
                              isLoading = false;
                            });
                          },
                      ),
                    ])),
                    const SizedBox(height: 30),
                    Container(
                        width: size.width * 0.4,
                        child: GestureDetector(
                            onTap: () {
                              resendOtp(authProvider);
                            },
                            child: const Text(
                              "Resend",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: AppColor.black,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w500,
                                  decorationThickness: 3),
                            ))),
                    const SizedBox(height: 70),
                    AppButton(
                        color: pin.length != 6
                            ? AppColor.primaryColor2
                            : AppColor.primaryColor,
                        title: 'Continue',
                        textColor: AppColor.black,
                        onTap: () => verifyUser(authProvider))
                  ],
                ),
              ),
              if (isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColor.primaryColor,
                    ),
                  ),
                ),
            ]));
  }
}
