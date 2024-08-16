import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../Providers/main_provider.dart';
import '../Providers/theme_provider.dart';
import 'Pages/test_home_page.dart';
import 'DataBase/database_helper.dart';

void main() async{
  if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.windows || 
                  defaultTargetPlatform == TargetPlatform.linux || 
                  defaultTargetPlatform == TargetPlatform.macOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  await DatabaseHelper().deleteAllListingRecords();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MainProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider())
      ],
      child: const MyApp(),
    )
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeBrightness = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
        }
      ),
      debugShowCheckedModeBanner: false,
      theme: _themeSettings(themeBrightness.isDarkMode),
      home: const TestHomePage(),
    );
  }
}

ThemeData _themeSettings(bool darkMode){
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: darkMode ? Brightness.dark : Brightness.light
    ),
    useMaterial3: true,
  );
}