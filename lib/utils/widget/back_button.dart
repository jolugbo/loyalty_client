import 'package:flutter/material.dart';
import 'package:moniback/utils/constants/app_colors.dart';

class GoBackButtton extends StatelessWidget {
  final Color color;
  final Color iconColor;
  final Color borderColor;
  const GoBackButtton({
    super.key,
    this.color = Colors.transparent,
    this.iconColor = AppColor.white,
    this.borderColor = AppColor.bordergrey,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      child: Container(
        height: 35,
        width: 35,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(color: borderColor)),
        child: Icon(Icons.arrow_back, size: 25, color: iconColor),
      ),
    );
  }
}
