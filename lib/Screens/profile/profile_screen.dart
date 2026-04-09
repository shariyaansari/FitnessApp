import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_profile.dart';
import '../analytics/analytics_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = auth.profile;
    if (profile == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D0D1A),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final goalColors = {
      'lose': Colors.orangeAccent,
      'maintain': const Color(0xFF4ECDC4),
      'gain': const Color(0xFF6C63FF),
    };
    final goalColor = goalColors[profile.goalType] ?? const Color(0xFF6C63FF);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFF0D0D1A),
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF6C63FF).withOpacity(0.3),
                          const Color(0xFF0D0D1A),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      CircleAvatar(
                        radius: 44,
                        backgroundImage: profile.photoUrl.isNotEmpty
                            ? CachedNetworkImageProvider(profile.photoUrl)
                            : null,
                        backgroundColor: const Color(0xFF6C63FF),
                        child: profile.photoUrl.isEmpty
                            ? Text(
                                profile.name.isNotEmpty
                                    ? profile.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold))
                            : null,
                      ),
                      const SizedBox(height: 10),
                      Text(profile.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      Text(profile.email,
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            title: const Text('Profile',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                onPressed: () => _showEditDialog(context, profile),
                icon: const Icon(Icons.edit_rounded, color: Colors.white54),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Goal + BMR
                  _InfoCard(
                    children: [
                      _InfoRow(
                        label: 'Goal',
                        value: _goalLabel(profile.goalType),
                        color: goalColor,
                      ),
                      _InfoRow(
                        label: 'Daily Calorie Target',
                        value: '${profile.adjustedCalorieGoal} kcal',
                        color: const Color(0xFF6C63FF),
                      ),
                      _InfoRow(label: 'BMI', value: '${profile.bmi.toStringAsFixed(1)} (${profile.bmiCategory})'),
                      _InfoRow(label: 'Height', value: '${profile.heightCm.round()} cm'),
                      _InfoRow(label: 'Weight', value: '${profile.weightKg.round()} kg'),
                      _InfoRow(label: 'Age', value: '${profile.age} years'),
                    ],
                  ).animate().fadeIn(duration: 400.ms),

                  const SizedBox(height: 14),

                  // Streak
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 32)),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${profile.streakDays} Day Streak',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            Text(
                              profile.isPremium ? '⭐ Premium Member' : 'Free Plan',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

                  const SizedBox(height: 14),

                  // Analytics button
                  _ActionTile(
                    icon: Icons.bar_chart_rounded,
                    title: 'View Analytics',
                    subtitle: '7-day charts & insights',
                    color: const Color(0xFF6C63FF),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const AnalyticsScreen())),
                  ).animate(delay: 200.ms).fadeIn(duration: 300.ms),

                  const SizedBox(height: 10),

                  // Premium upgrade card
                  if (!profile.isPremium)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF6C63FF).withOpacity(0.2),
                            const Color(0xFF4ECDC4).withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: const Color(0xFF6C63FF).withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Text('👑', style: TextStyle(fontSize: 32)),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Upgrade to Premium',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                                Text(
                                  'Unlock AI coach + advanced analytics',
                                  style: TextStyle(
                                      color: Colors.white54, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF6C63FF),
                                    Color(0xFF4ECDC4)
                                  ]),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('Upgrade',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13)),
                          ),
                        ],
                      ),
                    ).animate(delay: 300.ms).fadeIn(duration: 300.ms),

                  const SizedBox(height: 20),

                  // Sign out
                  _ActionTile(
                    icon: Icons.logout_rounded,
                    title: 'Sign Out',
                    subtitle: 'Signed in as ${profile.email}',
                    color: Colors.redAccent,
                    onTap: () => _confirmSignOut(context, auth),
                  ).animate(delay: 400.ms).fadeIn(duration: 300.ms),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _goalLabel(String goal) {
    switch (goal) {
      case 'lose':     return '🔥 Lose Weight';
      case 'gain':     return '💪 Build Muscle';
      case 'maintain': return '⚖️ Stay Fit';
      default:         return goal;
    }
  }

  void _confirmSignOut(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF13132A),
        title: const Text('Sign Out?',
            style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to sign out?',
            style: TextStyle(color: Colors.white54)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              auth.signOut();
            },
            child: const Text('Sign Out',
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, UserProfile profile) {
    final weightCtrl =
        TextEditingController(text: profile.weightKg.round().toString());
    final heightCtrl =
        TextEditingController(text: profile.heightCm.round().toString());
    String goal = profile.goalType;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF13132A),
        title: const Text('Edit Profile',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: StatefulBuilder(builder: (ctx, setS) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: weightCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  labelStyle: TextStyle(color: Colors.white38),
                ),
              ),
              TextField(
                controller: heightCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Height (cm)',
                  labelStyle: TextStyle(color: Colors.white38),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['lose', 'maintain', 'gain'].map((g) {
                  return GestureDetector(
                    onTap: () => setS(() => goal = g),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: goal == g
                            ? const Color(0xFF6C63FF)
                            : Colors.white12,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(g,
                          style: TextStyle(
                              color: goal == g ? Colors.white : Colors.white54,
                              fontSize: 12)),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        }),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF)),
            onPressed: () {
              Navigator.pop(context);
              final updated = profile.copyWith(
                weightKg: double.tryParse(weightCtrl.text) ?? profile.weightKg,
                heightCm: double.tryParse(heightCtrl.text) ?? profile.heightCm,
                goalType: goal,
              );
              context
                  .read<AuthProvider>()
                  .updateProfile(updated.toMap());
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _InfoRow({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 14)),
          Text(value,
              style: TextStyle(
                  color: color ?? Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  Text(subtitle,
                      style:
                          const TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: color.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}
