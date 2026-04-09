import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/user_profile.dart';
import '../models/meal_entry.dart';
import '../models/workout_entry.dart';

class AIService {
  // ─── OpenAI (only used when useOpenAiApi == true) ───────────

  static Future<String> _callOpenAI(String systemPrompt, String userMessage) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer ${AppConfig.openAiApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': AppConfig.openAiModel,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userMessage},
          ],
          'max_tokens': 500,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] as String;
      }
      return _fallback(userMessage, null, null, null);
    } catch (_) {
      return _fallback(userMessage, null, null, null);
    }
  }

  // ─── LOCAL RULE-BASED FALLBACK ───────────────────────────────

  static String _fallback(
    String message,
    UserProfile? profile,
    List<MealEntry>? todayMeals,
    List<WorkoutEntry>? todayWorkouts,
  ) {
    final msg = message.toLowerCase();
    final goal = profile?.goalType ?? 'maintain';
    final calories = todayMeals?.fold<int>(0, (s, m) => s + m.calories) ?? 0;
    final burned = todayWorkouts?.fold<int>(0, (s, w) => s + w.caloriesBurned) ?? 0;
    final calGoal = profile?.adjustedCalorieGoal ?? 2000;
    final remaining = calGoal - calories + burned;

    // Greetings
    if (msg.contains('hello') || msg.contains('hi') || msg.contains('hey')) {
      return 'Hey there! 👋 I\'m your FitAI assistant. Ask me about meals, workouts, or tips to reach your ${_goalLabel(goal)} goal!';
    }

    // Diet advice
    if (msg.contains('eat') || msg.contains('food') || msg.contains('diet') || msg.contains('meal') || msg.contains('calorie')) {
      if (remaining > 500) {
        return '🍽️ You still have **$remaining kcal** left for today! Good options:\n\n'
            '• **Breakfast**: Oatmeal + boiled eggs + fruit (~350 kcal)\n'
            '• **Lunch**: Grilled chicken breast + brown rice + broccoli (~450 kcal)\n'
            '• **Snack**: Greek yogurt + almonds (~250 kcal)\n\n'
            '${goal == 'lose' ? '💡 Stay high protein (>30g/meal) to preserve muscle.' : goal == 'gain' ? '💡 Add healthy fats like avocado and peanut butter.' : '💡 Keep a good protein-carb-fat balance (30-50-20%).'}'  ;
      } else if (remaining < 0) {
        return '⚠️ You\'ve exceeded your calorie goal by **${(-remaining).abs()} kcal** today.\n\nTips:\n• Drink water before meals to reduce hunger\n• Have light veggies (spinach, cucumber) if hungry\n• Plan better tomorrow — log meals in advance!';
      } else {
        return '✅ You\'re right on track! **$remaining kcal** remaining.\n\nFor dinner, consider:\n• Salmon + quinoa + greens (~500 kcal)\n• Or lentil soup + whole-grain bread (~400 kcal)\n\nKeep it up! 🔥';
      }
    }

    // Workout advice
    if (msg.contains('workout') || msg.contains('exercise') || msg.contains('train') || msg.contains('gym')) {
      if (burned == 0) {
        return '🏋️ You haven\'t logged a workout yet today! Here\'s a quick plan:\n\n'
            '**${msg.contains('20') ? '20-min' : '30-min'} ${_recommendedWorkout(goal)} session:**\n'
            '${_workoutPlan(goal, msg.contains('20') ? 20 : 30)}\n\n'
            'Log it in the Workout tab when done! 💪';
      } else {
        return '💪 Great job! You\'ve already burned **$burned kcal** today.\n\n'
            'Recovery tips:\n• Stretch for 10 minutes\n• Protein within 30 min post-workout\n• Sleep 7-8 hours tonight for muscle repair';
      }
    }

    // Weight / progress
    if (msg.contains('weight') || msg.contains('progress') || msg.contains('result')) {
      return '📊 Consistency is key! Track your weight every morning under the same conditions.\n\n'
          'Based on your **${_goalLabel(goal)}** goal:\n'
          '• ${goal == 'lose' ? 'Aim for 0.5-1kg loss per week — safe and sustainable.' : goal == 'gain' ? 'Aim for 0.25-0.5kg gain per week for lean bulk.' : 'Monitor weekly averages, not daily fluctuations.'}\n\n'
          'You\'ve logged **$calories kcal** today and burned **$burned kcal**. Net: **${calories - burned} kcal**. Keep it consistent!';
      }

    // Water
    if (msg.contains('water') || msg.contains('hydrat')) {
      return '💧 Hydration goal: **2.5 liters** per day.\n\nTips:\n• Drink a glass first thing in the morning\n• Set a reminder every 2 hours\n• Add lemon/cucumber for flavor\n• Drink water before every meal';
    }

    // Protein
    if (msg.contains('protein')) {
      final pGoal = profile?.dailyProteinGoal ?? 150;
      return '🥩 Your protein goal is **${pGoal}g/day**.\n\nBest sources:\n• Chicken breast (31g/100g)\n• Eggs (6g each)\n• Greek yogurt (17g/cup)\n• Tuna (42g/can)\n• Lentils (18g/cup)\n\nAim for **25-35g protein** per meal across 3-4 meals.';
    }

    // Sleep
    if (msg.contains('sleep') || msg.contains('rest') || msg.contains('recover')) {
      return '😴 Sleep is your secret weapon for fitness!\n\n• **7-9 hours** for optimal recovery\n• Keep a consistent sleep schedule\n• Avoid screens 1 hour before bed\n• Sleep in a cool, dark room\n• Protein before bed? Casein (cottage cheese) helps muscle repair overnight.';
    }

    // Default
    return '🤖 I\'m here to help with your **${_goalLabel(goal)}** fitness goal!\n\nYou can ask me:\n• "What should I eat today?"\n• "Suggest a 20-min workout"\n• "How much protein do I need?"\n• "How do I lose weight faster?"\n• "Tips for better sleep"\n\nToday\'s summary: 🍽️ **$calories kcal** eaten · 🔥 **$burned kcal** burned';
  }

  static String _goalLabel(String goal) {
    switch (goal) {
      case 'lose':     return 'weight loss';
      case 'gain':     return 'muscle gain';
      case 'maintain': return 'maintenance';
      default:         return goal;
    }
  }

  static String _recommendedWorkout(String goal) {
    switch (goal) {
      case 'lose':     return 'cardio (HIIT)';
      case 'gain':     return 'strength training';
      case 'maintain': return 'full-body';
      default:         return 'full-body';
    }
  }

  static String _workoutPlan(String goal, int minutes) {
    if (goal == 'lose') {
      return '• 2 min warm-up\n• 30 sec on / 30 sec rest × ${minutes ~/ 2} rounds\n  - Burpees → Mountain Climbers → Jump Rope → Jumping Jacks\n• 2 min cooldown stretch';
    } else if (goal == 'gain') {
      return '• Push-ups: 3×15\n• Squats: 4×12\n• Dumbbell rows: 3×10/arm\n• Plank: 3×45 sec\n• Rest 60 sec between sets';
    } else {
      return '• 5 min jog / brisk walk\n• Push-ups: 3×12\n• Squats: 3×12\n• Plank: 2×45 sec\n• 5 min yoga stretch';
    }
  }

  // ─── PUBLIC API ──────────────────────────────────────────────

  static Future<String> chat({
    required String message,
    required UserProfile? profile,
    required List<MealEntry> todayMeals,
    required List<WorkoutEntry> todayWorkouts,
    List<Map<String, String>> history = const [],
  }) async {
    if (AppConfig.useOpenAiApi) {
      final systemPrompt = _buildSystemPrompt(profile, todayMeals, todayWorkouts);
      return _callOpenAI(systemPrompt, message);
    }
    return _fallback(message, profile, todayMeals, todayWorkouts);
  }

  static Future<String> getDietRecommendation(
      UserProfile profile, List<MealEntry> todayMeals) async {
    final cal = todayMeals.fold<int>(0, (s, m) => s + m.calories);
    final message = 'Give me a diet recommendation for today. I\'ve eaten $cal calories so far.';

    if (AppConfig.useOpenAiApi) {
      final system = _buildSystemPrompt(profile, todayMeals, []);
      return _callOpenAI(system, message);
    }
    return _fallback(message, profile, todayMeals, []);
  }

  static Future<String> getWorkoutRecommendation(UserProfile profile) async {
    final message = 'Suggest a workout plan for today.';
    if (AppConfig.useOpenAiApi) {
      final system = _buildSystemPrompt(profile, [], []);
      return _callOpenAI(system, message);
    }
    return _fallback(message, profile, [], []);
  }

  static Future<String> getWeeklyInsight(
      UserProfile profile,
      List<Map<String, dynamic>> mealSummary,
      List<Map<String, dynamic>> workoutSummary) async {
    final avgCal = mealSummary.isEmpty
        ? 0
        : (mealSummary.fold<int>(0, (s, m) => s + (m['calories'] as int)) /
                mealSummary.length)
            .round();
    final totalWorkouts = workoutSummary.where((w) => w['caloriesBurned'] > 0).length;
    final goal = profile.goalType;

    String insight = '';
    if (avgCal > profile.adjustedCalorieGoal + 200) {
      insight =
          '⚠️ You averaged **$avgCal kcal/day** this week — that\'s **${avgCal - profile.adjustedCalorieGoal} kcal** over your goal. Try meal prepping to stay under ${profile.adjustedCalorieGoal} kcal.';
    } else if (totalWorkouts < 3) {
      insight =
          '🏃 You only worked out **$totalWorkouts time${totalWorkouts == 1 ? '' : 's'}** this week. Aim for 4-5 sessions to see better results for your **${_goalLabel(goal)}** goal!';
    } else {
      insight =
          '🎉 Solid week! You averaged **$avgCal kcal/day** and worked out **$totalWorkouts times**. Keep the momentum going! Consistency is 80% of the battle.';
    }
    return insight;
  }

  // ─── PRIVATE ─────────────────────────────────────────────────

  static String _buildSystemPrompt(
    UserProfile? profile,
    List<MealEntry> meals,
    List<WorkoutEntry> workouts,
  ) {
    final cal = meals.fold<int>(0, (s, m) => s + m.calories);
    final burned = workouts.fold<int>(0, (s, w) => s + w.caloriesBurned);
    return '''You are FitAI, an expert fitness and nutrition coach.
User profile: ${profile?.name ?? 'User'}, ${profile?.age ?? 25}yo ${profile?.gender ?? 'person'}, 
${profile?.weightKg ?? 70}kg, ${profile?.heightCm ?? 170}cm, goal: ${profile?.goalType ?? 'maintain'}.
Daily calorie goal: ${profile?.adjustedCalorieGoal ?? 2000} kcal.
Today: consumed $cal kcal, burned $burned kcal, net ${cal - burned} kcal.
Be concise, warm, motivating. Use markdown with emojis.''';
  }
}
