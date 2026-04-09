import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CalorieRing extends StatelessWidget {
  final int consumed;
  final int goal;
  final int burned;

  const CalorieRing({
    super.key,
    required this.consumed,
    required this.goal,
    required this.burned,
  });

  @override
  Widget build(BuildContext context) {
    final net = consumed - burned;
    final remaining = (goal - net).clamp(0, goal);
    final percent = ((net / goal).clamp(0.0, 1.0)).toDouble();
    final isOver = net > goal;

    return Center(
      child: CircularPercentIndicator(
        radius: 100.0,
        lineWidth: 14.0,
        animation: true,
        animationDuration: 1200,
        percent: percent.clamp(0.0, 1.0),
        center: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$remaining',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: isOver ? Colors.redAccent : Colors.white,
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.3, end: 0),
            const SizedBox(height: 2),
            Text(
              isOver ? 'over goal' : 'kcal left',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white60,
              ),
            ),
            const SizedBox(height: 6),
            _pill(Icons.local_fire_department, '$consumed', Colors.orangeAccent),
            const SizedBox(height: 4),
            _pill(Icons.fitness_center, '-$burned', Colors.greenAccent),
          ],
        ),
        circularStrokeCap: CircularStrokeCap.round,
        progressColor: isOver ? Colors.redAccent : const Color(0xFF6C63FF),
        backgroundColor: Colors.white12,
      ),
    );
  }

  Widget _pill(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: color)),
      ],
    );
  }
}
