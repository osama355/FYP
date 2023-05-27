import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_sharing_app/screens/driver/driverscreens/chat/see_reviews.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages, unused_import
import 'package:intl/intl.dart' show DateFormat;

class DriverHistory extends StatefulWidget {
  const DriverHistory({super.key});

  @override
  State<DriverHistory> createState() => _DriverHistoryState();
}

class _DriverHistoryState extends State<DriverHistory> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final seatController = TextEditingController();
  final priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final user = auth.currentUser;
    final CollectionReference historyCollection =
        FirebaseFirestore.instance.collection('rides');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff4BA0FE),
        title: const Text("History"),
      ),
      body: StreamBuilder(
        stream: historyCollection
            .orderBy('date')
            .orderBy(
              'time',
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Something went wrong");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Text("Loading..."));
          }
          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No ride created yet"),
            );
          }

          final sortedDocs = snapshot.data!.docs.where((doc) {
            final rideStatus = doc['status'];
            return rideStatus == 'cancel' || rideStatus == 'completed';
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
            return const Center(child: Text("No history yet"));
          }

          return ListView.builder(
            itemCount: sortedDocs.length,
            itemBuilder: (context, index) {
              if (sortedDocs[index]['driver-id'] == user?.uid) {
                final time = DateFormat('HH:mm')
                    .format(DateFormat.jm().parse(sortedDocs[index]['time']));
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
                            Text(
                              "Total Seats : ${sortedDocs[index]['require-pess']}",
                              style: const TextStyle(fontSize: 13),
                            ),
                            Text(
                              "Reserved Seats : ${sortedDocs[index]['reservedSeats']}",
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.circle,
                              size: 10.0,
                              color: Colors.green,
                            ),
                            const SizedBox(
                              width: 3,
                            ),
                            const Text(
                              "Start : ",
                              style: TextStyle(fontSize: 13),
                            ),
                            Text(
                              sortedDocs[index]['source'],
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
                              size: 10.0,
                              color: Colors.blue,
                            ),
                            const SizedBox(
                              width: 3,
                            ),
                            const Text(
                              "Via : ",
                              style: TextStyle(fontSize: 13),
                            ),
                            Text(
                              sortedDocs[index]['via-route'],
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
                              size: 10.0,
                              color: Colors.red,
                            ),
                            const SizedBox(
                              width: 3,
                            ),
                            const Text(
                              "Destination : ",
                              style: TextStyle(fontSize: 13),
                            ),
                            Text(
                              sortedDocs[index]['destination'],
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
                              "Date : ",
                              style: TextStyle(fontSize: 13),
                            ),
                            Text(
                              sortedDocs[index]['date'],
                              style: const TextStyle(fontSize: 13),
                            ),
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
                              time,
                              style: const TextStyle(fontSize: 13),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        ElevatedButtonTheme(
                            data: ElevatedButtonThemeData(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.blue),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                padding: MaterialStateProperty.all(
                                  const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 5.0),
                                ),
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    await showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                              title:
                                                  const Text('Recreate Ride'),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () async {
                                                      DateTime? datePicked =
                                                          await showDatePicker(
                                                              context: context,
                                                              initialDate:
                                                                  DateTime
                                                                      .now(),
                                                              firstDate:
                                                                  DateTime
                                                                      .now(),
                                                              lastDate:
                                                                  DateTime(
                                                                      2024));
                                                      if (datePicked != null) {
                                                        setState(() {
                                                          dateController.text =
                                                              '${datePicked.day}-${datePicked.month}-${datePicked.year}';
                                                        });
                                                      }
                                                    },
                                                    child: TextFormField(
                                                        controller:
                                                            dateController,
                                                        enabled: false,
                                                        showCursor: false,
                                                        decoration:
                                                            const InputDecoration(
                                                                contentPadding:
                                                                    EdgeInsets.only(
                                                                        top:
                                                                            15.0,
                                                                        bottom:
                                                                            15.0),
                                                                prefixIcon:
                                                                    Icon(
                                                                  Icons
                                                                      .date_range,
                                                                  color: Color(
                                                                      0xff4BA0FE),
                                                                  size: 20,
                                                                ),
                                                                filled: true,
                                                                fillColor:
                                                                    Colors
                                                                        .white,
                                                                hintText:
                                                                    'Select Date',
                                                                border:
                                                                    OutlineInputBorder())),
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  GestureDetector(
                                                    onTap: () async {
                                                      TimeOfDay? timePicked =
                                                          await showTimePicker(
                                                              context: context,
                                                              initialTime:
                                                                  TimeOfDay
                                                                      .now());
                                                      if (timePicked != null) {
                                                        String setTime =
                                                            "${timePicked.hour}:${timePicked.minute}:00";
                                                        setState(() {
                                                          timeController
                                                              .text = DateFormat
                                                                  .jm()
                                                              .format(DateFormat(
                                                                      "hh:mm:ss")
                                                                  .parse(
                                                                      setTime));
                                                        });
                                                      }
                                                    },
                                                    child: TextFormField(
                                                      controller:
                                                          timeController,
                                                      enabled: false,
                                                      showCursor: false,
                                                      decoration:
                                                          const InputDecoration(
                                                              contentPadding:
                                                                  EdgeInsets.only(
                                                                      top: 15.0,
                                                                      bottom:
                                                                          15.0),
                                                              prefixIcon: Icon(
                                                                Icons.timer,
                                                                color: Color(
                                                                    0xff4BA0FE),
                                                                size: 20,
                                                              ),
                                                              filled: true,
                                                              fillColor:
                                                                  Colors.white,
                                                              hintText:
                                                                  'Select Time',
                                                              border:
                                                                  OutlineInputBorder()),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  TextFormField(
                                                    controller: seatController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    decoration:
                                                        const InputDecoration(
                                                            contentPadding:
                                                                EdgeInsets.only(
                                                                    top: 15.0,
                                                                    bottom:
                                                                        15.0),
                                                            prefixIcon: Icon(
                                                              Icons
                                                                  .event_seat_sharp,
                                                              color: Color(
                                                                  0xff4BA0FE),
                                                              size: 20,
                                                            ),
                                                            filled: true,
                                                            fillColor:
                                                                Colors.white,
                                                            hintText:
                                                                'Required Seats',
                                                            border:
                                                                OutlineInputBorder()),
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  TextFormField(
                                                    controller: priceController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    decoration:
                                                        const InputDecoration(
                                                            contentPadding:
                                                                EdgeInsets.only(
                                                                    top: 15.0,
                                                                    bottom:
                                                                        15.0),
                                                            prefixIcon: Icon(
                                                              Icons
                                                                  .attach_money,
                                                              color: Color(
                                                                  0xff4BA0FE),
                                                              size: 20,
                                                            ),
                                                            filled: true,
                                                            fillColor:
                                                                Colors.white,
                                                            hintText:
                                                                'Price Per Seat',
                                                            border:
                                                                OutlineInputBorder()),
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('Cancel'),
                                                ),
                                                ElevatedButton(
                                                    onPressed: () async {
                                                      int totalSeats =
                                                          int.parse(
                                                              seatController
                                                                  .text);
                                                      if (dateController.text.isNotEmpty &&
                                                          timeController.text
                                                              .isNotEmpty &&
                                                          seatController.text
                                                              .isNotEmpty &&
                                                          priceController.text
                                                              .isNotEmpty) {
                                                        await firestore
                                                            .collection('rides')
                                                            .doc(sortedDocs[
                                                                    index]
                                                                .id)
                                                            .update({
                                                          'status': 'stop',
                                                          'date': dateController
                                                              .text,
                                                          'time': timeController
                                                              .text,
                                                          'price':
                                                              priceController
                                                                  .text,
                                                          'require-pess':
                                                              totalSeats,
                                                          'reservedSeats': 0
                                                        }).then((value) {
                                                          Navigator.of(context)
                                                              .pop();
                                                        });
                                                      }
                                                    },
                                                    child: const Text('Save'))
                                              ],
                                            ));
                                  },
                                  icon: const Icon(Icons.create),
                                  label: const Text('Recreate'),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    await firestore.runTransaction(
                                      (Transaction transaction) async {
                                        transaction.delete(
                                            sortedDocs[index].reference);
                                      },
                                    );
                                  },
                                  label: const Text(
                                    "Remove",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  icon: const Icon(Icons.cancel),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    String rideId = sortedDocs[index].id;
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SeeReviews(rideId: rideId)));
                                  },
                                  label: const Text(
                                    "See Reviews",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  icon: const Icon(Icons.reviews),
                                ),
                              ],
                            ))
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
