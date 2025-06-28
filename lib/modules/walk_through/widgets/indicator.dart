
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moniback/utils/constants/app_colors.dart';

class SlideIndicator extends StatelessWidget {
  final int currentIndex;
  final int total;
  const SlideIndicator(
      {super.key, required this.currentIndex, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        total,
        (index) => _indicator(currentIndex == index),
      ),
    );
  }

  Widget _indicator(bool isCurrent) => AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: isCurrent ? 14.w : 6.w,
        height: 6.w,
        margin: EdgeInsets.symmetric(horizontal: 5.w),
        decoration: BoxDecoration(
          color:
              isCurrent ? AppColor.primaryColor : AppColor.lightgrey,
          borderRadius: BorderRadius.circular(1000.r),
          // gradient: isCurrent
          //     ? const LinearGradient(
          //         colors: [
          //           Color(0xFF232527),
          //           Color(0xFF111318),
          //         ],
          //       )
          //     : null,
        ),
      );
}
