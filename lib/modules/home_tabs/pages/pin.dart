import 'package:flutter/material.dart';
import 'package:moniback/providers/auth_providers.dart';
import 'package:moniback/utils/constants/app_colors.dart';
import 'package:moniback/utils/widget/app_button.dart';
import 'package:provider/provider.dart';

class Pin extends StatefulWidget {
  final token;
  const Pin({required this.token, super.key});
  @override
  State<Pin> createState() => _PinState();
}

class _PinState extends State<Pin> {
  int activeTabIndex = 0;
  final TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  late Future<String> _pinFuture;
  @override
  void initState() {
    super.initState();
    _refreshPin(false); // Load the initial PIN
  }

  void _refreshPin(bool newPin) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    setState(() {
      _pinFuture = authProvider.getPin(token: widget.token, isNew: newPin);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    //final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColor.white,
      body: Center(
        child: Container(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                height: size.height * 0.12,
                alignment: Alignment.bottomCenter,
                padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: const Text(
                  "PIN",
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: AppColor.dark),
                ),
              ),
              Container(
                height: 2,
                width: size.width,
                color: Colors.grey[300],
              ),
              Container(
                height: size.height * 0.1,
                alignment: Alignment.bottomCenter,
                padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: const Text(
                  "Security PIN to complete transaction",
                  style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: AppColor.dark),
                ),
              ),
              Container(
                width: size.width * 0.9, alignment: Alignment.center,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: FutureBuilder<String>(
                  future: _pinFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text(
                        "Loading...",
                        style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 40,
                            color: AppColor.dark),
                      );
                    } else if (snapshot.hasError) {
                      return Text(
                        snapshot.error.toString(),
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 40,
                            color: AppColor.dark),
                      );
                    } else {
                      return Text(
                        snapshot.data!,
                        style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 40,
                            color: AppColor.dark),
                      );
                    }
                  },
                ),
              ),
              SizedBox(
                height: size.height * 0.05,
              ),
              Container(
                width: size.width * 0.9,
                alignment: Alignment.centerLeft,
                child: const Text(
                  "Your 4-digit PIN secures your rewards across all Qbicles stores. It’s single-use, after each purchase, you’ll get a new one for your next transaction.",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: AppColor.dark),
                ),
              ),
              SizedBox(
                height: size.height * 0.1,
              ),
              SizedBox(
                width: size.width * 0.9,
                height: size.height * 0.07,
                child: AppButton(
                    title: 'Generate new PIN',
                    color: AppColor.primaryColor,
                    textColor: AppColor.black,
                    onTap: () {
                      _refreshPin(true);
                    }),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
