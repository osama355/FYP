import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_sharing_app/screens/driver/driverscreens/driver_home_screen.dart';
import 'package:drive_sharing_app/screens/driver/driverscreens/driver_profile_screen.dart';
import 'package:drive_sharing_app/screens/driver/driverscreens/my_rides.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../utils/utils.dart';
import '../auth/main_driver_signup.dart';

class DriverSidebar extends StatefulWidget {
  const DriverSidebar({super.key});

  @override
  State<DriverSidebar> createState() => _DriverSidebarState();
}

class _DriverSidebarState extends State<DriverSidebar> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

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

  Future<String> getUserImage() async {
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
                    const Text("Status : Driver"),
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
                          child: snapshot.data == ""
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
                        builder: (context) => const DriverPost()));
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
                        builder: (context) => const DriverProfileScreen()));
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
                title: Text("Requests"),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const MyRides()));
              },
              child: const ListTile(
                leading: Icon(
                  Icons.drive_eta,
                  color: Color(0xff4BA0FE),
                ),
                title: Text("My Rides"),
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
