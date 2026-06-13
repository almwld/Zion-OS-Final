import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/theme_provider.dart';
import 'desktop_home.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final TextEditingController _pinController = TextEditingController();
  final String _correctPin = "1234";
  String _errorMessage = "";
  String _currentTime = "";
  String _currentDate = "";

  @override
  void initState() {
    super.initState();
    _updateDateTime();
  }

  void _updateDateTime() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        final now = DateTime.now();
        setState(() {
          _currentTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
          _currentDate = "${now.day}/${now.month}/${now.year}";
        });
        _updateDateTime();
      }
    });
  }

  void _unlock() {
    if (_pinController.text == _correctPin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ZionDesktop()),
      );
    } else {
      setState(() {
        _errorMessage = "security.pin_incorrect".tr();
        _pinController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: theme.isDarkMode
                ? [const Color(0xFF0D2E3B), const Color(0xFF03090C)]
                : [const Color(0xFFE0F7FA), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.5)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text("Z", style: TextStyle(fontSize: 55, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "app_name".tr(),
                    style: theme.getThemeData().textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 50),
                  Text(_currentTime, style: theme.getThemeData().textTheme.displayLarge),
                  const SizedBox(height: 8),
                  Text(_currentDate, style: theme.getThemeData().textTheme.bodyMedium),
                  const SizedBox(height: 50),
                  Container(
                    width: screenWidth * 0.65,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    decoration: BoxDecoration(
                      color: theme.isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: theme.primaryColor.withOpacity(0.5)),
                    ),
                    child: TextField(
                      controller: _pinController,
                      obscureText: true,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.primaryColor, fontSize: 24, letterSpacing: 10),
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      decoration: const InputDecoration(
                        hintText: "••••",
                        border: InputBorder.none,
                        counterText: "",
                      ),
                      onSubmitted: (_) => _unlock(),
                    ),
                  ),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Text(_errorMessage, style: const TextStyle(color: Colors.red)),
                    ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: screenWidth * 0.8,
                    child: GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 3,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 20,
                      childAspectRatio: 1.1,
                      children: [
                        _buildButton("1", theme), _buildButton("2", theme), _buildButton("3", theme),
                        _buildButton("4", theme), _buildButton("5", theme), _buildButton("6", theme),
                        _buildButton("7", theme), _buildButton("8", theme), _buildButton("9", theme),
                        _buildButton("", theme), _buildButton("0", theme), _buildDeleteButton(theme),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String num, ThemeProvider theme) {
    return GestureDetector(
      onTap: () {
        if (_pinController.text.length < 4) {
          _pinController.text += num;
          if (_pinController.text.length == 4) _unlock();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
        ),
        child: Center(
          child: Text(num, style: TextStyle(color: theme.primaryColor, fontSize: 28, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(ThemeProvider theme) {
    return GestureDetector(
      onTap: () {
        if (_pinController.text.isNotEmpty) {
          _pinController.text = _pinController.text.substring(0, _pinController.text.length - 1);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
        ),
        child: Center(
          child: Icon(Icons.backspace, color: theme.primaryColor, size: 28),
        ),
      ),
    );
  }
}
