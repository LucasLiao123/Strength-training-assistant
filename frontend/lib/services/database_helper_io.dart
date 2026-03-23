// 本地SQLite数据库管理
// 管理动作库、训练计划、训练记录的CRUD操作

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/exercise.dart';
import '../models/training_plan.dart';
import '../models/training_record.dart';
import 'preset_exercises.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'strength_training.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 动作表
    await db.execute('''
      CREATE TABLE exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        muscle_group TEXT NOT NULL,
        type TEXT NOT NULL,
        difficulty TEXT NOT NULL,
        default_sets INTEGER DEFAULT 4,
        default_reps INTEGER DEFAULT 10,
        min_weight REAL DEFAULT 0,
        max_weight REAL DEFAULT 100,
        description TEXT DEFAULT '',
        image_url TEXT,
        video_url TEXT,
        is_preset INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // 训练计划表
    await db.execute('''
      CREATE TABLE training_plans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        goal TEXT NOT NULL,
        level TEXT NOT NULL,
        days_per_week INTEGER DEFAULT 4,
        minutes_per_session INTEGER DEFAULT 60,
        avoid_muscles TEXT DEFAULT '',
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    // 每日计划表
    await db.execute('''
      CREATE TABLE daily_plans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        plan_id INTEGER NOT NULL,
        day_of_week INTEGER NOT NULL,
        focus TEXT NOT NULL,
        FOREIGN KEY (plan_id) REFERENCES training_plans(id) ON DELETE CASCADE
      )
    ''');

    // 计划动作表
    await db.execute('''
      CREATE TABLE plan_exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        daily_plan_id INTEGER NOT NULL,
        exercise_id INTEGER NOT NULL,
        exercise_name TEXT NOT NULL,
        sets INTEGER DEFAULT 4,
        reps INTEGER DEFAULT 10,
        weight REAL DEFAULT 0,
        order_index INTEGER DEFAULT 0,
        rest_seconds INTEGER DEFAULT 90,
        FOREIGN KEY (daily_plan_id) REFERENCES daily_plans(id) ON DELETE CASCADE,
        FOREIGN KEY (exercise_id) REFERENCES exercises(id)
      )
    ''');

    // 训练记录表
    await db.execute('''
      CREATE TABLE training_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        plan_exercise_id INTEGER,
        exercise_id INTEGER NOT NULL,
        exercise_name TEXT NOT NULL,
        muscle_group TEXT NOT NULL,
        completed_sets INTEGER DEFAULT 0,
        completed_reps INTEGER DEFAULT 0,
        completed_weight REAL DEFAULT 0,
        completion_score INTEGER DEFAULT 5,
        fatigue_score INTEGER DEFAULT 5,
        target_met INTEGER DEFAULT 0,
        notes TEXT,
        training_date TEXT NOT NULL,
        FOREIGN KEY (exercise_id) REFERENCES exercises(id)
      )
    ''');

    // 用户信息表
    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        name TEXT,
        goal TEXT DEFAULT '增肌',
        level TEXT DEFAULT '中级',
        days_per_week INTEGER DEFAULT 4,
        minutes_per_session INTEGER DEFAULT 60,
        avoid_muscles TEXT DEFAULT ''
      )
    ''');

    // 插入预设动作
    await _insertPresetExercises(db);
  }

  Future<void> _insertPresetExercises(Database db) async {
    final batch = db.batch();
    for (final exercise in PresetExercises.all) {
      batch.insert('exercises', exercise.toMap());
    }
    await batch.commit(noResult: true);
  }

  // =================== 动作库 CRUD ===================

  Future<List<Exercise>> getExercises({
    String? muscleGroup,
    String? type,
    String? difficulty,
    String? searchQuery,
  }) async {
    final db = await database;
    String where = '';
    List<String> conditions = [];
    List<dynamic> args = [];

    if (muscleGroup != null && muscleGroup.isNotEmpty) {
      conditions.add('muscle_group = ?');
      args.add(muscleGroup);
    }
    if (type != null && type.isNotEmpty) {
      conditions.add('type = ?');
      args.add(type);
    }
    if (difficulty != null && difficulty.isNotEmpty) {
      conditions.add('difficulty = ?');
      args.add(difficulty);
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      conditions.add('name LIKE ?');
      args.add('%$searchQuery%');
    }

    if (conditions.isNotEmpty) {
      where = conditions.join(' AND ');
    }

    final maps = await db.query(
      'exercises',
      where: where.isNotEmpty ? where : null,
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: 'muscle_group, name',
    );

    return maps.map((m) => Exercise.fromMap(m)).toList();
  }

  Future<Exercise?> getExercise(int id) async {
    final db = await database;
    final maps = await db.query('exercises', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Exercise.fromMap(maps.first);
  }

  Future<int> insertExercise(Exercise exercise) async {
    final db = await database;
    return await db.insert('exercises', exercise.toMap());
  }

  Future<int> updateExercise(Exercise exercise) async {
    final db = await database;
    return await db.update(
      'exercises',
      exercise.toMap(),
      where: 'id = ?',
      whereArgs: [exercise.id],
    );
  }

  Future<int> deleteExercise(int id) async {
    final db = await database;
    return await db.delete('exercises', where: 'id = ?', whereArgs: [id]);
  }

  // =================== 训练计划 CRUD ===================

  Future<int> insertPlan(TrainingPlan plan) async {
    final db = await database;
    // 如果设为活跃，先将其他计划设为非活跃
    if (plan.isActive) {
      await db.update('training_plans', {'is_active': 0});
    }
    final planId = await db.insert('training_plans', plan.toMap());

    // 插入每日计划及动作
    for (final daily in plan.dailyPlans) {
      final dailyMap = daily.toMap();
      dailyMap['plan_id'] = planId;
      final dailyId = await db.insert('daily_plans', dailyMap);

      for (final exercise in daily.exercises) {
        final exMap = exercise.toMap();
        exMap['daily_plan_id'] = dailyId;
        await db.insert('plan_exercises', exMap);
      }
    }
    return planId;
  }

  Future<TrainingPlan?> getActivePlan() async {
    final db = await database;
    final plans = await db.query(
      'training_plans',
      where: 'is_active = 1',
      limit: 1,
    );
    if (plans.isEmpty) return null;

    final plan = plans.first;
    final dailyPlans = await _getDailyPlans(plan['id'] as int);
    return TrainingPlan.fromMap(plan, dailyPlans: dailyPlans);
  }

  Future<List<TrainingPlan>> getAllPlans() async {
    final db = await database;
    final plans = await db.query('training_plans', orderBy: 'created_at DESC');
    List<TrainingPlan> result = [];
    for (final p in plans) {
      final dailyPlans = await _getDailyPlans(p['id'] as int);
      result.add(TrainingPlan.fromMap(p, dailyPlans: dailyPlans));
    }
    return result;
  }

  Future<List<DailyPlan>> _getDailyPlans(int planId) async {
    final db = await database;
    final dailies = await db.query(
      'daily_plans',
      where: 'plan_id = ?',
      whereArgs: [planId],
      orderBy: 'day_of_week',
    );

    List<DailyPlan> result = [];
    for (final d in dailies) {
      final exercises = await db.query(
        'plan_exercises',
        where: 'daily_plan_id = ?',
        whereArgs: [d['id']],
        orderBy: 'order_index',
      );
      result.add(DailyPlan.fromMap(
        d,
        exercises: exercises.map((e) => PlanExercise.fromMap(e)).toList(),
      ));
    }
    return result;
  }

  Future<void> deletePlan(int id) async {
    final db = await database;
    await db.delete('training_plans', where: 'id = ?', whereArgs: [id]);
  }

  // =================== 训练记录 CRUD ===================

  Future<int> insertRecord(TrainingRecord record) async {
    final db = await database;
    return await db.insert('training_records', record.toMap());
  }

  Future<List<TrainingRecord>> getRecords({
    DateTime? from,
    DateTime? to,
    String? muscleGroup,
  }) async {
    final db = await database;
    List<String> conditions = [];
    List<dynamic> args = [];

    if (from != null) {
      conditions.add('training_date >= ?');
      args.add(from.toIso8601String());
    }
    if (to != null) {
      conditions.add('training_date <= ?');
      args.add(to.toIso8601String());
    }
    if (muscleGroup != null) {
      conditions.add('muscle_group = ?');
      args.add(muscleGroup);
    }

    final maps = await db.query(
      'training_records',
      where: conditions.isNotEmpty ? conditions.join(' AND ') : null,
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: 'training_date DESC',
    );

    return maps.map((m) => TrainingRecord.fromMap(m)).toList();
  }

  Future<List<TrainingRecord>> getRecentRecords(int days) async {
    final from = DateTime.now().subtract(Duration(days: days));
    return getRecords(from: from);
  }

  // =================== 用户信息 ===================

  Future<UserProfile> getUserProfile() async {
    final db = await database;
    final maps = await db.query('user_profile');
    if (maps.isEmpty) {
      // 返回默认配置
      return UserProfile();
    }
    return UserProfile.fromMap(maps.first);
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    final db = await database;
    final existing = await db.query('user_profile');
    final map = profile.toMap();
    map['id'] = 1;
    if (existing.isEmpty) {
      await db.insert('user_profile', map);
    } else {
      await db.update('user_profile', map, where: 'id = 1');
    }
  }

  // =================== 导出/导入 ===================

  Future<Map<String, dynamic>> exportData() async {
    final db = await database;
    return {
      'exercises': await db.query('exercises'),
      'training_plans': await db.query('training_plans'),
      'daily_plans': await db.query('daily_plans'),
      'plan_exercises': await db.query('plan_exercises'),
      'training_records': await db.query('training_records'),
      'user_profile': await db.query('user_profile'),
    };
  }
}
