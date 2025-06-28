import 'package:flutter/material.dart';
import 'package:moniback/utils/constants/app_colors.dart';

class TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color bgColor;
  final VoidCallback onTap;

  TabButton(
      {required this.label,
      this.isActive = false,
      required this.onTap,
      this.bgColor = Colors.transparent});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          // border: Border.all(color: isEnabled ? borderColor : Colors.grey),
        ),
        child: GestureDetector(
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: isActive ? Colors.black : Colors.grey,
                  fontWeight: isActive ? FontWeight.w400 : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 2,
                width: 50,
                decoration: BoxDecoration(
                  color: isActive ? Colors.black : Colors.transparent,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ));
  }
}

class TabButton2 extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  TabButton2({
    required this.label,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
        decoration: BoxDecoration(
          color: isActive ? AppColor.background : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          // border: Border.all(color: isEnabled ? borderColor : Colors.grey),
        ),
        child: GestureDetector(
          onTap: onTap,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isActive ? Colors.black : Colors.grey,
              fontWeight: isActive ? FontWeight.w400 : FontWeight.normal,
            ),
          ),
        ));
  }
}
