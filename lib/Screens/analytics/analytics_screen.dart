import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../providers/meal_provider.dart';
import '../../providers/workout_provider.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  List<Map<String, dynamic>> _mealData = [];
  List<Map<String, dynamic>> _workoutData = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = context.read<AuthProvider>().firebaseUser?.uid;
    if (uid == null) return;
    final m = await context.read<MealProvider>().getWeeklySummary(uid);
    final w = await context.read<WorkoutProvider>().getWeeklySummary(uid);
    if (mounted) {
      setState(() {
        _mealData = m;
        _workoutData = w;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AuthProvider>().profile;
    final calGoal = profile?.adjustedCalorieGoal ?? 2000;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D1A),
        title: const Text('Analytics',
            style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation(Color(0xFF6C63FF))))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SectionHeader(title: '7-Day Calorie Overview'),
                const SizedBox(height: 12),
                _CalorieChart(
                  mealData: _mealData,
                  workoutData: _workoutData,
                  calGoal: calGoal,
                ).animate().fadeIn(duration: 500.ms),

                const SizedBox(height: 24),
                _SectionHeader(title: 'Weekly Activity'),
                const SizedBox(height: 12),
                _ActivityGrid(workoutData: _workoutData)
                    .animate(delay: 100.ms)
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: 24),
                _SectionHeader(title: 'This Week\'s Summary'),
                const SizedBox(height: 12),
                _WeeklySummaryCards(
                        mealData: _mealData,
                        workoutData: _workoutData,
                        calGoal: calGoal)
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: 30),
              ],
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
            fontSize: 15));
  }
}

class _CalorieChart extends StatelessWidget {
  final List<Map<String, dynamic>> mealData;
  final List<Map<String, dynamic>> workoutData;
  final int calGoal;

  const _CalorieChart(
      {required this.mealData, required this.workoutData, required this.calGoal});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(0, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: Colors.white.withOpacity(0.05), strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (v, _) => Text(
                  '${v.round()}',
                  style: const TextStyle(color: Colors.white30, fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= mealData.length) return const SizedBox();
                  final date = DateTime.parse(mealData[i]['date']);
                  return Text(
                    DateFormat('E').format(date),
                    style: const TextStyle(color: Colors.white38, fontSize: 10),
                  );
                },
              ),
            ),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            // Intake line
            LineChartBarData(
              spots: mealData.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), (e.value['calories'] as int).toDouble());
              }).toList(),
              isCurved: true,
              color: const Color(0xFF6C63FF),
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                  radius: 4,
                  color: const Color(0xFF6C63FF),
                  strokeWidth: 2,
                  strokeColor: const Color(0xFF0D0D1A),
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF6C63FF).withOpacity(0.1),
              ),
            ),
            // Burned line
            LineChartBarData(
              spots: workoutData.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(),
                    (e.value['caloriesBurned'] as int).toDouble());
              }).toList(),
              isCurved: true,
              color: Colors.orangeAccent,
              barWidth: 3,
              dashArray: [5, 3],
              dotData: FlDotData(
                show: true,
                getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                  radius: 4,
                  color: Colors.orangeAccent,
                  strokeWidth: 2,
                  strokeColor: const Color(0xFF0D0D1A),
                ),
              ),
              belowBarData: BarAreaData(show: false),
            ),
            // Goal line
            LineChartBarData(
              spots: List.generate(mealData.length,
                  (i) => FlSpot(i.toDouble(), calGoal.toDouble())),
              isCurved: false,
              color: Colors.white12,
              barWidth: 1.5,
              dashArray: [8, 4],
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityGrid extends StatelessWidget {
  final List<Map<String, dynamic>> workoutData;
  const _ActivityGrid({required this.workoutData});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: workoutData.map((d) {
        final burned = d['caloriesBurned'] as int;
        final date = DateTime.parse(d['date']);
        final isToday = d['date'] ==
            DateFormat('yyyy-MM-dd').format(DateTime.now());
        final intensity = burned > 400
            ? 1.0
            : burned > 200
                ? 0.6
                : burned > 0
                    ? 0.3
                    : 0.05;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Column(
              children: [
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withOpacity(intensity),
                    borderRadius: BorderRadius.circular(8),
                    border: isToday
                        ? Border.all(color: Colors.orangeAccent, width: 1.5)
                        : null,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  DateFormat('E').format(date)[0],
                  style:
                      const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _WeeklySummaryCards extends StatelessWidget {
  final List<Map<String, dynamic>> mealData;
  final List<Map<String, dynamic>> workoutData;
  final int calGoal;

  const _WeeklySummaryCards(
      {required this.mealData, required this.workoutData, required this.calGoal});

  @override
  Widget build(BuildContext context) {
    final totalCal = mealData.fold<int>(0, (s, d) => s + (d['calories'] as int));
    final avgCal = mealData.isEmpty ? 0 : totalCal ~/ mealData.length;
    final totalBurned = workoutData.fold<int>(
        0, (s, d) => s + (d['caloriesBurned'] as int));
    final activeDays = workoutData.where((d) => d['caloriesBurned'] > 0).length;

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.4,
      children: [
        _AnalyticCard(
          label: 'Avg. Daily Calories',
          value: '$avgCal kcal',
          icon: Icons.restaurant_menu_rounded,
          color: const Color(0xFF6C63FF),
          sub: avgCal > calGoal ? '↑ above goal' : '✓ on track',
        ),
        _AnalyticCard(
          label: 'Total Burned',
          value: '$totalBurned kcal',
          icon: Icons.local_fire_department_rounded,
          color: Colors.orangeAccent,
          sub: '7-day total',
        ),
        _AnalyticCard(
          label: 'Active Days',
          value: '$activeDays / 7',
          icon: Icons.directions_run_rounded,
          color: const Color(0xFF4ECDC4),
          sub: activeDays >= 5 ? '🏆 Excellent!' : activeDays >= 3 ? '👍 Good!' : '🎯 Keep going!',
        ),
        _AnalyticCard(
          label: 'Net Calories',
          value: '${totalCal - totalBurned} kcal',
          icon: Icons.balance_rounded,
          color: Colors.greenAccent,
          sub: '7-day net',
        ),
      ],
    );
  }
}

class _AnalyticCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final IconData icon;
  final Color color;

  const _AnalyticCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          Text(sub,
              style: TextStyle(color: color.withOpacity(0.7), fontSize: 10)),
        ],
      ),
    );
  }
}
