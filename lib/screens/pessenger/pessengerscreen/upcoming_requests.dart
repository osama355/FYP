// ignore_for_file: non_constant_identifier_names
import 'dart:convert';
import 'package:drive_sharing_app/screens/pessenger/pessengerscreen/join_ride.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: depend_on_referenced_packages, unused_import
import 'package:intl/intl.dart' show DateFormat;
import 'package:http/http.dart' as http;
import '../../../utils/utils.dart';

class UpcomingRequests extends StatefulWidget {
  const UpcomingRequests({super.key});

  @override
  State<UpcomingRequests> createState() => _UpcomingRequestsState();
}

class _UpcomingRequestsState extends State<UpcomingRequests> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  sendNotification1(String title, String token, String passName, String source,
      String destination) async {
    final data = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'id': 1,
      'status': 'done',
      'message': title
    };
    try {
      http.Response response =
          await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: <String, String>{
                'Content-Type': 'application/json',
                'Authorization':
                    'key=AAAADnkker0:APA91bEJO2ufASuDfJNV6yaKiiAES-O0X-jkQW2UL1ciN8hVCgXkCKSsKAQ4jO_7UNUzwrwVAC0iX3Ihu4xvLwsJifoYkVzo1QbYMyJyBXNj4_5f-S39WR9AI2QsYGzBc_jz5myyY5re'
              },
              body: jsonEncode(<String, dynamic>{
                'notification': <String, dynamic>{
                  'title': title,
                  'body':
                      '$passName has canceled his seat from $source to $destination'
                },
                'priority': 'high',
                'data': data,
                'to': token
              }));

      if (response.statusCode == 200) {
        Utils().toastMessage("Notification has been send");
      } else {
        Utils().toastMessage("Somethin went wrong");
      }
    } catch (e) {
      Utils().toastMessage(e.toString());
    }
  }

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
              child: Text("No Upcoming Ride Yet"),
            );
          }

          final now = DateTime.now();
          final sortedDocs = snapshot.data!.docs.where((doc) {
            final rideDate = DateFormat('dd-MM-yyyy').parse(doc['date']);
            final rideDateTime =
                DateTime(rideDate.year, rideDate.month, rideDate.day);
            final reqStatus = doc['request_status'];
            final rideStatus = doc['ride_status'];
            final pass_id = doc['pass_id'];
            if (pass_id == user?.uid) {
              if (reqStatus == 'Accepted' || reqStatus == 'Cancel') {
                if (rideStatus == 'Stop' || rideStatus == 'Start') {
                  return rideDateTime
                      .isAfter(now.subtract(const Duration(days: 1)));
                }
                return false;
              }
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
              child: Text('No Upcoming Rides'),
            );
          }

          return ListView.builder(
            itemCount: sortedDocs.length,
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
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                sortedDocs[index]['driver_profile_url'] != ""
                                    ? Colors.transparent
                                    : const Color(0xff4BA0FE),
                            child: SizedBox(
                              width: 60,
                              height: 60,
                              child: ClipOval(
                                child: sortedDocs[index]
                                            ['driver_profile_url'] !=
                                        ""
                                    ? Image.network(
                                        sortedDocs[index]['driver_profile_url'])
                                    : const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              sortedDocs[index]['driver_name'],
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: sortedDocs[index]['ride_status'] ==
                                          'Start' &&
                                      sortedDocs[index]['request_status'] !=
                                          'Cancel'
                                  ? () async {
                                      String driver_id =
                                          sortedDocs[index]['driver_id'];
                                      String driver_name =
                                          sortedDocs[index]['driver_name'];
                                      String driver_source =
                                          sortedDocs[index]['driver_source'];
                                      double driver_source_lat =
                                          sortedDocs[index]
                                              ['driver_source_lat'];
                                      double driver_source_lng =
                                          sortedDocs[index]
                                              ['driver_source_lng'];
                                      String driver_via =
                                          sortedDocs[index]['driver_via'];
                                      double driver_via_lat =
                                          sortedDocs[index]['driver_via_lat'];
                                      double driver_via_lng =
                                          sortedDocs[index]['driver_via_lng'];
                                      String driver_destination =
                                          sortedDocs[index]
                                              ['driver_destination'];
                                      double driver_destination_lat =
                                          sortedDocs[index]
                                              ['driver_destination_lat'];
                                      double driver_destination_lng =
                                          sortedDocs[index]
                                              ['driver_destination_lng'];

                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => JoinRide(
                                                    driver_name: driver_name,
                                                    driver_id: driver_id,
                                                    driver_source:
                                                        driver_source,
                                                    driver_source_lat:
                                                        driver_source_lat,
                                                    driver_source_lng:
                                                        driver_source_lng,
                                                    driver_via: driver_via,
                                                    driver_via_lat:
                                                        driver_via_lat,
                                                    driver_via_lng:
                                                        driver_via_lng,
                                                    driver_destination:
                                                        driver_destination,
                                                    driver_destination_lat:
                                                        driver_destination_lat,
                                                    driver_destination_lng:
                                                        driver_destination_lng,
                                                  )));
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: sortedDocs[index]
                                                ['ride_status'] ==
                                            'Start' &&
                                        sortedDocs[index]['request_status'] !=
                                            'Cancel'
                                    ? const Color(0xff4BA0FE)
                                    : Colors.grey[300],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                "Join",
                                style: TextStyle(
                                    color: sortedDocs[index]['ride_status'] ==
                                                'Start' &&
                                            sortedDocs[index]
                                                    ['request_status'] !=
                                                'Cancel'
                                        ? Colors.white
                                        : Colors.grey),
                              ),
                            ),
                          ),
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
                          Text(
                            '${sortedDocs[index]['request_status']}',
                            style: TextStyle(
                                fontSize: 13,
                                color: sortedDocs[index]['request_status'] ==
                                        "Cancel"
                                    ? Colors.red
                                    : const Color(0xff4BA0FE)),
                          ),
                          MaterialButton(
                            onPressed: sortedDocs[index]['request_status'] ==
                                    'Cancel'
                                ? () async {
                                    await firestore.runTransaction(
                                        (Transaction transaction) async {
                                      transaction
                                          .delete(sortedDocs[index].reference);
                                    });
                                  }
                                : () async {
                                    var requestedDriverDoc = await firestore
                                        .collection('app')
                                        .doc('user')
                                        .collection('driver')
                                        .doc(sortedDocs[index]['driver_id'])
                                        .get();

                                    final remainSeats = await firestore
                                        .collection('rides')
                                        .doc(sortedDocs[index]['ride_id'])
                                        .get();
                                    String driverToken =
                                        await requestedDriverDoc.get('token');

                                    await firestore
                                        .collection('requests')
                                        .doc(sortedDocs[index].id)
                                        .update({'request_status': "Cancel"});
                                    await firestore
                                        .collection('rides')
                                        .doc(sortedDocs[index]['ride_id'])
                                        .update({
                                      'reservedSeats':
                                          remainSeats.data()?['reservedSeats'] -
                                              1
                                    });
                                    sendNotification1(
                                        'Cancel',
                                        driverToken,
                                        sortedDocs[index]['pass_name'],
                                        sortedDocs[index]['pass_pickup'],
                                        sortedDocs[index]['pass_dest']);
                                  },
                            height: 30.0,
                            minWidth: 60.0,
                            color: const Color(0xff4BA0FE),
                            textColor: Colors.white,
                            child: Text(
                              sortedDocs[index]['request_status'] == "Cancel"
                                  ? "Delete Request"
                                  : "Cancle Request",
                              style: const TextStyle(fontSize: 13),
                            ),
                          )
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
