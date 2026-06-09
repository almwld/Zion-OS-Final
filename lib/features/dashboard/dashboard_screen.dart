import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/unified_core_service.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _targetController = TextEditingController(text: '192.168.1.1');
  String _output = '';
  bool _loading = false;

  Future<void> _execute(String command) async {
    setState(() => _loading = true);
    final service = ref.read(unifiedCoreProvider);
    final result = await service.execute(command, target: _targetController.text);
    setState(() { _output = result; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Zion'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.account_circle_outlined), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // حقل الهدف
            TextField(
              controller: _targetController,
              style: const TextStyle(color: Color(0xFF00FF41), fontFamily: 'monospace'),
              decoration: const InputDecoration(
                labelText: 'عنوان الهدف (IP / URL)',
                prefixIcon: Icon(Icons.language, color: Color(0xFF00FF41)),
              ),
            ),
            const SizedBox(height: 16),

            // أزرار سريعة
            const Text('⚡ أوامر سريعة', style: TextStyle(color: Color(0xFF00FF41), fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _quickBtn('فحص المنافذ', 'port_scan'),
                _quickBtn('Ping', 'ping'),
                _quickBtn('DNS', 'dns_lookup'),
                _quickBtn('HTTP Headers', 'http_headers'),
                _quickBtn('معلومات النظام', 'system_info'),
              ],
            ),
            const SizedBox(height: 20),

            // شريط التحميل
            if (_loading) const LinearProgressIndicator(color: Color(0xFF00FF41)),
            const SizedBox(height: 16),

            // منطقة الإخراج (ترمينال مصغر)
            const Text('📟 المخرجات', style: TextStyle(color: Color(0xFF00FF41), fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 250,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0E0A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF1A3A1A)),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _output.isNotEmpty ? _output : 'جاهز... \nاكتب أمر أو اضغط على أحد الأزرار أعلاه',
                  style: const TextStyle(color: Color(0xFF00FF41), fontFamily: 'monospace', fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickBtn(String label, String command) {
    return ElevatedButton.icon(
      onPressed: () => _execute(command),
      icon: const Icon(Icons.play_arrow, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 13)),
    );
  }
}
