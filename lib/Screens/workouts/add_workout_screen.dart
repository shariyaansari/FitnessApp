import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/workout_provider.dart';

class AddWorkoutScreen extends StatefulWidget {
  final Map<String, dynamic>? preset;
  const AddWorkoutScreen({super.key, this.preset});

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();

  String _category = 'gym';
  int _duration = 30;
  int _sets = 3;
  int _reps = 12;
  int _caloriesBurned = 0;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.preset != null) {
      final p = widget.preset!;
      _nameController.text = p['name'] ?? '';
      _category = p['category'] ?? 'gym';
      _duration = p['durationMin'] ?? 30;
      _sets = p['defaultSets'] ?? 3;
      _reps = p['defaultReps'] ?? 12;
      _caloriesBurned = (_duration * ((p['caloriesPerMin'] ?? 8) as int));
    }
  }

  void _recalcCalories() {
    final perMin = {
      'gym': 8, 'home': 7, 'yoga': 3, 'cardio': 10,
    };
    setState(() {
      _caloriesBurned = _duration * (perMin[_category] ?? 7);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final uid = context.read<AuthProvider>().firebaseUser!.uid;
    await context.read<WorkoutProvider>().addWorkout(uid,
      name: _nameController.text.trim(),
      category: _category,
      durationMin: _duration,
      caloriesBurned: _caloriesBurned,
      sets: _sets,
      reps: _reps,
      notes: _notesController.text.trim(),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final catColors = {
      'gym':    const Color(0xFF6C63FF),
      'home':   const Color(0xFF4ECDC4),
      'yoga':   Colors.purpleAccent,
      'cardio': Colors.orangeAccent,
    };
    final color = catColors[_category] ?? Colors.white54;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D1A),
        title: const Text('Log Workout',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Summary card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(0.25)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MiniStat(label: 'Duration', value: '$_duration min', color: color),
                  _MiniStat(label: 'Burned', value: '$_caloriesBurned kcal', color: color),
                  _MiniStat(label: 'Sets', value: '$_sets × $_reps', color: color),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Category selector
            const Text('Category',
                style: TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 8),
            Row(
              children: ['gym', 'home', 'yoga', 'cardio'].map((c) {
                final selected = c == _category;
                final catColor = catColors[c] ?? Colors.white54;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _category = c);
                      _recalcCalories();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected
                            ? catColor.withOpacity(0.15)
                            : Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected ? catColor : Colors.white.withOpacity(0.08),
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        c[0].toUpperCase() + c.substring(1),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: selected ? catColor : Colors.white38,
                            fontSize: 12,
                            fontWeight: selected
                                ? FontWeight.bold
                                : FontWeight.normal),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Name
            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              validator: (v) => v?.isEmpty == true ? 'Required' : null,
              decoration: _inputDeco('Workout Name', Icons.fitness_center_rounded),
            ),

            const SizedBox(height: 16),

            // Duration slider
            _SliderControl(
              label: 'Duration',
              value: _duration,
              unit: 'min',
              min: 5,
              max: 120,
              color: color,
              onChanged: (v) {
                setState(() => _duration = v);
                _recalcCalories();
              },
            ),

            const SizedBox(height: 16),

            // Sets
            _SliderControl(
              label: 'Sets',
              value: _sets,
              unit: 'sets',
              min: 0,
              max: 10,
              color: color,
              onChanged: (v) => setState(() => _sets = v),
            ),

            const SizedBox(height: 16),

            // Reps
            _SliderControl(
              label: 'Reps per Set',
              value: _reps,
              unit: 'reps',
              min: 0,
              max: 50,
              color: color,
              onChanged: (v) => setState(() => _reps = v),
            ),

            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              style: const TextStyle(color: Colors.white),
              maxLines: 2,
              decoration: _inputDeco('Notes (optional)', Icons.note_outlined),
            ),

            const SizedBox(height: 28),

            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: _loading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white)))
                    : const Icon(Icons.check_rounded, color: Colors.white),
                label: Text(_loading ? 'Saving...' : 'Log Workout',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white38, fontSize: 13),
      prefixIcon: Icon(icon, color: const Color(0xFF6C63FF), size: 18),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}

class _SliderControl extends StatelessWidget {
  final String label;
  final int value;
  final String unit;
  final int min;
  final int max;
  final Color color;
  final ValueChanged<int> onChanged;

  const _SliderControl({
    required this.label,
    required this.value,
    required this.unit,
    required this.min,
    required this.max,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
            Text('$value $unit',
                style: TextStyle(
                    color: color, fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: max - min,
          activeColor: color,
          inactiveColor: Colors.white12,
          onChanged: (v) => onChanged(v.round()),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      ],
    );
  }
}
