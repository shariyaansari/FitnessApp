import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/user_profile.dart';
import '../models/meal_entry.dart';
import '../models/workout_entry.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _today => DateFormat('yyyy-MM-dd').format(DateTime.now());

  // ─── USER PROFILE ────────────────────────────────────────────

  Future<UserProfile?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromMap(doc.data()!);
  }

  Future<void> createUser(UserProfile profile) async {
    await _db.collection('users').doc(profile.uid).set(profile.toMap());
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  Stream<UserProfile?> userStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      return UserProfile.fromMap(snap.data()!);
    });
  }

  // ─── STREAK ──────────────────────────────────────────────────

  Future<void> updateStreak(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return;

    final data = doc.data()!;
    final lastActive = data['lastActiveDate'] as String? ?? '';
    final today = _today;
    final yesterday = DateFormat('yyyy-MM-dd')
        .format(DateTime.now().subtract(const Duration(days: 1)));

    int streak = data['streakDays'] ?? 0;
    if (lastActive == today) return;
    if (lastActive == yesterday) {
      streak++;
    } else {
      streak = 1;
    }

    await _db.collection('users').doc(uid).update({
      'streakDays': streak,
      'lastActiveDate': today,
    });
  }

  // ─── MEALS ───────────────────────────────────────────────────

  Stream<List<MealEntry>> mealsStream(String uid, [String? date]) {
    final d = date ?? _today;
    return _db
        .collection('meals')
        .doc(uid)
        .collection(d)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => MealEntry.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> addMeal(String uid, MealEntry meal) async {
    await _db
        .collection('meals')
        .doc(uid)
        .collection(_today)
        .doc(meal.id)
        .set(meal.toMap());
    await updateStreak(uid);
  }

  Future<void> deleteMeal(String uid, String mealId, [String? date]) async {
    final d = date ?? _today;
    await _db.collection('meals').doc(uid).collection(d).doc(mealId).delete();
  }

  Future<List<Map<String, dynamic>>> getMealSummaryLastDays(
      String uid, int days) async {
    final result = <Map<String, dynamic>>[];
    for (int i = days - 1; i >= 0; i--) {
      final date = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(Duration(days: i)));
      final snap = await _db.collection('meals').doc(uid).collection(date).get();
      final meals =
          snap.docs.map((d) => MealEntry.fromMap(d.id, d.data())).toList();
      final totalCal = meals.fold<int>(0, (s, m) => s + m.calories);
      result.add({'date': date, 'calories': totalCal, 'meals': meals});
    }
    return result;
  }

  // ─── WORKOUTS ────────────────────────────────────────────────

  Stream<List<WorkoutEntry>> workoutsStream(String uid, [String? date]) {
    final d = date ?? _today;
    return _db
        .collection('workouts')
        .doc(uid)
        .collection(d)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => WorkoutEntry.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> addWorkout(String uid, WorkoutEntry workout) async {
    await _db
        .collection('workouts')
        .doc(uid)
        .collection(_today)
        .doc(workout.id)
        .set(workout.toMap());
    await updateStreak(uid);
  }

  Future<void> deleteWorkout(
      String uid, String workoutId, [String? date]) async {
    final d = date ?? _today;
    await _db
        .collection('workouts')
        .doc(uid)
        .collection(d)
        .doc(workoutId)
        .delete();
  }

  Future<List<Map<String, dynamic>>> getWorkoutSummaryLastDays(
      String uid, int days) async {
    final result = <Map<String, dynamic>>[];
    for (int i = days - 1; i >= 0; i--) {
      final date = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(Duration(days: i)));
      final snap =
          await _db.collection('workouts').doc(uid).collection(date).get();
      final workouts =
          snap.docs.map((d) => WorkoutEntry.fromMap(d.id, d.data())).toList();
      final totalCal =
          workouts.fold<int>(0, (s, w) => s + w.caloriesBurned);
      final totalMin = workouts.fold<int>(0, (s, w) => s + w.durationMin);
      result.add({
        'date': date,
        'caloriesBurned': totalCal,
        'durationMin': totalMin,
        'workouts': workouts,
      });
    }
    return result;
  }
}
