import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:moniback/models/slide_models.dart';
import 'package:moniback/modules/home_tabs/pages/home.dart';
import 'package:moniback/modules/login.dart';
import 'package:moniback/modules/signup/signup.dart';
import 'package:moniback/modules/walk_through/widgets/indicator.dart';
import 'package:moniback/modules/walk_through/widgets/slide.dart';
import 'package:moniback/utils/constants/app_colors.dart';
import 'package:moniback/utils/constants/app_images.dart';
import 'package:moniback/utils/styles/text_style.dart';
import 'package:moniback/utils/widget/app_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class Permission extends StatefulWidget {
  const Permission({super.key});

  @override
  State<Permission> createState() => _PermissionState();
}

class _PermissionState extends State<Permission>
    with SingleTickerProviderStateMixin {
  int index = 0;
  final PageController _controller = PageController();

  final List<SlideModel> slides = [
    SlideModel(
      imagePath: AppImages.walkthrough1,
      titleText: 'Discover Exclusive Deals',
      subtitleText:
          'Unlock discounts, perks, and upgrades you won’t find anywhere else.',
    ),
    SlideModel(
      imagePath: AppImages.walkthrough2,
      titleText: 'Claim Vouchers in Seconds',
      subtitleText:
          'Browse curated offers and save your favorite deals with just a tap.',
    ),
    SlideModel(
      imagePath: AppImages.walkthrough3,
      titleText: 'Redeem When You Arrive',
      subtitleText:
          'Show your voucher at the location and enjoy instant benefits, no hidden steps.',
    ),
  ];

  @override
  void initState() {
    super.initState();
  }

  Future<void> requestLocation(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    // Check permission status
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permissions are denied')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permissions are permanently denied.')),
      );
      return;
    }

    // If permissions are granted, get the current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text('Location: ${position.latitude}, ${position.longitude}')),
    );
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return WillPopScope(
        onWillPop: () async {
          exit(0);
          //showExitAppBottomModal(context);
        },
        child: Scaffold(
          body: Stack(
            children: [
              Image.asset(
                AppImages.permission_header,
                width: size.width,
                height: size.height * 0.3,
                fit: BoxFit.cover,
              ),
              Container(
                height: size.height,
                color: Colors.transparent,
                width: size.width,
                alignment: Alignment.bottomCenter,
                padding: EdgeInsets.fromLTRB(0, size.height * 0.19, 0, 0),
                child: Image.asset(
                  AppImages.permission_bg,
                  width: size.width,
                  height: size.height,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: size.height * 0.7,
                child: Container(
                  height: size.height,
                  color: AppColor.background2,
                  width: size.width,
                  alignment: Alignment.bottomCenter,
                  padding: EdgeInsets.fromLTRB(0, size.height * 0.19, 0, 0),
                  child: Image.asset(
                    AppImages.permission_bg,
                    width: size.width,
                    height: size.height,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: size.height * 0.32,
                child: Container(
                  height: size.height,
                  alignment: Alignment.topLeft,
                  //color: AppColor.Red,
                  width: size.width,
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(
                            size.width * 0.03, 0, size.width * 0.08, 0),
                        width: size.width * 0.8,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: "One last step...\n",
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  color: AppColor.black,
                                ),
                              ),
                              TextSpan(
                                text:
                                    "To get the most out of Moniback, you’ll need to allow the following:",
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
                      SizedBox(
                        height: size.height * 0.05,
                      ),
                      Container(
                          padding:
                              EdgeInsets.fromLTRB(size.width * 0.05, 0, 0, 0),
                          width: size.width,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    AppImages.router,
                                    width: 20,
                                    height: 20,
                                    fit: BoxFit.cover,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    width: size.width * 0.8,
                                    child: const Text.rich(
                                      textAlign: TextAlign.start,
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "Location\n",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: AppColor.black,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                "Share your location to get the nearby recommendations",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: AppColor.black,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: size.height * 0.02,
                              ),
                              Row(
                                children: [
                                  Image.asset(
                                    AppImages.notification,
                                    width: 20,
                                    height: 20,
                                    fit: BoxFit.cover,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    width: size.width * 0.6,
                                    child: const Text.rich(
                                      textAlign: TextAlign.start,
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "Notifications\n",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: AppColor.black,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                "Find out about any updates to your bookings and exclusive deals",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: AppColor.black,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          )),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: size.height * 0.8,
                child: Container(
                  height: size.height * 0.3,
                  width: size.width,
                  color: AppColor.background2,
                  alignment: Alignment.bottomCenter,
                  padding: EdgeInsets.fromLTRB(
                      size.width * 0.06, 0, size.width * 0.06, 0),
                  child: Column(
                    children: [
                      AppButton(
                          title: 'Sure',
                          color: AppColor.primaryColor,
                          textColor: AppColor.black,
                          onTap: () {
                            requestLocation(context);
                          }),
                      SizedBox(
                        height: size.height * 0.01,
                      ),
                      AppButton(
                          title: 'I’ll do this later',
                          color: Colors.transparent,
                          textColor: AppColor.black,
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage()));
                          })
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
