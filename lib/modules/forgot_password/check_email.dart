import 'package:flutter/material.dart';
import 'package:moniback/modules/forgot_password/forgot_password.dart';
import 'package:moniback/modules/login.dart';
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

class Check_Email extends StatefulWidget {
  final email;
  const Check_Email({super.key, required this.email});

  @override
  State<Check_Email> createState() => _Check_EmailState();
}

class _Check_EmailState extends State<Check_Email> {
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

  @override
  void initState() {
    super.initState();
    // emailController.text = "ike.enenmoh@atomsinteractive.com";
    // passwordController.text = "Donnacha@83";

//      hammed.sanni@atomsbusiness.com
// Atoms@112
  }

  Future<void> resendOTP(AuthProvider authProvider) async {
    try {
      setState(() {
        isLoading = true;
      });

        final resp = await authProvider.otp(email: widget.email);
      setState((){
          isLoading = false;
        if (resp['success']) {
          CustomSnackbar.showSuccess(context, resp['data']);
        } else {
          CustomSnackbar.showError(context, resp['data']);
        }
      });
    } catch (e) {
      print("Error: $e");
      CustomSnackbar.showError(context, "An unexpected error occurred.");
    } finally {
      setState(() {
        isLoading = false;
      });
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
          Container(
              height: size.height,
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: size.height * 0.1,
                  ),
                  Image.asset(
                    AppImages.check_email,
                    width: 300,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    width: size.width * 0.9,
                    child:  Text.rich(
                      textAlign: TextAlign.start,
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: "Check your email\n\n",
                            style:   TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: AppColor.black,
                            ),
                          ),
                          TextSpan(
                            text:
                                "An email has been sent to ${widget.email} with further instructions. If you don't receive the email you can choose to resend it. Please remeber to check your spam folder too",
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColor.black,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    color: AppColor.lightRed,
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          AppImages.caution,
                          width: 30,
                          height: 30,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          width: size.width *
                              0.7, // Ensures the container can expand horizontally
                          child: Text(
                            'The reset link attached to the email can only be used once and expires in the next 2 hours',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.red,
                            ),
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    width: size.width * 0.9,
                    child: GestureDetector(
                    onTap: (){
                       resendOTP(authProvider);
                    },
                    child: const Text(
                      'Resend',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        color: AppColor.dark,
                      ),
                      softWrap: true,
                    ),)
                  ),
                ],
              )),
          Positioned(
            top: size.height * 0.85,
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child:  SizedBox(
                      width: size.width * 0.9,
                      child: AppButton(
                          title: 'Go to Login',
                         // isEnabled: _isFormValid,
                          textColor: AppColor.black,
                          color: AppColor.primaryColor,
                          textSize: 16,
                          onTap: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage()));
                          }),
                    ),),
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
