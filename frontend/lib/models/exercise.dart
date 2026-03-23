// 动作数据模型
// 包含力量训练动作的全部属性

class Exercise {
  final int? id;
  final String name;             // 动作名称
  final String muscleGroup;      // 训练部位: 胸/背/肩/腿/手臂/核心
  final String type;             // 动作类型: 复合/孤立
  final String difficulty;       // 难度: 新手/中级/高级
  final int defaultSets;         // 默认组数
  final int defaultReps;         // 默认次数
  final double minWeight;        // 最小建议重量(kg)
  final double maxWeight;        // 最大建议重量(kg)
  final String description;      // 动作说明/要点
  final String? imageUrl;        // 示范图片链接(可选)
  final String? videoUrl;        // 示范视频链接(可选)
  final bool isPreset;           // 是否为预设动作
  final DateTime createdAt;

  Exercise({
    this.id,
    required this.name,
    required this.muscleGroup,
    required this.type,
    required this.difficulty,
    this.defaultSets = 4,
    this.defaultReps = 10,
    this.minWeight = 0,
    this.maxWeight = 100,
    this.description = '',
    this.imageUrl,
    this.videoUrl,
    this.isPreset = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'muscle_group': muscleGroup,
      'type': type,
      'difficulty': difficulty,
      'default_sets': defaultSets,
      'default_reps': defaultReps,
      'min_weight': minWeight,
      'max_weight': maxWeight,
      'description': description,
      'image_url': imageUrl,
      'video_url': videoUrl,
      'is_preset': isPreset ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as int?,
      name: map['name'] as String,
      muscleGroup: map['muscle_group'] as String,
      type: map['type'] as String,
      difficulty: map['difficulty'] as String,
      defaultSets: map['default_sets'] as int? ?? 4,
      defaultReps: map['default_reps'] as int? ?? 10,
      minWeight: (map['min_weight'] as num?)?.toDouble() ?? 0,
      maxWeight: (map['max_weight'] as num?)?.toDouble() ?? 100,
      description: map['description'] as String? ?? '',
      imageUrl: map['image_url'] as String?,
      videoUrl: map['video_url'] as String?,
      isPreset: (map['is_preset'] as int?) == 1,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
    );
  }

  Exercise copyWith({
    int? id,
    String? name,
    String? muscleGroup,
    String? type,
    String? difficulty,
    int? defaultSets,
    int? defaultReps,
    double? minWeight,
    double? maxWeight,
    String? description,
    String? imageUrl,
    String? videoUrl,
    bool? isPreset,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      defaultSets: defaultSets ?? this.defaultSets,
      defaultReps: defaultReps ?? this.defaultReps,
      minWeight: minWeight ?? this.minWeight,
      maxWeight: maxWeight ?? this.maxWeight,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      isPreset: isPreset ?? this.isPreset,
      createdAt: createdAt,
    );
  }
}

// 训练部位常量
class MuscleGroups {
  static const List<String> all = ['胸', '背', '肩', '腿', '手臂', '核心'];
}

// 动作类型常量
class ExerciseTypes {
  static const List<String> all = ['复合', '孤立'];
}

// 难度常量
class DifficultyLevels {
  static const List<String> all = ['新手', '中级', '高级'];
}
