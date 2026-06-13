import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;
  Color _primaryColor = const Color(0xFF00BCD4);
  double _fontScale = 1.0;
  double _iconSize = 58.0;

  bool get isDarkMode => _isDarkMode;
  Color get primaryColor => _primaryColor;
  double get fontScale => _fontScale;
  double get iconSize => _iconSize;

  ThemeProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('dark_mode') ?? true;
    _fontScale = prefs.getDouble('font_scale') ?? 1.0;
    _iconSize = prefs.getDouble('icon_size') ?? 58.0;
    final colorHex = prefs.getString('theme_color');
    if (colorHex != null) {
      _primaryColor = Color(int.parse(colorHex));
    }
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', _isDarkMode);
    notifyListeners();
  }

  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_color', color.value.toString());
    notifyListeners();
  }

  Future<void> setFontScale(double scale) async {
    _fontScale = scale.clamp(0.8, 1.5);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('font_scale', _fontScale);
    notifyListeners();
  }

  Future<void> setIconSize(double size) async {
    _iconSize = size.clamp(48.0, 78.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('icon_size', _iconSize);
    notifyListeners();
  }

  ThemeData getThemeData() {
    return ThemeData(
      brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      primaryColor: _primaryColor,
      colorScheme: ColorScheme(
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        primary: _primaryColor,
        onPrimary: _isDarkMode ? Colors.black : Colors.white,
        secondary: _primaryColor,
        onSecondary: _isDarkMode ? Colors.black : Colors.white,
        error: Colors.red,
        onError: Colors.white,
        background: _isDarkMode ? Colors.black : Colors.grey[50]!,
        onBackground: _isDarkMode ? Colors.white : Colors.black87,
        surface: _isDarkMode ? Colors.grey[900]! : Colors.white,
        onSurface: _isDarkMode ? Colors.white70 : Colors.black54,
      ),
      scaffoldBackgroundColor: _isDarkMode ? Colors.black : Colors.grey[50],
      cardColor: _isDarkMode ? Colors.grey[900] : Colors.white,
      dividerColor: _isDarkMode ? Colors.grey[800] : Colors.grey[300],
      fontFamily: 'Cairo',
      textTheme: TextTheme(
        displayLarge: TextStyle(fontSize: 57 * _fontScale, fontWeight: FontWeight.bold, color: _isDarkMode ? Colors.white : Colors.black87),
        displayMedium: TextStyle(fontSize: 45 * _fontScale, fontWeight: FontWeight.bold, color: _isDarkMode ? Colors.white : Colors.black87),
        displaySmall: TextStyle(fontSize: 36 * _fontScale, fontWeight: FontWeight.bold, color: _isDarkMode ? Colors.white : Colors.black87),
        headlineLarge: TextStyle(fontSize: 32 * _fontScale, fontWeight: FontWeight.w600, color: _isDarkMode ? Colors.white : Colors.black87),
        headlineMedium: TextStyle(fontSize: 28 * _fontScale, fontWeight: FontWeight.w600, color: _isDarkMode ? Colors.white : Colors.black87),
        headlineSmall: TextStyle(fontSize: 24 * _fontScale, fontWeight: FontWeight.w600, color: _isDarkMode ? Colors.white : Colors.black87),
        titleLarge: TextStyle(fontSize: 20 * _fontScale, fontWeight: FontWeight.w500, color: _isDarkMode ? Colors.white : Colors.black87),
        titleMedium: TextStyle(fontSize: 16 * _fontScale, fontWeight: FontWeight.w500, color: _isDarkMode ? Colors.white70 : Colors.black54),
        titleSmall: TextStyle(fontSize: 14 * _fontScale, fontWeight: FontWeight.w500, color: _isDarkMode ? Colors.white60 : Colors.black45),
        bodyLarge: TextStyle(fontSize: 16 * _fontScale, color: _isDarkMode ? Colors.white70 : Colors.black87),
        bodyMedium: TextStyle(fontSize: 14 * _fontScale, color: _isDarkMode ? Colors.white60 : Colors.black54),
        bodySmall: TextStyle(fontSize: 12 * _fontScale, color: _isDarkMode ? Colors.white54 : Colors.black45),
        labelLarge: TextStyle(fontSize: 14 * _fontScale, fontWeight: FontWeight.w500, color: _primaryColor),
        labelMedium: TextStyle(fontSize: 12 * _fontScale, fontWeight: FontWeight.w500, color: _primaryColor),
        labelSmall: TextStyle(fontSize: 11 * _fontScale, fontWeight: FontWeight.w500, color: _primaryColor),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _isDarkMode ? Colors.black : Colors.white,
        foregroundColor: _primaryColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(fontSize: 20 * _fontScale, fontWeight: FontWeight.w600, color: _primaryColor),
      ),
      iconTheme: IconThemeData(color: _primaryColor, size: 24 * (_iconSize / 58)),
      buttonTheme: ButtonThemeData(
        buttonColor: _primaryColor,
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: _isDarkMode ? Colors.black : Colors.white,
          textStyle: TextStyle(fontSize: 14 * _fontScale),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(color: _primaryColor),
        floatingLabelStyle: TextStyle(color: _primaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _primaryColor.withOpacity(0.5))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _primaryColor, width: 2)),
      ),
      cardTheme: CardTheme(
        color: _isDarkMode ? Colors.grey[900] : Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
