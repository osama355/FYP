// ignore_for_file: avoid_print

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_sharing_app/firebase_services/local_push_notification.dart';
import 'package:drive_sharing_app/screens/pessenger/pessengerscreen/get_ride.dart';
import 'package:drive_sharing_app/screens/pessenger/pessengerscreen/pessenger_sidebar.dart';
import 'package:drive_sharing_app/screens/pessenger/pessengerscreen/search_ride.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';

class PessePostScreen extends StatefulWidget {
  const PessePostScreen({super.key});

  @override
  State<PessePostScreen> createState() => _PessePostScreenState();
}

class _PessePostScreenState extends State<PessePostScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  final Completer<GoogleMapController> mapController = Completer();
  static const CameraPosition kGooglePlex =
      CameraPosition(target: LatLng(33.6844, 73.0479), zoom: 14);
  final List<Marker> _markers = <Marker>[];

  final loc.Location location = loc.Location();
  StreamSubscription<loc.LocationData>? _locationSubscription;

  Future<Position> getCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {
      print("error$error");
    });

    return await Geolocator.getCurrentPosition();
  }

  //////////////////////////////////

  initStatefCurrentLocation() async {
    getCurrentLocation().then((value) async {
      try {
        print("My current location");
        print("${value.latitude} ${value.longitude}");
        _markers.add(Marker(
            markerId: const MarkerId('1'),
            position: LatLng(value.latitude, value.longitude),
            infoWindow: const InfoWindow(title: "My current location")));
        CameraPosition cameraPosition = CameraPosition(
            target: LatLng(value.latitude, value.longitude), zoom: 14);

        final GoogleMapController controller = await mapController.future;
        controller
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
        setState(() {});
      } catch (e) {
        print(e);
      }
    });
  }

  Future<void> _listenLocation() async {
    _locationSubscription = location.onLocationChanged.handleError((onError) {
      print(onError);
      _locationSubscription?.cancel();
      setState(() {
        _locationSubscription = null;
      });
    }).listen((loc.LocationData currentLocation) async {
      await firestore
          .collection('app')
          .doc('user')
          .collection('pessenger')
          .doc(auth.currentUser!.uid)
          .update({
        'live_latitude': currentLocation.latitude,
        'live_longitude': currentLocation.longitude,
      });
    });
  }

  // handleLive() async {
  //   final user = auth.currentUser;
  //   final driverDoc = await firestore
  //       .collection('app')
  //       .doc('user')
  //       .collection('pessenger')
  //       .doc(user?.uid)
  //       .get();

  //   if (driverDoc.data()?['status'] == 'pessenger') {
  //     await location.changeSettings(
  //         interval: 300, accuracy: loc.LocationAccuracy.high);
  //     await location.enableBackgroundMode(enable: true);
  //   }
  // }

  stopListening() {
    _locationSubscription?.cancel();
    setState(() {
      _locationSubscription = null;
    });
  }

///////////////////////////////////////

  storeNotificationToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      await FirebaseFirestore.instance
          .collection('app')
          .doc('user')
          .collection('pessenger')
          .doc(auth.currentUser?.uid)
          .set({'token': token}, SetOptions(merge: true));
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.getInitialMessage();
    FirebaseMessaging.onMessage.listen((event) {
      LocalNotificationService.display(event);
    });
    storeNotificationToken();
    initStatefCurrentLocation();
    // handleLive();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const PessengerSidebar(),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xff4BA0FE)),
        elevation: 0,
        title: const Text(
          "Ride Node",
          style: TextStyle(fontSize: 25, color: Color(0xff4BA0FE)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: const Color(0xff4BA0FE)),
                height: 120,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.drive_eta,
                        size: 60,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Welcome to Ride Node",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SearchRide()));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xff4BA0FE),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        height: 100,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                "Search ",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                              Icon(Icons.search, size: 20, color: Colors.white)
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const GetRide()));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xff4BA0FE),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      height: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text("Get ",
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white)),
                          Icon(Icons.directions_car,
                              size: 20, color: Colors.white)
                        ],
                      ),
                    ),
                  ))
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  TextButton(
                      onPressed: () {
                        _listenLocation();
                      },
                      child: const Text('Get Live')),
                  TextButton(
                      onPressed: () {
                        stopListening();
                      },
                      child: const Text('Stop Live')),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              SizedBox(
                height: 280,
                child: GoogleMap(
                    initialCameraPosition: kGooglePlex,
                    mapType: MapType.normal,
                    myLocationButtonEnabled: true,
                    myLocationEnabled: true,
                    onMapCreated: (GoogleMapController controller) {
                      mapController.complete(controller);
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
