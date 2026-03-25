class VoiceService {
  Future<void> init() async {}

  Future<bool> get isAvailable async => false;

  Future<void> startListening(Function(String) onResult) async {
    onResult('网页版暂不支持麦克风语音识别，请使用手动输入指令。');
  }

  Future<void> stopListening() async {}

  Future<void> speak(String message) async {}
}
