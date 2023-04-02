import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages, unused_import
import 'package:intl/intl.dart' show DateFormat;

class DriverHistory extends StatefulWidget {
  const DriverHistory({super.key});

  @override
  State<DriverHistory> createState() => _DriverHistoryState();
}

class _DriverHistoryState extends State<DriverHistory> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final user = auth.currentUser;
    final CollectionReference historyCollection =
        FirebaseFirestore.instance.collection('rides');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff4BA0FE),
        title: const Text("History"),
      ),
      body: StreamBuilder(
        stream: historyCollection
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

          final now = DateTime.now();
          final sortedDocs = snapshot.data!.docs.where((doc) {
            final rideDate = DateFormat('dd-MM-yyyy').parse(doc['date']);
            final rideDateTime =
                DateTime(rideDate.year, rideDate.month, rideDate.day);
            final rideStatus = doc['status'];
            return rideDateTime
                        .isAfter(now.subtract(const Duration(days: 1))) &&
                    rideStatus == 'cancel' ||
                rideStatus == 'completed';
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
            return const Center(child: Text("No history yet"));
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
                            SizedBox(
                              width: 120,
                              child: ElevatedButton.icon(
                                  onPressed: () async {
                                    await firestore
                                        .collection('rides')
                                        .doc(sortedDocs[index].id)
                                        .update({'status': 'stop'});
                                  },
                                  icon: const Icon(Icons.create),
                                  label: const Text("Recreate")),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            SizedBox(
                              width: 120,
                              child: ElevatedButton.icon(
                                  onPressed: () {
                                    firestore.runTransaction(
                                        (Transaction transaction) async {
                                      transaction.delete(
                                          snapshot.data!.docs[index].reference);
                                    });
                                  },
                                  icon: const Icon(Icons.cancel),
                                  label: const Text("Remove",
                                      style: TextStyle(fontSize: 12))),
                            )
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
