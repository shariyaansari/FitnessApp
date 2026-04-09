import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../providers/workout_provider.dart';
import '../../models/workout_entry.dart';
import 'add_workout_screen.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  String _filterCategory = 'All';
  final categories = ['All', 'Gym', 'Home', 'Yoga', 'Cardio'];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final workouts = context.watch<WorkoutProvider>();
    final uid = auth.firebaseUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D1A),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Workouts',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            Text(DateFormat('EEEE, MMM d').format(DateTime.now()),
                style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AddWorkoutScreen())),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orangeAccent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add_rounded,
                  color: Colors.orangeAccent, size: 22),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orangeAccent.withOpacity(0.15),
                  Colors.deepOrangeAccent.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.orangeAccent.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Stat(
                    label: 'Sessions',
                    value: '${workouts.todayWorkouts.length}',
                    color: Colors.orangeAccent),
                _Stat(
                    label: 'Duration',
                    value: '${workouts.totalDurationMin} min',
                    color: const Color(0xFF4ECDC4)),
                _Stat(
                    label: 'Burned',
                    value: '${workouts.totalCaloriesBurned} kcal',
                    color: Colors.greenAccent),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 20),

          // Today's Log
          if (workouts.todayWorkouts.isNotEmpty) ...[
            const Text('Today\'s Log',
                style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
            const SizedBox(height: 10),
            ...workouts.todayWorkouts.asMap().entries.map((entry) {
              final w = entry.value;
              return Dismissible(
                key: Key(w.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(Icons.delete_rounded, color: Colors.white),
                ),
                onDismissed: (_) {
                  if (uid != null) {
                    context.read<WorkoutProvider>().deleteWorkout(uid, w.id);
                  }
                },
                child: _WorkoutCard(workout: w)
                    .animate(delay: Duration(milliseconds: entry.key * 50))
                    .fadeIn(duration: 300.ms)
                    .slideX(begin: 0.1, end: 0),
              );
            }),
            const SizedBox(height: 20),
          ],

          // Library header + filter
          Row(
            children: [
              const Expanded(
                child: Text('Workout Library',
                    style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((c) {
                final selected = c == _filterCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(c),
                    selected: selected,
                    onSelected: (_) => setState(() => _filterCategory = c),
                    selectedColor: Colors.orangeAccent,
                    backgroundColor: Colors.white.withOpacity(0.06),
                    labelStyle: TextStyle(
                        color: selected ? Colors.white : Colors.white54),
                    side: BorderSide.none,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Library grid
          ...kWorkoutLibrary
              .where((w) =>
                  _filterCategory == 'All' ||
                  w['category'] == _filterCategory.toLowerCase())
              .map((w) => _LibraryCard(
                    workout: w,
                    onAdd: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddWorkoutScreen(preset: w),
                      ),
                    ),
                  )),
          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orangeAccent,
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddWorkoutScreen())),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final WorkoutEntry workout;
  const _WorkoutCard({required this.workout});

  @override
  Widget build(BuildContext context) {
    final catColors = {
      'gym':    const Color(0xFF6C63FF),
      'home':   const Color(0xFF4ECDC4),
      'yoga':   Colors.purpleAccent,
      'cardio': Colors.orangeAccent,
    };
    final color = catColors[workout.category] ?? Colors.white54;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_catIcon(workout.category), color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(workout.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600)),
                Text(
                  '${workout.durationMin} min · ${workout.sets > 0 ? '${workout.sets}×${workout.reps} reps · ' : ''}${workout.caloriesBurned} kcal',
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              workout.category.toUpperCase(),
              style: TextStyle(
                  color: color, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  IconData _catIcon(String category) {
    switch (category) {
      case 'gym':    return Icons.fitness_center_rounded;
      case 'home':   return Icons.home_rounded;
      case 'yoga':   return Icons.self_improvement_rounded;
      case 'cardio': return Icons.directions_run_rounded;
      default:       return Icons.sports_rounded;
    }
  }
}

class _LibraryCard extends StatelessWidget {
  final Map<String, dynamic> workout;
  final VoidCallback onAdd;

  const _LibraryCard({required this.workout, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final catColors = {
      'gym':    const Color(0xFF6C63FF),
      'home':   const Color(0xFF4ECDC4),
      'yoga':   Colors.purpleAccent,
      'cardio': Colors.orangeAccent,
    };
    final color = catColors[workout['category'] as String] ?? Colors.white54;
    final cals = (workout['durationMin'] as int) * (workout['caloriesPerMin'] as int);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(workout['name'],
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(
                  '${workout['durationMin']} min · ~$cals kcal'
                  '${workout['defaultSets'] > 0 ? ' · ${workout['defaultSets']}×${workout['defaultReps']} reps' : ''}',
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.add_rounded, color: color, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _Stat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      ],
    );
  }
}
