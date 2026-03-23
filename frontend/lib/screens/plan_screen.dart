import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/exercise.dart';
import '../models/training_plan.dart';
import '../providers/plan_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_header.dart';
import '../widgets/section_card.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  String _goal = TrainingGoals.all.first;
  String _level = DifficultyLevels.all[1];
  int _daysPerWeek = 4;
  int _minutes = 60;
  final Set<String> _avoidMuscles = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlanProvider>().loadPlan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<PlanProvider>(
          builder: (context, provider, _) {
            return ListView(
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                const GradientHeader(
                  title: '智能计划',
                  subtitle: '按附件应用的信息填写页结构组织内容，但训练逻辑仅围绕个人力量训练计划生成与调整。',
                  trailing: Icon(Icons.auto_awesome, size: 42, color: Colors.white),
                ),
                SectionCard(
                  title: '用户信息采集',
                  subtitle: '这里对应附件视频中的信息填写页交互节奏。未实现任何教练匹配、教练咨询或派单入口。',
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _goal,
                        items: TrainingGoals.all.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                        onChanged: (value) => setState(() => _goal = value ?? _goal),
                        decoration: const InputDecoration(labelText: '训练目标'),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _level,
                        items: DifficultyLevels.all.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                        onChanged: (value) => setState(() => _level = value ?? _level),
                        decoration: const InputDecoration(labelText: '训练水平'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('每周训练天数：$_daysPerWeek'),
                                Slider(
                                  value: _daysPerWeek.toDouble(),
                                  min: 2,
                                  max: 6,
                                  divisions: 4,
                                  label: _daysPerWeek.toString(),
                                  onChanged: (value) => setState(() => _daysPerWeek = value.round()),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('单次时长：$_minutes 分钟'),
                                Slider(
                                  value: _minutes.toDouble(),
                                  min: 30,
                                  max: 120,
                                  divisions: 6,
                                  label: _minutes.toString(),
                                  onChanged: (value) => setState(() => _minutes = value.round()),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('禁忌部位', style: Theme.of(context).textTheme.titleMedium),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final muscle in MuscleGroups.all)
                            FilterChip(
                              label: Text(muscle),
                              selected: _avoidMuscles.contains(muscle),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _avoidMuscles.add(muscle);
                                  } else {
                                    _avoidMuscles.remove(muscle);
                                  }
                                });
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: provider.loading
                              ? null
                              : () {
                                  provider.generatePlan(
                                    goal: _goal,
                                    level: _level,
                                    daysPerWeek: _daysPerWeek,
                                    minutesPerSession: _minutes,
                                    avoidMuscles: _avoidMuscles.toList(),
                                  );
                                },
                          icon: const Icon(Icons.bolt),
                          label: Text(provider.loading ? '生成中...' : '生成本周训练计划'),
                        ),
                      ),
                    ],
                  ),
                ),
                SectionCard(
                  title: '动态调整规则',
                  subtitle: '完成度高则渐进超负荷，疲劳高或有伤病备注则自动降强度或换动作。',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('1. 完成度 >= 8 且疲劳度 <= 5：下周重量上调 5%-10% 或增加 1 组。'),
                      SizedBox(height: 8),
                      Text('2. 完成度 <= 5 或疲劳度 >= 8：减少组数或改为更简单动作。'),
                      SizedBox(height: 8),
                      Text('3. 备注含膝盖/肩/腰不适：规避对应高强度动作并替换为安全变式。'),
                    ],
                  ),
                ),
                if (provider.activePlan != null) ...[
                  SectionCard(
                    title: provider.activePlan!.name,
                    subtitle: provider.status,
                    child: Column(
                      children: [
                        for (final day in provider.activePlan!.dailyPlans) _buildDayCard(day),
                      ],
                    ),
                  ),
                ] else
                  SectionCard(
                    title: '当前没有已激活计划',
                    subtitle: provider.status,
                    child: const Text('先填写上面的基础信息并生成计划。'),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDayCard(DailyPlan day) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor.withOpacity(0.28),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(DailyPlan.dayName(day.dayOfWeek), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              Chip(label: Text(day.focus)),
            ],
          ),
          const SizedBox(height: 10),
          for (final item in day.exercises)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.chevron_right, color: AppTheme.primaryColor),
                  Expanded(child: Text(item.exerciseName)),
                  Text('${item.sets}x${item.reps}'),
                  const SizedBox(width: 12),
                  Text('${item.weight.toStringAsFixed(0)}kg'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
