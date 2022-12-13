import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_sharing_app/screens/driver/driverscreens/driver_sidebar.dart';
import 'package:drive_sharing_app/screens/driver/driverscreens/googlemap/driver_map_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyRides extends StatefulWidget {
  const MyRides({super.key});

  @override
  State<MyRides> createState() => _MyRidesState();
}

class _MyRidesState extends State<MyRides> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    CollectionReference rides = FirebaseFirestore.instance
        .collection('app')
        .doc('user')
        .collection('driver')
        .doc(auth.currentUser?.uid)
        .collection('rides');
    return Scaffold(
      drawer: const DriverSidebar(),
      appBar: AppBar(
        title: const Text("My Rides"),
      ),
      body: StreamBuilder(
        stream: rides.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Something went wrong");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading...");
          }
          return ListView.builder(
            itemCount: snapshot.data?.docs.length,
            itemBuilder: (context, index) {
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
                          Row(
                            children: [
                              const Text(
                                "Sharing : ",
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                snapshot.data!.docs[index]['require-pess'],
                                style: const TextStyle(fontSize: 20),
                              )
                            ],
                          ),
                          Row(
                            children: const [
                              Text("Requests : "),
                              Text("0"),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const Text(
                            "Start : ",
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(
                            snapshot.data!.docs[index]['source'],
                            style: const TextStyle(fontSize: 20),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const Text(
                            "Via : ",
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(
                            snapshot.data!.docs[index]['via-route'],
                            style: const TextStyle(fontSize: 20),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const Text(
                            "Destination : ",
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(
                            snapshot.data!.docs[index]['destination'],
                            style: const TextStyle(fontSize: 20),
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
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(
                            snapshot.data!.docs[index]['date'],
                            style: const TextStyle(fontSize: 20),
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
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(
                            snapshot.data!.docs[index]['time'],
                            style: const TextStyle(fontSize: 20),
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
                                        builder: (context) => DriverMapScreen(
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
                              },
                              child: const Text("Cancle"))
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
