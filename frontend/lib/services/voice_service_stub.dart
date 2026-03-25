class VoiceService {
  Future<void> init() async {}

  Future<bool> get isAvailable async => false;

  Future<void> startListening(Function(String) onResult) async {
    onResult('当前平台不支持语音功能');
  }

  Future<void> stopListening() async {}

  Future<void> speak(String message) async {}
}
