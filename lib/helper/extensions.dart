import 'package:flash_downloader/main.dart';
import 'package:flutter/material.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }

  void showSnackbar() {
    scaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
      content: Text(this),
    ));
  }
}
