import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../providers/meal_provider.dart';
import '../../providers/workout_provider.dart';
import '../../providers/ai_provider.dart';
import '../../widgets/calorie_ring.dart';
import '../../widgets/macro_bar.dart';
import '../../widgets/streak_card.dart';
import '../../widgets/stat_card.dart';
import '../meals/add_meal_screen.dart';
import '../workouts/add_workout_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _insight = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInsight();
    });
  }

  Future<void> _loadInsight() async {
    final auth = context.read<AuthProvider>();
    final meals = context.read<MealProvider>();
    final workouts = context.read<WorkoutProvider>();
    final ai = context.read<AIProvider>();

    if (auth.profile != null) {
      final mealSummary = await meals.getWeeklySummary(auth.firebaseUser!.uid);
      final workoutSummary =
          await workouts.getWeeklySummary(auth.firebaseUser!.uid);
      await ai.loadWeeklyInsight(auth.profile!, mealSummary, workoutSummary);
      if (mounted && ai.weeklyInsight != null) {
        setState(() => _insight = ai.weeklyInsight!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final meals = context.watch<MealProvider>();
    final workouts = context.watch<WorkoutProvider>();
    final profile = auth.profile;

    final calGoal = profile?.adjustedCalorieGoal ?? 2000;
    final consumed = meals.totalCalories;
    final burned = workouts.totalCaloriesBurned;
    final today = DateFormat('EEEE, MMMM d').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFF0D0D1A),
            floating: true,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good ${_greeting()}, ${profile?.name.split(' ').first ?? 'there'}!',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  today,
                  style:
                      const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
            actions: [
              if (profile?.photoUrl.isNotEmpty == true)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(profile!.photoUrl),
                    radius: 18,
                  ),
                ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Calorie Ring
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF6C63FF).withOpacity(0.15),
                          const Color(0xFF4ECDC4).withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.07)),
                    ),
                    child: CalorieRing(
                        consumed: consumed, goal: calGoal, burned: burned),
                  ).animate().fadeIn(duration: 500.ms).scale(
                      begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),

                  const SizedBox(height: 16),

                  // Macro bars
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: Colors.white.withOpacity(0.07)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Macros',
                            style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        MacroBar(
                          label: 'Protein',
                          current: meals.totalProtein,
                          goal: (profile?.dailyProteinGoal ?? 150).toDouble(),
                          color: const Color(0xFF6C63FF),
                        ),
                        MacroBar(
                          label: 'Carbs',
                          current: meals.totalCarbs,
                          goal: (profile?.dailyCarbsGoal ?? 250).toDouble(),
                          color: const Color(0xFF4ECDC4),
                        ),
                        MacroBar(
                          label: 'Fats',
                          current: meals.totalFats,
                          goal: (profile?.dailyFatsGoal ?? 65).toDouble(),
                          color: const Color(0xFFFFBE0B),
                        ),
                      ],
                    ),
                  ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

                  const SizedBox(height: 16),

                  // Streak
                  StreakCard(streak: profile?.streakDays ?? 0)
                      .animate(delay: 200.ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 16),

                  // Stat cards
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.15,
                    children: [
                      StatCard(
                        title: 'Calories Eaten',
                        value: '$consumed kcal',
                        icon: Icons.restaurant_menu_rounded,
                        color: const Color(0xFF6C63FF),
                        subtitle: '${calGoal - consumed > 0 ? calGoal - consumed : 0} left',
                      ),
                      StatCard(
                        title: 'Calories Burned',
                        value: '$burned kcal',
                        icon: Icons.local_fire_department_rounded,
                        color: Colors.orangeAccent,
                        subtitle: '${workouts.totalDurationMin} minutes active',
                      ),
                      StatCard(
                        title: 'Meals Today',
                        value: '${meals.todayMeals.length}',
                        icon: Icons.fastfood_rounded,
                        color: const Color(0xFF4ECDC4),
                        subtitle: meals.todayMeals.isEmpty ? 'Log your first meal!' : 'tracked',
                      ),
                      StatCard(
                        title: 'Workouts',
                        value: '${workouts.todayWorkouts.length}',
                        icon: Icons.fitness_center_rounded,
                        color: Colors.greenAccent,
                        subtitle: workouts.todayWorkouts.isEmpty ? 'Stay active!' : 'completed',
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // AI Insight
                  if (_insight.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF4ECDC4).withOpacity(0.12),
                            const Color(0xFF6C63FF).withOpacity(0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: const Color(0xFF4ECDC4).withOpacity(0.25)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('🤖',
                              style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Weekly Insight',
                                    style: TextStyle(
                                        color: Color(0xFF4ECDC4),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13)),
                                const SizedBox(height: 4),
                                Text(_insight,
                                    style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                        height: 1.5)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate(delay: 400.ms).fadeIn(duration: 500.ms),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickAdd(context),
        backgroundColor: const Color(0xFF6C63FF),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label:
            const Text('Quick Add', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }

  void _showQuickAdd(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF13132A),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Quick Add',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _QuickAddButton(
                    icon: Icons.restaurant_menu_rounded,
                    label: 'Log Meal',
                    color: const Color(0xFF6C63FF),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AddMealScreen()));
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _QuickAddButton(
                    icon: Icons.fitness_center_rounded,
                    label: 'Log Workout',
                    color: Colors.orangeAccent,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AddWorkoutScreen()));
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _QuickAddButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAddButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
