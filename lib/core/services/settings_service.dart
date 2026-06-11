import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();
  
  // Theme Settings
  bool _darkMode = true;
  String _themeColor = 'Turquoise';
  String _fontFamily = 'Default';
  double _fontSize = 14.0;
  
  // Security Settings
  bool _biometricEnabled = false;
  bool _autoLockEnabled = true;
  int _autoLockTimeout = 30;
  bool _encryptionEnabled = true;
  
  // Notification Settings
  bool _pushNotifications = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  
  // Privacy Settings
  bool _incognitoMode = false;
  bool _clearHistoryOnExit = false;
  bool _hideActivities = false;
  
  // Performance Settings
  bool _animationsEnabled = true;
  bool _backgroundProcesses = true;
  String _performanceMode = 'Balanced';
  
  // Display Settings
  String _language = 'ar';
  String _dateFormat = 'DD/MM/YYYY';
  String _timeFormat = '24h';
  
  Future<void> init() async {
    await _loadAllSettings();
  }
  
  Future<void> _loadAllSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Theme
    _darkMode = prefs.getBool('dark_mode') ?? true;
    _themeColor = prefs.getString('theme_color') ?? 'Turquoise';
    _fontFamily = prefs.getString('font_family') ?? 'Default';
    _fontSize = prefs.getDouble('font_size') ?? 14.0;
    
    // Security
    _biometricEnabled = prefs.getBool('biometric_enabled') ?? false;
    _autoLockEnabled = prefs.getBool('auto_lock_enabled') ?? true;
    _autoLockTimeout = prefs.getInt('auto_lock_timeout') ?? 30;
    _encryptionEnabled = prefs.getBool('encryption_enabled') ?? true;
    
    // Notification
    _pushNotifications = prefs.getBool('push_notifications') ?? true;
    _soundEnabled = prefs.getBool('sound_enabled') ?? true;
    _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
    
    // Privacy
    _incognitoMode = prefs.getBool('incognito_mode') ?? false;
    _clearHistoryOnExit = prefs.getBool('clear_history_on_exit') ?? false;
    _hideActivities = prefs.getBool('hide_activities') ?? false;
    
    // Performance
    _animationsEnabled = prefs.getBool('animations_enabled') ?? true;
    _backgroundProcesses = prefs.getBool('background_processes') ?? true;
    _performanceMode = prefs.getString('performance_mode') ?? 'Balanced';
    
    // Display
    _language = prefs.getString('language') ?? 'ar';
    _dateFormat = prefs.getString('date_format') ?? 'DD/MM/YYYY';
    _timeFormat = prefs.getString('time_format') ?? '24h';
  }
  
  Future<void> saveAllSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Theme
    await prefs.setBool('dark_mode', _darkMode);
    await prefs.setString('theme_color', _themeColor);
    await prefs.setString('font_family', _fontFamily);
    await prefs.setDouble('font_size', _fontSize);
    
    // Security
    await prefs.setBool('biometric_enabled', _biometricEnabled);
    await prefs.setBool('auto_lock_enabled', _autoLockEnabled);
    await prefs.setInt('auto_lock_timeout', _autoLockTimeout);
    await prefs.setBool('encryption_enabled', _encryptionEnabled);
    
    // Notification
    await prefs.setBool('push_notifications', _pushNotifications);
    await prefs.setBool('sound_enabled', _soundEnabled);
    await prefs.setBool('vibration_enabled', _vibrationEnabled);
    
    // Privacy
    await prefs.setBool('incognito_mode', _incognitoMode);
    await prefs.setBool('clear_history_on_exit', _clearHistoryOnExit);
    await prefs.setBool('hide_activities', _hideActivities);
    
    // Performance
    await prefs.setBool('animations_enabled', _animationsEnabled);
    await prefs.setBool('background_processes', _backgroundProcesses);
    await prefs.setString('performance_mode', _performanceMode);
    
    // Display
    await prefs.setString('language', _language);
    await prefs.setString('date_format', _dateFormat);
    await prefs.setString('time_format', _timeFormat);
  }
  
  // Getters and Setters
  bool get darkMode => _darkMode;
  set darkMode(bool value) {
    _darkMode = value;
    saveAllSettings();
  }
  
  String get themeColor => _themeColor;
  set themeColor(String value) {
    _themeColor = value;
    saveAllSettings();
  }
  
  String get fontFamily => _fontFamily;
  set fontFamily(String value) {
    _fontFamily = value;
    saveAllSettings();
  }
  
  double get fontSize => _fontSize;
  set fontSize(double value) {
    _fontSize = value;
    saveAllSettings();
  }
  
  bool get biometricEnabled => _biometricEnabled;
  set biometricEnabled(bool value) {
    _biometricEnabled = value;
    saveAllSettings();
  }
  
  bool get autoLockEnabled => _autoLockEnabled;
  set autoLockEnabled(bool value) {
    _autoLockEnabled = value;
    saveAllSettings();
  }
  
  int get autoLockTimeout => _autoLockTimeout;
  set autoLockTimeout(int value) {
    _autoLockTimeout = value;
    saveAllSettings();
  }
  
  bool get encryptionEnabled => _encryptionEnabled;
  set encryptionEnabled(bool value) {
    _encryptionEnabled = value;
    saveAllSettings();
  }
  
  bool get pushNotifications => _pushNotifications;
  set pushNotifications(bool value) {
    _pushNotifications = value;
    saveAllSettings();
  }
  
  bool get soundEnabled => _soundEnabled;
  set soundEnabled(bool value) {
    _soundEnabled = value;
    saveAllSettings();
  }
  
  bool get vibrationEnabled => _vibrationEnabled;
  set vibrationEnabled(bool value) {
    _vibrationEnabled = value;
    saveAllSettings();
  }
  
  bool get incognitoMode => _incognitoMode;
  set incognitoMode(bool value) {
    _incognitoMode = value;
    saveAllSettings();
  }
  
  bool get clearHistoryOnExit => _clearHistoryOnExit;
  set clearHistoryOnExit(bool value) {
    _clearHistoryOnExit = value;
    saveAllSettings();
  }
  
  bool get hideActivities => _hideActivities;
  set hideActivities(bool value) {
    _hideActivities = value;
    saveAllSettings();
  }
  
  bool get animationsEnabled => _animationsEnabled;
  set animationsEnabled(bool value) {
    _animationsEnabled = value;
    saveAllSettings();
  }
  
  bool get backgroundProcesses => _backgroundProcesses;
  set backgroundProcesses(bool value) {
    _backgroundProcesses = value;
    saveAllSettings();
  }
  
  String get performanceMode => _performanceMode;
  set performanceMode(String value) {
    _performanceMode = value;
    saveAllSettings();
  }
  
  String get language => _language;
  set language(String value) {
    _language = value;
    saveAllSettings();
  }
  
  String get dateFormat => _dateFormat;
  set dateFormat(String value) {
    _dateFormat = value;
    saveAllSettings();
  }
  
  String get timeFormat => _timeFormat;
  set timeFormat(String value) {
    _timeFormat = value;
    saveAllSettings();
  }
  
  Future<void> resetToDefault() async {
    _darkMode = true;
    _themeColor = 'Turquoise';
    _fontFamily = 'Default';
    _fontSize = 14.0;
    _biometricEnabled = false;
    _autoLockEnabled = true;
    _autoLockTimeout = 30;
    _encryptionEnabled = true;
    _pushNotifications = true;
    _soundEnabled = true;
    _vibrationEnabled = true;
    _incognitoMode = false;
    _clearHistoryOnExit = false;
    _hideActivities = false;
    _animationsEnabled = true;
    _backgroundProcesses = true;
    _performanceMode = 'Balanced';
    _language = 'ar';
    _dateFormat = 'DD/MM/YYYY';
    _timeFormat = '24h';
    await saveAllSettings();
  }
}
