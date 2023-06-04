// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ReviewDriver extends StatefulWidget {
  final String rideId;
  final String driverId;
  final String passName;
  const ReviewDriver(
      {super.key,
      required this.rideId,
      required this.driverId,
      required this.passName});

  @override
  State<ReviewDriver> createState() => _ReviewDriverState();
}

class _ReviewDriverState extends State<ReviewDriver> {
  double _rating = 0.0;
  String _review = '';

  final auth = FirebaseAuth.instance;

  Future<void> _submitReview() async {
    Map<String, dynamic> reviewObject = {
      'passengerId': auth.currentUser!.uid,
      'passengerName': widget.passName,
      'rideId': widget.rideId,
      'rating': _rating,
      'reviewText': _review,
    };

    // Save the review to Firestore
    await FirebaseFirestore.instance
        .collection('app')
        .doc('user')
        .collection('driver')
        .doc(widget.driverId)
        .update({
      'rating': FieldValue.arrayUnion([reviewObject]),
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Review'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Rate your ride',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            Slider(
              value: _rating,
              onChanged: (newValue) {
                setState(() {
                  _rating = newValue;
                });
              },
              min: 0.0,
              max: 5.0,
              divisions: 5,
              label: _rating.toString(),
            ),
            const SizedBox(height: 16.0),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Write a review',
                border: OutlineInputBorder(),
              ),
              onChanged: (newValue) {
                setState(() {
                  _review = newValue;
                });
              },
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _submitReview,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
