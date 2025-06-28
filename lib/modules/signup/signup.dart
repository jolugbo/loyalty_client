import 'package:flutter/material.dart';
import 'package:moniback/modules/login.dart';
import 'package:moniback/modules/signup/password.dart';
import 'package:moniback/modules/signup/verification_code.dart';
import 'package:moniback/providers/auth_providers.dart';
import 'package:moniback/utils/constants/app_colors.dart';
import 'package:moniback/utils/constants/app_images.dart';
import 'package:moniback/modules/home_tabs/index.dart';
import 'package:moniback/utils/widget/app_button.dart';
import 'package:moniback/utils/widget/app_text_fields.dart';
import 'package:moniback/utils/widget/custom_snackbar.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  final email;
  SignUpPage({
    super.key,
    required this.email,
  });

  @override
  State<SignUpPage> createState() => SignUpState();
}

class SignUpState extends State<SignUpPage> {
  bool isLoading = false;
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isFormValid = false;

  void _checkFormValid() {
    setState(() {
      _isFormValid = _formKey.currentState?.validate() ?? false;
    });
  }

  Future<void> signupUser(AuthProvider authProvider) async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await authProvider.create_account(
          username: userNameController.text,
          email: widget.email,
          firstname: firstNameController.text,
          lastname: lastNameController.text);
      // if (response['data'] == "Account created successfully!") {
      // print(response['data']);
      //   final resp = await authProvider.otp(email: widget.email);
      // }
      setState((){
        if (response['data'] == "Account created successfully!") {
          isLoading = false;
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PasswordPage(
                        email: widget.email,
                      )));
        } else {
          CustomSnackbar.showError(context, response['data']);
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
                              text: "Create account\n\n",
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
                          "First name",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColor.black,
                            fontWeight: FontWeight.w500,
                          ),
                        )),
                    const SizedBox(height: 15),
                    AppTextFields(
                        controller: firstNameController,
                        validator: (value) =>
                            value!.isEmpty ? 'first name is required' : null,
                        hint: 'What is your first name?'),
                    const SizedBox(height: 30),
                    SizedBox(
                        width: size.width * 0.8,
                        child: const Text(
                          "Last name",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColor.black,
                            fontWeight: FontWeight.w500,
                          ),
                        )),
                    const SizedBox(height: 15),
                    AppTextFields(
                        controller: lastNameController,
                        validator: (value) =>
                            value!.isEmpty ? 'last name is required' : null,
                        hint: 'What is your last name?'),
                    const SizedBox(height: 30),
                    SizedBox(
                        width: size.width * 0.8,
                        child: const Text(
                          "Username",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColor.black,
                            fontWeight: FontWeight.w500,
                          ),
                        )),
                    const SizedBox(height: 15),
                    AppTextFields(
                        controller: userNameController,
                        validator: (value) =>
                            value!.isEmpty ? 'username is required' : null,
                        hint: 'Create a unique username'),
                    const SizedBox(height: 20),
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
                              await signupUser(authProvider);
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
}
