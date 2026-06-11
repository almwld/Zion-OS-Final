import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'desktop_home.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final TextEditingController _pinController = TextEditingController();
  final String _correctPin = "1234";
  final LocalAuthentication _localAuth = LocalAuthentication();
  String _errorMessage = "";
  String _currentTime = "";
  String _currentDate = "";
  String _currentDay = "";
  bool _isLoading = false;
  bool _isBiometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _updateDateTime();
    _checkBiometricAvailability();
  }

  void _updateDateTime() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        final now = DateTime.now();
        setState(() {
          _currentTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
          _currentDay = _getDayName(now.weekday).toUpperCase();
          _currentDate = "${now.day.toString().padLeft(2, '0')} ${_getMonthName(now.month).toUpperCase()} ${now.year}";
        });
        _updateDateTime();
      }
    });
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      setState(() {
        _isBiometricAvailable = isAvailable && isDeviceSupported;
      });
    } catch (_) {
      setState(() {
        _isBiometricAvailable = false;
      });
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    if (!_isBiometricAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biometric authentication not available'), backgroundColor: Colors.orange),
      );
      return;
    }

    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Verify your identity to unlock Zion OS',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      
      if (authenticated) {
        _unlock();
      } else {
        setState(() {
          _errorMessage = "BIOMETRIC AUTHENTICATION FAILED";
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _errorMessage = "");
        });
      }
    } catch (e) {
      print("Biometric error: $e");
    }
  }

  void _unlock() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ZionDesktop()),
      );
    }
  }

  void _checkPin() {
    if (_pinController.text == _correctPin) {
      _unlock();
    } else {
      setState(() {
        _errorMessage = "PIN INCORRECT";
        _pinController.clear();
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _errorMessage = "");
      });
    }
  }

  String _getDayName(int weekday) {
    const days = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isLandscape = screenWidth > screenHeight;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [Color(0xFF0D2E3B), Color(0xFF03090C)],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: Color(0xFF00BCD4)),
                      const SizedBox(height: 16),
                      Text(
                        'LOADING ZION OS...',
                        style: TextStyle(color: const Color(0xFF00BCD4), fontSize: screenWidth * 0.035, letterSpacing: 2),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Container(
                    height: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(flex: 1),
                        
                        // Logo
                        Container(
                          width: screenWidth * 0.2,
                          height: screenWidth * 0.2,
                          constraints: const BoxConstraints(maxWidth: 100, maxHeight: 100),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF00BCD4), Color(0xFF006064)]),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00BCD4).withOpacity(0.5),
                                blurRadius: screenWidth * 0.05,
                                spreadRadius: screenWidth * 0.01,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              "Z",
                              style: TextStyle(
                                fontSize: screenWidth * 0.1,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.025),
                        
                        // Title
                        Text(
                          "ZION OS 2027",
                          style: TextStyle(
                            fontSize: screenWidth * 0.07,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF00BCD4),
                            letterSpacing: 3,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        
                        // Date
                        Text(
                          _currentDate,
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: Colors.white54,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        
                        // Day
                        Text(
                          _currentDay,
                          style: TextStyle(
                            fontSize: screenWidth * 0.025,
                            color: Colors.white38,
                            letterSpacing: 2,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.04),
                        
                        // Time
                        Text(
                          _currentTime,
                          style: TextStyle(
                            fontSize: screenWidth * 0.15,
                            fontWeight: FontWeight.w300,
                            color: const Color(0xFF00BCD4),
                            letterSpacing: 5,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.06),
                        
                        // PIN Input
                        Container(
                          width: screenWidth * 0.65,
                          constraints: const BoxConstraints(maxWidth: 300),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.5)),
                          ),
                          child: TextField(
                            controller: _pinController,
                            obscureText: true,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFF00BCD4),
                              fontSize: screenWidth * 0.07,
                              letterSpacing: 12,
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            decoration: const InputDecoration(
                              hintText: "••••",
                              hintStyle: TextStyle(color: Colors.white30, fontSize: 20),
                              border: InputBorder.none,
                              counterText: "",
                            ),
                            onSubmitted: (_) => _checkPin(),
                          ),
                        ),
                        
                        if (_errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(color: Colors.red, fontSize: 12, letterSpacing: 1),
                            ),
                          ),
                        
                        SizedBox(height: screenHeight * 0.04),
                        
                        // Number Pad
                        Container(
                          width: screenWidth * 0.8,
                          constraints: const BoxConstraints(maxWidth: 350),
                          child: GridView.count(
                            shrinkWrap: true,
                            crossAxisCount: 3,
                            mainAxisSpacing: screenHeight * 0.02,
                            crossAxisSpacing: screenWidth * 0.04,
                            childAspectRatio: 1.1,
                            children: [
                              _buildNumberButton("1", screenWidth),
                              _buildNumberButton("2", screenWidth),
                              _buildNumberButton("3", screenWidth),
                              _buildNumberButton("4", screenWidth),
                              _buildNumberButton("5", screenWidth),
                              _buildNumberButton("6", screenWidth),
                              _buildNumberButton("7", screenWidth),
                              _buildNumberButton("8", screenWidth),
                              _buildNumberButton("9", screenWidth),
                              _buildNumberButton("0", screenWidth),
                              _buildBiometricButton(screenWidth),
                              _buildDeleteButton("⌫", screenWidth),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: screenHeight * 0.03),
                        
                        // Biometric hint text
                        if (!_isBiometricAvailable)
                          Text(
                            "Biometric not available",
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: screenWidth * 0.025,
                            ),
                          ),
                        
                        const Spacer(flex: 1),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildNumberButton(String num, double screenWidth) {
    return GestureDetector(
      onTap: () {
        if (_pinController.text.length < 4) {
          _pinController.text += num;
          if (_pinController.text.length == 4) _checkPin();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
        ),
        child: Center(
          child: Text(
            num,
            style: TextStyle(
              color: const Color(0xFF00BCD4),
              fontSize: screenWidth * 0.07,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricButton(double screenWidth) {
    return GestureDetector(
      onTap: _authenticateWithBiometrics,
      child: Container(
        decoration: BoxDecoration(
          color: _isBiometricAvailable 
              ? const Color(0xFF00BCD4).withOpacity(0.15)
              : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isBiometricAvailable 
                ? const Color(0xFF00BCD4).withOpacity(0.5)
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Center(
          child: Icon(
            Icons.fingerprint,
            color: _isBiometricAvailable 
                ? const Color(0xFF00BCD4)
                : Colors.white38,
            size: screenWidth * 0.08,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(String label, double screenWidth) {
    return GestureDetector(
      onTap: () {
        if (_pinController.text.isNotEmpty) {
          _pinController.text = _pinController.text.substring(0, _pinController.text.length - 1);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
        ),
        child: Center(
          child: Icon(
            Icons.backspace,
            color: const Color(0xFF00BCD4),
            size: screenWidth * 0.07,
          ),
        ),
      ),
    );
  }
}
