import 'package:flutter/material.dart';
import 'package:homecare_app/screens/splash_screen.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Homecare App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32), // warna hijau dari logo
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32), // tombol utama
            foregroundColor: Colors.white, // teks tombol
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(
              0xFF2E7D32,
            ), // untuk link seperti "Belum punya akun?"
          ),
        ),
      ),

      builder: FlutterSmartDialog.init(),
      navigatorObservers: [FlutterSmartDialog.observer],
      home: const SplashScreen(),
    );
  }
}
