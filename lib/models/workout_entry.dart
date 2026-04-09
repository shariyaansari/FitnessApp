import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutEntry {
  final String id;
  final String name;
  final String category; // 'gym' | 'home' | 'yoga' | 'cardio'
  final int durationMin;
  final int caloriesBurned;
  final int sets;
  final int reps;
  final String notes;
  final DateTime timestamp;

  WorkoutEntry({
    required this.id,
    required this.name,
    this.category = 'gym',
    this.durationMin = 30,
    this.caloriesBurned = 0,
    this.sets = 0,
    this.reps = 0,
    this.notes = '',
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory WorkoutEntry.fromMap(String id, Map<String, dynamic> map) {
    return WorkoutEntry(
      id: id,
      name: map['name'] ?? '',
      category: map['category'] ?? 'gym',
      durationMin: map['durationMin'] ?? 30,
      caloriesBurned: map['caloriesBurned'] ?? 0,
      sets: map['sets'] ?? 0,
      reps: map['reps'] ?? 0,
      notes: map['notes'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'durationMin': durationMin,
      'caloriesBurned': caloriesBurned,
      'sets': sets,
      'reps': reps,
      'notes': notes,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

// Predefined workout library
const List<Map<String, dynamic>> kWorkoutLibrary = [
  // GYM
  {'name': 'Bench Press',      'category': 'gym',    'durationMin': 20, 'caloriesPerMin': 8,  'defaultSets': 4, 'defaultReps': 10},
  {'name': 'Squats',           'category': 'gym',    'durationMin': 25, 'caloriesPerMin': 9,  'defaultSets': 4, 'defaultReps': 12},
  {'name': 'Deadlift',         'category': 'gym',    'durationMin': 25, 'caloriesPerMin': 10, 'defaultSets': 3, 'defaultReps': 8},
  {'name': 'Pull-ups',         'category': 'gym',    'durationMin': 15, 'caloriesPerMin': 7,  'defaultSets': 3, 'defaultReps': 10},
  {'name': 'Overhead Press',   'category': 'gym',    'durationMin': 20, 'caloriesPerMin': 8,  'defaultSets': 3, 'defaultReps': 10},
  {'name': 'Barbell Row',      'category': 'gym',    'durationMin': 20, 'caloriesPerMin': 8,  'defaultSets': 3, 'defaultReps': 10},
  {'name': 'Leg Press',        'category': 'gym',    'durationMin': 20, 'caloriesPerMin': 7,  'defaultSets': 4, 'defaultReps': 15},
  {'name': 'Cable Curls',      'category': 'gym',    'durationMin': 15, 'caloriesPerMin': 5,  'defaultSets': 3, 'defaultReps': 12},
  // HOME
  {'name': 'Push-ups',         'category': 'home',   'durationMin': 10, 'caloriesPerMin': 7,  'defaultSets': 3, 'defaultReps': 20},
  {'name': 'Sit-ups',          'category': 'home',   'durationMin': 10, 'caloriesPerMin': 5,  'defaultSets': 3, 'defaultReps': 20},
  {'name': 'Lunges',           'category': 'home',   'durationMin': 15, 'caloriesPerMin': 6,  'defaultSets': 3, 'defaultReps': 12},
  {'name': 'Plank',            'category': 'home',   'durationMin': 10, 'caloriesPerMin': 4,  'defaultSets': 3, 'defaultReps': 1},
  {'name': 'Burpees',          'category': 'home',   'durationMin': 10, 'caloriesPerMin': 10, 'defaultSets': 3, 'defaultReps': 15},
  {'name': 'Mountain Climbers','category': 'home',   'durationMin': 10, 'caloriesPerMin': 9,  'defaultSets': 3, 'defaultReps': 20},
  {'name': 'Jumping Jacks',    'category': 'home',   'durationMin': 10, 'caloriesPerMin': 8,  'defaultSets': 3, 'defaultReps': 30},
  {'name': 'Glute Bridges',    'category': 'home',   'durationMin': 10, 'caloriesPerMin': 4,  'defaultSets': 3, 'defaultReps': 15},
  // YOGA
  {'name': 'Sun Salutation',   'category': 'yoga',   'durationMin': 20, 'caloriesPerMin': 4,  'defaultSets': 0, 'defaultReps': 5},
  {'name': 'Warrior Pose',     'category': 'yoga',   'durationMin': 15, 'caloriesPerMin': 3,  'defaultSets': 0, 'defaultReps': 3},
  {'name': 'Tree Pose',        'category': 'yoga',   'durationMin': 10, 'caloriesPerMin': 2,  'defaultSets': 0, 'defaultReps': 3},
  {'name': 'Child\'s Pose',    'category': 'yoga',   'durationMin': 10, 'caloriesPerMin': 2,  'defaultSets': 0, 'defaultReps': 1},
  {'name': 'Downward Dog',     'category': 'yoga',   'durationMin': 10, 'caloriesPerMin': 2,  'defaultSets': 0, 'defaultReps': 5},
  {'name': 'Cobra Stretch',    'category': 'yoga',   'durationMin': 10, 'caloriesPerMin': 2,  'defaultSets': 0, 'defaultReps': 5},
  // CARDIO
  {'name': 'Running (5km)',    'category': 'cardio', 'durationMin': 30, 'caloriesPerMin': 11, 'defaultSets': 0, 'defaultReps': 0},
  {'name': 'Cycling (30min)', 'category': 'cardio', 'durationMin': 30, 'caloriesPerMin': 9,  'defaultSets': 0, 'defaultReps': 0},
  {'name': 'Jump Rope',        'category': 'cardio', 'durationMin': 15, 'caloriesPerMin': 12, 'defaultSets': 0, 'defaultReps': 0},
  {'name': 'Swimming (30min)','category': 'cardio', 'durationMin': 30, 'caloriesPerMin': 10, 'defaultSets': 0, 'defaultReps': 0},
  {'name': 'HIIT Session',     'category': 'cardio', 'durationMin': 20, 'caloriesPerMin': 13, 'defaultSets': 0, 'defaultReps': 0},
  {'name': 'Brisk Walk',       'category': 'cardio', 'durationMin': 30, 'caloriesPerMin': 5,  'defaultSets': 0, 'defaultReps': 0},
];
