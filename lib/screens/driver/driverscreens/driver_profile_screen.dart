import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_sharing_app/screens/driver/driverscreens/driver_sidebar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../../../utils/utils.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  File? image;
  final picker = ImagePicker();
  String imageUrl = " ";
  String username = "";
  final _formKey = GlobalKey<FormState>();

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

  Future<String> getProfileImage() async {
    final uid = auth.currentUser?.uid;
    final users = await firestore
        .collection("app")
        .doc("user")
        .collection("driver")
        .doc(uid)
        .get();
    return users.data()?['dp'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const DriverSidebar(),
        appBar: AppBar(
          backgroundColor: const Color(0xff4BA0FE),
          centerTitle: false,
          title: const Text("Profile"),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Center(
              child: Column(
                children: [
                  const SizedBox(
                    height: 40,
                  ),
                  SizedBox(
                    height: 120,
                    width: 120,
                    child: Stack(
                      clipBehavior: Clip.none,
                      fit: StackFit.expand,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: const Color(0xff4BA0FE),
                              borderRadius: BorderRadius.circular(100.0)),
                          child: FutureBuilder(
                            future: getProfileImage(),
                            builder: (_, AsyncSnapshot snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircleAvatar(
                                  backgroundColor: Color(0xff4BA0FE),
                                );
                              }
                              return Container(
                                  height: 100,
                                  width: 100,
                                  decoration: BoxDecoration(
                                      color: const Color(0xff4BA0FE),
                                      borderRadius: BorderRadius.circular(100)),
                                  child: snapshot.data == ""
                                      ? ClipOval(
                                          child: SizedBox.fromSize(
                                            size: const Size.fromRadius(48.0),
                                            child: const CircleAvatar(),
                                          ),
                                        )
                                      : ClipOval(
                                          child: SizedBox.fromSize(
                                              size: const Size.fromRadius(48.0),
                                              child: Image.network(
                                                  snapshot.data.toString())),
                                        ));
                            },
                          ),
                        ),
                        Positioned(
                            bottom: 0,
                            right: -25,
                            child: RawMaterialButton(
                              onPressed: () {
                                getProfile();
                              },
                              elevation: 2.0,
                              fillColor: Colors.white,
                              padding: const EdgeInsets.all(15.0),
                              shape: const CircleBorder(),
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                color: Color(0xff4BA0FE),
                              ),
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
