// ignore_for_file: deprecated_member_use
import 'package:drive_sharing_app/firebase_services/local_push_notification.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:drive_sharing_app/screens/splash_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

final databaseRef = FirebaseDatabase.instance.reference();

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  /// onClick listener
  // print("Handling a background message : ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  LocalNotificationService.initialize();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const SplashScreen());
  }
}
