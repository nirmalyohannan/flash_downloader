import 'package:flash_downloader/global/theme_data.dart';
import 'package:flash_downloader/provider/app_settings_provider.dart';
import 'package:flash_downloader/views/home_screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: 'Flash Downloader',
      theme: themeData,
      home: const ProviderInit(child: HomeScreen()),
    );
  }
}

class ProviderInit extends StatelessWidget {
  final Widget child;
  const ProviderInit({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => AppSettingsProvider.instance),
      ],
      child: child,
    );
  }
}
