// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_sharing_app/screens/driver/driverscreens/googlemap/driver_map_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../utils/utils.dart';
import 'package:http/http.dart' as http;

class TravelPartners extends StatefulWidget {
  //prop from my_ride.dart
  final double? startPositionLat;
  final double? startPositionLng;
  final double? midPositionLat;
  final double? midPositionLng;
  final double? endPositionLat;
  final double? endPositionLng;
  final String rideId;

  const TravelPartners(
      {super.key,
      required this.rideId,
      required this.startPositionLat,
      required this.startPositionLng,
      required this.midPositionLat,
      required this.midPositionLng,
      required this.endPositionLat,
      required this.endPositionLng});

  @override
  State<TravelPartners> createState() => _TravelPartnersState();
}

class _TravelPartnersState extends State<TravelPartners> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late bool isAccept;

  sendNotification1(
      String title, String token, String source, String destination) async {
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
                      'Your ride from $source to $destination hase been started'
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = auth.currentUser;
    final CollectionReference requestCollection =
        FirebaseFirestore.instance.collection('requests');
    List<String> requestIds = [];

    return Scaffold(
        appBar: AppBar(
          title: const Text("Partners"),
          backgroundColor: const Color(0xff4BA0FE),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: StreamBuilder(
                stream: requestCollection.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text("Something went wrong");
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text("No Request Yet"),
                    );
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      if (snapshot.data!.docs[index]['driver_id'] ==
                          user?.uid) {
                        if (snapshot.data!.docs[index]['request_status'] ==
                            "Accepted") {
                          if (snapshot.data!.docs[index]['ride_id'] ==
                              widget.rideId) {
                            String requestId = snapshot.data!.docs[index].id;
                            requestIds.add(requestId);

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
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: Color(
                                                              0xff4BA0FE)),
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
                                          snapshot.data!.docs[index]
                                              ['pass_name'],
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
                                          snapshot.data!.docs[index]
                                              ['pass_phone'],
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
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xff4BA0FE),
              ),
              height: 60,
              width: double.infinity,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(const Color(0xff4BA0FE)),
                ),
                onPressed: () async {
                  try {
                    await firestore
                        .collection('rides')
                        .doc(widget.rideId)
                        .update({'status': 'start'});

                    ///for request collection
                    await requestCollection
                        .where('ride_id', isEqualTo: widget.rideId)
                        .get()
                        .then((snapshot) async {
                      for (var doc in snapshot.docs) {
                        requestCollection
                            .doc(doc.id)
                            .update({'ride_status': 'Start'});
                        var requestedDoc =
                            await requestCollection.doc(doc.id).get();
                        String passToken = requestedDoc.get('pass_token');
                        String passPickup = requestedDoc.get('pass_pickup');
                        String passDest = requestedDoc.get('pass_dest');
                        sendNotification1(
                            'Ride', passToken, passPickup, passDest);
                      }
                    }).then((value) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DriverMapScreen(
                                    rideId: widget.rideId,
                                    startPositionLat: widget.startPositionLat,
                                    startPositionLng: widget.startPositionLng,
                                    midPositionLat: widget.midPositionLat,
                                    midPositionLng: widget.midPositionLng,
                                    endPositionLat: widget.endPositionLat,
                                    endPositionLng: widget.endPositionLng,
                                  )));
                    });
                  } catch (e) {
                    print(e);
                  }
                },
                child: const Text(
                  "Start Ride",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ],
        ));
  }
}
