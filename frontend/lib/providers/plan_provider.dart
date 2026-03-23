import 'package:flutter/foundation.dart';

import '../models/training_plan.dart';
import '../models/training_record.dart';
import '../services/api_service.dart';
import '../services/database_helper.dart';

class PlanProvider extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final ApiService _apiService = ApiService();

  TrainingPlan? _activePlan;
  bool _loading = false;
  String _status = '尚未生成计划';

  TrainingPlan? get activePlan => _activePlan;
  bool get loading => _loading;
  String get status => _status;

  Future<void> loadPlan() async {
    _loading = true;
    notifyListeners();
    _activePlan = await _databaseHelper.getActivePlan();
    _status = _activePlan == null ? '尚未生成计划' : '当前计划已加载';
    _loading = false;
    notifyListeners();
  }

  Future<void> generatePlan({
    required String goal,
    required String level,
    required int daysPerWeek,
    required int minutesPerSession,
    required List<String> avoidMuscles,
  }) async {
    _loading = true;
    _status = '正在生成计划';
    notifyListeners();

    try {
      final payload = {
        'goal': goal,
        'level': level,
        'days_per_week': daysPerWeek,
        'minutes_per_session': minutesPerSession,
        'avoid_muscles': avoidMuscles,
      };
      final response = await _apiService.generatePlan(payload);
      final plan = _fromBackendResponse(response);
      await _databaseHelper.insertPlan(plan);
      _activePlan = await _databaseHelper.getActivePlan();
      _status = '计划生成完成';
    } catch (_) {
      _status = '后端不可用，显示本地默认状态';
    }

    _loading = false;
    notifyListeners();
  }

  Future<String> adjustPlan(List<TrainingRecord> records) async {
    if (_activePlan == null) return '当前没有可调整的计划';
    _loading = true;
    notifyListeners();

    try {
      final response = await _apiService.adjustPlan({
        'plan': _serializePlan(_activePlan!),
        'records': records.map((record) => record.toMap()).toList(),
      });
      _status = response['summary']?.toString() ?? '计划已调整';
    } catch (_) {
      _status = '后端未连接，暂未执行自动调整';
    }

    _loading = false;
    notifyListeners();
    return _status;
  }

  TrainingPlan _fromBackendResponse(Map<String, dynamic> response) {
    final days = (response['days'] as List<dynamic>? ?? []);
    return TrainingPlan(
      name: response['name']?.toString() ?? '智能训练计划',
      goal: response['goal']?.toString() ?? '增肌',
      level: response['level']?.toString() ?? '中级',
      daysPerWeek: response['days_per_week'] as int? ?? 4,
      minutesPerSession: response['minutes_per_session'] as int? ?? 60,
      avoidMuscles: (response['avoid_muscles'] as List<dynamic>? ?? []).cast<String>(),
      dailyPlans: days.map((item) {
        final day = item as Map<String, dynamic>;
        return DailyPlan(
          dayOfWeek: day['day_of_week'] as int? ?? 1,
          focus: day['focus']?.toString() ?? '全身',
          exercises: (day['exercises'] as List<dynamic>? ?? []).map((exercise) {
            final value = exercise as Map<String, dynamic>;
            return PlanExercise(
              exerciseId: value['exercise_id'] as int? ?? 0,
              exerciseName: value['exercise_name']?.toString() ?? '',
              sets: value['sets'] as int? ?? 4,
              reps: value['reps'] as int? ?? 10,
              weight: (value['weight'] as num?)?.toDouble() ?? 0,
              orderIndex: value['order_index'] as int? ?? 0,
              restSeconds: value['rest_seconds'] as int? ?? 90,
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  Map<String, dynamic> _serializePlan(TrainingPlan plan) {
    return {
      ...plan.toMap(),
      'daily_plans': plan.dailyPlans.map((day) {
        return {
          ...day.toMap(),
          'exercises': day.exercises.map((exercise) => exercise.toMap()).toList(),
        };
      }).toList(),
    };
  }
}
