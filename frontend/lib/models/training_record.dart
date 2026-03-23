// 训练记录及反馈数据模型
// 用于记录每次训练的完成情况及支持动态调整

class TrainingRecord {
  final int? id;
  final int? planExerciseId;
  final int exerciseId;
  final String exerciseName;
  final String muscleGroup;
  final int completedSets;
  final int completedReps;
  final double completedWeight;
  final int completionScore;    // 完成度 1-10
  final int fatigueScore;       // 疲劳度 1-10
  final bool targetMet;         // 是否达标
  final String? notes;          // 备注(如伤病信息)
  final DateTime trainingDate;

  TrainingRecord({
    this.id,
    this.planExerciseId,
    required this.exerciseId,
    required this.exerciseName,
    required this.muscleGroup,
    this.completedSets = 0,
    this.completedReps = 0,
    this.completedWeight = 0,
    this.completionScore = 5,
    this.fatigueScore = 5,
    this.targetMet = false,
    this.notes,
    DateTime? trainingDate,
  }) : trainingDate = trainingDate ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plan_exercise_id': planExerciseId,
      'exercise_id': exerciseId,
      'exercise_name': exerciseName,
      'muscle_group': muscleGroup,
      'completed_sets': completedSets,
      'completed_reps': completedReps,
      'completed_weight': completedWeight,
      'completion_score': completionScore,
      'fatigue_score': fatigueScore,
      'target_met': targetMet ? 1 : 0,
      'notes': notes,
      'training_date': trainingDate.toIso8601String(),
    };
  }

  factory TrainingRecord.fromMap(Map<String, dynamic> map) {
    return TrainingRecord(
      id: map['id'] as int?,
      planExerciseId: map['plan_exercise_id'] as int?,
      exerciseId: map['exercise_id'] as int,
      exerciseName: map['exercise_name'] as String,
      muscleGroup: map['muscle_group'] as String,
      completedSets: map['completed_sets'] as int? ?? 0,
      completedReps: map['completed_reps'] as int? ?? 0,
      completedWeight: (map['completed_weight'] as num?)?.toDouble() ?? 0,
      completionScore: map['completion_score'] as int? ?? 5,
      fatigueScore: map['fatigue_score'] as int? ?? 5,
      targetMet: (map['target_met'] as int?) == 1,
      notes: map['notes'] as String?,
      trainingDate: map['training_date'] != null
          ? DateTime.parse(map['training_date'] as String)
          : DateTime.now(),
    );
  }
}

// 周报告模型
class WeeklyReport {
  final DateTime weekStart;
  final DateTime weekEnd;
  final int totalSessions;        // 总训练次数
  final int plannedSessions;      // 计划训练次数
  final double completionRate;    // 完成率 0-1
  final Map<String, int> muscleDistribution;  // 部位训练分布
  final double avgCompletionScore;
  final double avgFatigueScore;
  final Map<String, double> strengthProgress;  // 力量变化趋势

  WeeklyReport({
    required this.weekStart,
    required this.weekEnd,
    this.totalSessions = 0,
    this.plannedSessions = 0,
    this.completionRate = 0,
    this.muscleDistribution = const {},
    this.avgCompletionScore = 0,
    this.avgFatigueScore = 0,
    this.strengthProgress = const {},
  });
}

// 用户个人信息
class UserProfile {
  final String? name;
  final String goal;            // 增肌/减脂/力量
  final String level;           // 新手/中级/高级
  final int daysPerWeek;
  final int minutesPerSession;
  final List<String> avoidMuscles;

  UserProfile({
    this.name,
    this.goal = '增肌',
    this.level = '中级',
    this.daysPerWeek = 4,
    this.minutesPerSession = 60,
    this.avoidMuscles = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'goal': goal,
      'level': level,
      'days_per_week': daysPerWeek,
      'minutes_per_session': minutesPerSession,
      'avoid_muscles': avoidMuscles.join(','),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] as String?,
      goal: map['goal'] as String? ?? '增肌',
      level: map['level'] as String? ?? '中级',
      daysPerWeek: map['days_per_week'] as int? ?? 4,
      minutesPerSession: map['minutes_per_session'] as int? ?? 60,
      avoidMuscles: (map['avoid_muscles'] as String?)?.isNotEmpty == true
          ? (map['avoid_muscles'] as String).split(',')
          : [],
    );
  }
}
