import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../providers/meal_provider.dart';
import '../../models/meal_entry.dart';
import 'add_meal_screen.dart';

class MealScreen extends StatelessWidget {
  const MealScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final meals = context.watch<MealProvider>();
    final uid = auth.firebaseUser?.uid;

    final mealTypes = ['All', 'Breakfast', 'Lunch', 'Dinner', 'Snack'];

    return DefaultTabController(
      length: mealTypes.length,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D1A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0D0D1A),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Meals',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              Text(DateFormat('EEEE, MMM d').format(DateTime.now()),
                  style:
                      const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AddMealScreen())),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add_rounded,
                    color: Color(0xFF6C63FF), size: 22),
              ),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            labelColor: const Color(0xFF6C63FF),
            unselectedLabelColor: Colors.white38,
            indicatorColor: const Color(0xFF6C63FF),
            tabs: mealTypes.map((t) => Tab(text: t)).toList(),
          ),
        ),
        body: TabBarView(
          children: mealTypes.map((type) {
            final filtered = type == 'All'
                ? meals.todayMeals
                : meals.todayMeals
                    .where((m) =>
                        m.mealType == type.toLowerCase())
                    .toList();

            return _MealList(
              meals: filtered,
              uid: uid,
              totalCalories: meals.totalCalories,
              calGoal: context.watch<AuthProvider>().profile?.adjustedCalorieGoal ?? 2000,
            );
          }).toList(),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF6C63FF),
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddMealScreen())),
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),
    );
  }
}

class _MealList extends StatelessWidget {
  final List<MealEntry> meals;
  final String? uid;
  final int totalCalories;
  final int calGoal;

  const _MealList({
    required this.meals,
    required this.uid,
    required this.totalCalories,
    required this.calGoal,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Summary bar
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.07)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SummaryItem(
                  label: 'Eaten', value: '$totalCalories kcal',
                  color: const Color(0xFF6C63FF)),
              _SummaryItem(
                  label: 'Goal', value: '$calGoal kcal',
                  color: Colors.white54),
              _SummaryItem(
                  label: 'Remaining',
                  value: '${(calGoal - totalCalories).clamp(0, calGoal)} kcal',
                  color: const Color(0xFF4ECDC4)),
            ],
          ),
        ),
        Expanded(
          child: meals.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🍽️',
                          style: TextStyle(fontSize: 52)),
                      const SizedBox(height: 12),
                      const Text('No meals yet!',
                          style: TextStyle(
                              color: Colors.white54, fontSize: 16)),
                      const SizedBox(height: 6),
                      const Text('Tap + to log your first meal.',
                          style: TextStyle(color: Colors.white30)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: meals.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, i) {
                    final m = meals[i];
                    return _MealCard(meal: m, uid: uid)
                        .animate(delay: Duration(milliseconds: i * 60))
                        .fadeIn(duration: 300.ms)
                        .slideX(begin: 0.1, end: 0);
                  },
                ),
        ),
      ],
    );
  }
}

class _MealCard extends StatelessWidget {
  final MealEntry meal;
  final String? uid;

  const _MealCard({required this.meal, required this.uid});

  @override
  Widget build(BuildContext context) {
    final typeColors = {
      'breakfast': Colors.orangeAccent,
      'lunch': const Color(0xFF6C63FF),
      'dinner': Colors.purpleAccent,
      'snack': const Color(0xFF4ECDC4),
    };
    final color = typeColors[meal.mealType] ?? Colors.white54;

    return Dismissible(
      key: Key(meal.id),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) {
        if (uid != null) {
          context.read<MealProvider>().deleteMeal(uid!, meal.id);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_mealIcon(meal.mealType), color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(meal.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15)),
                  const SizedBox(height: 3),
                  Text(
                    'P:${meal.protein.round()}g  C:${meal.carbs.round()}g  F:${meal.fats.round()}g',
                    style:
                        const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${meal.calories}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Text('kcal',
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _mealIcon(String type) {
    switch (type) {
      case 'breakfast': return Icons.wb_sunny_rounded;
      case 'lunch':     return Icons.wb_cloudy_rounded;
      case 'dinner':    return Icons.nightlight_round;
      case 'snack':     return Icons.fastfood_rounded;
      default:          return Icons.restaurant_rounded;
    }
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryItem(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 15)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: Colors.white38, fontSize: 11)),
      ],
    );
  }
}
