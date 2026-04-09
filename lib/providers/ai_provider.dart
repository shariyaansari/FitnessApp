import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/meal_entry.dart';
import '../models/workout_entry.dart';
import '../services/ai_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  ChatMessage({required this.text, required this.isUser, DateTime? time})
      : time = time ?? DateTime.now();
}

class AIProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _loading = false;
  String? _dietRecommendation;
  String? _workoutRecommendation;
  String? _weeklyInsight;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get loading => _loading;
  String? get dietRecommendation => _dietRecommendation;
  String? get workoutRecommendation => _workoutRecommendation;
  String? get weeklyInsight => _weeklyInsight;

  void initChat() {
    if (_messages.isEmpty) {
      _messages.add(ChatMessage(
        text: '👋 Hi! I\'m FitAI, your personal fitness assistant.\n\nAsk me anything about:\n• 🍽️ What to eat today\n• 🏋️ Workout suggestions\n• 💊 Nutrition tips\n• 📈 Progress insights',
        isUser: false,
      ));
      notifyListeners();
    }
  }

  Future<void> sendMessage({
    required String message,
    required UserProfile? profile,
    required List<MealEntry> todayMeals,
    required List<WorkoutEntry> todayWorkouts,
  }) async {
    if (message.trim().isEmpty) return;

    _messages.add(ChatMessage(text: message, isUser: true));
    _loading = true;
    notifyListeners();

    try {
      final response = await AIService.chat(
        message: message,
        profile: profile,
        todayMeals: todayMeals,
        todayWorkouts: todayWorkouts,
        history: _messages
            .where((m) => !m.isUser)
            .map((m) => {'role': 'assistant', 'content': m.text})
            .toList(),
      );
      _messages.add(ChatMessage(text: response, isUser: false));
    } catch (e) {
      _messages.add(ChatMessage(
        text: '⚠️ Something went wrong. Please try again.',
        isUser: false,
      ));
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadDietRecommendation(
      UserProfile profile, List<MealEntry> meals) async {
    _dietRecommendation = null;
    notifyListeners();
    _dietRecommendation =
        await AIService.getDietRecommendation(profile, meals);
    notifyListeners();
  }

  Future<void> loadWorkoutRecommendation(UserProfile profile) async {
    _workoutRecommendation = null;
    notifyListeners();
    _workoutRecommendation =
        await AIService.getWorkoutRecommendation(profile);
    notifyListeners();
  }

  Future<void> loadWeeklyInsight(
      UserProfile profile,
      List<Map<String, dynamic>> mealSummary,
      List<Map<String, dynamic>> workoutSummary) async {
    _weeklyInsight = null;
    notifyListeners();
    _weeklyInsight = await AIService.getWeeklyInsight(
        profile, mealSummary, workoutSummary);
    notifyListeners();
  }

  void clearChat() {
    _messages.clear();
    initChat();
  }
}
