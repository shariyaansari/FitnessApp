import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MealScreen extends StatefulWidget {
  @override
  _MealScreenState createState() => _MealScreenState();
}

class _MealScreenState extends State<MealScreen> {
  final TextEditingController _caloriesController = TextEditingController();

  void addMeal() async {
    final user = FirebaseAuth.instance.currentUser!;
    final today = DateTime.now().toString().split(' ')[0];

    await FirebaseFirestore.instance
        .collection('meals')
        .doc(user.uid)
        .collection(today)
        .add({
      'calories': int.parse(_caloriesController.text),
      'timestamp': Timestamp.now(),
    });

    _caloriesController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Meals")),
      body: Column(
        children: [
          TextField(
            controller: _caloriesController,
            decoration: InputDecoration(labelText: "Calories"),
            keyboardType: TextInputType.number,
          ),
          ElevatedButton(
            onPressed: addMeal,
            child: Text("Add Meal"),
          ),
        ],
      ),
    );
  }
}
