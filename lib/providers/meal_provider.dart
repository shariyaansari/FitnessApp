import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/meal_entry.dart';
import '../services/firestore_service.dart';

class MealProvider extends ChangeNotifier {
  final FirestoreService _db = FirestoreService();
  final _uuid = const Uuid();

  List<MealEntry> _todayMeals = [];
  bool _loading = false;

  List<MealEntry> get todayMeals => _todayMeals;
  bool get loading => _loading;

  int get totalCalories => _todayMeals.fold(0, (s, m) => s + m.calories);
  double get totalProtein => _todayMeals.fold(0.0, (s, m) => s + m.protein);
  double get totalCarbs => _todayMeals.fold(0.0, (s, m) => s + m.carbs);
  double get totalFats => _todayMeals.fold(0.0, (s, m) => s + m.fats);

  List<MealEntry> get breakfasts =>
      _todayMeals.where((m) => m.mealType == 'breakfast').toList();
  List<MealEntry> get lunches =>
      _todayMeals.where((m) => m.mealType == 'lunch').toList();
  List<MealEntry> get dinners =>
      _todayMeals.where((m) => m.mealType == 'dinner').toList();
  List<MealEntry> get snacks =>
      _todayMeals.where((m) => m.mealType == 'snack').toList();

  void listenToMeals(String uid) {
    _db.mealsStream(uid).listen((meals) {
      _todayMeals = meals;
      notifyListeners();
    });
  }

  Future<void> addMeal(String uid, {
    required String name,
    required int calories,
    required double protein,
    required double carbs,
    required double fats,
    required String mealType,
  }) async {
    _loading = true;
    notifyListeners();
    try {
      final meal = MealEntry(
        id: _uuid.v4(),
        name: name,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fats: fats,
        mealType: mealType,
      );
      await _db.addMeal(uid, meal);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> deleteMeal(String uid, String mealId) async {
    await _db.deleteMeal(uid, mealId);
  }

  Future<List<Map<String, dynamic>>> getWeeklySummary(String uid) async {
    return _db.getMealSummaryLastDays(uid, 7);
  }
}
