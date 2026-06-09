import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/dashboard/cosmic_dashboard.dart';
import 'features/terminal/cosmic_terminal.dart';
import 'features/reports/cosmic_reports.dart';
import 'features/settings/cosmic_settings.dart';
import 'features/monitor/cosmic_monitor.dart';
import 'features/network/cosmic_network_map.dart';

class ZionApp extends StatelessWidget {
  const ZionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Zion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF00FF41),
        scaffoldBackgroundColor: const Color(0xFF050805),
        fontFamily: 'monospace',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const CosmicMainScreen(),
    );
  }
}

class CosmicMainScreen extends StatefulWidget {
  const CosmicMainScreen({super.key});

  @override
  State<CosmicMainScreen> createState() => _CosmicMainScreenState();
}

class _CosmicMainScreenState extends State<CosmicMainScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  final _pages = const [
    CosmicDashboard(),
    CosmicNetworkMap(),
    CosmicMonitor(),
    CosmicTerminal(),
    CosmicReports(),
    CosmicSettings(),
  ];

  final _titles = ['القيادة', 'الشبكة', 'المراقبة', 'الطرفية', 'التقارير', 'الإعدادات'];

  late final AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shield, color: Color(0xFF00FF41), size: 22),
            const SizedBox(width: 8),
            Text(_titles[_currentIndex], style: const TextStyle(color: Color(0xFF00FF41), fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF00FF41)),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: _buildCosmicDrawer(),
      body: Stack(
        children: [
          // خلفية المطر Matrix
          Positioned.fill(child: _MatrixRainBackground(controller: _bgController)),
          // المحتوى
          _pages[_currentIndex],
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF0A0E0A),
          selectedItemColor: const Color(0xFF00FF41),
          unselectedItemColor: const Color(0xFF555555),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'القيادة'),
            BottomNavigationBarItem(icon: Icon(Icons.language), label: 'الشبكة'),
            BottomNavigationBarItem(icon: Icon(Icons.monitor_heart), label: 'مراقبة'),
            BottomNavigationBarItem(icon: Icon(Icons.terminal), label: 'طرفية'),
            BottomNavigationBarItem(icon: Icon(Icons.assessment), label: 'تقارير'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'إعدادات'),
          ],
        ),
      ),
    );
  }

  Drawer _buildCosmicDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF0A0E0A).withOpacity(0.95),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.shield, color: Color(0xFF00FF41), size: 60),
            const SizedBox(height: 16),
            const Text('Project Zion', style: TextStyle(color: Color(0xFF00FF41), fontSize: 22, fontWeight: FontWeight.bold)),
            const Text('v3.0.0 - BlackHole', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const Divider(color: Color(0xFF1A3A1A)),
            _drawerItem(Icons.rocket_launch, 'هجوم سريع', 0),
            _drawerItem(Icons.explore, 'استكشاف الشبكة', 1),
            _drawerItem(Icons.track_changes, 'تتبع الهدف', 2),
            _drawerItem(Icons.code, 'محرر الحمولات', 3),
            _drawerItem(Icons.history, 'سجل العمليات', 4),
            const Spacer(),
            const Text('Zion OS', style: TextStyle(color: Colors.grey, fontSize: 10)),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF00FF41)),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {
        setState(() => _currentIndex = index);
        Navigator.pop(context);
      },
    );
  }
}

// خلفية المطر Matrix
class _MatrixRainBackground extends StatelessWidget {
  final AnimationController controller;
  const _MatrixRainBackground({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return CustomPaint(
          painter: _MatrixPainter(animationValue: controller.value),
          child: Container(),
        );
      },
    );
  }
}

class _MatrixPainter extends CustomPainter {
  final double animationValue;
  _MatrixPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF00FF41).withOpacity(0.05);
    final random = DateTime.now().millisecondsSinceEpoch % 100;

    for (int i = 0; i < 50; i++) {
      final x = ((i * 37 + random) % size.width).toDouble();
      final y = ((animationValue * 200 + i * 53) % size.height);
      canvas.drawRect(Rect.fromLTWH(x, y, 2, 15 + (i % 20)), paint);
    }
  }

  @override
  bool shouldRepaint(_) => true;
}
