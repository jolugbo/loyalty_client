import 'package:flutter/material.dart';
import 'package:moniback/modules/forgot_password/check_email.dart';
import 'package:moniback/modules/signup/signup.dart';
import 'package:moniback/modules/signup/verification_code.dart';
import 'package:moniback/providers/auth_providers.dart';
import 'package:moniback/providers/session_manager.dart';
import 'package:moniback/utils/constants/app_colors.dart';
import 'package:moniback/utils/constants/app_images.dart';
import 'package:moniback/modules/home_tabs/index.dart';
import 'package:moniback/utils/functions/helper.dart';
import 'package:moniback/utils/widget/app_button.dart';
import 'package:moniback/utils/widget/app_text_fields.dart';
import 'package:moniback/utils/widget/custom_snackbar.dart';
import 'package:provider/provider.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  bool isLoading = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isFormValid = false;
  bool _obscurePassword = true;

  void _checkFormValid() {
    setState(() {
      _isFormValid = _formKey.currentState?.validate() ?? false;
    });
  }

  void _checkPinValid() {
    setState(() {
      _isFormValid = _formKey.currentState?.validate() ?? false;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> checkEmail(AuthProvider authProvider) async {
    bool hasInternet = await HelperClass().hasInternetConnection();
    if (hasInternet) {
      setState(() {
        isLoading = true;
      });

      final response =
          await authProvider.forgotPass(email: emailController.text);

      setState(() {
        isLoading = false;
      });
      if (response['success']) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Check_Email(
                      email: emailController.text,
                    )));
      } else {
        CustomSnackbar.showError(context, response['data']);
      }

      // if (response['success']) {
      //   final sessionManager =
      //       Provider.of<SessionManager>(context, listen: false);

      //   Provider.of<SessionManager>(context, listen: false).updateTokens(
      //       accessToken: response['access_token'],
      //       refreshToken: response['refresh_token']);
      //   Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //           builder: (context) => VerificationCode(
      //                 emailOrPhone:emailController.text,
      //               )));
      // } else {
      //   CustomSnackbar.showError(context, response['data']);
      // }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No internet connection. Please try again later.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final size = MediaQuery.of(context).size;

    return Scaffold(
        // backgroundColor: AppColor.primaryColor, // Neon green background
        body: Stack(
            //overflow: Overflow.visible,
            children: <Widget>[
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                onChanged: _checkFormValid,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: size.height * 0.1,
                    ),
                    Container(
                      width: size.width * 0.8,
                      child: const Text.rich(
                        textAlign: TextAlign.start,
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Forgot Password\n\n",
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: AppColor.black,
                              ),
                            ),
                            TextSpan(
                              text:
                                  "Kindly provide email address for a forgot password link to be sent to.",
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
                          "Email address ",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColor.black,
                            fontWeight: FontWeight.w500,
                          ),
                        )),
                    const SizedBox(height: 10),
                    AppTextFields(
                        controller: emailController,
                        validator: (value) =>
                            value!.isEmpty ? 'email address is required' : null,
                        hint: 'Enter your email address'),
                    const SizedBox(height: 10),
                    Visibility(
                        visible: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                width: size.width * 0.9,
                                child: const Text(
                                  "Password ",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColor.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )),
                            const SizedBox(height: 10),
                            // Password field
                            AppTextFields(
                                isPassword: _obscurePassword,
                                controller: passwordController,
                                validator: (value) => value!.isEmpty
                                    ? 'Password is Required'
                                    : null,
                                hint: 'Enter your Password'),
                            // AppTextFields(
                            //     controller: emailController,
                            //     validator: (value) => value!.isEmpty
                            //         ? 'password is required'
                            //         : null,
                            //     hint: 'Enter your password'),
                            const SizedBox(height: 15),
                            GestureDetector(
                              child: Container(
                                  width: size.width * 0.9,
                                  alignment: Alignment.bottomRight,
                                  child: const Text(
                                    "Forgot your Password?",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColor.grey2,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )),
                            ),
                          ],
                        )),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: size.width * 0.9,
                      child: AppButton(
                          title: 'Continue',
                          isEnabled: _isFormValid,
                          textColor: AppColor.black,
                          color: AppColor.primaryColor,
                          textSize: 16,
                          onTap: () async {
                            if (_formKey.currentState!.validate()) {
                              await checkEmail(authProvider);
                            }
                          }),
                    ),
                  ],
                ),
              )),
          Positioned(
            top: size.height * 0.85,
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    Container(
                      width: size.width * 0.9,
                      child: const Text.rich(
                        textAlign: TextAlign.start,
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  "By signing up or loggin in, you acknowledge and agree to Moniback’s",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppColor.black,
                              ),
                            ),
                            TextSpan(
                              text: " General Terms of Use ",
                              style: TextStyle(
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                                color: AppColor.black,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                              text: "and",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppColor.black,
                              ),
                            ),
                            TextSpan(
                              text: " Privacy Policy",
                              style: TextStyle(
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                                color: AppColor.black,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            // width: size.width * 0.8,
                            // alignment: Alignment.bottomRight,
                            child: const Text(
                          "Powered by",
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColor.lightdark,
                            fontWeight: FontWeight.w400,
                          ),
                        )),
                        SizedBox(height: size.height * 0.1),
                        Image.asset(
                          AppImages.q_logo,
                          // width: 50,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      ],
                    )
                  ],
                )),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColor.primaryColor,
                ),
              ),
            ),
        ]));
  }
}
