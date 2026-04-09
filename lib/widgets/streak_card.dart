import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StreakCard extends StatelessWidget {
  final int streak;

  const StreakCard({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Text('🔥', style: const TextStyle(fontSize: 36))
              .animate(onPlay: (c) => c.repeat())
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.15, 1.15),
                duration: 800.ms,
              )
              .then()
              .scale(
                begin: const Offset(1.15, 1.15),
                end: const Offset(1, 1),
                duration: 800.ms,
              ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$streak Day Streak!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 2),
                Text(
                  streak == 0
                      ? 'Log today to start your streak!'
                      : streak < 7
                          ? 'Keep going! Every day counts.'
                          : streak < 30
                              ? 'You\'re on fire! Don\'t break it! 💪'
                              : 'Legendary! ${streak} days strong! 🏆',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                _badge(streak),
                style: const TextStyle(fontSize: 28),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _badge(int streak) {
    if (streak >= 100) return '👑';
    if (streak >= 30)  return '🏆';
    if (streak >= 14)  return '🥇';
    if (streak >= 7)   return '⭐';
    return '🎯';
  }
}
