import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;
  Color _primaryColor = const Color(0xFF00BCD4);
  double _fontScale = 1.0;
  double _iconSize = 58.0;
  String _userPin = "1234";

  bool get isDarkMode => _isDarkMode;
  Color get primaryColor => _primaryColor;
  double get fontScale => _fontScale;
  double get iconSize => _iconSize;

  ThemeProvider() { _loadSettings(); }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('dark_mode') ?? true;
    _fontScale = prefs.getDouble('font_scale') ?? 1.0;
    _iconSize = prefs.getDouble('icon_size') ?? 58.0;
    _userPin = prefs.getString('user_pin') ?? "1234";
    final colorHex = prefs.getString('theme_color');
    if (colorHex != null && colorHex.isNotEmpty) {
      try {
        _primaryColor = Color(int.parse(colorHex));
      } catch (_) { _primaryColor = const Color(0xFF00BCD4); }
    }
    notifyListeners();
  }

  Future<bool> changePin(String oldPin, String newPin) async {
    if (oldPin == _userPin && newPin.length == 4) {
      _userPin = newPin;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_pin', newPin);
      notifyListeners();
      return true;
    }
    return false;
  }

  bool validatePin(String pin) => pin == _userPin;

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await SharedPreferences.getInstance().then((p) => p.setBool('dark_mode', _isDarkMode));
    notifyListeners();
  }

  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color;
    await SharedPreferences.getInstance().then((p) => p.setString('theme_color', color.value.toString()));
    notifyListeners();
  }

  Future<void> setFontScale(double scale) async {
    _fontScale = scale.clamp(0.8, 1.5);
    await SharedPreferences.getInstance().then((p) => p.setDouble('font_scale', _fontScale));
    notifyListeners();
  }

  Future<void> setIconSize(double size) async {
    _iconSize = size.clamp(48.0, 78.0);
    await SharedPreferences.getInstance().then((p) => p.setDouble('icon_size', _iconSize));
    notifyListeners();
  }

  ThemeData getThemeData() {
    final baseTheme = _isDarkMode ? ThemeData.dark() : ThemeData.light();
    return baseTheme.copyWith(
      primaryColor: _primaryColor,
      scaffoldBackgroundColor: _isDarkMode ? Colors.black : Colors.grey[50],
      textTheme: baseTheme.textTheme.apply(
        bodyColor: _isDarkMode ? Colors.white : Colors.black87,
        displayColor: _isDarkMode ? Colors.white : Colors.black87,
        fontFamily: 'Cairo',
        fontSizeFactor: _fontScale,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _isDarkMode ? Colors.black : Colors.white,
        foregroundColor: _primaryColor,
      ),
      iconTheme: IconThemeData(color: _primaryColor, size: 24 * (_iconSize / 58)),
    );
  }
}
