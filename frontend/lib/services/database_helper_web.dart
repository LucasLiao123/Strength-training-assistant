// Web 平台的内存数据库实现（不依赖 sqflite）
// 数据存储在 Dart 内存中，刷新页面后重置

import '../models/exercise.dart';
import '../models/training_plan.dart';
import '../models/training_record.dart';
import 'preset_exercises.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal() {
    _seedExercises();
  }

  // ─── 内存存储 ───────────────────────────────────────────
  final List<Exercise> _exercises = [];
  final List<TrainingPlan> _plans = [];
  final List<TrainingRecord> _records = [];
  UserProfile _userProfile = UserProfile();

  int _exerciseIdSeq = 1;
  int _planIdSeq = 1;
  int _recordIdSeq = 1;

  void _seedExercises() {
    for (final e in PresetExercises.all) {
      _exercises.add(Exercise(
        id: _exerciseIdSeq++,
        name: e.name,
        muscleGroup: e.muscleGroup,
        type: e.type,
        difficulty: e.difficulty,
        defaultSets: e.defaultSets,
        defaultReps: e.defaultReps,
        minWeight: e.minWeight,
        maxWeight: e.maxWeight,
        description: e.description,
        isPreset: true,
        createdAt: DateTime.now(),
      ));
    }
  }

  // ─── 动作库 CRUD ─────────────────────────────────────────

  Future<List<Exercise>> getExercises({
    String? muscleGroup,
    String? type,
    String? difficulty,
    String? searchQuery,
  }) async {
    return _exercises.where((e) {
      if (muscleGroup != null && muscleGroup.isNotEmpty && e.muscleGroup != muscleGroup) return false;
      if (type != null && type.isNotEmpty && e.type != type) return false;
      if (difficulty != null && difficulty.isNotEmpty && e.difficulty != difficulty) return false;
      if (searchQuery != null && searchQuery.isNotEmpty &&
          !e.name.toLowerCase().contains(searchQuery.toLowerCase())) return false;
      return true;
    }).toList()
      ..sort((a, b) {
        final mg = a.muscleGroup.compareTo(b.muscleGroup);
        return mg != 0 ? mg : a.name.compareTo(b.name);
      });
  }

  Future<Exercise?> getExercise(int id) async {
    try {
      return _exercises.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<int> insertExercise(Exercise exercise) async {
    final id = _exerciseIdSeq++;
    _exercises.add(Exercise(
      id: id,
      name: exercise.name,
      muscleGroup: exercise.muscleGroup,
      type: exercise.type,
      difficulty: exercise.difficulty,
      defaultSets: exercise.defaultSets,
      defaultReps: exercise.defaultReps,
      minWeight: exercise.minWeight,
      maxWeight: exercise.maxWeight,
      description: exercise.description,
      imageUrl: exercise.imageUrl,
      videoUrl: exercise.videoUrl,
      isPreset: exercise.isPreset,
      createdAt: exercise.createdAt,
    ));
    return id;
  }

  Future<int> updateExercise(Exercise exercise) async {
    final idx = _exercises.indexWhere((e) => e.id == exercise.id);
    if (idx == -1) return 0;
    _exercises[idx] = exercise;
    return 1;
  }

  Future<int> deleteExercise(int id) async {
    final before = _exercises.length;
    _exercises.removeWhere((e) => e.id == id);
    return _exercises.length < before ? 1 : 0;
  }

  // ─── 训练计划 CRUD ────────────────────────────────────────

  Future<int> insertPlan(TrainingPlan plan) async {
    final id = _planIdSeq++;
    if (plan.isActive) {
      for (var i = 0; i < _plans.length; i++) {
        _plans[i] = TrainingPlan(
          id: _plans[i].id,
          name: _plans[i].name,
          goal: _plans[i].goal,
          level: _plans[i].level,
          daysPerWeek: _plans[i].daysPerWeek,
          minutesPerSession: _plans[i].minutesPerSession,
          avoidMuscles: _plans[i].avoidMuscles,
          dailyPlans: _plans[i].dailyPlans,
          createdAt: _plans[i].createdAt,
          isActive: false,
        );
      }
    }
    _plans.add(TrainingPlan(
      id: id,
      name: plan.name,
      goal: plan.goal,
      level: plan.level,
      daysPerWeek: plan.daysPerWeek,
      minutesPerSession: plan.minutesPerSession,
      avoidMuscles: plan.avoidMuscles,
      dailyPlans: plan.dailyPlans,
      createdAt: plan.createdAt,
      isActive: plan.isActive,
    ));
    return id;
  }

  Future<TrainingPlan?> getActivePlan() async {
    try {
      return _plans.firstWhere((p) => p.isActive);
    } catch (_) {
      return null;
    }
  }

  Future<List<TrainingPlan>> getAllPlans() async {
    return List.from(_plans.reversed);
  }

  Future<void> deletePlan(int id) async {
    _plans.removeWhere((p) => p.id == id);
  }

  // ─── 训练记录 CRUD ────────────────────────────────────────

  Future<int> insertRecord(TrainingRecord record) async {
    final id = _recordIdSeq++;
    _records.add(TrainingRecord(
      id: id,
      planExerciseId: record.planExerciseId,
      exerciseId: record.exerciseId,
      exerciseName: record.exerciseName,
      muscleGroup: record.muscleGroup,
      completedSets: record.completedSets,
      completedReps: record.completedReps,
      completedWeight: record.completedWeight,
      completionScore: record.completionScore,
      fatigueScore: record.fatigueScore,
      targetMet: record.targetMet,
      notes: record.notes,
      trainingDate: record.trainingDate,
    ));
    return id;
  }

  Future<List<TrainingRecord>> getRecords({
    DateTime? from,
    DateTime? to,
    String? muscleGroup,
  }) async {
    return _records.where((r) {
      if (from != null && r.trainingDate.isBefore(from)) return false;
      if (to != null && r.trainingDate.isAfter(to)) return false;
      if (muscleGroup != null && r.muscleGroup != muscleGroup) return false;
      return true;
    }).toList()
      ..sort((a, b) => b.trainingDate.compareTo(a.trainingDate));
  }

  Future<List<TrainingRecord>> getRecentRecords(int days) async {
    final from = DateTime.now().subtract(Duration(days: days));
    return getRecords(from: from);
  }

  // ─── 用户信息 ─────────────────────────────────────────────

  Future<UserProfile> getUserProfile() async => _userProfile;

  Future<void> saveUserProfile(UserProfile profile) async {
    _userProfile = profile;
  }

  // ─── 导出 ─────────────────────────────────────────────────

  Future<Map<String, dynamic>> exportData() async {
    return {
      'exercises': _exercises.map((e) => e.toMap()).toList(),
      'training_plans': _plans.map((p) => p.toMap()).toList(),
      'training_records': _records.map((r) => r.toMap()).toList(),
      'user_profile': [_userProfile.toMap()],
    };
  }
}
