import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SeeReviews extends StatefulWidget {
  final String rideId;
  const SeeReviews({super.key, required this.rideId});

  @override
  State<SeeReviews> createState() => _SeeReviewsState();
}

class _SeeReviewsState extends State<SeeReviews> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  Stream<DocumentSnapshot>? reviewStream;

  @override
  void initState() {
    super.initState();
    reviewStream = firestore
        .collection('app')
        .doc('user')
        .collection('driver')
        .doc(auth.currentUser!.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Reviews'),
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: reviewStream,
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data;
            final reviews = data?['rating'] as List<dynamic>?;

            if (reviews == null || reviews.isEmpty) {
              return const Center(
                  child: Text('No reviews found for this ride.'));
            }

            final filterReview = reviews.where((doc) {
              final rideId = doc['rideId'];
              return rideId == widget.rideId;
            }).toList();

            if (filterReview.isEmpty) {
              return const Center(
                  child: Text('No reviews found for this ride.'));
            }

            return ListView.builder(
              itemCount: filterReview.length,
              itemBuilder: (context, index) {
                final review = filterReview[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    color: Colors.grey[200],
                    child: ListTile(
                      leading: Icon(Icons.star, color: Colors.yellow.shade700),
                      trailing: Text(
                        review['passengerName'].toString().toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      title: Text(
                        'Rating: ${review['rating']}',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[700],
                        ),
                      ),
                      subtitle: Text('Review: ${review['reviewText']}'),
                    ),
                  ),
                );
              },
            );
          },
        ));
  }
}
