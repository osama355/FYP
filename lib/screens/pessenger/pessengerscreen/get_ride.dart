// ignore_for_file: non_constant_identifier_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_sharing_app/screens/pessenger/pessengerscreen/pessenger_sidebar.dart';
import 'package:drive_sharing_app/screens/pessenger/pessengerscreen/see_complete_ride_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GetRide extends StatefulWidget {
  const GetRide({super.key});

  @override
  State<GetRide> createState() => _GetRideState();
}

class _GetRideState extends State<GetRide> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference rides = FirebaseFirestore.instance.collection('rides');
    return Scaffold(
      drawer: const PessengerSidebar(),
      appBar: AppBar(
        backgroundColor: const Color(0xff4BA0FE),
        title: const Text("All Rides"),
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
                                      ? Image.network(snapshot.data!.docs[index]
                                          ['profile_url'])
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
                            size: 10.0,
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
                            onPressed: () {
                              String ride_id = snapshot.data!.docs[index].id;
                              String profile_url =
                                  snapshot.data!.docs[index]['profile_url'];
                              String driver_token =
                                  snapshot.data!.docs[index]['driver_token'];
                              String driver_name =
                                  snapshot.data!.docs[index]['driver-name'];
                              String driver_id =
                                  snapshot.data!.docs[index]['driver-id'];
                              String car_name =
                                  snapshot.data!.docs[index]['car_name'];
                              String car_model =
                                  snapshot.data!.docs[index]['car_model'];
                              String car_number =
                                  snapshot.data!.docs[index]['car-number'];
                              String source =
                                  snapshot.data!.docs[index]['source'];
                              String via =
                                  snapshot.data!.docs[index]['via-route'];
                              String destination =
                                  snapshot.data!.docs[index]['destination'];
                              String date = snapshot.data!.docs[index]['date'];
                              String time = snapshot.data!.docs[index]['time'];
                              String phone =
                                  snapshot.data!.docs[index]['phone'];
                              String seats =
                                  snapshot.data!.docs[index]['require-pess'];
                              double source_lat =
                                  snapshot.data!.docs[index]['source-lat'];
                              double source_lng =
                                  snapshot.data!.docs[index]['source-lng'];
                              double via_lat =
                                  snapshot.data!.docs[index]['via-lat'];
                              double via_lng =
                                  snapshot.data!.docs[index]['via-lng'];
                              double destination_lat =
                                  snapshot.data!.docs[index]['destination-lat'];
                              double destination_lng =
                                  snapshot.data!.docs[index]['destination-lng'];

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SeeCompleteRideInfo(
                                          driver_token: driver_token,
                                          driver_id: driver_id,
                                          ride_id: ride_id,
                                          seats: seats,
                                          phone: phone,
                                          profile_url: profile_url,
                                          driver_name: driver_name,
                                          car_name: car_name,
                                          car_model: car_model,
                                          car_number: car_number,
                                          source: source,
                                          via: via,
                                          destination: destination,
                                          date: date,
                                          time: time,
                                          source_lat: source_lat,
                                          source_lng: source_lng,
                                          via_lat: via_lat,
                                          via_lng: via_lng,
                                          destination_lat: destination_lat,
                                          destination_lng: destination_lng)));
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
            },
          );
        },
      ),
    );
  }
}
