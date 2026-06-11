import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const ZionOSApp());
}

class ZionOSApp extends StatelessWidget {
  const ZionOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zion OS v4.0',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: const Color(0xFF00FF41),
      ),
      home: const SplashScreen(),
    );
  }
}
