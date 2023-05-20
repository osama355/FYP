// ignore_for_file: file_names
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../../../../utils/utils.dart';
import '../../../../widgets/round_button.dart';

class PessengerProfileScreen extends StatefulWidget {
  const PessengerProfileScreen({super.key});

  @override
  State<PessengerProfileScreen> createState() => _PessengerProfileScreenState();
}

class _PessengerProfileScreenState extends State<PessengerProfileScreen> {
  File? image;
  final picker = ImagePicker();
  String imageUrl = " ";
  String username = "";

  final nameController = TextEditingController();

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
  }

  Future<void> setProfile() async {
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
    ref.getDownloadURL().then((value) async {
      setState(() {
        imageUrl = value;
      });
      await firestore
          .collection("app")
          .doc("user")
          .collection("pessenger")
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
        .collection("pessenger")
        .doc(uid)
        .get();
    return users.data()?['dp'];

    // return users.data()?['dp'] ?? " ";
  }

  Future updateuserData() async {
    final uid = auth.currentUser?.uid;
    final user = firestore
        .collection('app')
        .doc('user')
        .collection('pessenger')
        .doc(uid);
    if (nameController.text.isNotEmpty) {
      user.update({'name': nameController.text});
    }
    Utils().toastMessage("Profile Updated successfully");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: const Color(0xff4BA0FE),
          title: const Text("Profile"),
        ),
        body: SingleChildScrollView(
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
                              setProfile();
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
                ),
                StreamBuilder(
                  stream: firestore
                      .collection("app")
                      .doc("user")
                      .collection("pessenger")
                      .doc(auth.currentUser?.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    return Column(
                      children: [
                        const SizedBox(
                          height: 15,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 30, right: 30),
                          child: TextFormField(
                            readOnly: true,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              hintText: snapshot.data?['phone'],
                              hintStyle: const TextStyle(
                                color: Color.fromARGB(255, 26, 24, 24),
                              ),
                              suffixIcon: const Icon(
                                Icons.phone,
                                size: 20,
                                color: Color(0xff4BA0FE),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 30, right: 30),
                          child: TextFormField(
                            controller: nameController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              hintText: snapshot.data?['name'],
                              hintStyle: const TextStyle(
                                  color: Color.fromARGB(255, 21, 21, 21)),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        RoundButton(
                          title: "Save",
                          onTap: () {
                            updateuserData();
                          },
                        ),
                        const SizedBox(
                          height: 30,
                        )
                      ],
                    );
                  },
                )
              ],
            ),
          ),
        ));
  }
}
