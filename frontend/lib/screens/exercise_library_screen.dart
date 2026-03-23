import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/exercise.dart';
import '../providers/exercise_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/exercise_form_dialog.dart';
import '../widgets/gradient_header.dart';
import '../widgets/section_card.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExerciseProvider>().loadExercises();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('添加动作'),
      ),
      body: SafeArea(
        child: Consumer<ExerciseProvider>(
          builder: (context, provider, _) {
            return Column(
              children: [
                const GradientHeader(
                  title: '动作库管理',
                  subtitle: '参照附件应用的卡片式内容页节奏，但仅保留普通用户自主管理训练动作。',
                  trailing: Icon(Icons.dashboard_customize, size: 42, color: Colors.white),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    onChanged: provider.updateSearch,
                    decoration: const InputDecoration(
                      hintText: '搜索动作，例如 卧推 / 深蹲 / 核心',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildChip('全部部位', provider.selectedMuscle.isEmpty, () => provider.updateFilters(muscle: '')),
                      for (final muscle in MuscleGroups.all)
                        _buildChip(muscle, provider.selectedMuscle == muscle, () => provider.updateFilters(muscle: muscle)),
                    ],
                  ),
                ),
                Expanded(
                  child: provider.loading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView(
                          padding: const EdgeInsets.only(bottom: 96),
                          children: [
                            SectionCard(
                              title: '当前动作总数',
                              subtitle: '支持手动与语音扩展，完全剔除任何教练入驻/派单/指导功能入口。',
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${provider.exercises.length} 个动作', style: Theme.of(context).textTheme.headlineMedium),
                                  OutlinedButton(
                                    onPressed: provider.clearFilters,
                                    child: const Text('清空筛选'),
                                  ),
                                ],
                              ),
                            ),
                            for (final exercise in provider.exercises) _buildExerciseTile(context, provider, exercise),
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

  Widget _buildChip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }

  Widget _buildExerciseTile(BuildContext context, ExerciseProvider provider, Exercise exercise) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AppTheme.muscleColors[exercise.muscleGroup] ?? AppTheme.primaryColor,
          child: Text(exercise.muscleGroup.substring(0, 1)),
        ),
        title: Text(exercise.name),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(label: Text(exercise.muscleGroup)),
                  Chip(label: Text(exercise.type)),
                  Chip(label: Text(exercise.difficulty)),
                ],
              ),
              const SizedBox(height: 8),
              Text('${exercise.defaultSets} 组 x ${exercise.defaultReps} 次  ·  ${exercise.minWeight.toStringAsFixed(0)}-${exercise.maxWeight.toStringAsFixed(0)}kg'),
              const SizedBox(height: 6),
              Text(exercise.description),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'edit') {
              _openForm(context, initial: exercise);
            }
            if (value == 'delete' && exercise.id != null) {
              await provider.deleteExercise(exercise.id!);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('编辑')),
            PopupMenuItem(value: 'delete', child: Text('删除')),
          ],
        ),
      ),
    );
  }

  Future<void> _openForm(BuildContext context, {Exercise? initial}) async {
    final result = await showDialog<Exercise>(
      context: context,
      builder: (_) => ExerciseFormDialog(initial: initial),
    );
    if (!context.mounted || result == null) return;
    final provider = context.read<ExerciseProvider>();
    if (initial == null) {
      await provider.addExercise(result);
    } else {
      await provider.updateExercise(result);
    }
  }
}
