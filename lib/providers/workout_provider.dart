import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/workout_entry.dart';
import '../services/firestore_service.dart';

class WorkoutProvider extends ChangeNotifier {
  final FirestoreService _db = FirestoreService();
  final _uuid = const Uuid();

  List<WorkoutEntry> _todayWorkouts = [];
  bool _loading = false;

  List<WorkoutEntry> get todayWorkouts => _todayWorkouts;
  bool get loading => _loading;

  int get totalCaloriesBurned =>
      _todayWorkouts.fold(0, (s, w) => s + w.caloriesBurned);
  int get totalDurationMin =>
      _todayWorkouts.fold(0, (s, w) => s + w.durationMin);
  int get totalSets =>
      _todayWorkouts.fold(0, (s, w) => s + w.sets);

  void listenToWorkouts(String uid) {
    _db.workoutsStream(uid).listen((workouts) {
      _todayWorkouts = workouts;
      notifyListeners();
    });
  }

  Future<void> addWorkout(String uid, {
    required String name,
    required String category,
    required int durationMin,
    required int caloriesBurned,
    required int sets,
    required int reps,
    String notes = '',
  }) async {
    _loading = true;
    notifyListeners();
    try {
      final workout = WorkoutEntry(
        id: _uuid.v4(),
        name: name,
        category: category,
        durationMin: durationMin,
        caloriesBurned: caloriesBurned,
        sets: sets,
        reps: reps,
        notes: notes,
      );
      await _db.addWorkout(uid, workout);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> deleteWorkout(String uid, String workoutId) async {
    await _db.deleteWorkout(uid, workoutId);
  }

  Future<List<Map<String, dynamic>>> getWeeklySummary(String uid) async {
    return _db.getWorkoutSummaryLastDays(uid, 7);
  }
}
