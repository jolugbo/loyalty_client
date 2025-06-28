import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:moniback/modules/home_tabs/index.dart';
import 'package:moniback/modules/signup/verification_code.dart';
import 'package:moniback/providers/auth_providers.dart';
import 'package:moniback/providers/session_manager.dart';
import 'package:moniback/utils/functions/helper.dart';
import 'package:moniback/utils/widget/custom_snackbar.dart';
import 'package:provider/provider.dart';

class Refresh extends StatefulWidget {
  final String email;
  final String password;
  const Refresh({
    super.key,
    required this.email,
    required this.password,
  });
  @override
  State<Refresh> createState() => _RefreshState();
}

class _RefreshState extends State<Refresh> {
  bool isLoading = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> loginUser(AuthProvider authProvider) async {
    bool hasInternet = await HelperClass().hasInternetConnection();
    if (hasInternet) {
      setState(() {
        isLoading = true;
      });

      final response = await authProvider.login(
          password: widget.password, username: widget.email);

      setState(() {
        isLoading = false;
      });
      if (response['success']) {
        final sessionManager =
            Provider.of<SessionManager>(context, listen: false);

        Provider.of<SessionManager>(context, listen: false).updateTokens(
            accessToken: response['access_token'],
            refreshToken: response['refresh_token']);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => indexPage(
                      token: response['access_token'],
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
  void initState() {
    super.initState();
    // Wait for 3 seconds then navigate
    Future.delayed(Duration(seconds: 2), () async {
      await loginUser(Provider.of<AuthProvider>(context, listen: false));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8FF3F),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Spacer(),
            Image.asset(
              'assets/images/logo.png',
              width: 160,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}

//
