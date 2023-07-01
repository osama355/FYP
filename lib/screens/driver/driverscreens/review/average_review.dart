// ignore_for_file: avoid_print
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AverageRating extends StatefulWidget {
  final String driverId;
  const AverageRating({super.key, required this.driverId});

  @override
  State<AverageRating> createState() => _AverageRatingState();
}

class _AverageRatingState extends State<AverageRating> {
  FirebaseAuth auth = FirebaseAuth.instance;
  double averageRating = 0;

  Future<void> fetchAverageRating() async {
    final DocumentReference documentRef = FirebaseFirestore.instance
        .collection('app')
        .doc('user')
        .collection('driver')
        .doc(widget.driverId);

    try {
      final snapshot = await documentRef.get();
      if (snapshot.exists) {
        final documentData = snapshot.data() as Map<String, dynamic>;
        final reviewField = documentData['rating'];
        if (reviewField != null) {
          final reviews = reviewField as List<dynamic>;
          if (reviews.isNotEmpty) {
            double totalRating = 0;
            for (final review in reviews) {
              final rating = review['rating'] as num;
              totalRating += rating.toDouble();
            }
            setState(() {
              averageRating = totalRating / reviews.length;
            });
          }
        }
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAverageRating();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star,
              size: 15,
              color: averageRating >= 1 ? Colors.amber : Colors.grey,
            ),
            Icon(
              Icons.star,
              size: 15,
              color: averageRating >= 2 ? Colors.amber : Colors.grey,
            ),
            Icon(
              Icons.star,
              size: 15,
              color: averageRating >= 3 ? Colors.amber : Colors.grey,
            ),
            Icon(
              Icons.star,
              size: 15,
              color: averageRating >= 4 ? Colors.amber : Colors.grey,
            ),
            Icon(
              Icons.star,
              size: 15,
              color: averageRating >= 5 ? Colors.amber : Colors.grey,
            ),
          ],
        ),
        Text('${averageRating.toStringAsFixed(1)}'),
      ],
    );
  }
}
