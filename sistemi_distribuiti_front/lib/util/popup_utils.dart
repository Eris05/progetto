
import 'package:flutter/material.dart';
class PopupUtils{
static Future<void> showCenterPopup(BuildContext context, String message, {bool isError = false}) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      backgroundColor: isError ? Colors.red[400] : Colors.green[400],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle,
            color: Colors.white,
            size: 26,
          ),
          SizedBox(width: 12),
          Text(
            message,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    ),
  );
  await Future.delayed(Duration(seconds: 1));
  Navigator.of(context, rootNavigator: true).pop();
}
}