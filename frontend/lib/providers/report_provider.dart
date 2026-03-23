import 'package:flutter/foundation.dart';

import '../models/training_record.dart';
import '../services/database_helper.dart';

class ReportProvider extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  WeeklyReport? _weeklyReport;
  bool _loading = false;

  WeeklyReport? get weeklyReport => _weeklyReport;
  bool get loading => _loading;

  Future<void> loadWeeklyReport() async {
    _loading = true;
    notifyListeners();

    final end = DateTime.now();
    final start = end.subtract(Duration(days: end.weekday - 1));
    final records = await _databaseHelper.getRecords(from: start, to: end);
    final muscleDistribution = <String, int>{};
    final strengthProgress = <String, double>{};

    double completionSum = 0;
    double fatigueSum = 0;
    for (final record in records) {
      muscleDistribution.update(record.muscleGroup, (value) => value + 1, ifAbsent: () => 1);
      strengthProgress[record.exerciseName] = record.completedWeight;
      completionSum += record.completionScore;
      fatigueSum += record.fatigueScore;
    }

    _weeklyReport = WeeklyReport(
      weekStart: start,
      weekEnd: end,
      totalSessions: records.length,
      plannedSessions: 4,
      completionRate: records.isEmpty ? 0 : records.length / 4,
      muscleDistribution: muscleDistribution,
      avgCompletionScore: records.isEmpty ? 0 : completionSum / records.length,
      avgFatigueScore: records.isEmpty ? 0 : fatigueSum / records.length,
      strengthProgress: strengthProgress,
    );

    _loading = false;
    notifyListeners();
  }
}
