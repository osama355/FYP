import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_sharing_app/firebase_services/local_push_notification.dart';
import 'package:drive_sharing_app/screens/pessenger/pessengerscreen/pessenger_sidebar.dart';
import 'package:drive_sharing_app/screens/pessenger/pessengerscreen/search_ride.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class PessePostScreen extends StatefulWidget {
  const PessePostScreen({super.key});

  @override
  State<PessePostScreen> createState() => _PessePostScreenState();
}

class _PessePostScreenState extends State<PessePostScreen> {
  storeNotificationToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    FirebaseFirestore.instance
        .collection('app')
        .doc('user')
        .collection('pessenger')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({'token': token}, SetOptions(merge: true));
  }

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.getInitialMessage();
    FirebaseMessaging.onMessage.listen((event) {
      LocalNotificationService.display(event);
    });
    storeNotificationToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const PessengerSidebar(),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xff4BA0FE)),
        elevation: 0,
        title: const Text(
          "Ride Node",
          style: TextStyle(fontSize: 25, color: Color(0xff4BA0FE)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  color: const Color(0xff4BA0FE)),
              height: 120,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: const [
                    Icon(
                      Icons.drive_eta,
                      size: 60,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Welcome to Ride Node",
                      style: TextStyle(fontSize: 25, color: Colors.white),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              height: 120,
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  color: const Color(0xff4BA0FE)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: const [
                    Icon(
                      Icons.mode_of_travel,
                      size: 60,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Share and travel",
                      style: TextStyle(fontSize: 25, color: Colors.white),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SearchRide(),
                        fullscreenDialog: true));
              },
              autofocus: false,
              showCursor: false,
              keyboardType: TextInputType.none,
              decoration: InputDecoration(
                  hintText: 'Search for ride',
                  hintStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                      color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: InputBorder.none),
            )
          ],
        ),
      ),
    );
  }
}
