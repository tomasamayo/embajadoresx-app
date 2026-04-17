import 'package:flutter/material.dart';

snackBar(context, message, bgColor, textColor) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))),
      duration: const Duration(seconds: 2),
      elevation: 5,
      backgroundColor: bgColor,
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            style: TextStyle(
                color: textColor, fontSize: 18.0, fontWeight: FontWeight.w300),
          ),
        ],
      ),
    ),
  );
}
