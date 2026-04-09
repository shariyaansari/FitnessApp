import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkoutScreen extends StatefulWidget {
  @override
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final TextEditingController _durationController = TextEditingController();

  void addWorkout() async {
    final user = FirebaseAuth.instance.currentUser!;
    final today = DateTime.now().toString().split(' ')[0];

    await FirebaseFirestore.instance
        .collection('workouts')
        .doc(user.uid)
        .collection(today)
        .add({
      'duration': int.parse(_durationController.text),
      'timestamp': Timestamp.now(),
    });

    _durationController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Workout")),
      body: Column(
        children: [
          TextField(
            controller: _durationController,
            decoration: InputDecoration(labelText: "Duration (min)"),
            keyboardType: TextInputType.number,
          ),
          ElevatedButton(
            onPressed: addWorkout,
            child: Text("Add Workout"),
          ),
        ],
      ),
    );
  }
}
