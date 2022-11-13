import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_sharing_app/screens/driver/auth/main_driver_signup.dart';
import 'package:drive_sharing_app/screens/driver/driverscreens/driver_sidebar.dart';
import 'package:drive_sharing_app/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class DriverPost extends StatefulWidget {
  const DriverPost({super.key});

  @override
  State<DriverPost> createState() => _DriverPost();
}

class _DriverPost extends State<DriverPost> {
  File? image;
  final picker = ImagePicker();
  String imageUrl = " ";
  String username = "";
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> getProfile() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );

    final user = auth.currentUser;
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref('/profiledp/${DateTime.now().millisecondsSinceEpoch}');
    await ref.putFile(File(image!.path));

    ref.getDownloadURL().then((value) {
      setState(() {
        imageUrl = value;
      });
      firestore
          .collection("app")
          .doc("user")
          .collection("driver")
          .doc(user?.uid)
          .update({'dp': imageUrl.toString()});
      Utils().toastMessage("Profile uploaded successfully");
    }).onError((error, stackTrace) {
      Utils().toastMessage(error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DriverSidebar(),
      appBar: AppBar(
        centerTitle: false,
        title: const Text("Home"),
      ),
      body: const Center(
        child: Text("Driver"),
      ),
    );
  }
}
