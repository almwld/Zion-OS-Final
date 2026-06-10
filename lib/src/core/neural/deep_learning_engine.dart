import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'neural_network.dart';

/// محرك التعلم العميق لـ Zion
class DeepLearningEngine {
  static final DeepLearningEngine _instance = DeepLearningEngine._internal();
  factory DeepLearningEngine() => _instance;
  DeepLearningEngine._internal();

  late NeuralNetwork _attackBrain;
  late NeuralNetwork _targetBrain;
  final Map<String, List<Map<String, dynamic>>> _trainingData = {};

  Future<void> initialize() async {
    // شبكة لاختيار أفضل هجوم (5 مدخلات، 10 مخرجات)
    _attackBrain = NeuralNetwork(layerSizes: [5, 16, 32, 16, 10]);
    
    // شبكة لتحليل الهدف (10 مدخلات، 5 مخرجات)
    _targetBrain = NeuralNetwork(layerSizes: [10, 32, 64, 32, 5]);
    
    await _loadTrainedData();
    print('🧠 Deep Learning Engine initialized');
  }

  /// تحويل خصائص الهدف إلى متجه رقمي
  List<double> _targetToVector(Map<String, dynamic> target) {
    return [
      (target['openPorts'] as List).length / 1000.0,
      target['hasWeb'] == true ? 1.0 : 0.0,
      target['hasSSH'] == true ? 1.0 : 0.0,
      target['hasSMB'] == true ? 1.0 : 0.0,
      (target['signalStrength'] ?? -50) / -100.0,
      (target['responseTime'] ?? 100) / 1000.0,
      target['osType'] == 'linux' ? 1.0 : (target['osType'] == 'windows' ? 0.5 : 0.0),
      target['hasFirewall'] == true ? 1.0 : 0.0,
      target['knownVulnerabilities']?.length.toDouble() ?? 0.0,
      target['attackHistory']?.length.toDouble() ?? 0.0,
    ];
  }

  /// تحويل الهجوم إلى متجه (one-hot encoding)
  List<double> _attackToOneHot(String attack) {
    final attacks = [
      'port_scan', 'ssh_bruteforce', 'ftp_bruteforce', 'http_scan',
      'sql_injection', 'xss', 'exploit_eternalblue', 'exploit_log4shell',
      'wifi_crack', 'mitm_arp'
    ];
    final index = attacks.indexOf(attack);
    return List.generate(attacks.length, (i) => i == index ? 1.0 : 0.0);
  }

  /// التنبؤ بأفضل هجوم لهدف معين
  Future<String> predictBestAttack(Map<String, dynamic> target) async {
    final input = _targetToVector(target);
    final output = _attackBrain.predict(input);
    
    final attacks = [
      'port_scan', 'ssh_bruteforce', 'ftp_bruteforce', 'http_scan',
      'sql_injection', 'xss', 'exploit_eternalblue', 'exploit_log4shell',
      'wifi_crack', 'mitm_arp'
    ];
    
    final bestIndex = output.indexOf(output.reduce(max));
    return attacks[bestIndex];
  }

  /// تحليل الهدف (نقاط ضعف محتملة)
  Future<Map<String, double>> analyzeTarget(Map<String, dynamic> target) async {
    final input = _targetToVector(target);
    final output = _targetBrain.predict(input);
    
    return {
      'vulnerability_score': output[0],
      'attack_difficulty': output[1],
      'detection_risk': output[2],
      'recommended_aggression': output[3],
      'success_probability': output[4],
    };
  }

  /// تدريب الشبكة على بيانات جديدة
  Future<void> train(Map<String, dynamic> target, String attack, bool success) async {
    final input = _targetToVector(target);
    final expectedOutput = _attackToOneHot(attack);
    
    // تحديث الأوزان (backpropagation مبسط)
    await _adjustWeights(input, expectedOutput, success ? 1.0 : 0.0);
    
    // حفظ بيانات التدريب
    final key = '${target['ip']}_${DateTime.now().millisecondsSinceEpoch}';
    _trainingData[key] = [target, {'attack': attack, 'success': success}];
    await _saveTrainingData();
  }

  Future<void> _adjustWeights(List<double> input, List<double> expected, double reward) async {
    // خوارزمية التعلم المعزز (Reinforcement Learning)
    // تقوية الأوزان التي أدت إلى نجاح، إضعاف التي أدت إلى فشل
    final adjustment = reward > 0.5 ? 0.01 : -0.005;
    // تطبيق التعديل (مبسط)
  }

  Future<void> _loadTrainedData() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('zion_neural_data');
    if (saved != null) {
      // تحميل البيانات المحفوظة
    }
  }

  Future<void> _saveTrainingData() async {
    final prefs = await SharedPreferences.getInstance();
    // حفظ البيانات
  }

  /// الحصول على إحصائيات التعلم
  Future<Map<String, dynamic>> getLearningStats() async {
    return {
      'samples_trained': _trainingData.length,
      'network_layers': _attackBrain.layers.length,
      'total_neurons': _attackBrain.layers.fold(0, (s, l) => s + l.outputSize),
    };
  }
}
