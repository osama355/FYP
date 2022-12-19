import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_sharing_app/screens/driver/driverscreens/driver_sidebar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DriverRequests extends StatefulWidget {
  const DriverRequests({super.key});

  @override
  State<DriverRequests> createState() => _DriverRequestsState();
}

class _DriverRequestsState extends State<DriverRequests> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List requests = [];

  @override
  Widget build(BuildContext context) {
    final user = auth.currentUser;
    final CollectionReference requestCollection =
        FirebaseFirestore.instance.collection('requests');

    return Scaffold(
        drawer: const DriverSidebar(),
        appBar: AppBar(
          title: const Text("My Request"),
        ),
        body: StreamBuilder(
          stream: requestCollection.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text("Something went wrong");
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Loading...");
            }
            if (snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text("No Request yet"),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                if (snapshot.data!.docs[index]['driver_id'] == user?.uid) {
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
                                    "Name : ",
                                    style: TextStyle(fontSize: 13),
                                  ),
                                  Text(
                                    snapshot.data!.docs[index]
                                        ['pessenger_name'],
                                    style: const TextStyle(fontSize: 13),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  const Text(
                                    "Phone : ",
                                    style: TextStyle(fontSize: 13),
                                  ),
                                  Text(
                                    snapshot.data!.docs[index]
                                        ['pessenger_phone_no'],
                                    style: const TextStyle(fontSize: 13),
                                  ),
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
                                "Pickup : ",
                                style: TextStyle(fontSize: 13),
                              ),
                              Text(
                                snapshot.data!.docs[index]
                                    ['pessenger_pickup_loc'],
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
                                "Destination : ",
                                style: TextStyle(fontSize: 13),
                              ),
                              Text(
                                snapshot.data!.docs[index]
                                    ['pessenger_destination'],
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
                                "Time : ",
                                style: TextStyle(fontSize: 13),
                              ),
                              Text(
                                '${snapshot.data!.docs[index]['pessenger_date']}${snapshot.data!.docs[index]['pessenger_time']}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              ElevatedButton(
                                  onPressed: () {
                                    firestore
                                        .collection('requests')
                                        .doc(snapshot.data!.docs[index].id)
                                        .update({'request_Status': "Accepted"});
                                  },
                                  child: const Text(
                                    "Accept",
                                    style: TextStyle(fontSize: 12),
                                  )),
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
                                        .collection('requests')
                                        .doc(snapshot.data!.docs[index].id)
                                        .delete();
                                  },
                                  child: const Text("Reject",
                                      style: TextStyle(fontSize: 12)))
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
        ));
  }
}
