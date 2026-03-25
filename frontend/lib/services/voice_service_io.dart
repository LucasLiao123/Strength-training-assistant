import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  final SpeechToText speech = SpeechToText();
  final FlutterTts tts = FlutterTts();

  Future<void> init() async {
    await speech.initialize();
    await tts.setLanguage('zh-CN');
    await tts.setSpeechRate(0.42);
    await tts.setPitch(1.0);
  }

  Future<bool> get isAvailable async => speech.initialize();

  Future<void> startListening(Function(String) onResult) async {
    await speech.listen(
      localeId: 'zh_CN',
      onResult: (result) => onResult(result.recognizedWords),
    );
  }

  Future<void> stopListening() async {
    await speech.stop();
  }

  Future<void> speak(String message) async {
    await tts.stop();
    await tts.speak(message);
  }
}
