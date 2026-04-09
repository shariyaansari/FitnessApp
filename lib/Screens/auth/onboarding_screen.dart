import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _step = 0;

  // Step 1 — Name
  final _nameController = TextEditingController();
  // Step 2 — Age & Gender
  int _age = 25;
  String _gender = 'male';
  // Step 3 — Height & Weight
  double _height = 170;
  double _weight = 70;
  // Step 4 — Goal
  String _goal = 'maintain';

  bool _loading = false;

  void _nextStep() {
    if (_step < 3) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
      setState(() => _step++);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    await auth.completeOnboarding(
      age: _age,
      gender: _gender,
      heightCm: _height,
      weightKg: _weight,
      goalType: _goal,
    );
    if (!mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: List.generate(4, (i) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: i <= _step
                            ? const Color(0xFF6C63FF)
                            : Colors.white12,
                      ),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _StepNamePage(controller: _nameController),
                  _StepAgePage(
                    age: _age,
                    gender: _gender,
                    onAgeChanged: (v) => setState(() => _age = v),
                    onGenderChanged: (v) => setState(() => _gender = v),
                  ),
                  _StepBodyPage(
                    height: _height,
                    weight: _weight,
                    onHeightChanged: (v) => setState(() => _height = v),
                    onWeightChanged: (v) => setState(() => _weight = v),
                  ),
                  _StepGoalPage(
                    goal: _goal,
                    onGoalChanged: (v) => setState(() => _goal = v),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2.5,
                        )
                      : Text(
                          _step < 3 ? 'Continue →' : 'Let\'s Go! 🚀',
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Step Pages ─────────────────────────────────────────────────────────────

class _StepNamePage extends StatelessWidget {
  final TextEditingController controller;
  const _StepNamePage({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text('👋', style: TextStyle(fontSize: 48))
              .animate().scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 20),
          const Text('What should we\ncall you?',
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 8),
          const Text('This is how FitAI will greet you.',
              style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 40),
          TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            decoration: InputDecoration(
              hintText: 'Your name...',
              hintStyle: const TextStyle(color: Colors.white30),
              filled: true,
              fillColor: Colors.white.withOpacity(0.07),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              prefixIcon:
                  const Icon(Icons.person_outline, color: Color(0xFF6C63FF)),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepAgePage extends StatelessWidget {
  final int age;
  final String gender;
  final ValueChanged<int> onAgeChanged;
  final ValueChanged<String> onGenderChanged;

  const _StepAgePage({
    required this.age,
    required this.gender,
    required this.onAgeChanged,
    required this.onGenderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text('🎂', style: TextStyle(fontSize: 48))
              .animate().scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 20),
          const Text('Age & Gender',
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 8),
          const Text('Helps us calculate your calorie goal.',
              style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Age',
                        style: TextStyle(color: Colors.white70, fontSize: 16)),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline,
                              color: Color(0xFF6C63FF)),
                          onPressed: () => onAgeChanged(age > 10 ? age - 1 : age),
                        ),
                        Text('$age',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline,
                              color: Color(0xFF6C63FF)),
                          onPressed: () =>
                              onAgeChanged(age < 100 ? age + 1 : age),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(color: Colors.white12, height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ['male', 'female', 'other'].map((g) {
                    final selected = g == gender;
                    return GestureDetector(
                      onTap: () => onGenderChanged(g),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF6C63FF)
                              : Colors.white12,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          g[0].toUpperCase() + g.substring(1),
                          style: TextStyle(
                              color: selected ? Colors.white : Colors.white54,
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepBodyPage extends StatelessWidget {
  final double height;
  final double weight;
  final ValueChanged<double> onHeightChanged;
  final ValueChanged<double> onWeightChanged;

  const _StepBodyPage({
    required this.height,
    required this.weight,
    required this.onHeightChanged,
    required this.onWeightChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text('📏', style: TextStyle(fontSize: 48))
              .animate().scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 20),
          const Text('Height & Weight',
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 8),
          const Text('Used to compute BMR/TDEE for your goal.',
              style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 40),
          _SliderRow(
            label: 'Height',
            value: height,
            unit: 'cm',
            min: 130,
            max: 220,
            onChanged: onHeightChanged,
          ),
          const SizedBox(height: 24),
          _SliderRow(
            label: 'Weight',
            value: weight,
            unit: 'kg',
            min: 30,
            max: 200,
            onChanged: onWeightChanged,
          ),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.unit,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 15)),
            Text('${value.round()} $unit',
                style: const TextStyle(
                    color: Color(0xFF6C63FF),
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: const Color(0xFF6C63FF),
          inactiveColor: Colors.white12,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _StepGoalPage extends StatelessWidget {
  final String goal;
  final ValueChanged<String> onGoalChanged;

  const _StepGoalPage(
      {required this.goal, required this.onGoalChanged});

  @override
  Widget build(BuildContext context) {
    final goals = [
      {
        'key': 'lose',
        'emoji': '🔥',
        'title': 'Lose Weight',
        'desc': 'Calorie deficit · High protein',
        'color': Colors.orangeAccent,
      },
      {
        'key': 'maintain',
        'emoji': '⚖️',
        'title': 'Stay Fit',
        'desc': 'Balanced diet · Regular exercise',
        'color': const Color(0xFF4ECDC4),
      },
      {
        'key': 'gain',
        'emoji': '💪',
        'title': 'Build Muscle',
        'desc': 'Calorie surplus · Strength training',
        'color': const Color(0xFF6C63FF),
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text('🎯', style: TextStyle(fontSize: 48))
              .animate().scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 20),
          const Text('What\'s your goal?',
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 8),
          const Text('FitAI will personalise your plan.',
              style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 32),
          ...goals.map((g) {
            final selected = g['key'] == goal;
            return GestureDetector(
              onTap: () => onGoalChanged(g['key'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: selected
                      ? (g['color'] as Color).withOpacity(0.15)
                      : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected
                        ? g['color'] as Color
                        : Colors.white.withOpacity(0.08),
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(g['emoji'] as String,
                        style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(g['title'] as String,
                              style: TextStyle(
                                  color: selected
                                      ? g['color'] as Color
                                      : Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          Text(g['desc'] as String,
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 13)),
                        ],
                      ),
                    ),
                    if (selected)
                      Icon(Icons.check_circle_rounded,
                          color: g['color'] as Color),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
