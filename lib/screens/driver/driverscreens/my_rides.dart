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
            child: const Icon(Icons.arrow_back),
          )),
      body: StreamBuilder(
        stream: ridesCollection
            .orderBy('date')
            .orderBy(
              'time',
            )
            .snapshots(),
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

          // final now = DateTime.now();
          // final sortedDocs = snapshot.data!.docs.where((doc) {
          //   final rideDate = DateFormat('dd-MM-yyyy').parse(doc['date']);
          //   return rideDate.isAtSameMomentAs(now) ||
          //       rideDate.isAfter(now);
          // }).toList();
          // sortedDocs.sort((a, b) {
          //   final aDate = DateFormat('dd-MM-yyyy').parse(a['date']);
          //   final bDate = DateFormat('dd-MM-yyyy').parse(b['date']);
          //   final aTime = DateFormat.jm().parse(a['time']).hour;
          //   final bTime = DateFormat.jm().parse(b['time']).hour;
          //   if (aDate.isBefore(bDate)) {
          //     return -1;
          //   } else if (aDate.isAfter(bDate)) {
          //     return 1;
          //   } else {
          //     return aTime.compareTo(bTime);
          //   }
          // });

          final now = DateTime.now();
          // final sortedDocs = snapshot.data!.docs.where((doc) {
          //   final rideDate = DateFormat('dd-MM-yyyy').parse(doc['date']);
          //   final rideTime = DateFormat.jm().parse(doc['time']);
          //   final rideDateTime = DateTime(rideDate.year, rideDate.month,
          //       rideDate.day, rideTime.hour, rideTime.minute);
          //   return rideDateTime.isAfter(now) || rideDate.isAfter(now);
          // }).toList();

          final sortedDocs = snapshot.data!.docs.where((doc) {
            final rideDate = DateFormat('dd-MM-yyyy').parse(doc['date']);
            final rideDateTime =
                DateTime(rideDate.year, rideDate.month, rideDate.day);
            return rideDateTime.isAfter(now.subtract(const Duration(days: 1)));
          }).toList();

          sortedDocs.sort((a, b) {
            final aDate = DateFormat('dd-MM-yyyy').parse(a['date']);
            final bDate = DateFormat('dd-MM-yyyy').parse(b['date']);
            final aTime = DateFormat.jm().parse(a['time']).hour;
            final bTime = DateFormat.jm().parse(b['time']).hour;
            if (aDate.isBefore(bDate)) {
              return -1;
            } else if (aDate.isAfter(bDate)) {
              return 1;
            } else {
              return aTime.compareTo(bTime);
            }
          });

          if (sortedDocs.isEmpty) {
            return const Center(child: Text("No ride yet"));
          }

          return ListView.builder(
            itemCount: sortedDocs.length,
            itemBuilder: (context, index) {
              if (sortedDocs[index]['driver-id'] == user?.uid) {
                final time = DateFormat('HH:mm')
                    .format(DateFormat.jm().parse(sortedDocs[index]['time']));
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
                              "Total Seats : ${sortedDocs[index]['require-pess']}",
                              style: const TextStyle(fontSize: 13),
                            ),
                            Text(
                              "Reserved Seats : ${sortedDocs[index]['reservedSeats']}",
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
                              sortedDocs[index]['source'],
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
                              sortedDocs[index]['via-route'],
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
                              sortedDocs[index]['destination'],
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
                              sortedDocs[index]['date'],
                              // snapshot.data!.docs[index]['date'],
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
                              time,
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
                                  String rideId = sortedDocs[index].id;
                                  double sourceLat =
                                      sortedDocs[index]["source-lat"];
                                  double sourceLng =
                                      sortedDocs[index]["source-lng"];
                                  double viaLat = sortedDocs[index]["via-lat"];
                                  double viaLng = sortedDocs[index]["via-lng"];
                                  double destinationLat =
                                      sortedDocs[index]["destination-lat"];
                                  double destinationLng =
                                      sortedDocs[index]["destination-lng"];
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
