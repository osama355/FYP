// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_sharing_app/screens/driver/driverscreens/driver_sidebar.dart';
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
  bool isPressed = true;

  @override
  void initState() {
    super.initState();
  }

  sendNotification1(String title, String token) async {
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
                  'body': 'Request has been accepted'
                },
                'priority': 'high',
                'data': data,
                'to': token
              }));

      if (response.statusCode == 200) {
        print("Notification has been send");
      } else {
        print("Something wrong");
        print('Token >>>>> $token');
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  sendNotification2(String title, String token) async {
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
                  'body': 'Request has been rejected'
                },
                'priority': 'high',
                'data': data,
                'to': token
              }));

      if (response.statusCode == 200) {
        print("Notification has been send");
      } else {
        print("Something wrong");
        print('Token >>>>> $token');
      }
      // ignore: empty_catches
    } catch (e) {}
  }

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
                                '${snapshot.data!.docs[index]['date']}${snapshot.data!.docs[index]['time']}',
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
                                  onPressed: snapshot.data!.docs[index]
                                              ['request_Status'] ==
                                          'Pending'
                                      ? () {
                                          String token = snapshot
                                              .data!.docs[index]['pass_token'];
                                          sendNotification1('Request', token);
                                          firestore
                                              .collection('requests')
                                              .doc(
                                                  snapshot.data!.docs[index].id)
                                              .update({
                                            'request_Status': "Accepted"
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
                                  onPressed: () {
                                    String token = snapshot.data!.docs[index]
                                        ['pass_token'];
                                    sendNotification2('Request', token);
                                    firestore
                                        .collection('requests')
                                        .doc(snapshot.data!.docs[index].id)
                                        .delete()
                                        .then((value) {
                                      Utils().toastMessage("You Reject Ride");
                                    });
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
