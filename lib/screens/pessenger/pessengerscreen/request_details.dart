// ignore_for_file: non_constant_identifier_names, avoid_print
import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_sharing_app/screens/pessenger/pessengerscreen/pessenger_requests.dart';
import 'package:drive_sharing_app/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';
import 'package:http/http.dart' as http;

class RequestDetails extends StatefulWidget {
  //props from see_complete_ride_info
  final String? driver_id;
  final String? driver_token;
  final String? ride_id;
  final String? profile_url;
  final String? driver_name;
  final String? car_name;
  final String? phone;
  final String? car_model;
  final String? car_number;
  final String? source;
  final String? via;
  final String? destination;
  final String? date;
  final String? time;
  final double? source_lat;
  final double? source_lng;
  final double? via_lat;
  final double? via_lng;
  final double? destination_lat;
  final double? destination_lng;

  const RequestDetails({
    super.key,
    this.driver_id,
    this.driver_token,
    this.ride_id,
    this.profile_url,
    this.driver_name,
    this.phone,
    this.car_model,
    this.car_name,
    this.car_number,
    this.date,
    this.time,
    this.source,
    this.via,
    this.destination,
    this.source_lat,
    this.source_lng,
    this.via_lat,
    this.via_lng,
    this.destination_lat,
    this.destination_lng,
  });

  @override
  State<RequestDetails> createState() => _RequestDetailsState();
}

class _RequestDetailsState extends State<RequestDetails> {
  TextEditingController searchStartController = TextEditingController();
  TextEditingController searchEndController = TextEditingController();

  late FocusNode searchStartFocusNode;
  late FocusNode searchEndFocusNode;

  DetailsResult? searchStartPosition;
  DetailsResult? searchEndPosition;

  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];
  Timer? _debounce;

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    String apiKey = 'AIzaSyCsAFe-3nLf0PkH2NIxcNheXEGeu__n2ew';
    googlePlace = GooglePlace(apiKey);
    searchStartFocusNode = FocusNode();
    searchEndFocusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    searchStartFocusNode.dispose();
    searchEndFocusNode.dispose();
  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlace.autocomplete.get(value);
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        predictions = result.predictions!;
      });
    }
  }

  sendNotification(String title, String token, String passName) async {
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
                  'body': 'You have request from $passName'
                },
                'priority': 'high',
                'data': data,
                'to': token
              }));

      if (response.statusCode == 200) {
        Utils().toastMessage("Notification has been send");
      } else {
        Utils().toastMessage("Something wrong");
      }
    } catch (e) {
      Utils().toastMessage("Please restart the app");
    }
  }

  void createRequest() async {
    final uid = auth.currentUser!.uid;
    final passData = await firestore
        .collection('app')
        .doc('user')
        .collection('pessenger')
        .doc(uid)
        .get();

    // String token = widget.driver_token!;
    String passName = passData.data()?['name'];

    var requestedDoc = await firestore
        .collection('app')
        .doc('user')
        .collection('driver')
        .doc(widget.driver_id)
        .get();
    String driverToken = await requestedDoc.get('token');

    await firestore.collection('requests').doc('$uid${DateTime.now()}').set({
      'driver_id': widget.driver_id,
      'pass_token': passData.data()?['token'],
      'pass_id': uid,
      'ride_id': widget.ride_id,
      'driver_name': widget.driver_name,
      'driver_profile_url': widget.profile_url,
      'car_name': widget.car_name,
      'car_model': widget.car_model,
      'car_number': widget.car_number,
      'driver_phone': widget.phone,
      'pass_phone': auth.currentUser!.phoneNumber,
      'pass_profile_url': passData.data()?['dp'],
      'pass_name': passData.data()?['name'],
      'driver_source': widget.source,
      'driver_via': widget.via,
      'driver_destination': widget.destination,
      'date': widget.date,
      'time': widget.time,
      'driver_source_lat': widget.source_lat,
      'driver_source_lng': widget.source_lng,
      'driver_via_lat': widget.via_lat,
      'driver_via_lng': widget.via_lng,
      'driver_destination_lat': widget.destination_lat,
      'driver_destination_lng': widget.destination_lng,
      'pass_pickup': searchStartController.text,
      'pass_dest': searchEndController.text,
      'pass_pickup_lat': searchStartPosition!.geometry!.location!.lat,
      'pass_pickup_lng': searchStartPosition!.geometry!.location!.lng,
      'pass_dest_lat': searchEndPosition!.geometry!.location!.lat,
      'pass_dest_lng': searchEndPosition!.geometry!.location!.lng,
      'request_status': 'Pending',
      'ride_status': 'Stop'
    }).then((value) {
      sendNotification("Request", driverToken, passName);
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const PassengerRequests()));
    }).catchError((error) {
      Utils().toastMessage(error);
    });
    // sendNotification("Request", token, passName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff4BA0FE),
        title: const Text('Pickup Details'),
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
                    onTap: () {
                      createRequest();
                    },
                    child: SizedBox(
                      height: 30,
                      child: Row(
                        children: const [
                          Text(
                            "Request",
                            style: TextStyle(
                                fontSize: 20.0, color: Color(0xff4BA0FE)),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Icon(
                            Icons.arrow_right,
                            color: Color(0xff4BA0FE),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20.0,
              ),
              TextFormField(
                controller: searchStartController,
                autofocus: false,
                focusNode: searchStartFocusNode,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.only(top: 15.0, bottom: 15.0, left: 10),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Your pickup point',
                  prefixIcon: const Icon(
                    Icons.location_on,
                    color: Colors.amber,
                    size: 20.0,
                  ),
                  border: const OutlineInputBorder(),
                  suffixIcon: searchStartController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            setState(() {
                              predictions = [];
                              searchStartController.clear();
                            });
                          },
                          icon: const Icon(Icons.clear_outlined),
                        )
                      : null,
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Enter Pickup point';
                  }
                  return null;
                },
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
                        searchStartPosition = null;
                      });
                    }
                  });
                },
              ),
              const SizedBox(
                height: 10.0,
              ),
              TextFormField(
                controller: searchEndController,
                autofocus: false,
                focusNode: searchEndFocusNode,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.only(top: 15.0, bottom: 15.0, left: 10),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Your Destination',
                  prefixIcon: const Icon(
                    Icons.location_on,
                    color: Color(0xff4BA0FE),
                  ),
                  border: const OutlineInputBorder(),
                  suffixIcon: searchEndController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            setState(() {
                              predictions = [];
                              searchEndController.clear();
                            });
                          },
                          icon: const Icon(Icons.clear_outlined),
                        )
                      : null,
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Enter destination';
                  }
                  return null;
                },
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
                        searchEndPosition = null;
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
                      if (details != null && mounted) {
                        if (searchStartFocusNode.hasFocus) {
                          setState(() {
                            searchStartPosition = details.result;
                            searchStartController.text = details.result!.name!;
                          });
                        } else if (searchEndFocusNode.hasFocus) {
                          setState(() {
                            searchEndPosition = details.result;
                            searchEndController.text = details.result!.name!;
                          });
                        }
                        predictions = [];
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
