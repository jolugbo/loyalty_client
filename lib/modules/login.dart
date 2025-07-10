import 'package:flutter/material.dart';
import 'package:moniback/modules/forgot_password/forgot_password.dart';
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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoading = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isFormValid = false;
  bool _showPassword = false;
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
    emailController.text = "ike.enenmoh@atomsinteractive.com";
    passwordController.text = "Donnacha@83";

//      hammed.sanni@atomsbusiness.com
// Atoms@112
  }

  Future<void> loginUser(AuthProvider authProvider) async {
    bool hasInternet = await HelperClass().hasInternetConnection();
    if (hasInternet) {
      setState(() {
        isLoading = true;
      });
      final response = await authProvider.login(
          username: emailController.text.trim(),
          password: passwordController.text.trim());

      setState(() {
        isLoading = false;
      });
      if (response['success']) {
        final sessionManager =
            Provider.of<SessionManager>(context, listen: false);

        Provider.of<SessionManager>(context, listen: false).updateTokens(
            accessToken: response['access_token'],
            refreshToken: response['refresh_token']);
        Future.microtask(() {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => indexPage(
                token: response['access_token'],
              ),
            ),
          );
        });
      } else {
        CustomSnackbar.showError(context, response['data']);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No internet connection. Please try again later.')),
      );
    }
  }

  Future<void> verifyUser(AuthProvider authProvider) async {
    bool hasInternet = await HelperClass().hasInternetConnection();
    if (hasInternet) {
      setState(() {
        isLoading = true;
      });

      final response =
          await authProvider.verifyEmail(username: emailController.text);

      setState(() {
        isLoading = false;
      });
      if (response['data'] == "Create an account to get started!") {
        CustomSnackbar.showSuccess(context, response['data']);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SignUpPage(
                      email: emailController.text,
                    )));
      }
      if (response['data'] == "Login to continue") {
        _showPassword = true;
      } else {}
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
                              text: "Login or Sign up\n\n",
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: AppColor.black,
                              ),
                            ),
                            TextSpan(
                              text:
                                  "Get a Moniback account to start claiming exclusive deals wherever you are",
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
                        visible: _showPassword,
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
                              onTap: () => {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ForgotPassword()))
                              },
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
                              if (_showPassword) {
                                await loginUser(authProvider);
                              } else {
                                await verifyUser(authProvider);
                              }
                            }
                          }),
                    ),
                    // const SizedBox(height: 20),
                    // // Password field
                    // TextFormField(
                    //   obscureText: _obscurePassword,
                    //   controller: passwordController,
                    //   validator: (value) =>
                    //       value!.isEmpty ? 'Password is Required' : null,
                    //   style: const TextStyle(color: Colors.black),
                    //   decoration: InputDecoration(
                    //     prefixIcon:
                    //         Icon(Icons.lock_outlined, color: Colors.black),
                    //     suffixIcon: GestureDetector(
                    //       onTap: () {
                    //         setState(() {
                    //           _obscurePassword = !_obscurePassword;
                    //         });
                    //       },
                    //       child: Icon(
                    //         _obscurePassword
                    //             ? Icons.visibility_off
                    //             : Icons.visibility,
                    //         color:
                    //             _obscurePassword ? Colors.grey : Colors.black,
                    //       ),
                    //     ),
                    //     labelText: "PASSWORD",
                    //     labelStyle: TextStyle(color: Colors.black),
                    //     enabledBorder: const UnderlineInputBorder(
                    //       borderSide: BorderSide(color: Colors.black),
                    //     ),
                    //     focusedBorder: const UnderlineInputBorder(
                    //       borderSide: BorderSide(color: Colors.black),
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(height: 10),
                    // const Align(
                    //   alignment: Alignment.center,
                    //   child: Text(
                    //     "Forgot your password?",
                    //     style: TextStyle(
                    //       fontSize: 14,
                    //       color: Colors.black,
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(height: 30),
                    // Login Button
                    // SizedBox(
                    //   width: double.infinity,
                    //   child: AppButton(
                    //       title: 'Continue',
                    //       isEnabled: _isFormValid,
                    //       color: AppColor.dark,
                    //       onTap: () async {
                    //         if (_formKey.currentState!.validate()) {
                    //           await loginUser(authProvider);
                    //         }
                    //       }),
                    // ),
                    // const SizedBox(height: 20),
                    // // Footer
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     const Text(
                    //       "No Qbicles Account? ",
                    //       style: TextStyle(fontSize: 14, color: Colors.black),
                    //     ),
                    //     TextButton(
                    //       onPressed: () {
                    //         Navigator.push(
                    //             context,
                    //             MaterialPageRoute(
                    //                 builder: (context) => SignUpPage()));
                    //       },
                    //       child: const Text(
                    //         "SIGN UP",
                    //         style: TextStyle(
                    //           fontSize: 14,
                    //           fontWeight: FontWeight.bold,
                    //           color: Colors.black,
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
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
