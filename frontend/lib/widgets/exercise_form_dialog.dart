import 'package:flutter/material.dart';

import '../models/exercise.dart';

class ExerciseFormDialog extends StatefulWidget {
  const ExerciseFormDialog({super.key, this.initial});

  final Exercise? initial;

  @override
  State<ExerciseFormDialog> createState() => _ExerciseFormDialogState();
}

class _ExerciseFormDialogState extends State<ExerciseFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _setsController;
  late final TextEditingController _repsController;
  late final TextEditingController _minWeightController;
  late final TextEditingController _maxWeightController;
  late final TextEditingController _descriptionController;
  late String _muscle;
  late String _type;
  late String _difficulty;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _nameController = TextEditingController(text: initial?.name ?? '');
    _setsController = TextEditingController(text: (initial?.defaultSets ?? 4).toString());
    _repsController = TextEditingController(text: (initial?.defaultReps ?? 10).toString());
    _minWeightController = TextEditingController(text: (initial?.minWeight ?? 0).toString());
    _maxWeightController = TextEditingController(text: (initial?.maxWeight ?? 40).toString());
    _descriptionController = TextEditingController(text: initial?.description ?? '');
    _muscle = initial?.muscleGroup ?? MuscleGroups.all.first;
    _type = initial?.type ?? ExerciseTypes.all.first;
    _difficulty = initial?.difficulty ?? DifficultyLevels.all.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _minWeightController.dispose();
    _maxWeightController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? '添加动作' : '编辑动作'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: '动作名称')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(value: _muscle, items: MuscleGroups.all.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(), onChanged: (value) => setState(() => _muscle = value ?? _muscle), decoration: const InputDecoration(labelText: '训练部位')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(value: _type, items: ExerciseTypes.all.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(), onChanged: (value) => setState(() => _type = value ?? _type), decoration: const InputDecoration(labelText: '动作类型')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(value: _difficulty, items: DifficultyLevels.all.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(), onChanged: (value) => setState(() => _difficulty = value ?? _difficulty), decoration: const InputDecoration(labelText: '难度')),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: _setsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '组数'))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: _repsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '次数'))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: _minWeightController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: '最小重量'))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: _maxWeightController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: '最大重量'))),
              ],
            ),
            const SizedBox(height: 12),
            TextField(controller: _descriptionController, maxLines: 3, decoration: const InputDecoration(labelText: '动作说明')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('取消')),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(
              Exercise(
                id: widget.initial?.id,
                name: _nameController.text.trim(),
                muscleGroup: _muscle,
                type: _type,
                difficulty: _difficulty,
                defaultSets: int.tryParse(_setsController.text) ?? 4,
                defaultReps: int.tryParse(_repsController.text) ?? 10,
                minWeight: double.tryParse(_minWeightController.text) ?? 0,
                maxWeight: double.tryParse(_maxWeightController.text) ?? 40,
                description: _descriptionController.text.trim(),
                isPreset: widget.initial?.isPreset ?? false,
              ),
            );
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}
