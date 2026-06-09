import 'package:flutter/material.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/terminal/terminal_screen.dart';
import 'features/reports/reports_screen.dart';
import 'features/settings/settings_screen.dart';

class ZionApp extends StatelessWidget {
  const ZionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Zion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF00FF41),
        scaffoldBackgroundColor: const Color(0xFF0A0E0A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A0E0A),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(color: Color(0xFF00FF41), fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF0A0E0A),
          selectedItemColor: Color(0xFF00FF41),
          unselectedItemColor: Color(0xFF555555),
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF111811),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF00FF41))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF333333))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF00FF41), width: 2)),
          labelStyle: const TextStyle(color: Color(0xFF00FF41)),
          filled: true,
          fillColor: const Color(0xFF0D120D),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00FF41),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final _pages = const [
    DashboardScreen(),
    TerminalScreen(),
    ReportsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFF1A1A1A), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'لوحة القيادة'),
            BottomNavigationBarItem(icon: Icon(Icons.terminal), label: 'الطرفية'),
            BottomNavigationBarItem(icon: Icon(Icons.assessment), label: 'التقارير'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'الإعدادات'),
          ],
        ),
      ),
    );
  }
}
