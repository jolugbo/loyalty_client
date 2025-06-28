import 'package:flutter/material.dart';
import 'package:moniback/utils/constants/app_colors.dart';
import 'package:moniback/utils/styles/text_style.dart';
typedef ValidatorFunction = String? Function(String? value);
class AppTextFields extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final bool isPassword;
  final bool isReadOnly;
  final VoidCallback? onTab;
  final String? error;
  final ValidatorFunction? validator;

  const AppTextFields({
    super.key,
    required this.controller,
    required this.hint,
    this.validator,
    //this.onChanged,
    this.isPassword = false,
    this.keyboardType,
    this.isReadOnly = false,
    this.onTab,
    this.error,
  });

  @override
  State<AppTextFields> createState() => _AppTextFieldsState();
}

class _AppTextFieldsState extends State<AppTextFields> {
  bool _isPasswordVisible = false;
  String? errorText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      onTap: widget.onTab,
      keyboardType: widget.keyboardType,
      obscureText: widget.isPassword && !_isPasswordVisible,
      style: AppTextStyle.body(fontWeight: FontWeight.bold, size: 15),
      validator: widget.validator, // Use the validator
      readOnly: widget.isReadOnly,
      decoration: InputDecoration(
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColor.primaryColor),
        ),
        hintText: widget.hint,
        errorText: errorText,
        hintStyle: AppTextStyle.body(size: 12.5, fontWeight: FontWeight.normal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(width: 0.1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(width: 0.3),
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
      ),
      onChanged: (value) {
        setState(() {
          errorText = widget.validator!(value);
        });
      },
    );
  
  }
}
