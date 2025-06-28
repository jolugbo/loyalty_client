import 'package:flutter/material.dart';

class CustomSnackbar {
  // Success Snackbar
  static void showSuccess(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.white), // Success icon
          SizedBox(width: 8),
          Expanded(child: Text(message, style: TextStyle(color: Colors.white))),
        ],
      ),
      backgroundColor: Colors.green, // Success color
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Error Snackbar
  static void showError(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(Icons.error, color: Colors.white), // Error icon
          SizedBox(width: 8),
          Expanded(child: Text(message, style: TextStyle(color: Colors.white))),
        ],
      ),
      backgroundColor: Colors.red, // Error color
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
