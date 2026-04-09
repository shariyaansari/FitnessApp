import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String photoUrl;
  final int age;
  final String gender; // 'male' | 'female' | 'other'
  final double heightCm;
  final double weightKg;
  final String goalType; // 'lose' | 'gain' | 'maintain'
  final int dailyCalorieGoal;
  final int dailyProteinGoal;
  final int dailyCarbsGoal;
  final int dailyFatsGoal;
  final bool isPremium;
  final int streakDays;
  final String lastActiveDate; // yyyy-MM-dd
  final DateTime createdAt;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl = '',
    this.age = 25,
    this.gender = 'male',
    this.heightCm = 170,
    this.weightKg = 70,
    this.goalType = 'maintain',
    this.dailyCalorieGoal = 2000,
    this.dailyProteinGoal = 150,
    this.dailyCarbsGoal = 250,
    this.dailyFatsGoal = 65,
    this.isPremium = false,
    this.streakDays = 0,
    this.lastActiveDate = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // BMR using Mifflin-St Jeor
  double get bmr {
    if (gender == 'female') {
      return (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
    }
    return (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
  }

  // TDEE (moderate activity assumed)
  int get tdee => (bmr * 1.55).round();

  // Adjusted goal
  int get adjustedCalorieGoal {
    switch (goalType) {
      case 'lose':     return (tdee - 500).clamp(1200, 9999);
      case 'gain':     return tdee + 300;
      case 'maintain': return tdee;
      default:         return tdee;
    }
  }

  double get bmi => weightKg / ((heightCm / 100) * (heightCm / 100));

  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25)   return 'Normal';
    if (bmi < 30)   return 'Overweight';
    return 'Obese';
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      age: map['age'] ?? 25,
      gender: map['gender'] ?? 'male',
      heightCm: (map['heightCm'] ?? 170).toDouble(),
      weightKg: (map['weightKg'] ?? 70).toDouble(),
      goalType: map['goalType'] ?? 'maintain',
      dailyCalorieGoal: map['dailyCalorieGoal'] ?? 2000,
      dailyProteinGoal: map['dailyProteinGoal'] ?? 150,
      dailyCarbsGoal: map['dailyCarbsGoal'] ?? 250,
      dailyFatsGoal: map['dailyFatsGoal'] ?? 65,
      isPremium: map['isPremium'] ?? false,
      streakDays: map['streakDays'] ?? 0,
      lastActiveDate: map['lastActiveDate'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'age': age,
      'gender': gender,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'goalType': goalType,
      'dailyCalorieGoal': dailyCalorieGoal,
      'dailyProteinGoal': dailyProteinGoal,
      'dailyCarbsGoal': dailyCarbsGoal,
      'dailyFatsGoal': dailyFatsGoal,
      'isPremium': isPremium,
      'streakDays': streakDays,
      'lastActiveDate': lastActiveDate,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserProfile copyWith({
    String? name,
    String? photoUrl,
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
    String? goalType,
    int? dailyCalorieGoal,
    int? dailyProteinGoal,
    int? dailyCarbsGoal,
    int? dailyFatsGoal,
    bool? isPremium,
    int? streakDays,
    String? lastActiveDate,
  }) {
    return UserProfile(
      uid: uid,
      name: name ?? this.name,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      goalType: goalType ?? this.goalType,
      dailyCalorieGoal: dailyCalorieGoal ?? this.dailyCalorieGoal,
      dailyProteinGoal: dailyProteinGoal ?? this.dailyProteinGoal,
      dailyCarbsGoal: dailyCarbsGoal ?? this.dailyCarbsGoal,
      dailyFatsGoal: dailyFatsGoal ?? this.dailyFatsGoal,
      isPremium: isPremium ?? this.isPremium,
      streakDays: streakDays ?? this.streakDays,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      createdAt: createdAt,
    );
  }
}
