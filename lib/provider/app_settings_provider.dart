import 'package:dio/dio.dart';
import 'package:flash_downloader/helper/network_manager.dart';
import 'package:flutter/material.dart';

class AppSettingsProvider extends ChangeNotifier {
  // Private constructor
  AppSettingsProvider._privateConstructor();

  static final AppSettingsProvider instance =
      AppSettingsProvider._privateConstructor();

  Duration connectionTimeOut = const Duration(seconds: 10);
  Duration recieveTimeOut = const Duration(seconds: 10);
  Duration sendTimeOut = const Duration(seconds: 10);

  void updateNetworkManager() {
    Dio dio = Dio(
      BaseOptions(
        connectTimeout: connectionTimeOut,
        receiveTimeout: recieveTimeOut,
        sendTimeout: sendTimeOut,
      ),
    );
    NetworkManager.dio = dio;
    notifyListeners();
  }
}
