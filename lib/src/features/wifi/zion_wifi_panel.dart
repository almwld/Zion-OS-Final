import 'package:flutter/material.dart';
import '../../../core/arsenal/zion_wifi_advanced.dart';

class ZionWifiPanel extends StatefulWidget {
  const ZionWifiPanel({super.key});

  @override
  State<ZionWifiPanel> createState() => _ZionWifiPanelState();
}

class _ZionWifiPanelState extends State<ZionWifiPanel> {
  final ZionWiFiAdvanced _wifi = ZionWiFiAdvanced();
  List<Map<String, dynamic>> _networks = [];
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _scanNetworks();
  }

  Future<void> _scanNetworks() async {
    setState(() => _isScanning = true);
    
    final hidden = await _wifi.discoverHiddenNetworks();
    _networks = hidden.map((n) => {
      'ssid': n.realSSID,
      'bssid': n.bssid,
      'signal': n.signalStrength,
      'hidden': true,
    }).toList();
    
    setState(() => _isScanning = false);
  }

  void _showAttackDialog(Map<String, dynamic> network) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('WiFi Attack'),
        content: Text('Launch attack on ${network['ssid']}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final result = await _wifi.fullAttack(network['bssid']);
              if (result.success && result.password != null) {
                _showResultDialog('Password found: ${result.password}');
              } else {
                _showResultDialog('Attack failed');
              }
            },
            child: const Text('Attack'),
          ),
        ],
      ),
    );
  }

  void _showResultDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Result'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Zion WiFi - Advanced'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: _isScanning
          ? const Center(child: CircularProgressIndicator())
          : _networks.isEmpty
              ? const Center(child: Text('No networks found', style: TextStyle(color: Colors.white)))
              : ListView.builder(
                  itemCount: _networks.length,
                  itemBuilder: (ctx, i) {
                    final net = _networks[i];
                    return ListTile(
                      leading: const Icon(Icons.wifi, color: Colors.blue),
                      title: Text(net['ssid'], style: const TextStyle(color: Colors.white)),
                      subtitle: Text('${net['bssid']} - Signal: ${net['signal']}', style: const TextStyle(color: Colors.grey)),
                      trailing: ElevatedButton(
                        onPressed: () => _showAttackDialog(net),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Attack'),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scanNetworks,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
