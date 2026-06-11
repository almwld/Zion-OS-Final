import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';

class DataHubApp extends StatefulWidget {
  const DataHubApp({super.key});

  @override
  State<DataHubApp> createState() => _DataHubAppState();
}

class _DataHubAppState extends State<DataHubApp> {
  int _selectedTab = 0;
  
  final List<Map<String, dynamic>> _tabs = [
    {'name': 'Storage', 'icon': Icons.storage},
    {'name': 'Battery', 'icon': Icons.battery_full},
    {'name': 'Memory', 'icon': Icons.memory},
    {'name': 'Stats', 'icon': Icons.bar_chart},
  ];
  
  // Storage Data
  List<Map<String, dynamic>> _storageInfo = [];
  double _totalStorage = 0;
  double _usedStorage = 0;
  double _freeStorage = 0;
  
  // Battery Data
  int _batteryLevel = 0;
  String _batteryStatus = '';
  double _batteryTemp = 0;
  int _batteryHealth = 100;
  
  // Memory Data
  int _totalRam = 0;
  int _usedRam = 0;
  int _freeRam = 0;
  int _totalSwap = 0;
  int _usedSwap = 0;
  
  // Stats
  Timer? _monitorTimer;
  List<FlSpot> _storageHistory = [];
  List<FlSpot> _ramHistory = [];
  int _dataPoint = 0;
  
  // Apps Storage
  final List<Map<String, dynamic>> _appsStorage = [
    {'name': 'System', 'size': 6.5, 'color': 0xFF00BCD4},
    {'name': 'Apps', 'size': 8.2, 'color': 0xFF2196F3},
    {'name': 'Media', 'size': 12.5, 'color': 0xFF4CAF50},
    {'name': 'Documents', 'size': 2.1, 'color': 0xFFFF9800},
    {'name': 'Cache', 'size': 1.8, 'color': 0xFF9C27B0},
    {'name': 'Other', 'size': 1.5, 'color': 0xFFE91E63},
  ];

  @override
  void initState() {
    super.initState();
    _initData();
    _loadAllData();
    _startMonitoring();
  }

  @override
  void dispose() {
    _monitorTimer?.cancel();
    super.dispose();
  }

  void _initData() {
    for (int i = 0; i < 20; i++) {
      _storageHistory.add(FlSpot(i.toDouble(), 0));
      _ramHistory.add(FlSpot(i.toDouble(), 0));
    }
  }

  void _startMonitoring() {
    _monitorTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _updateBattery();
      _updateMemory();
      _updateHistory();
      setState(() {});
    });
  }

  Future<void> _loadAllData() async {
    await _loadStorageInfo();
    await _updateBattery();
    await _updateMemory();
    setState(() {});
  }

  Future<void> _loadStorageInfo() async {
    try {
      final result = await Process.run('df', ['-h'], runInShell: true);
      final output = result.stdout.toString();
      final lines = output.split('\n');
      
      for (final line in lines) {
        if (line.contains('/data')) {
          final parts = line.trim().split(RegExp(r'\s+'));
          if (parts.length >= 6) {
            _totalStorage = _parseSize(parts[1]);
            _usedStorage = _parseSize(parts[2]);
            _freeStorage = _parseSize(parts[3]);
            break;
          }
        }
      }
    } catch (_) {}
  }

  double _parseSize(String size) {
    if (size.contains('G')) return double.parse(size.replaceAll('G', ''));
    if (size.contains('M')) return double.parse(size.replaceAll('M', '')) / 1024;
    return 0;
  }

  Future<void> _updateBattery() async {
    try {
      final result = await Process.run('dumpsys', ['battery'], runInShell: true);
      final output = result.stdout.toString();
      
      final levelMatch = RegExp(r'level: (\d+)').firstMatch(output);
      if (levelMatch != null) _batteryLevel = int.parse(levelMatch.group(1)!);
      
      final tempMatch = RegExp(r'temperature: (\d+)').firstMatch(output);
      if (tempMatch != null) _batteryTemp = int.parse(tempMatch.group(1)!) / 10;
      
      final statusMatch = RegExp(r'status: (\d+)').firstMatch(output);
      if (statusMatch != null) {
        const statuses = {1: 'Unknown', 2: 'Charging', 3: 'Discharging', 4: 'Not charging', 5: 'Full'};
        _batteryStatus = statuses[int.parse(statusMatch.group(1)!)] ?? 'Unknown';
      }
    } catch (_) {}
  }

  Future<void> _updateMemory() async {
    try {
      final result = await Process.run('free', ['-m'], runInShell: true);
      final output = result.stdout.toString();
      final lines = output.split('\n');
      if (lines.length > 1) {
        final parts = lines[1].split(RegExp(r'\s+'));
        if (parts.length >= 4) {
          _totalRam = int.parse(parts[1]);
          _usedRam = int.parse(parts[2]);
          _freeRam = int.parse(parts[3]);
        }
      }
      if (lines.length > 2) {
        final swapParts = lines[2].split(RegExp(r'\s+'));
        if (swapParts.length >= 4) {
          _totalSwap = int.parse(swapParts[1]);
          _usedSwap = int.parse(swapParts[2]);
        }
      }
    } catch (_) {}
  }

  void _updateHistory() {
    _dataPoint++;
    _storageHistory.add(FlSpot(_dataPoint.toDouble(), _usedStorage));
    _ramHistory.add(FlSpot(_dataPoint.toDouble(), _usedRam));
    
    if (_storageHistory.length > 20) _storageHistory.removeAt(0);
    if (_ramHistory.length > 20) _ramHistory.removeAt(0);
  }

  String _formatStorage(double gb) {
    if (gb > 1024) return '${(gb / 1024).toStringAsFixed(2)} TB';
    return '${gb.toStringAsFixed(1)} GB';
  }

  List<PieChartSectionData> _getStoragePieData() {
    return _appsStorage.map((app) => PieChartSectionData(
      value: app['size'],
      title: '${app['name']}\n${app['size'].toStringAsFixed(1)} GB',
      color: Color(app['color']),
      radius: 80,
      titleStyle: const TextStyle(color: Colors.white, fontSize: 10),
    )).toList();
  }

  @override
  Widget build(BuildContext context) {
    final storageUsage = _totalStorage > 0 ? (_usedStorage / _totalStorage * 100).toInt() : 0;
    final ramUsage = _totalRam > 0 ? (_usedRam / _totalRam * 100).toInt() : 0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Data Hub', style: TextStyle(color: Color(0xFF00BCD4))),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00BCD4)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF00BCD4)),
            onPressed: _loadAllData,
          ),
        ],
        bottom: TabBar(
          onTap: (index) => setState(() => _selectedTab = index),
          labelColor: const Color(0xFF00BCD4),
          unselectedLabelColor: Colors.white54,
          indicatorColor: const Color(0xFF00BCD4),
          tabs: _tabs.map((tab) => Tab(icon: Icon(tab['icon']), text: tab['name'])).toList(),
        ),
      ),
      body: IndexedStack(
        index: _selectedTab,
        children: [
          _buildStorageTab(storageUsage),
          _buildBatteryTab(),
          _buildMemoryTab(ramUsage),
          _buildStatsTab(),
        ],
      ),
    );
  }

  Widget _buildStorageTab(int usage) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Storage Overview
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF00BCD4), Color(0xFF006064)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text('Storage Usage', style: TextStyle(color: Colors.white, fontSize: 14)),
                const SizedBox(height: 8),
                Text('$usage%', style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: usage / 100,
                  backgroundColor: Colors.white24,
                  color: Colors.white,
                  minHeight: 10,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStorageItem('Total', _formatStorage(_totalStorage)),
                    _buildStorageItem('Used', _formatStorage(_usedStorage)),
                    _buildStorageItem('Free', _formatStorage(_freeStorage)),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Storage Breakdown Chart
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
            ),
            child: Column(
              children: [
                const Text('Storage Breakdown', style: TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: _getStoragePieData(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: _appsStorage.map((app) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 10, height: 10, decoration: BoxDecoration(color: Color(app['color']), shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      Text(app['name'], style: const TextStyle(color: Colors.white70, fontSize: 10)),
                    ],
                  )).toList(),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Storage History Chart
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
            ),
            child: Column(
              children: [
                const Text('Storage History', style: TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: true),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _storageHistory,
                          isCurved: true,
                          color: const Color(0xFF00BCD4),
                          barWidth: 2,
                          dotData: const FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatteryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Battery Level Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _batteryLevel > 50 
                    ? [Colors.green, Colors.green.withOpacity(0.5)]
                    : _batteryLevel > 20
                        ? [Colors.orange, Colors.orange.withOpacity(0.5)]
                        : [Colors.red, Colors.red.withOpacity(0.5)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text('Battery Level', style: TextStyle(color: Colors.white, fontSize: 14)),
                const SizedBox(height: 8),
                Text('$_batteryLevel%', style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: _batteryLevel / 100,
                  backgroundColor: Colors.white24,
                  color: Colors.white,
                  minHeight: 10,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Battery Details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
            ),
            child: Column(
              children: [
                _buildDetailRow('Status', _batteryStatus, Icons.battery_charging_full),
                _buildDetailRow('Temperature', '${_batteryTemp.toStringAsFixed(1)}°C', Icons.thermostat),
                _buildDetailRow('Health', '${_batteryHealth}%', Icons.favorite),
                _buildDetailRow('Technology', 'Li-Po', Icons.battery_full),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryTab(int usage) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // RAM Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF00BCD4), Color(0xFF006064)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text('RAM Usage', style: TextStyle(color: Colors.white, fontSize: 14)),
                const SizedBox(height: 8),
                Text('$usage%', style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: usage / 100,
                  backgroundColor: Colors.white24,
                  color: Colors.white,
                  minHeight: 10,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMemoryItem('Total', '${_totalRam} MB'),
                    _buildMemoryItem('Used', '${_usedRam} MB'),
                    _buildMemoryItem('Free', '${_freeRam} MB'),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // RAM History Chart
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
            ),
            child: Column(
              children: [
                const Text('RAM History', style: TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: true),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _ramHistory,
                          isCurved: true,
                          color: Colors.green,
                          barWidth: 2,
                          dotData: const FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          if (_totalSwap > 0) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Text('Swap Memory', style: TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMemoryItem('Total', '${_totalSwap} MB'),
                      _buildMemoryItem('Used', '${_usedSwap} MB'),
                      _buildMemoryItem('Free', '${_totalSwap - _usedSwap} MB'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatCard('Total Storage', _formatStorage(_totalStorage), Icons.storage, Colors.blue),
        _buildStatCard('Used Storage', _formatStorage(_usedStorage), Icons.storage, Colors.orange),
        _buildStatCard('Free Storage', _formatStorage(_freeStorage), Icons.storage, Colors.green),
        _buildStatCard('Total RAM', '${_totalRam} MB', Icons.memory, Colors.blue),
        _buildStatCard('Used RAM', '${_usedRam} MB', Icons.memory, Colors.orange),
        _buildStatCard('Free RAM', '${_freeRam} MB', Icons.memory, Colors.green),
        _buildStatCard('Battery', '$_batteryLevel%', Icons.battery_full, _getBatteryColor()),
        _buildStatCard('Temperature', '${_batteryTemp.toStringAsFixed(1)}°C', Icons.thermostat, Colors.red),
      ],
    );
  }

  Widget _buildStorageItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _buildMemoryItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00BCD4), size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getBatteryColor() {
    if (_batteryLevel > 50) return Colors.green;
    if (_batteryLevel > 20) return Colors.orange;
    return Colors.red;
  }
}
