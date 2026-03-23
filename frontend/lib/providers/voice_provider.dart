import 'package:flutter/foundation.dart';

import '../services/api_service.dart';
import '../services/voice_service.dart';

class VoiceProvider extends ChangeNotifier {
  final VoiceService _voiceService = VoiceService();
  final ApiService _apiService = ApiService();

  bool _listening = false;
  String _recognizedText = '';
  String _feedback = '点击开始语音';
  Map<String, dynamic>? _lastParsedCommand;

  bool get listening => _listening;
  String get recognizedText => _recognizedText;
  String get feedback => _feedback;
  Map<String, dynamic>? get lastParsedCommand => _lastParsedCommand;

  Future<void> init() async {
    await _voiceService.init();
  }

  Future<void> toggleListening() async {
    if (_listening) {
      await _voiceService.stopListening();
      _listening = false;
      notifyListeners();
      return;
    }

    _recognizedText = '';
    _feedback = '正在监听，请说出指令';
    _listening = true;
    notifyListeners();

    await _voiceService.startListening((text) async {
      _recognizedText = text;
      notifyListeners();
      if (text.trim().isNotEmpty) {
        await parseCommand(text);
      }
    });
  }

  Future<void> parseCommand(String text) async {
    try {
      final parsed = await _apiService.parseVoiceCommand(text);
      _lastParsedCommand = parsed;
      _feedback = parsed['reply']?.toString() ?? '已解析语音指令';
      await _voiceService.speak(_feedback);
    } catch (_) {
      _feedback = '语音服务暂不可用，已保留识别文本';
    } finally {
      _listening = false;
      notifyListeners();
    }
  }
}
