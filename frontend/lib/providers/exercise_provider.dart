import 'package:flutter/foundation.dart';

import '../models/exercise.dart';
import '../services/database_helper.dart';

class ExerciseProvider extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  List<Exercise> _exercises = [];
  bool _loading = false;
  String _searchQuery = '';
  String _selectedMuscle = '';
  String _selectedType = '';
  String _selectedDifficulty = '';

  List<Exercise> get exercises => _exercises;
  bool get loading => _loading;
  String get searchQuery => _searchQuery;
  String get selectedMuscle => _selectedMuscle;
  String get selectedType => _selectedType;
  String get selectedDifficulty => _selectedDifficulty;

  Future<void> loadExercises() async {
    _loading = true;
    notifyListeners();
    _exercises = await _databaseHelper.getExercises(
      muscleGroup: _selectedMuscle.isEmpty ? null : _selectedMuscle,
      type: _selectedType.isEmpty ? null : _selectedType,
      difficulty: _selectedDifficulty.isEmpty ? null : _selectedDifficulty,
      searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
    );
    _loading = false;
    notifyListeners();
  }

  Future<void> addExercise(Exercise exercise) async {
    await _databaseHelper.insertExercise(exercise);
    await loadExercises();
  }

  Future<void> updateExercise(Exercise exercise) async {
    await _databaseHelper.updateExercise(exercise);
    await loadExercises();
  }

  Future<void> deleteExercise(int id) async {
    await _databaseHelper.deleteExercise(id);
    await loadExercises();
  }

  void updateSearch(String value) {
    _searchQuery = value;
    loadExercises();
  }

  void updateFilters({String? muscle, String? type, String? difficulty}) {
    _selectedMuscle = muscle ?? _selectedMuscle;
    _selectedType = type ?? _selectedType;
    _selectedDifficulty = difficulty ?? _selectedDifficulty;
    loadExercises();
  }

  void clearFilters() {
    _selectedMuscle = '';
    _selectedType = '';
    _selectedDifficulty = '';
    loadExercises();
  }
}
