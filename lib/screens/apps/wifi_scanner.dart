import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class WiFiScannerApp extends StatefulWidget {
  const WiFiScannerApp({super.key});

  @override
  State<WiFiScannerApp> createState() => _WiFiScannerAppState();
}

class _WiFiScannerAppState extends State<WiFiScannerApp> {
  List<Map<String, String>> _networks = [];
  bool _isScanning = false;
  String _errorMessage = '';
  String _currentWiFi = '';
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final locationStatus = await Permission.location.status;
    if (!locationStatus.isGranted) {
      await Permission.location.request();
    }
    _hasPermission = await Permission.location.isGranted;
    if (_hasPermission) {
      _getCurrentWiFi();
      _scanWiFi();
    } else {
      setState(() => _errorMessage = 'Location permission required to scan WiFi');
    }
  }

  Future<void> _getCurrentWiFi() async {
    try {
      final result = await Process.run('dumpsys', ['wifi'], runInShell: true);
      final output = result.stdout.toString();
      final match = RegExp(r'mWifiInfo.*?SSID: "([^"]+)"', caseSensitive: false).firstMatch(output);
      if (match != null && match.group(1) != null && match.group(1) != '<unknown ssid>') {
        setState(() => _currentWiFi = match.group(1)!);
      }
    } catch (_) {}
  }

  Future<void> _scanWiFi() async {
    if (!_hasPermission) {
      setState(() => _errorMessage = 'Location permission required');
      return;
    }

    setState(() {
      _isScanning = true;
      _networks.clear();
      _errorMessage = '';
    });

    try {
      final result = await Process.run('dumpsys', ['wifi'], runInShell: true);
      final output = result.stdout.toString();
      
      final regex = RegExp(r'SSID: "([^"]+)".*?BSSID: ([0-9a-f:]+).*?RSSI: (-?\d+)', caseSensitive: false);
      final matches = regex.allMatches(output);
      
      final networksList = <Map<String, String>>[];
      for (final match in matches) {
        final ssid = match.group(1);
        final bssid = match.group(2);
        final rssi = match.group(3);
        if (ssid != null && ssid.isNotEmpty && ssid != 'unknown' && ssid != '<unknown ssid>' && ssid != '0x') {
          networksList.add({
            'ssid': ssid,
            'bssid': bssid ?? 'Unknown',
            'signal': rssi ?? '0',
          });
        }
      }
      
      setState(() {
        _networks = networksList;
        _isScanning = false;
        if (_networks.isEmpty) {
          _errorMessage = 'No WiFi networks found. Make sure WiFi is enabled.';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isScanning = false;
      });
    }
  }

  int _getSignalStrength(int rssi) {
    if (rssi > -50) return 4;
    if (rssi > -60) return 3;
    if (rssi > -70) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('WiFi Scanner', style: TextStyle(color: Color(0xFF00BCD4))),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00BCD4)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF00BCD4)),
            onPressed: _scanWiFi,
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_hasPermission)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_off, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: const Text(
                      'Location permission required to scan WiFi networks',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  TextButton(
                    onPressed: _checkPermissions,
                    child: const Text('Grant', style: TextStyle(color: Color(0xFF00BCD4))),
                  ),
                ],
              ),
            ),
          
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00BCD4), Color(0xFF006064)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.wifi, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Connected to:', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      Text(
                        _currentWiFi.isNotEmpty ? _currentWiFi : 'Not connected',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _isScanning ? null : _scanWiFi,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF00BCD4),
                  ),
                  child: Text(_isScanning ? 'SCANNING...' : 'SCAN'),
                ),
              ],
            ),
          ),
          
          if (_errorMessage.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_errorMessage, style: const TextStyle(color: Colors.white70, fontSize: 12))),
                ],
              ),
            ),
          
          Expanded(
            child: _isScanning
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF00BCD4)),
                        SizedBox(height: 16),
                        Text('Scanning for networks...', style: TextStyle(color: Colors.white38)),
                      ],
                    ),
                  )
                : _networks.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.wifi_off, size: 64, color: Colors.white24),
                            SizedBox(height: 16),
                            Text('No networks found', style: TextStyle(color: Colors.white38)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _networks.length,
                        itemBuilder: (context, index) {
                          final network = _networks[index];
                          final rssi = int.tryParse(network['signal'] ?? '-70') ?? -70;
                          final strength = _getSignalStrength(rssi);
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  strength > 2 ? Icons.signal_cellular_alt : Icons.signal_cellular_alt,
                                  color: strength > 2 ? Colors.green : Colors.orange,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        network['ssid']!,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        network['bssid']!,
                                        style: const TextStyle(color: Colors.white38, fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${rssi} dBm',
                                  style: TextStyle(
                                    color: strength > 2 ? Colors.green : Colors.orange,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
