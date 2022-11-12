import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_sharing_app/screens/driver/auth/main_driver_signup.dart';
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

  Future<String> getUserName() async {
    final uid = auth.currentUser?.uid;
    final users = await firestore
        .collection("app")
        .doc("user")
        .collection("driver")
        .doc(uid)
        .get();
    return users.data()?['name'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        title: const Text("Driver"),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            SizedBox(
              height: 250,
              child: DrawerHeader(
                  child: Center(
                child: Column(
                  children: [
                    const Text("Status : Driver"),
                    const SizedBox(
                      height: 20,
                    ),
                    InkWell(
                      onTap: getProfile,
                      child: Container(
                          height: 130,
                          width: 130,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: imageUrl == " "
                              ? ClipOval(
                                  child: SizedBox.fromSize(
                                    size: const Size.fromRadius(48.0),
                                    child: const Icon(
                                      Icons.person,
                                      size: 80,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : ClipOval(
                                  child: SizedBox.fromSize(
                                      size: const Size.fromRadius(48.0),
                                      child:
                                          Image.network(imageUrl.toString())))),
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    FutureBuilder(
                      future: getUserName(),
                      builder: (_, AsyncSnapshot snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return Text(snapshot.data);
                      },
                    )
                  ],
                ),
              )),
            ),
            GestureDetector(
              onTap: () {},
              child: const ListTile(
                title: Text("Home"),
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: const ListTile(
                title: Text("Profile"),
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: const ListTile(
                title: Text("My Request"),
              ),
            ),
            GestureDetector(
              onTap: () {
                auth.signOut().then((value) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const SignUp()));
                }).onError((error, stackTrace) {
                  Utils().toastMessage(error.toString());
                });
              },
              child: const ListTile(
                title: Text("Sign out"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
