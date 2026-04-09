import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/meal_provider.dart';
import '../../models/meal_entry.dart';

class AddMealScreen extends StatefulWidget {
  const AddMealScreen({super.key});

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _calController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatsController = TextEditingController();
  final _searchController = TextEditingController();

  String _mealType = 'breakfast';
  bool _loading = false;
  List<Map<String, dynamic>> _filtered = List.from(kFoodDatabase);

  void _search(String query) {
    setState(() {
      _filtered = kFoodDatabase
          .where((f) =>
              (f['name'] as String)
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();
    });
  }

  void _selectFood(Map<String, dynamic> food) {
    setState(() {
      _nameController.text = food['name'];
      _calController.text = food['calories'].toString();
      _proteinController.text = food['protein'].toString();
      _carbsController.text = food['carbs'].toString();
      _fatsController.text = food['fats'].toString();
    });
  }

  Future<void> _add() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final uid = context.read<AuthProvider>().firebaseUser!.uid;
    await context.read<MealProvider>().addMeal(uid,
      name: _nameController.text.trim(),
      calories: int.tryParse(_calController.text) ?? 0,
      protein: double.tryParse(_proteinController.text) ?? 0,
      carbs: double.tryParse(_carbsController.text) ?? 0,
      fats: double.tryParse(_fatsController.text) ?? 0,
      mealType: _mealType,
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D1A),
        title: const Text('Log Meal',
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
            // Search
            TextField(
              controller: _searchController,
              onChanged: _search,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search food...',
                hintStyle: const TextStyle(color: Colors.white30),
                prefixIcon:
                    const Icon(Icons.search_rounded, color: Color(0xFF6C63FF)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Food list
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _filtered.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final food = _filtered[i];
                  return GestureDetector(
                    onTap: () => _selectFood(food),
                    child: Container(
                      width: 130,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.restaurant_rounded,
                              color: Color(0xFF6C63FF), size: 22),
                          const SizedBox(height: 8),
                          Text(food['name'],
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text('${food['calories']} kcal',
                              style: const TextStyle(
                                  color: Color(0xFF4ECDC4), fontSize: 12)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
            const Divider(color: Colors.white12),
            const SizedBox(height: 16),
            const Text('Meal Details',
                style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
            const SizedBox(height: 12),

            // Meal type
            Wrap(
              spacing: 10,
              children: ['breakfast', 'lunch', 'dinner', 'snack'].map((t) {
                final selected = t == _mealType;
                return ChoiceChip(
                  label: Text(t[0].toUpperCase() + t.substring(1)),
                  selected: selected,
                  onSelected: (_) => setState(() => _mealType = t),
                  selectedColor: const Color(0xFF6C63FF),
                  backgroundColor: Colors.white.withOpacity(0.06),
                  labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.white54),
                  side: BorderSide.none,
                );
              }).toList(),
            ),

            const SizedBox(height: 16),
            _InputField(
              controller: _nameController,
              label: 'Food Name',
              icon: Icons.label_outline_rounded,
              required: true,
            ),
            const SizedBox(height: 12),
            _InputField(
              controller: _calController,
              label: 'Calories (kcal)',
              icon: Icons.local_fire_department_outlined,
              keyboardType: TextInputType.number,
              required: true,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _InputField(
                    controller: _proteinController,
                    label: 'Protein (g)',
                    icon: Icons.egg_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _InputField(
                    controller: _carbsController,
                    label: 'Carbs (g)',
                    icon: Icons.grain_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _InputField(
                    controller: _fatsController,
                    label: 'Fats (g)',
                    icon: Icons.water_drop_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _add,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white)))
                    : const Icon(Icons.check_rounded, color: Colors.white),
                label: Text(_loading ? 'Saving...' : 'Log Meal',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool required;

  const _InputField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      validator: required
          ? (v) => (v == null || v.isEmpty) ? 'Required' : null
          : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white38, fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFF6C63FF), size: 18),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        errorStyle: const TextStyle(fontSize: 10),
      ),
    );
  }
}
