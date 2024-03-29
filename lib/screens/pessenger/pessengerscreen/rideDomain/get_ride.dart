import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_sharing_app/screens/driver/driverscreens/review/average_review.dart';
import 'package:drive_sharing_app/screens/pessenger/pessengerscreen/rideDomain/see_complete_ride_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart' show DateFormat;

class GetRide extends StatefulWidget {
  const GetRide({super.key});

  @override
  State<GetRide> createState() => _GetRideState();
}

class _GetRideState extends State<GetRide> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  int rating = 2;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference rides = FirebaseFirestore.instance.collection('rides');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff4BA0FE),
        automaticallyImplyLeading: true,
        title: const Text("All Rides"),
      ),
      body: StreamBuilder(
        stream: rides.orderBy('date').orderBy('time').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Something went wrong");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No ride Available'),
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
                rideStatus == 'stop';
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
            return const Center(child: Text("No Ride Available Yet"));
          }

          return ListView.builder(
            // itemCount: snapshot.data?.docs.length,
            itemCount: sortedDocs.length,
            itemBuilder: (context, index) {
              int availableSeats = sortedDocs[index]['require-pess'] -
                  sortedDocs[index]['reservedSeats'];
              final time = DateFormat('HH:mm')
                  .format(DateFormat.jm().parse(sortedDocs[index]['time']));

              String driverId = sortedDocs[index]['driver-id'];

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
                              CircleAvatar(
                                  backgroundColor:
                                      sortedDocs[index]['profile_url'] != ""
                                          ? Colors.transparent
                                          : const Color(0xff4BA0FE),
                                  child: SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: ClipOval(
                                      child: sortedDocs[index]['profile_url'] !=
                                              ""
                                          ? Image.network(
                                              sortedDocs[index]['profile_url'])
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
                                sortedDocs[index]['driver-name'],
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                          AverageRating(driverId: driverId)
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
                            'Start : ${sortedDocs[index]['source']}',
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
                            'Via : ${sortedDocs[index]['via-route']}',
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
                            'Destination : ${sortedDocs[index]['destination']}',
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
                            "Time : ${sortedDocs[index]['date']} at $time",
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
                            'Car : ${sortedDocs[index]['car_name']} | ${snapshot.data!.docs[index]['car_model']}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              'Total seats : ${sortedDocs[index]['require-pess']}'),
                          availableSeats <= 0
                              ? const Text('Available : 0')
                              : Text('Available : $availableSeats'),
                          MaterialButton(
                            onPressed: availableSeats == 0
                                ? () {}
                                : () {
                                    String rideId = sortedDocs[index].id;
                                    String profileUrl =
                                        sortedDocs[index]['profile_url'];
                                    String driverToken =
                                        sortedDocs[index]['driver_token'];
                                    String driverName =
                                        sortedDocs[index]['driver-name'];
                                    String driverId =
                                        sortedDocs[index]['driver-id'];
                                    String carName =
                                        sortedDocs[index]['car_name'];
                                    String carModel =
                                        sortedDocs[index]['car_model'];
                                    String carNumber =
                                        sortedDocs[index]['car-number'];
                                    String source = sortedDocs[index]['source'];
                                    String via = sortedDocs[index]['via-route'];
                                    String destination =
                                        sortedDocs[index]['destination'];
                                    String date = sortedDocs[index]['date'];
                                    String time = sortedDocs[index]['time'];
                                    String phone = sortedDocs[index]['phone'];
                                    String seats = sortedDocs[index]
                                            ['require-pess']
                                        .toString();
                                    String price = sortedDocs[index]['price'];
                                    double sourceLat =
                                        sortedDocs[index]['source-lat'];
                                    double sourceLng =
                                        sortedDocs[index]['source-lng'];
                                    double viaLat =
                                        sortedDocs[index]['via-lat'];
                                    double viaLng =
                                        sortedDocs[index]['via-lng'];
                                    double destinationLat =
                                        sortedDocs[index]['destination-lat'];
                                    double destinationLng =
                                        sortedDocs[index]['destination-lng'];
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SeeCompleteRideInfo(
                                                    driver_token: driverToken,
                                                    driver_id: driverId,
                                                    ride_id: rideId,
                                                    seats: seats,
                                                    phone: phone,
                                                    price: price,
                                                    profile_url: profileUrl,
                                                    driver_name: driverName,
                                                    car_name: carName,
                                                    car_model: carModel,
                                                    car_number: carNumber,
                                                    source: source,
                                                    via: via,
                                                    destination: destination,
                                                    date: date,
                                                    time: time,
                                                    source_lat: sourceLat,
                                                    source_lng: sourceLng,
                                                    via_lat: viaLat,
                                                    via_lng: viaLng,
                                                    destination_lat:
                                                        destinationLat,
                                                    destination_lng:
                                                        destinationLng)));
                                  },
                            height: 30.0,
                            minWidth: 60.0,
                            color: availableSeats == 0
                                ? Colors.red
                                : const Color(0xff4BA0FE),
                            textColor: Colors.white,
                            child: Text(
                              availableSeats == 0
                                  ? 'No Seat Available'
                                  : "Request",
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
