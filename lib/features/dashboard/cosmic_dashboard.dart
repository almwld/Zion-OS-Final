import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../core/services/unified_core_service.dart';

class CosmicDashboard extends ConsumerStatefulWidget {
  const CosmicDashboard({super.key});

  @override
  ConsumerState<CosmicDashboard> createState() => _CosmicDashboardState();
}

class _CosmicDashboardState extends ConsumerState<CosmicDashboard> {
  final _targetController = TextEditingController(text: '192.168.1.1');
  String _output = '';
  bool _loading = false;
  bool _isOnline = true;
  double _cpuUsage = 34;
  double _ramUsage = 67;
  int _activeSessions = 3;
  int _totalTools = 600;

  Future<void> _execute(String command) async {
    setState(() => _loading = true);
    final service = ref.read(unifiedCoreProvider);
    final result = await service.execute(command, target: _targetController.text);
    setState(() { _output = result; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // بطاقة الحالة
              _buildStatusCard(),
              const SizedBox(height: 16),

              // حقل الهدف
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF00FF41).withOpacity(0.3)),
                  color: const Color(0xFF0A0E0A).withOpacity(0.8),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.my_location, color: Color(0xFF00FF41)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _targetController,
                        style: const TextStyle(color: Color(0xFF00FF41), fontFamily: 'monospace', fontSize: 16),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'أدخل عنوان الهدف...',
                          hintStyle: TextStyle(color: Color(0xFF333333)),
                        ),
                      ),
                    ),
                    _loading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Color(0xFF00FF41)))
                        : IconButton(icon: const Icon(Icons.play_circle_fill, color: Color(0xFF00FF41), size: 36), onPressed: () => _execute('port_scan')),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // مؤشرات الموارد
              Row(
                children: [
                  Expanded(child: _buildGauge('CPU', _cpuUsage, const Color(0xFF00FF41))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildGauge('RAM', _ramUsage, const Color(0xFF2196F3))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildGauge('NET', 45, const Color(0xFFFF9800))),
                ],
              ),
              const SizedBox(height: 16),

              // أزرار الهجوم السريع
              const Text('⚡ أوامر هجومية', style: TextStyle(color: Color(0xFF00FF41), fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _attackBtn('💣 مسح المنافذ', 'port_scan', const Color(0xFF00FF41)),
                  _attackBtn('🎯 Ping', 'ping', const Color(0xFF2196F3)),
                  _attackBtn('🌐 DNS', 'dns_lookup', const Color(0xFFFF9800)),
                  _attackBtn('🔍 HTTP', 'http_headers', const Color(0xFFE91E63)),
                  _attackBtn('🖥️ النظام', 'system_info', const Color(0xFF9C27B0)),
                  _attackBtn('🆘 مساعدة', 'help', const Color(0xFF607D8B)),
                ],
              ),
              const SizedBox(height: 16),

              // الطرفية المصغرة
              Container(
                width: double.infinity,
                height: 200,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF050805).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF00FF41).withOpacity(0.2)),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _output.isNotEmpty ? _output : 'zion> جاهز لاستقبال الأوامر...\n',
                    style: const TextStyle(color: Color(0xFF00FF41), fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(colors: [Color(0xFF0A1A0A), Color(0xFF050805)]),
        border: Border.all(color: const Color(0xFF00FF41).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 12, height: 12,
            decoration: BoxDecoration(shape: BoxShape.circle, color: _isOnline ? const Color(0xFF00FF41) : Colors.red),
          ),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_isOnline ? 'النظام نشط' : 'النظام غير متصل', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text('الجلسات: $_activeSessions | الأدوات: $_totalTools', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ]),
          const Spacer(),
          Text('Zion v3.0', style: const TextStyle(color: Color(0xFF00FF41), fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Widget _buildGauge(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: const Color(0xFF0A0E0A), border: Border.all(color: color.withOpacity(0.2))),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          CircularPercentIndicator(radius: 30, percent: value / 100, progressColor: color, backgroundColor: color.withOpacity(0.1), center: Text('${value.toInt()}%', style: TextStyle(color: color, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _attackBtn(String label, String command, Color color) {
    return ElevatedButton(
      onPressed: () => _execute(command),
      style: ElevatedButton.styleFrom(backgroundColor: color.withOpacity(0.1), foregroundColor: color, side: BorderSide(color: color.withOpacity(0.3))),
      child: Text(label, style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
    );
  }
}
