import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moniback/models/slide_models.dart';
import 'package:moniback/modules/home_tabs/pages/home.dart';
import 'package:moniback/modules/signup/signup.dart';
import 'package:moniback/modules/walk_through/permissions.dart';
import 'package:moniback/modules/walk_through/widgets/indicator.dart';
import 'package:moniback/modules/walk_through/widgets/slide.dart';
// import 'package:gt_delivery/constant/app_color.dart';
// import 'package:gt_delivery/constant/app_images.dart';
// import 'package:gt_delivery/core/models/enumerators/button.dart';
// import 'package:gt_delivery/core/models/slide_models.dart';
// import 'package:gt_delivery/modules/create_account/create_account.dart';
// import 'package:gt_delivery/modules/home/home.dart';
// import 'package:gt_delivery/modules/login/welcome_back.dart';
// import 'package:gt_delivery/utils/textstyles/text_styles.dart';
// import 'package:gt_delivery/modules/walk_through/widgets/indicator.dart';
// import 'package:gt_delivery/modules/walk_through/widgets/slide.dart';
// import 'package:gt_delivery/utils/widget/button.dart';
import 'package:moniback/utils/constants/app_colors.dart';
import 'package:moniback/utils/constants/app_images.dart';
import 'package:moniback/utils/styles/text_style.dart';
import 'package:moniback/utils/widget/app_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class WalkthroughScreen extends StatefulWidget {
  const WalkthroughScreen({super.key});

  @override
  State<WalkthroughScreen> createState() => _WalkthroughScreenState();
}

class _WalkthroughScreenState extends State<WalkthroughScreen>
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToNextPage();
      _animateSlider();
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _navigateToNextPage() async {
    await Future.delayed(const Duration(seconds: 2)); // Splash screen delay
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      // Navigate to the Home page if the user is signed in
      final prefs = await SharedPreferences.getInstance();
      final key = prefs.getString("key");
      final id = prefs.getString("username");
      if (key != null && key != "") {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Home(
                      token: key,
                      // userId: id,
                    )));
      }
    }
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
          body: SizedBox(
              width: double.infinity,
              height: double.infinity, // Ensure full height
              child: Stack(
                children: [
                  Positioned.fill(
                    child: PageView.builder(
                      controller: _controller,
                      onPageChanged: (val) {
                        index = val;
                        setState(() {});
                      },
                      itemCount: slides.length,
                      itemBuilder: (_, index) => WalkthroughItem(
                        model: slides[index],
                      ),
                    ),
                  ),
                  Container(
                    height: size.height * 0.9,
                    width: size.width,
                    alignment: Alignment.bottomCenter,
                    padding: EdgeInsets.fromLTRB(
                        size.width * 0.06, 0, size.width * 0.06, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SlideIndicator(
                            currentIndex: index, total: slides.length),
                        SizedBox(height: 27.h),
                        Visibility(
                          visible: (index == 2),
                          child: AppButton(
                              title: 'Start claiming deals',
                              color: AppColor.primaryColor,
                              textColor: AppColor.black,
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Permission()));
                              }),
                        )

                        // AppButton(
                        //   // isValidated: true,R
                        //   buttonText: 'Get Started',
                        //   onPressed: () {
                        //     Navigator.push(
                        //           context,
                        //           MaterialPageRoute(
                        //               builder: (context) => const CreateAccount()));
                        //   },
                        // ),
                      ],
                    ),
                  ),
                ],
              )),
        ));
  }

  void _animateSlider() {
    Future.delayed(const Duration(seconds: 3)).then((_) {
      if (!_controller.hasClients) return;
      index = _controller.page!.round() + 1;

      if (index == slides.length) {
        index = 0;
      }

      _controller
          .animateToPage(index,
              duration: const Duration(milliseconds: 800),
              curve: Curves.fastOutSlowIn)
          .then((_) => _animateSlider());
    });
  }
}
