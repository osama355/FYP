import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_sharing_app/screens/getting_started.dart';
import 'package:drive_sharing_app/screens/driver/driverscreens/profile/driver_home_screen.dart';
import 'package:drive_sharing_app/screens/pessenger/pessengerscreen/pass/pessenger_home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashServices {
  Future<void> isLogin(BuildContext context) async {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;

    final driverDoc = await FirebaseFirestore.instance
        .collection('app')
        .doc('user')
        .collection("driver")
        .doc(user?.uid)
        .get();

    if (user != null) {
      if (driverDoc.data()?['status'] == 'driver') {
        Timer(
            const Duration(seconds: 2),
            () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const DriverPost())));
      } else {
        Timer(
            const Duration(seconds: 2),
            () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const PessePostScreen())));
      }
    } else {
      Timer(
          const Duration(seconds: 3),
          () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => const GettingStarted())));
    }
  }
}
