import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: depend_on_referenced_packages, unused_import
import 'package:intl/intl.dart' show DateFormat;

class PreviousRequests extends StatefulWidget {
  const PreviousRequests({super.key});

  @override
  State<PreviousRequests> createState() => _PreviousRequestsState();
}

class _PreviousRequestsState extends State<PreviousRequests> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final user = auth.currentUser;
    final CollectionReference requestCollection =
        FirebaseFirestore.instance.collection('requests');

    return Scaffold(
      body: StreamBuilder(
        stream: requestCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Something went wrong");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Text("Loading..."));
          }
          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No Request yet"),
            );
          }

          final now = DateTime.now();
          final sortedDocs = snapshot.data!.docs.where((doc) {
            final rideDate = DateFormat('dd-MM-yyyy').parse(doc['date']);
            final rideDateTime =
                DateTime(rideDate.year, rideDate.month, rideDate.day);
            final reqStatus = doc['request_status'];
            if (reqStatus == 'Accepted' || reqStatus == 'Cancel') {
              return rideDateTime
                  .isBefore(now.subtract(const Duration(days: 1)));
            }
            return false;
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
            return const Center(
              child: Text('No Request Found'),
            );
          }

          return ListView.builder(
            itemCount: sortedDocs.length,
            itemBuilder: (context, index) {
              if (sortedDocs[index]['pass_id'] == user?.uid) {
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
                          children: [
                            CircleAvatar(
                                backgroundColor: sortedDocs[index]
                                            ['driver_profile_url'] !=
                                        ""
                                    ? Colors.transparent
                                    : const Color(0xff4BA0FE),
                                child: SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: ClipOval(
                                    child: sortedDocs[index]
                                                ['driver_profile_url'] !=
                                            ""
                                        ? Image.network(sortedDocs[index]
                                            ['driver_profile_url'])
                                        : const Icon(
                                            Icons.person,
                                            color: Colors.white,
                                          ),
                                  ),
                                )),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              sortedDocs[index]['driver_name'],
                              style: const TextStyle(fontSize: 13),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.circle,
                              color: Colors.green,
                              size: 10,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Start : ${sortedDocs[index]['driver_source']}',
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
                              color: Colors.blue,
                              size: 10.0,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Via : ${sortedDocs[index]['driver_via']}',
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
                              color: Colors.red,
                              size: 10.0,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Destination : ${sortedDocs[index]['driver_destination']}',
                              style: const TextStyle(fontSize: 13),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Text(
                              "Time : ${sortedDocs[index]['date']} at ${sortedDocs[index]['time']}",
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Text(
                              'Car : ${sortedDocs[index]['car_name']} | ${sortedDocs[index]['car_model']}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            MaterialButton(
                              onPressed: () {
                                if (sortedDocs[index]['request_status'] ==
                                    "Accepted") {
                                  // Navigator.push(context,route)
                                }
                              },
                              height: 30.0,
                              minWidth: 60.0,
                              color: sortedDocs[index]['request_status'] ==
                                      'Cancel'
                                  ? Colors.red
                                  : const Color(0xff4BA0FE),
                              textColor: Colors.white,
                              child: Text(
                                '${sortedDocs[index]['request_status']}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            MaterialButton(
                              onPressed: () {
                                firestore.runTransaction(
                                    (Transaction transaction) async {
                                  transaction
                                      .delete(sortedDocs[index].reference);
                                });
                              },
                              height: 30.0,
                              minWidth: 60.0,
                              color: const Color(0xff4BA0FE),
                              textColor: Colors.white,
                              child: const Text(
                                "Delete Request",
                                style: TextStyle(fontSize: 13),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return const SizedBox(
                  height: 0,
                );
              }
            },
          );
        },
      ),
    );
  }
}
