import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_sharing_app/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DriverRequests extends StatefulWidget {
  const DriverRequests({super.key});

  @override
  State<DriverRequests> createState() => _DriverRequestsState();
}

class _DriverRequestsState extends State<DriverRequests> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List requests = [];
  late bool isAccept;
  late int reservedSeats;

  @override
  void initState() {
    super.initState();
  }

  sendNotification1(String title, String token, String driverName) async {
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
                  'body': isAccept
                      ? "Request has been accepted $driverName"
                      : "Request has been rejected $driverName"
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
        appBar: AppBar(
          title: const Text("My Request"),
          backgroundColor: const Color(0xff4BA0FE),
        ),
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

            final pendingRequest = snapshot.data!.docs.where((doc) {
              return doc.get('request_status') == 'Pending';
            }).toList();

            if (pendingRequest.isEmpty) {
              return const Center(child: Text("No Request yet"));
            }

            return ListView.builder(
              itemCount: pendingRequest.length,
              itemBuilder: (context, index) {
                if (pendingRequest[index]['driver_id'] == user?.uid) {
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
                              ClipOval(
                                child: pendingRequest[index]
                                            ['pass_profile_url'] !=
                                        ""
                                    ? Image.network(
                                        pendingRequest[index]
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
                                pendingRequest[index]['pass_name'],
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
                                pendingRequest[index]['pass_phone'],
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
                                'Pickup : ${pendingRequest[index]['pass_pickup']}',
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
                                'Drop : ${pendingRequest[index]['pass_dest']}',
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
                                '${pendingRequest[index]['date']}  ${snapshot.data!.docs[index]['time']}',
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
                                  onPressed: pendingRequest[index]
                                              ['request_status'] ==
                                          'Pending'
                                      ? () async {
                                          isAccept = true;
                                          String token = pendingRequest[index]
                                              ['pass_token'];
                                          String driverName =
                                              pendingRequest[index]
                                                  ['driver_name'];
                                          final remainSeats = await firestore
                                              .collection('rides')
                                              .doc(pendingRequest[index]
                                                  ['ride_id'])
                                              .get();

                                          sendNotification1(
                                              'Request', token, driverName);
                                          firestore
                                              .collection('requests')
                                              .doc(pendingRequest[index].id)
                                              .update({
                                            'request_status': "Accepted"
                                          });
                                          firestore
                                              .collection('rides')
                                              .doc(pendingRequest[index]
                                                  ['ride_id'])
                                              .update({
                                            'reservedSeats': remainSeats
                                                    .data()?['reservedSeats'] +
                                                1
                                          });
                                        }
                                      : null,
                                  child: const Text(
                                    "Accept",
                                    style: TextStyle(fontSize: 12),
                                  )),
                              const SizedBox(
                                width: 5,
                              ),
                              ElevatedButton(
                                  onPressed: pendingRequest[index]
                                              ['request_status'] ==
                                          'Pending'
                                      ? () {
                                          isAccept = false;
                                          String token = pendingRequest[index]
                                              ['pass_token'];
                                          String driverName =
                                              pendingRequest[index]
                                                  ['driver_name'];

                                          sendNotification1(
                                              'Request', token, driverName);
                                          firestore
                                              .collection('requests')
                                              .doc(pendingRequest[index].id)
                                              .update({
                                            'request_status': "Rejected"
                                          });
                                        }
                                      : pendingRequest[index]
                                                  ['request_status'] ==
                                              "Rejected"
                                          ? () {
                                              firestore.runTransaction(
                                                  (Transaction
                                                      transaction) async {
                                                transaction.delete(
                                                    pendingRequest[index]
                                                        .reference);
                                              });
                                            }
                                          : null,
                                  child: Text(
                                      pendingRequest[index]['request_status'] ==
                                                  'Pending' ||
                                              pendingRequest[index]
                                                      ['request_status'] ==
                                                  "Accepted"
                                          ? "Reject"
                                          : "Delete",
                                      style: const TextStyle(fontSize: 12)))
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
