import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class MacroBar extends StatelessWidget {
  final String label;
  final double current;
  final double goal;
  final Color color;
  final String unit;

  const MacroBar({
    super.key,
    required this.label,
    required this.current,
    required this.goal,
    required this.color,
    this.unit = 'g',
  });

  @override
  Widget build(BuildContext context) {
    final percent = (goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0).toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500)),
              Text('${current.toStringAsFixed(0)}/${goal.toStringAsFixed(0)}$unit',
                  style: TextStyle(fontSize: 12, color: color)),
            ],
          ),
          const SizedBox(height: 5),
          LinearPercentIndicator(
            lineHeight: 8.0,
            percent: percent,
            backgroundColor: Colors.white12,
            progressColor: color,
            barRadius: const Radius.circular(4),
            padding: EdgeInsets.zero,
            animation: true,
            animationDuration: 1000,
          ),
        ],
      ),
    );
  }
}
