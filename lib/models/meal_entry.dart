import 'package:cloud_firestore/cloud_firestore.dart';

class MealEntry {
  final String id;
  final String name;
  final int calories;
  final double protein; // g
  final double carbs;   // g
  final double fats;    // g
  final String mealType; // 'breakfast' | 'lunch' | 'dinner' | 'snack'
  final DateTime timestamp;

  MealEntry({
    required this.id,
    required this.name,
    required this.calories,
    this.protein = 0,
    this.carbs = 0,
    this.fats = 0,
    this.mealType = 'snack',
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory MealEntry.fromMap(String id, Map<String, dynamic> map) {
    return MealEntry(
      id: id,
      name: map['name'] ?? '',
      calories: map['calories'] ?? 0,
      protein: (map['protein'] ?? 0).toDouble(),
      carbs: (map['carbs'] ?? 0).toDouble(),
      fats: (map['fats'] ?? 0).toDouble(),
      mealType: map['mealType'] ?? 'snack',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'mealType': mealType,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

// Static food database (50 common items)
const List<Map<String, dynamic>> kFoodDatabase = [
  {'name': 'Boiled Egg',        'calories': 78,  'protein': 6.0,  'carbs': 0.6,  'fats': 5.0},
  {'name': 'Banana',            'calories': 89,  'protein': 1.1,  'carbs': 23.0, 'fats': 0.3},
  {'name': 'Apple',             'calories': 52,  'protein': 0.3,  'carbs': 14.0, 'fats': 0.2},
  {'name': 'Greek Yogurt (cup)','calories': 100, 'protein': 17.0, 'carbs': 6.0,  'fats': 0.7},
  {'name': 'Oatmeal (cup)',     'calories': 150, 'protein': 5.0,  'carbs': 27.0, 'fats': 3.0},
  {'name': 'Chicken Breast',    'calories': 165, 'protein': 31.0, 'carbs': 0.0,  'fats': 3.6},
  {'name': 'Brown Rice (cup)',  'calories': 216, 'protein': 5.0,  'carbs': 45.0, 'fats': 1.8},
  {'name': 'Salmon (100g)',     'calories': 208, 'protein': 20.0, 'carbs': 0.0,  'fats': 13.0},
  {'name': 'Broccoli (cup)',    'calories': 55,  'protein': 3.7,  'carbs': 11.0, 'fats': 0.6},
  {'name': 'Almonds (28g)',     'calories': 164, 'protein': 6.0,  'carbs': 6.0,  'fats': 14.0},
  {'name': 'Whole Milk (cup)',  'calories': 149, 'protein': 8.0,  'carbs': 12.0, 'fats': 8.0},
  {'name': 'Cottage Cheese',   'calories': 206, 'protein': 25.0, 'carbs': 8.0,  'fats': 9.0},
  {'name': 'Avocado (half)',    'calories': 160, 'protein': 2.0,  'carbs': 9.0,  'fats': 15.0},
  {'name': 'Peanut Butter (2tbsp)','calories':190,'protein':8.0,'carbs':6.0,   'fats': 16.0},
  {'name': 'White Rice (cup)',  'calories': 206, 'protein': 4.3,  'carbs': 45.0, 'fats': 0.4},
  {'name': 'Bread (slice)',     'calories': 79,  'protein': 2.7,  'carbs': 15.0, 'fats': 1.0},
  {'name': 'Pasta (cup)',       'calories': 220, 'protein': 8.0,  'carbs': 43.0, 'fats': 1.3},
  {'name': 'Tuna (can)',        'calories': 191, 'protein': 42.0, 'carbs': 0.0,  'fats': 1.4},
  {'name': 'Tofu (100g)',       'calories': 76,  'protein': 8.0,  'carbs': 2.0,  'fats': 4.0},
  {'name': 'Lentils (cup)',     'calories': 230, 'protein': 18.0, 'carbs': 40.0, 'fats': 0.8},
  {'name': 'Sweet Potato',      'calories': 103, 'protein': 2.3,  'carbs': 24.0, 'fats': 0.1},
  {'name': 'Egg White',         'calories': 17,  'protein': 3.6,  'carbs': 0.2,  'fats': 0.1},
  {'name': 'Orange',            'calories': 62,  'protein': 1.2,  'carbs': 15.0, 'fats': 0.2},
  {'name': 'Strawberries (cup)','calories': 49,  'protein': 1.0,  'carbs': 12.0, 'fats': 0.5},
  {'name': 'Blueberries (cup)', 'calories': 84,  'protein': 1.1,  'carbs': 21.0, 'fats': 0.5},
  {'name': 'Spinach (cup)',     'calories': 7,   'protein': 0.9,  'carbs': 1.1,  'fats': 0.1},
  {'name': 'Kale (cup)',        'calories': 33,  'protein': 2.9,  'carbs': 6.0,  'fats': 0.5},
  {'name': 'Quinoa (cup)',      'calories': 222, 'protein': 8.1,  'carbs': 39.0, 'fats': 3.5},
  {'name': 'Beef (100g)',       'calories': 250, 'protein': 26.0, 'carbs': 0.0,  'fats': 15.0},
  {'name': 'Shrimp (100g)',     'calories': 99,  'protein': 24.0, 'carbs': 0.2,  'fats': 0.3},
  {'name': 'Cheese (slice)',    'calories': 106, 'protein': 7.0,  'carbs': 0.4,  'fats': 8.9},
  {'name': 'Butter (tbsp)',     'calories': 102, 'protein': 0.1,  'carbs': 0.0,  'fats': 11.5},
  {'name': 'Olive Oil (tbsp)',  'calories': 119, 'protein': 0.0,  'carbs': 0.0,  'fats': 13.5},
  {'name': 'Protein Shake',    'calories': 130, 'protein': 25.0, 'carbs': 5.0,  'fats': 2.0},
  {'name': 'Energy Bar',        'calories': 190, 'protein': 5.0,  'carbs': 30.0, 'fats': 7.0},
  {'name': 'Pizza (slice)',     'calories': 285, 'protein': 12.0, 'carbs': 36.0, 'fats': 10.0},
  {'name': 'Burger (plain)',    'calories': 354, 'protein': 17.0, 'carbs': 29.0, 'fats': 17.0},
  {'name': 'French Fries (med)','calories': 365, 'protein': 4.0,  'carbs': 48.0, 'fats': 17.0},
  {'name': 'Soda (can)',        'calories': 140, 'protein': 0.0,  'carbs': 39.0, 'fats': 0.0},
  {'name': 'Orange Juice (cup)','calories': 112, 'protein': 1.7,  'carbs': 26.0, 'fats': 0.5},
  {'name': 'Coffee (black)',    'calories': 2,   'protein': 0.3,  'carbs': 0.0,  'fats': 0.0},
  {'name': 'Green Tea',         'calories': 2,   'protein': 0.0,  'carbs': 0.0,  'fats': 0.0},
  {'name': 'Dark Chocolate (30g)','calories':171,'protein':2.2,  'carbs':13.0,  'fats':12.0},
  {'name': 'Ice Cream (cup)',   'calories': 272, 'protein': 4.6,  'carbs': 31.0, 'fats': 14.5},
  {'name': 'Pancake (medium)',  'calories': 86,  'protein': 2.5,  'carbs': 15.0, 'fats': 2.0},
  {'name': 'Waffle',            'calories': 218, 'protein': 6.0,  'carbs': 25.0, 'fats': 11.0},
  {'name': 'Cereal (cup)',      'calories': 130, 'protein': 3.0,  'carbs': 28.0, 'fats': 1.0},
  {'name': 'Hummus (2tbsp)',    'calories': 70,  'protein': 2.5,  'carbs': 6.0,  'fats': 5.0},
  {'name': 'Roti / Chapati',   'calories': 104, 'protein': 3.1,  'carbs': 18.0, 'fats': 2.5},
  {'name': 'Dal (cup)',         'calories': 198, 'protein': 14.0, 'carbs': 30.0, 'fats': 2.2},
];
