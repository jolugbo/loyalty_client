import 'package:flutter/material.dart';
import 'package:moniback/modules/store/point_conversion.dart';
import 'package:moniback/utils/constants/app_colors.dart';
import 'package:moniback/utils/constants/app_images.dart';
import 'package:moniback/utils/widget/app_button.dart';
import 'package:moniback/utils/widget/custom_snackbar.dart';

class LoyaltyPointsPage extends StatefulWidget {
  const LoyaltyPointsPage(
      {required this.token, required this.business, super.key});
  final token;
  final business;

  @override
  State<LoyaltyPointsPage> createState() => _LoyaltyPointsPageState();
}

class _LoyaltyPointsPageState extends State<LoyaltyPointsPage> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.white,
        toolbarHeight: size.height * 0.1,
        elevation: 0,
        title: const Text("Loyalty Points",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColor.dark)),
        centerTitle: true,
      ),
      backgroundColor: AppColor.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image(
                        image: AssetImage(AppImages.big_star),
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Loyalty points",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColor.lightdark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${widget.business['Points']}",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: AppColor.dark),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: size.width * 0.7,
                    child: AppButton(
                        title: 'Convert to store credit',
                        isEnabled: widget.business['Points'] != 0,
                        textColor: AppColor.black,
                        color: AppColor.primaryColor,
                        textSize: 16,
                        onTap: () async {
                          if (widget.business['Points'] != 0) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PointConversion(
                                        business: widget.business,
                                        token: widget.token,
                                      )),
                            );
                          } else {
                            CustomSnackbar.showError(
                                context, "No Points available for conversion");
                          }
                        }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // What are loyalty points?
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.star_outline, color: Colors.orange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "What are loyalty points?",
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppColor.dark),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Loyalty points are rewards you earn every time you make a purchase from the store. The more you complete an order, the more points you collect.",
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: AppColor.dark),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),

            // How it works
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isExpanded = !isExpanded;
                      });
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb_outline,
                            color: Colors.green),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "How Loyalty Points work",
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppColor.dark),
                          ),
                        ),
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.black54,
                        )
                      ],
                    ),
                  ),
                  if (isExpanded) ...[
                    const SizedBox(height: 12),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "1. Go to the store (online or physical)",
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: AppColor.dark),
                      ),
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "2. Create an account with the business",
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: AppColor.dark),
                      ),
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "3. Complete a purchase",
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: AppColor.dark),
                      ),
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "4. Get your points",
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: AppColor.dark),
                      ),
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "5. Convert points to store credits which can be used on your next purchase",
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: AppColor.dark),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
