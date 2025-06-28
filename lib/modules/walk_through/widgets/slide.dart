import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moniback/models/slide_models.dart';
import 'package:moniback/modules/walk_through/permissions.dart';
import 'package:moniback/utils/constants/app_colors.dart';
import 'package:moniback/utils/constants/app_images.dart';
import 'package:moniback/utils/styles/text_style.dart';

class WalkthroughItem extends StatelessWidget {
  final SlideModel model;
  const WalkthroughItem({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: double.infinity, 
      child: Stack(
        children: [
          Image.asset(
            model.imagePath,
            width: size.width,
            height: size.height,
            fit: BoxFit.cover, 
          ),
          Container(
              width: size.width,
              padding: EdgeInsets.fromLTRB(
                  size.width * 0.06, size.width * 0.08, size.width * 0.06, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    AppImages.logo,
                    width: size.width * 0.2,
                  ),
                  GestureDetector(
                    onTap:(){
                       Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Permission()));
                    },
                    child: Text(
                    "Skip",
                    textAlign: TextAlign.center,
                    style: AppTextStyle.body(
                        fontWeight: FontWeight.w400,
                        size: 14,
                        color: AppColor.white),
                  ),
                  )
                  
                ],
              )),

          Container(
            height: size.height * 0.8,
            alignment: Alignment.bottomLeft,
             padding: EdgeInsets.fromLTRB(
                  size.width * 0.06,0, size.width * 0.06,  size.width * 0.08),
              
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "${model.titleText}\n",
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: AppColor.white,
                    ),
                  ),
                   TextSpan(
                    text: model.subtitleText,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColor.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

          ),
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
          //   child:Text(
          //   model.titleText,
          //   textAlign: TextAlign.center,
          //   style: AppTextStyle.body(fontWeight: FontWeight.bold, size: 27,color: AppColor.dark),
          // ),
          // ),

          // SizedBox(height: 8.h),
          // Padding(
          //   padding: EdgeInsets.fromLTRB(12.h, 5, 12.h, 10),
          //   child:Text(
          //   model.subtitleText,
          //   textAlign: TextAlign.center,
          //   style: AppTextStyle.body(size: 16,color: AppColor.lightdark),
          // ),
          // ),
        ],
      ),
    );
  }
}
