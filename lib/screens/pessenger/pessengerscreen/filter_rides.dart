import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_sharing_app/screens/pessenger/pessengerscreen/pessenger_requests.dart';
import 'package:drive_sharing_app/screens/pessenger/pessengerscreen/pessenger_sidebar.dart';
import 'package:drive_sharing_app/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FilterRides extends StatefulWidget {
  final String startSearchText;
  final String endSearchText;
  final String dateText;
  final String timeText;
  const FilterRides(
      {super.key,
      required this.startSearchText,
      required this.endSearchText,
      required this.dateText,
      required this.timeText});

  @override
  State<FilterRides> createState() => _FilterRidesState();
}

class _FilterRidesState extends State<FilterRides> {
  CollectionReference rides = FirebaseFirestore.instance.collection('rides');
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  var filterRides = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const PessengerSidebar(),
      appBar: AppBar(
        title: const Text("FIlter Rides"),
      ),
      body: StreamBuilder(
        stream: rides.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Something went wrong");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading");
          }
          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No ride Available'),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data?.docs.length,
            itemBuilder: (context, index) {
              if (snapshot.data!.docs[index]['destination'] ==
                      widget.endSearchText &&
                  snapshot.data!.docs[index]['date'] == widget.dateText) {
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
                              snapshot.data!.docs[index]['driver-name'],
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
                              color: Colors.blue,
                              size: 10.0,
                            ),
                            const SizedBox(
                              width: 5,
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
                              color: Colors.red,
                              size: 10.0,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              snapshot.data!.docs[index]['destination'],
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
                              "Time : ${snapshot.data!.docs[index]['date']} at ${snapshot.data!.docs[index]['time']}",
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
                            Text(
                                'Available seats : ${snapshot.data!.docs[index]['require-pess']}'),
                            MaterialButton(
                              onPressed: () async {
                                final user = auth.currentUser;
                                final time = DateTime.now();

                                final userData = await firestore
                                    .collection("app")
                                    .doc('user')
                                    .collection('pessenger')
                                    .doc(user?.uid)
                                    .get();

                                await firestore
                                    .collection('requests')
                                    .doc('${user?.uid}$time')
                                    .set({
                                  'pessenger_id': user?.uid,
                                  'ride_id': snapshot.data!.docs[index].id,
                                  'driver_id': snapshot.data!.docs[index]
                                      ['driver-id'],
                                  'driver_name': snapshot.data!.docs[index]
                                      ['driver-name'],
                                  'profile_url': snapshot.data!.docs[index]
                                      ['profile_url'],
                                  'drvier_source': snapshot.data!.docs[index]
                                      ['source'],
                                  'driver_via': snapshot.data!.docs[index]
                                      ['via-route'],
                                  'driver_Destination':
                                      snapshot.data!.docs[index]['destination'],
                                  'driver_date': snapshot.data!.docs[index]
                                      ['date'],
                                  'driver_time': snapshot.data!.docs[index]
                                      ['time'],
                                  'car_name': snapshot.data!.docs[index]
                                      ['car_name'],
                                  'car_model': snapshot.data!.docs[index]
                                      ['car_model'],
                                  'pessenger_name': userData.data()?['name'],
                                  'pessenger_phone_no':
                                      userData.data()?['phone'],
                                  'pessenger_pickup_loc':
                                      widget.startSearchText,
                                  'pessenger_destination': widget.endSearchText,
                                  'pessenger_date': widget.dateText,
                                  'pessenger_time': widget.timeText,
                                  'request_Status': 'pending'
                                }).then((value) {
                                  Utils().toastMessage(
                                      "Request Sent successfully");
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const PassengerRequests()));
                                });
                              },
                              height: 30.0,
                              minWidth: 60.0,
                              color: const Color(0xff4BA0FE),
                              textColor: Colors.white,
                              child: const Text(
                                "Request",
                                style: TextStyle(fontSize: 13),
                              ),
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
