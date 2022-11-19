import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_sharing_app/screens/pessenger/auth/pess_login.dart';
import 'package:drive_sharing_app/screens/pessenger/pessengerscreen/pessenger_home_screen.dart';
import 'package:drive_sharing_app/screens/pessenger/pessengerscreen/pessenger_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../utils/utils.dart';

class PessengerSidebar extends StatefulWidget {
  const PessengerSidebar({super.key});

  @override
  State<PessengerSidebar> createState() => _PessengerSidebarState();
}

class _PessengerSidebarState extends State<PessengerSidebar> {
  String imageUrl = " ";
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<String> getUserName() async {
    final uid = auth.currentUser?.uid;
    final users = await firestore
        .collection("app")
        .doc("user")
        .collection("pessenger")
        .doc(uid)
        .get();
    return users.data()?['name'];
  }

  Future<String> getUserImage() async {
    final uid = auth.currentUser?.uid;
    final users = await firestore
        .collection("app")
        .doc("user")
        .collection("pessenger")
        .doc(uid)
        .get();
    imageUrl = users.data()?['dp'] ?? " ";
    return imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: SizedBox(
      width: 280,
      child: Drawer(
        child: ListView(
          children: [
            SizedBox(
              height: 230,
              child: DrawerHeader(
                  child: Center(
                child: Column(
                  children: [
                    const Text("Status : Pessenger"),
                    const SizedBox(
                      height: 20,
                    ),
                    FutureBuilder(
                      future: getUserImage(),
                      builder: (_, AsyncSnapshot snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return ClipOval(
                            child: SizedBox.fromSize(
                              size: const Size.fromRadius(48.0),
                              child: const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                          );
                        }
                        return Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(100)),
                          child: imageUrl == " "
                              ? ClipOval(
                                  child: SizedBox.fromSize(
                                    size: const Size.fromRadius(48.0),
                                    child: const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : ClipOval(
                                  child: SizedBox.fromSize(
                                    size: const Size.fromRadius(48.0),
                                    child:
                                        Image.network(snapshot.data.toString()),
                                  ),
                                ),
                        );
                      },
                    ),
                    const SizedBox(
                      height: 20,
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
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PessePostScreen()));
              },
              child: const ListTile(
                leading: Icon(
                  Icons.home,
                  color: Color(0xff4BA0FE),
                ),
                title: Text("Home"),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PessengerProfileScreen()));
              },
              child: const ListTile(
                leading: Icon(
                  Icons.account_circle,
                  color: Color(0xff4BA0FE),
                ),
                title: Text("Profile"),
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: const ListTile(
                leading: Icon(
                  Icons.notifications,
                  color: Color(0xff4BA0FE),
                ),
                title: Text("User in Radius"),
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: const ListTile(
                leading: Icon(
                  Icons.settings,
                  color: Color(0xff4BA0FE),
                ),
                title: Text("Get Ride"),
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
                leading: Icon(
                  Icons.logout,
                  color: Color(0xff4BA0FE),
                ),
                title: Text("Sign out"),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
