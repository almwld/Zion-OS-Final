import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../providers/theme_provider.dart';

class SettingsApp extends StatefulWidget {
  const SettingsApp({super.key});

  @override
  State<SettingsApp> createState() => _SettingsAppState();
}

class _SettingsAppState extends State<SettingsApp> {
  late ThemeProvider _themeProvider;
  String _selectedLanguage = 'ar';
  String _currentPin = '1234';
  double _fontSize = 14.0;
  double _iconSize = 58.0;

  final List<Map<String, dynamic>> _languages = [
    {'code': 'ar', 'name': 'العربية', 'flag': '🇸🇦'},
    {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
  ];

  final List<Map<String, dynamic>> _themeColors = [
    {'name': 'Turquoise', 'color': Color(0xFF00BCD4)},
    {'name': 'Cyan', 'color': Colors.cyan},
    {'name': 'Green', 'color': Colors.green},
    {'name': 'Blue', 'color': Colors.blue},
    {'name': 'Purple', 'color': Colors.purple},
    {'name': 'Orange', 'color': Colors.orange},
    {'name': 'Pink', 'color': Colors.pink},
    {'name': 'Teal', 'color': Colors.teal},
  ];

  @override
  void initState() {
    super.initState();
    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? 'ar';
      _currentPin = prefs.getString('user_pin') ?? '1234';
    });
  }

  void _changeLanguage(String langCode) async {
    setState(() => _selectedLanguage = langCode);
    await context.setLocale(Locale(langCode));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', langCode);
  }

  void _changeThemeColor(Color color) {
    _themeProvider.setPrimaryColor(color);
  }

  void _changeFontSize(double value) {
    setState(() => _fontSize = value);
    _themeProvider.setFontScale(value / 14);
  }

  void _changeIconSize(double value) {
    setState(() => _iconSize = value);
    _themeProvider.setIconSize(value);
  }

  void _showChangePinDialog() {
    final oldPinCtrl = TextEditingController();
    final newPinCtrl = TextEditingController();
    final confirmPinCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('change_pin', style: TextStyle(color: _themeProvider.primaryColor)),
        backgroundColor: _themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPinCtrl,
              obscureText: true,
              style: TextStyle(color: _themeProvider.isDarkMode ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: 'current_pin',
                labelStyle: TextStyle(color: _themeProvider.primaryColor),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: newPinCtrl,
              obscureText: true,
              style: TextStyle(color: _themeProvider.isDarkMode ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: 'new_pin',
                labelStyle: TextStyle(color: _themeProvider.primaryColor),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: confirmPinCtrl,
              obscureText: true,
              style: TextStyle(color: _themeProvider.isDarkMode ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: 'confirm_pin',
                labelStyle: TextStyle(color: _themeProvider.primaryColor),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel', style: TextStyle(color: _themeProvider.primaryColor)),
          ),
          TextButton(
            onPressed: () async {
              if (oldPinCtrl.text == _currentPin) {
                if (newPinCtrl.text == confirmPinCtrl.text && newPinCtrl.text.length == 4) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('user_pin', newPinCtrl.text);
                  _currentPin = newPinCtrl.text;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('PIN changed successfully'), backgroundColor: _themeProvider.primaryColor),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PIN mismatch'), backgroundColor: Colors.red),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Wrong PIN'), backgroundColor: Colors.red),
                );
              }
            },
            child: Text('save', style: TextStyle(color: _themeProvider.primaryColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: theme.isDarkMode ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        title: Text('settings', style: TextStyle(color: theme.primaryColor)),
        backgroundColor: theme.isDarkMode ? Colors.black : Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          _buildSection('appearance', Icons.palette, theme),
          _buildThemeColorRow(theme),
          _buildLanguageRow(theme),
          _buildSliderRow('Font Size', _fontSize, 10, 20, _changeFontSize, theme),
          _buildSliderRow('Icon Size', _iconSize, 48, 78, _changeIconSize, theme),
          SwitchListTile(
            title: Text('dark_mode', style: TextStyle(color: theme.isDarkMode ? Colors.white : Colors.black87)),
            value: theme.isDarkMode,
            onChanged: (_) => theme.toggleTheme(),
            activeColor: theme.primaryColor,
          ),
          _buildSection('security', Icons.security, theme),
          _buildInfoTile('change_pin', 'update_security_pin', Icons.lock, _showChangePinDialog, theme),
          _buildInfoTile('biometric', 'enable_fingerprint', Icons.fingerprint, () {}, theme),
          _buildInfoTile('encryption', 'aes256_active', Icons.security, () {}, theme),
          _buildSection('about', Icons.info, theme),
          _buildInfoTile('version', 'Zion OS 4.0.0', Icons.info, () {}, theme),
          _buildInfoTile('developer', 'Zion Security Team', Icons.code, () {}, theme),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, ThemeProvider theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        children: [
          Icon(icon, color: theme.primaryColor, size: 20),
          const SizedBox(width: 10),
          Text(title, style: TextStyle(color: theme.isDarkMode ? Colors.white : Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildThemeColorRow(ThemeProvider theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('theme_color', style: TextStyle(color: theme.primaryColor)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _themeColors.map((color) => GestureDetector(
              onTap: () => _changeThemeColor(color['color']),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color['color'],
                  shape: BoxShape.circle,
                  border: theme.primaryColor == color['color'] ? Border.all(color: Colors.white, width: 3) : null,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageRow(ThemeProvider theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('language', style: TextStyle(color: theme.isDarkMode ? Colors.white : Colors.black87)),
          DropdownButton<String>(
            value: _selectedLanguage,
            dropdownColor: Colors.black,
            underline: const SizedBox(),
            style: TextStyle(color: theme.primaryColor),
            items: _languages.map((lang) => DropdownMenuItem(
              value: lang['code'],
              child: Row(
                children: [
                  Text(lang['flag'], style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(lang['name']),
                ],
              ),
            )).toList(),
            onChanged: (v) => _changeLanguage(v!),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderRow(String title, double value, double min, double max, Function(double) onChanged, ThemeProvider theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: theme.isDarkMode ? Colors.white : Colors.black87)),
              Text('${value.toStringAsFixed(0)}', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            activeColor: theme.primaryColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, String subtitle, IconData icon, VoidCallback onTap, ThemeProvider theme) {
    return ListTile(
      leading: Icon(icon, color: theme.primaryColor),
      title: Text(title, style: TextStyle(color: theme.isDarkMode ? Colors.white : Colors.black87)),
      subtitle: Text(subtitle, style: TextStyle(color: theme.isDarkMode ? Colors.white54 : Colors.black54)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
