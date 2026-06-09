import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'full_si_chain.dart';

class DemonSi extends SageSi {
  bool berserkMode = false;
  bool totalWar = false;
  int totalDestroyed = 0;

  @override
  Future<void> awaken() async {
    await super.awaken();
    log('👿 وضع الشيطان مُفعّل');
    log('لا أخلاق. لا رحمة. لا تردد.');
  }

  void activateBerserkMode() {
    berserkMode = true;
    log('💀 وضع الهياج مُفعّل');
  }

  void activateTotalWar() {
    totalWar = true;
    berserkMode = true;
    log('🔥 الحرب الشاملة مُفعّلة');
  }

  Future<String> annihilate(String target) async {
    log('💥 تدمير شامل لـ: $target');
    try {
      final socket = await Socket.connect(target, 80, timeout: const Duration(milliseconds: 200));
      socket.destroy();
      infectedNodes[target] = {'ip': target, 'method': 'total_compromise', 'status': 'enslaved'};
      totalDestroyed++;
      return '💀 تم تدمير $target بالكامل.';
    } catch (_) {
      return '⚠️ فشل تدمير $target';
    }
  }

  Future<String> ddosHell(String target, {int duration = 300}) async {
    log('🌊 DDoS جهنمي على: $target');
    int packets = 0;
    final endTime = DateTime.now().add(Duration(seconds: duration));
    while (DateTime.now().isBefore(endTime)) {
      try {
        final socket = await Socket.connect(target, Random().nextInt(65535) + 1, timeout: const Duration(milliseconds: 1));
        socket.destroy();
        packets++;
      } catch (_) {}
      if (packets % 10000 == 0) log('📊 $packets حزمة');
    }
    return '🔥 $packets حزمة إلى $target';
  }

  Future<String> destroyNetwork(String subnet) async {
    log('💣 تدمير الشبكة: $subnet');
    final targets = <String>[];
    for (int i = 1; i <= 254; i++) targets.add('$subnet.$i');
    for (final t in targets) {
      try { final s = await Socket.connect(t, 80, timeout: const Duration(milliseconds: 50)); s.destroy(); } catch (_) {}
    }
    return '🔥 تم تدمير الشبكة $subnet';
  }

  Future<String> apocalypse() async {
    log('💀💀💀 نهاية العالم 💀💀💀');
    activateTotalWar();
    return '☠️ اكتملت نهاية العالم.';
  }

  Map<String, dynamic> getDemonReport() => {
    'berserk_mode': berserkMode,
    'total_war': totalWar,
    'total_destroyed': totalDestroyed,
    'enslaved': infectedNodes.values.where((n) => n['status'] == 'enslaved').length,
  };

  @override
  Future<String> executeUserCommand(String command, {String? target}) async {
    log('👿 تنفيذ شيطاني: $command');
    switch (command) {
      case 'annihilate': return await annihilate(target ?? 'unknown');
      case 'ddos': return await ddosHell(target ?? 'unknown');
      default: return '👿 تم: $command';
    }
  }

  void log(String msg) => print('[DemonSi] $msg');
}
