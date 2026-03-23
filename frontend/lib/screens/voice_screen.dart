import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/voice_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_header.dart';
import '../widgets/section_card.dart';

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key});

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {
  final TextEditingController _manualController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VoiceProvider>().init();
    });
  }

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<VoiceProvider>(
          builder: (context, provider, _) {
            final parsed = provider.lastParsedCommand;
            return ListView(
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                const GradientHeader(
                  title: '语音交互',
                  subtitle: '支持动作库、计划、记录与查询语音指令，保留附件应用的反馈节奏，但不接入任何教练对话流。',
                  trailing: Icon(Icons.keyboard_voice, size: 42, color: Colors.white),
                ),
                SectionCard(
                  title: '常用语音指令',
                  subtitle: '可直接点击录音，也可手动输入文本模拟。',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      Chip(label: Text('添加动作 平板支撑')),
                      Chip(label: Text('生成本周训练计划')),
                      Chip(label: Text('记录今天深蹲完成4组12次，重量60kg')),
                      Chip(label: Text('我的近2周训练完成率是多少')),
                    ],
                  ),
                ),
                SectionCard(
                  title: '语音面板',
                  subtitle: '这里对应附件视频中的语音反馈页形式，包含大按钮、转写文本和结果回执。',
                  child: Column(
                    children: [
                      Container(
                        width: 168,
                        height: 168,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: provider.listening
                                ? [Colors.redAccent, Colors.deepOrange.shade300]
                                : [AppTheme.primaryColor, AppTheme.accentColor],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.35),
                              blurRadius: 28,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: IconButton(
                          iconSize: 64,
                          onPressed: provider.toggleListening,
                          icon: Icon(provider.listening ? Icons.stop : Icons.mic, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(provider.feedback, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundColor.withOpacity(0.28),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(provider.recognizedText.isEmpty ? '识别结果会显示在这里' : provider.recognizedText),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _manualController,
                        decoration: const InputDecoration(
                          labelText: '手动输入指令进行调试',
                          suffixIcon: Icon(Icons.send),
                        ),
                        onSubmitted: provider.parseCommand,
                      ),
                    ],
                  ),
                ),
                if (parsed != null)
                  SectionCard(
                    title: '解析结果',
                    subtitle: '后端返回的意图识别与结构化参数。',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('意图：${parsed['intent']}'),
                        const SizedBox(height: 8),
                        Text('实体：${parsed['entities']}'),
                        const SizedBox(height: 8),
                        Text('回复：${parsed['reply']}'),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
