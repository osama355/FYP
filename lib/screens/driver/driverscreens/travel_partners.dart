import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TravelPartners extends StatefulWidget {
  final String rideId; //prop from my_ride.dart
  const TravelPartners({super.key, required this.rideId});

  @override
  State<TravelPartners> createState() => _TravelPartnersState();
}

class _TravelPartnersState extends State<TravelPartners> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  final CollectionReference requestCollection =
      FirebaseFirestore.instance.collection('requests');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = auth.currentUser;

    return Scaffold(
        appBar: AppBar(
          title: const Text("Ride Partners"),
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
                child: Text("No ride created yet"),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                if (snapshot.data!.docs[index]['driver_id'] == user?.uid) {
                  if (snapshot.data!.docs[index]['request_Status'] ==
                      "Accepted") {
                    if (snapshot.data!.docs[index]['ride_id'] ==
                        widget.rideId) {
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
                                    offset: const Offset(0, 3)),
                              ]),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  ClipOval(
                                    child: snapshot.data!.docs[index]
                                                ['pass_profile_url'] !=
                                            ""
                                        ? Image.network(
                                            snapshot.data!.docs[index]
                                                ['pass_profile_url'],
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover)
                                        : Container(
                                            width: 60,
                                            height: 60,
                                            decoration: const BoxDecoration(
                                                color: Color(0xff4BA0FE)),
                                            child: const Icon(
                                              Icons.person,
                                              size: 40,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    snapshot.data!.docs[index]['pass_name'],
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.phone,
                                    color: Color(0xff4BA0FE),
                                    size: 15,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    snapshot.data!.docs[index]['pass_phone'],
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
                                    'Pickup : ${snapshot.data!.docs[index]['pass_pickup']}',
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
                                    color: Colors.red,
                                    size: 10.0,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    'Drop : ${snapshot.data!.docs[index]['pass_dest']}',
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
                                    '${snapshot.data!.docs[index]['date']}  ${snapshot.data!.docs[index]['time']}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  }
                }
                return const SizedBox(
                  height: 0,
                );
              },
            );
          },
        ));
  }
}
