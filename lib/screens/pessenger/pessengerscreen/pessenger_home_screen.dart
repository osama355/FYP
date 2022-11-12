import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_sharing_app/screens/pessenger/auth/pess_login.dart';
import 'package:drive_sharing_app/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class PessePostScreen extends StatefulWidget {
  const PessePostScreen({super.key});

  @override
  State<PessePostScreen> createState() => _PessePostScreenState();
}

class _PessePostScreenState extends State<PessePostScreen> {
  File? profile;

  final picker = ImagePicker();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  Future getProfile() async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 100);
    setState(() {
      if (pickedFile != null) {
        profile = File(pickedFile.path);
      } else {
        Utils().toastMessage("No image picked");
      }
    });

    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref('/profileImage/${DateTime.now().millisecondsSinceEpoch}');
    firebase_storage.UploadTask uploadTask = ref.putFile(profile!.absolute);
    Future.value(uploadTask).then((value) async {
      var newUrl = await ref.getDownloadURL();
      final user = auth.currentUser;
      firestore
          .collection("app")
          .doc("user")
          .collection("pessenger")
          .doc(user?.uid)
          .update({'profile_pic': newUrl.toString()});
      Utils().toastMessage("Profile Uploaded successfully");
    }).onError((error, stackTrace) {
      Utils().toastMessage(error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        title: const Text("Passenger"),
        backgroundColor: const Color(0xff4BA0FE),
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
                    const Text("Status : Passenger"),
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
                        child: profile != null
                            ? ClipOval(
                                child: SizedBox.fromSize(
                                  size: const Size.fromRadius(48.0),
                                  child: Image.file(profile!.absolute),
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.person,
                                    size: 100,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                      ),
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
                title: Text("Join Request"),
              ),
            ),
            GestureDetector(
              onTap: () {
                auth.signOut().then((value) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PessengerLogin()));
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
