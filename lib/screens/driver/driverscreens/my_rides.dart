import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_sharing_app/screens/driver/driverscreens/driver_home_screen.dart';
import 'package:drive_sharing_app/screens/driver/driverscreens/travel_partners.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages, unused_import
import 'package:intl/intl.dart' show DateFormat;

class MyRides extends StatefulWidget {
  const MyRides({super.key});

  @override
  State<MyRides> createState() => _MyRidesState();
}

class _MyRidesState extends State<MyRides> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference ridesCollection =
      FirebaseFirestore.instance.collection('rides');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = auth.currentUser;
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xff4BA0FE),
          title: const Text("My Rides"),
          leading: GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const DriverPost()));
            },
            child: Icon(Icons.arrow_back),
          )),
      body: StreamBuilder(
        stream: ridesCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Something went wrong");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Text("Loading..."));
          }
          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No ride created yet"),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data?.docs.length,
            itemBuilder: (context, index) {
              if (snapshot.data!.docs[index]['driver-id'] == user?.uid) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          )
                        ]),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total Seats : ${snapshot.data!.docs[index]['require-pess']}",
                              style: const TextStyle(fontSize: 13),
                            ),
                            Text(
                              "Reserved Seats : ${snapshot.data!.docs[index]['reservedSeats']}",
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.circle,
                              size: 10.0,
                              color: Colors.green,
                            ),
                            const SizedBox(
                              width: 3,
                            ),
                            const Text(
                              "Start : ",
                              style: TextStyle(fontSize: 13),
                            ),
                            Text(
                              snapshot.data!.docs[index]['source'],
                              style: const TextStyle(fontSize: 13),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.circle,
                              size: 10.0,
                              color: Colors.blue,
                            ),
                            const SizedBox(
                              width: 3,
                            ),
                            const Text(
                              "Via : ",
                              style: TextStyle(fontSize: 13),
                            ),
                            Text(
                              snapshot.data!.docs[index]['via-route'],
                              style: const TextStyle(fontSize: 13),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.circle,
                              size: 10.0,
                              color: Colors.red,
                            ),
                            const SizedBox(
                              width: 3,
                            ),
                            const Text(
                              "Destination : ",
                              style: TextStyle(fontSize: 13),
                            ),
                            Text(
                              snapshot.data!.docs[index]['destination'],
                              style: const TextStyle(fontSize: 13),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            const Text(
                              "Date : ",
                              style: TextStyle(fontSize: 13),
                            ),
                            Text(
                              snapshot.data!.docs[index]['date'],
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            const Text(
                              "Time : ",
                              style: TextStyle(fontSize: 13),
                            ),
                            Text(
                              snapshot.data!.docs[index]['time'],
                              style: const TextStyle(fontSize: 13),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            ElevatedButton(
                                onPressed: () {
                                  String rideId = snapshot.data!.docs[index].id;
                                  double sourceLat =
                                      snapshot.data?.docs[index]["source-lat"];
                                  double sourceLng =
                                      snapshot.data?.docs[index]["source-lng"];
                                  double viaLat =
                                      snapshot.data?.docs[index]["via-lat"];
                                  double viaLng =
                                      snapshot.data?.docs[index]["via-lng"];
                                  double destinationLat = snapshot
                                      .data?.docs[index]["destination-lat"];
                                  double destinationLng = snapshot
                                      .data?.docs[index]["destination-lng"];
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => TravelPartners(
                                                rideId: rideId,
                                                startPositionLat: sourceLat,
                                                startPositionLng: sourceLng,
                                                midPositionLat: viaLat,
                                                midPositionLng: viaLng,
                                                endPositionLat: destinationLat,
                                                endPositionLng: destinationLng,
                                              )));
                                },
                                child: const Text("Start")),
                            const SizedBox(
                              width: 5,
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  firestore.runTransaction(
                                      (Transaction transaction) async {
                                    transaction.delete(
                                        snapshot.data!.docs[index].reference);
                                  });
                                  firestore
                                      .collection('rides')
                                      .doc(snapshot.data!.docs[index].id)
                                      .delete();
                                },
                                child: const Text("Delete",
                                    style: TextStyle(fontSize: 12)))
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox(
                height: 0,
              );
            },
          );
        },
      ),
    );
  }
}
