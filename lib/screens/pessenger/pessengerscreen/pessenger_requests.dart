import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_sharing_app/screens/pessenger/pessengerscreen/pessenger_sidebar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PassengerRequests extends StatefulWidget {
  const PassengerRequests({super.key});

  @override
  State<PassengerRequests> createState() => _PassengerRequestsState();
}

class _PassengerRequestsState extends State<PassengerRequests> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final user = auth.currentUser;
    final CollectionReference requestCollection =
        FirebaseFirestore.instance.collection('requests');

    return Scaffold(
      drawer: const PessengerSidebar(),
      appBar: AppBar(
        title: const Text('Requests'),
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
              if (snapshot.data!.docs[index]['pessenger_id'] == user?.uid) {
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
                                backgroundColor: snapshot.data!.docs[index]
                                            ['profile_url'] !=
                                        ""
                                    ? Colors.transparent
                                    : const Color(0xff4BA0FE),
                                child: SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: ClipOval(
                                    child: snapshot.data!.docs[index]
                                                ['profile_url'] !=
                                            ""
                                        ? Image.network(snapshot
                                            .data!.docs[index]['profile_url'])
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
                              snapshot.data!.docs[index]['driver_name'],
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
                              snapshot.data!.docs[index]['drvier_source'],
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
                              snapshot.data!.docs[index]['driver_via'],
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
                              snapshot.data!.docs[index]['driver_Destination'],
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
                              "Time : ${snapshot.data!.docs[index]['driver_date']} at ${snapshot.data!.docs[index]['driver_time']}",
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
                              'Car : ${snapshot.data!.docs[index]['car_name']} | ${snapshot.data!.docs[index]['car_model']}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            MaterialButton(
                              onPressed: () {
                                firestore
                                    .collection('requests')
                                    .doc(snapshot.data!.docs[index].id)
                                    .update({
                                  'request_Status': "Pending",
                                });
                              },
                              height: 30.0,
                              minWidth: 60.0,
                              color: const Color(0xff4BA0FE),
                              textColor: Colors.white,
                              child: Text(
                                '${snapshot.data!.docs[index]['request_Status']}',
                                style: const TextStyle(fontSize: 13),
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
