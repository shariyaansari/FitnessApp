// ============================================================
// App Configuration — replace YOUR_OPENAI_API_KEY before prod
// ============================================================

class AppConfig {
  // OpenAI
  static const String openAiApiKey = 'YOUR_OPENAI_API_KEY';
  static const String openAiModel = 'gpt-4o-mini';

  // Feature flags
  static const bool useOpenAiApi = false; // set true when key is ready

  // App meta
  static const String appName = 'FitAI';
  static const String appVersion = '1.0.0';

  // Daily defaults (overridden by TDEE calculation)
  static const int defaultCalorieGoal = 2000;
  static const int defaultProteinGoal = 150; // g
  static const int defaultCarbsGoal = 250;   // g
  static const int defaultFatsGoal = 65;     // g
  static const int dailyWaterGoalMl = 2500;

  // Notification channel
  static const String notifChannelId = 'fitai_reminders';
  static const String notifChannelName = 'FitAI Reminders';

  // Colors (seed for ThemeData)
  static const int primaryColorValue = 0xFF6C63FF;
  static const int accentColorValue  = 0xFF4ECDC4;
}
