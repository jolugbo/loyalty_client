import 'package:flutter/material.dart';
import 'package:moniback/utils/constants/app_colors.dart';
import 'package:moniback/utils/styles/text_style.dart';

class AppButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Color color;
  final Color textColor;
  final Color borderColor;
  final double textSize;
  final double width;
  final bool isEnabled;
  const AppButton({
    super.key,
    required this.title,
    required this.onTap,this.isEnabled = true,
    this.color = AppColor.primaryColor,
    this.textColor = AppColor.white,
    this.borderColor = AppColor.white,
    this.width = double.infinity,
    this.textSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          alignment: Alignment.center,
          height: 45,
          width: width,
          decoration: BoxDecoration(
      color: isEnabled ? color :AppColor.primaryColor2,
              borderRadius: BorderRadius.circular(10),
      border: Border.all(color: isEnabled ? borderColor : Colors.grey),
      ),
          child: Text(
            title,
            style: AppTextStyle.body(
                color: textColor, fontWeight: FontWeight.w600,size: textSize),
          )),
    );
  }
}
