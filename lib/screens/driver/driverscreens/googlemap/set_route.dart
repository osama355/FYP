import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_sharing_app/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';

import '../my_rides.dart';

class SetRoute extends StatefulWidget {
  final String date;
  final String time;
  final String seats;
  final String price;
  const SetRoute(
      {super.key,
      required this.date,
      required this.time,
      required this.seats,
      required this.price});

  @override
  State<SetRoute> createState() => _SetRouteState();
}

class _SetRouteState extends State<SetRoute> {
  final startingPointController = TextEditingController();
  final middlePointController = TextEditingController();
  final destinationController = TextEditingController();
  late int totalSeats;
  late int reservedSeats;

  DetailsResult? startPosition;
  DetailsResult? midPosition;
  DetailsResult? endPosition;

  late FocusNode startFocusNode;
  late FocusNode midFocusNode;
  late FocusNode endFocusNode;

  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];
  Timer? _debounce;

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    String apiKey = 'AIzaSyCsAFe-3nLf0PkH2NIxcNheXEGeu__n2ew';
    googlePlace = GooglePlace(apiKey);
    startFocusNode = FocusNode();
    midFocusNode = FocusNode();
    endFocusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    startFocusNode.dispose();
    midFocusNode.dispose();
    endFocusNode.dispose();
  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlace.autocomplete.get(value);
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        predictions = result.predictions!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Set Route"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final user = auth.currentUser;
                      final uid = auth.currentUser?.uid;
                      totalSeats = int.parse(widget.seats);
                      final userData = await firestore
                          .collection('app')
                          .doc('user')
                          .collection('driver')
                          .doc(uid)
                          .get();

                      if (startingPointController.text.isNotEmpty &&
                          middlePointController.text.isNotEmpty &&
                          destinationController.text.isNotEmpty) {
                        final dateTime = DateTime.now();

                        await firestore
                            .collection("rides")
                            .doc('$uid$dateTime')
                            .set({
                          'driver-id': uid,
                          'profile_url': userData['dp'],
                          'driver-name': userData['name'],
                          'driver_token': userData['token'],
                          'car-number': userData['car_number'],
                          'car_name': userData['car_name'],
                          'car_model': userData['car_model'],
                          'phone': userData['phone'],
                          'email': userData['email'],
                          'require-pess': totalSeats,
                          'reservedSeats': 0,
                          'time': widget.time,
                          'date': widget.date,
                          'price': widget.price,
                          'source': startingPointController.text,
                          'via-route': middlePointController.text,
                          'destination': destinationController.text,
                          'source-lat': startPosition!.geometry!.location!.lat!,
                          'source-lng': startPosition!.geometry!.location!.lng!,
                          'via-lat': midPosition!.geometry!.location!.lat!,
                          'via-lng': midPosition!.geometry!.location!.lng!,
                          'destination-lat':
                              endPosition!.geometry!.location!.lat!,
                          'destination-lng':
                              endPosition!.geometry!.location!.lng!,
                          'ride-creation-date':
                              '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'
                        }).then((value) {
                          Utils().toastMessage("Ride Created Successfully");
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const MyRides()));
                        });
                      } else {
                        Utils().toastMessage("Please give a proper route");
                      }
                    },
                    child: SizedBox(
                      height: 30,
                      child: Row(
                        children: const [
                          Text(
                            "Create",
                            style: TextStyle(
                                fontSize: 20.0, color: Color(0xff4BA0FE)),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Icon(
                            Icons.add,
                            color: Color(0xff4BA0FE),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 10.0,
              ),
              TextField(
                controller: startingPointController,
                autofocus: false,
                focusNode: startFocusNode,
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.only(top: 15.0, bottom: 15.0),
                  prefixIcon: const Icon(
                    Icons.location_on,
                    color: Colors.green,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Starting Point',
                  border: const OutlineInputBorder(),
                  suffixIcon: startingPointController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            setState(() {
                              predictions = [];
                              startingPointController.clear();
                            });
                          },
                          icon: const Icon(Icons.clear_outlined))
                      : null,
                ),
                onChanged: (value) {
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce = Timer(const Duration(milliseconds: 1000), () {
                    if (value.isNotEmpty) {
                      autoCompleteSearch(value);
                      setState(() {
                        predictions = [];
                      });
                    } else {
                      setState(() {
                        predictions = [];
                        startPosition = null;
                      });
                    }
                  });
                },
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: middlePointController,
                autofocus: false,
                focusNode: midFocusNode,
                enabled: startingPointController.text.isNotEmpty &&
                    startPosition != null,
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.only(top: 15.0, bottom: 15.0),
                  prefixIcon: const Icon(
                    Icons.location_on,
                    color: Colors.amber,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFFFFFFF),
                  hintText: 'Via Route',
                  border: const OutlineInputBorder(),
                  suffixIcon: middlePointController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            setState(() {
                              predictions = [];
                              middlePointController.clear();
                            });
                          },
                          icon: const Icon(Icons.clear_outlined),
                        )
                      : null,
                ),
                onChanged: (value) {
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce = Timer(const Duration(milliseconds: 1000), () {
                    if (value.isNotEmpty) {
                      autoCompleteSearch(value);
                      setState(() {
                        predictions = [];
                      });
                    } else {
                      setState(() {
                        predictions = [];
                        midPosition = null;
                      });
                    }
                  });
                },
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: destinationController,
                autofocus: false,
                focusNode: endFocusNode,
                enabled: middlePointController.text.isNotEmpty &&
                    startPosition != null,
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.only(top: 15.0, bottom: 15.0),
                  prefixIcon: const Icon(
                    Icons.location_on,
                    color: Colors.amber,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Destination',
                  border: const OutlineInputBorder(),
                  suffixIcon: destinationController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            setState(() {
                              predictions = [];
                              destinationController.clear();
                            });
                          },
                          icon: const Icon(Icons.clear_outlined),
                        )
                      : null,
                ),
                onChanged: (value) {
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce = Timer(const Duration(milliseconds: 1000), () {
                    if (value.isNotEmpty) {
                      autoCompleteSearch(value);
                      setState(() {
                        predictions = [];
                      });
                    } else {
                      setState(() {
                        predictions = [];
                        endPosition = null;
                      });
                    }
                  });
                },
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: predictions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const CircleAvatar(
                      child: Icon(
                        Icons.pin_drop,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(predictions[index].description.toString()),
                    onTap: () async {
                      final placeId = predictions[index].placeId!;
                      final details = await googlePlace.details.get(placeId);

                      if (details != null &&
                          details.result != null &&
                          mounted) {
                        if (startFocusNode.hasFocus) {
                          setState(() {
                            startPosition = details.result;
                            startingPointController.text =
                                details.result!.name!;
                            predictions = [];
                          });
                        } else if (midFocusNode.hasFocus) {
                          setState(() {
                            midPosition = details.result;
                            middlePointController.text = details.result!.name!;
                            predictions = [];
                          });
                        } else {
                          setState(() {
                            endPosition = details.result;
                            destinationController.text = details.result!.name!;
                            predictions = [];
                          });
                        }
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
