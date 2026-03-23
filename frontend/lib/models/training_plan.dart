// 训练计划数据模型
// 包含周计划、每日训练安排及其中的具体动作

class TrainingPlan {
  final int? id;
  final String name;            // 计划名称
  final String goal;            // 训练目标: 增肌/减脂/力量
  final String level;           // 用户水平: 新手/中级/高级
  final int daysPerWeek;        // 每周训练天数
  final int minutesPerSession;  // 每次训练时长(分钟)
  final List<String> avoidMuscles; // 禁忌部位
  final List<DailyPlan> dailyPlans;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;          // 是否为当前启用计划

  TrainingPlan({
    this.id,
    required this.name,
    required this.goal,
    required this.level,
    this.daysPerWeek = 4,
    this.minutesPerSession = 60,
    this.avoidMuscles = const [],
    this.dailyPlans = const [],
    DateTime? createdAt,
    this.updatedAt,
    this.isActive = true,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'goal': goal,
      'level': level,
      'days_per_week': daysPerWeek,
      'minutes_per_session': minutesPerSession,
      'avoid_muscles': avoidMuscles.join(','),
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory TrainingPlan.fromMap(Map<String, dynamic> map,
      {List<DailyPlan> dailyPlans = const []}) {
    return TrainingPlan(
      id: map['id'] as int?,
      name: map['name'] as String,
      goal: map['goal'] as String,
      level: map['level'] as String,
      daysPerWeek: map['days_per_week'] as int? ?? 4,
      minutesPerSession: map['minutes_per_session'] as int? ?? 60,
      avoidMuscles: (map['avoid_muscles'] as String?)?.isNotEmpty == true
          ? (map['avoid_muscles'] as String).split(',')
          : [],
      dailyPlans: dailyPlans,
      isActive: (map['is_active'] as int?) == 1,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  TrainingPlan copyWith({
    int? id,
    String? name,
    String? goal,
    String? level,
    int? daysPerWeek,
    int? minutesPerSession,
    List<String>? avoidMuscles,
    List<DailyPlan>? dailyPlans,
    bool? isActive,
  }) {
    return TrainingPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      goal: goal ?? this.goal,
      level: level ?? this.level,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      minutesPerSession: minutesPerSession ?? this.minutesPerSession,
      avoidMuscles: avoidMuscles ?? this.avoidMuscles,
      dailyPlans: dailyPlans ?? this.dailyPlans,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

// 每日训练安排
class DailyPlan {
  final int? id;
  final int? planId;
  final int dayOfWeek;          // 周几(1=周一...7=周日)
  final String focus;           // 训练重点(如"胸+三头")
  final List<PlanExercise> exercises;

  DailyPlan({
    this.id,
    this.planId,
    required this.dayOfWeek,
    required this.focus,
    this.exercises = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plan_id': planId,
      'day_of_week': dayOfWeek,
      'focus': focus,
    };
  }

  factory DailyPlan.fromMap(Map<String, dynamic> map,
      {List<PlanExercise> exercises = const []}) {
    return DailyPlan(
      id: map['id'] as int?,
      planId: map['plan_id'] as int?,
      dayOfWeek: map['day_of_week'] as int,
      focus: map['focus'] as String,
      exercises: exercises,
    );
  }

  static String dayName(int dayOfWeek) {
    const days = ['', '周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return days[dayOfWeek.clamp(1, 7)];
  }
}

// 计划中的具体动作安排
class PlanExercise {
  final int? id;
  final int? dailyPlanId;
  final int exerciseId;
  final String exerciseName;
  final int sets;
  final int reps;
  final double weight;
  final int orderIndex;         // 动作顺序
  final int restSeconds;        // 组间休息(秒)

  PlanExercise({
    this.id,
    this.dailyPlanId,
    required this.exerciseId,
    required this.exerciseName,
    this.sets = 4,
    this.reps = 10,
    this.weight = 0,
    this.orderIndex = 0,
    this.restSeconds = 90,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'daily_plan_id': dailyPlanId,
      'exercise_id': exerciseId,
      'exercise_name': exerciseName,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'order_index': orderIndex,
      'rest_seconds': restSeconds,
    };
  }

  factory PlanExercise.fromMap(Map<String, dynamic> map) {
    return PlanExercise(
      id: map['id'] as int?,
      dailyPlanId: map['daily_plan_id'] as int?,
      exerciseId: map['exercise_id'] as int,
      exerciseName: map['exercise_name'] as String,
      sets: map['sets'] as int? ?? 4,
      reps: map['reps'] as int? ?? 10,
      weight: (map['weight'] as num?)?.toDouble() ?? 0,
      orderIndex: map['order_index'] as int? ?? 0,
      restSeconds: map['rest_seconds'] as int? ?? 90,
    );
  }

  PlanExercise copyWith({
    int? sets,
    int? reps,
    double? weight,
    int? restSeconds,
  }) {
    return PlanExercise(
      id: id,
      dailyPlanId: dailyPlanId,
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      orderIndex: orderIndex,
      restSeconds: restSeconds ?? this.restSeconds,
    );
  }
}

// 训练目标常量
class TrainingGoals {
  static const List<String> all = ['增肌', '减脂', '力量'];
}
