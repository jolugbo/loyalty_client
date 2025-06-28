import 'package:flutter/material.dart';
import 'package:moniback/modules/login.dart';
import 'package:moniback/modules/signup/verification_code.dart';
import 'package:moniback/providers/auth_providers.dart';
import 'package:moniback/utils/functions/helper.dart';
import 'package:moniback/utils/widget/custom_snackbar.dart';
import 'package:moniback/utils/widget/refresh.dart';
import 'package:moniback/utils/constants/app_colors.dart';
import 'package:moniback/utils/constants/app_images.dart';
import 'package:moniback/modules/home_tabs/index.dart';
import 'package:moniback/utils/widget/app_button.dart';
import 'package:moniback/utils/widget/app_text_fields.dart';
import 'package:provider/provider.dart';

class PasswordPage extends StatefulWidget {
  final String email;
  const PasswordPage({
    super.key,
    required this.email,
  });

  @override
  State<PasswordPage> createState() => PasswordPageState();
}

class PasswordPageState extends State<PasswordPage> {
  bool isLoading = false;
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isFormValid = false;
  bool isChecked = false;
  String password = "";
  bool get hasValidLength => password.length >= 8 && password.length <= 20;
  bool get hasNumber => password.contains(RegExp(r'[0-9]'));
  bool get hasLetter => password.contains(RegExp(r'[A-Za-z]'));
  bool get hasSpecialChar =>
      password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|_<>]'));
  Color getIconColor(bool condition) => condition ? Colors.green : Colors.grey;

  void _checkFormValid() {
    setState(() {
      _isFormValid = _formKey.currentState?.validate() ?? false;
    });
  }

  Future<void> createPassword(AuthProvider authProvider) async {
    if(!hasValidLength||!hasSpecialChar||!hasLetter||!hasNumber){
return;
    }
    bool hasInternet = await HelperClass().hasInternetConnection();
    if (hasInternet) {

      setState(() {
        isLoading = true;
      });

      final response =
          await authProvider.createPassword(email: widget.email,password: password);

      setState(() {
        isLoading = false;
      });
      if (response['success']) {
        CustomSnackbar.showSuccess(context, response['data']);
       Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => VerificationCode(
                        emailOrPhone: widget.email,password: password,
                      )));
                              
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
        // backgroundColor: AppColor.primaryColor,
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
                    const SizedBox(height: 50),
                    Container(
                      width: size.width * 0.8,
                      child: const Text.rich(
                        textAlign: TextAlign.start,
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Set up a password\n",
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
                    SizedBox(
                        width: size.width * 0.8,
                        child: const Text(
                          "Create a password",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColor.black,
                            fontWeight: FontWeight.w500,
                          ),
                        )),
                    const SizedBox(height: 15),
                    AppTextFields(
                        controller: passwordController,
                        isPassword: true,
                        validator: (value) {
                          setState(() {
                            password = value!;
                          });
                        },
                        hint: 'input preferred password'),
                    const SizedBox(height: 30),
                    Container(
                      width: size.width * 0.7,
                      child: const Text(
                        "Password must be\n",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColor.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: size.width * 0.9,
                      child: Column(
                        children: [
                          buildValidationRow(
                              "8 - 20 characters", hasValidLength, size),
                          const SizedBox(height: 5),
                          buildValidationRow(
                              "at least 1 number", hasNumber, size),
                          const SizedBox(height: 5),
                          buildValidationRow(
                              "at least 1 letter", hasLetter, size),
                          const SizedBox(height: 5),
                          buildValidationRow("at least 1 special symbol",
                              hasSpecialChar, size),
                        ],
                      ),
                    ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.start,
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   mainAxisSize: MainAxisSize.max,
                    //   children: [
                    //     Checkbox(
                    //       value: isChecked,
                    //       onChanged: (bool? value) {
                    //         setState(() {
                    //           isChecked = value!;
                    //         });
                    //       },
                    //     ),
                    // SizedBox(
                    //   width: size.width * 0.65,
                    //   child: Text(
                    //     "I would love to get exclusive offers and updates from Moniback. I understand i can unsubscribe at any time.",
                    //     style: TextStyle(
                    //       fontSize: 12,
                    //       color: AppColor.black,
                    //       fontWeight: FontWeight.w400,
                    //     ),
                    //   ),
                    // ),
                    // ],
                    //),
                    SizedBox(height: size.height * 0.08),
                    SizedBox(
                      width: size.width * 0.9,
                      height: size.height * 0.07,
                      child: AppButton(
                          title: 'Sign up',
                          //isEnabled: hasValidLength&&hasSpecialChar&&hasLetter&&hasNumber,
                          textColor: AppColor.black,
                          color: AppColor.primaryColor2,
                          textSize: 16,
                          onTap: () async {
                            if (_formKey.currentState!.validate()) {
                               await createPassword(authProvider);
                            }
                          }),
                    ),
                  ],
                ),
              )),
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

  Widget buildValidationRow(String text, bool condition, Size size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: size.width * 0.65,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: condition ? Colors.green : Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Icon(
          Icons.check_circle_outline,
          color: getIconColor(condition),
          size: 20,
        ),
      ],
    );
  }
}
