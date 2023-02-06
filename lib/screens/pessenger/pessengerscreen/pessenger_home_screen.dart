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

class PessePostScreen extends StatefulWidget {
  const PessePostScreen({super.key});

  @override
  State<PessePostScreen> createState() => _PessePostScreenState();
}

class _PessePostScreenState extends State<PessePostScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;

  final Completer<GoogleMapController> mapController = Completer();

  static const CameraPosition kGooglePlex =
      CameraPosition(target: LatLng(33.6844, 73.0479), zoom: 14);

  final List<Marker> _markers = <Marker>[];

  storeNotificationToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    FirebaseFirestore.instance
        .collection('app')
        .doc('user')
        .collection('pessenger')
        .doc(auth.currentUser?.uid)
        .set({'token': token}, SetOptions(merge: true));
  }

  Future<Position> getCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {});

    return await Geolocator.getCurrentPosition();
  }

  initStatefCurrentLocation() async {
    getCurrentLocation().then((value) async {
      _markers.add(Marker(
          markerId: MarkerId('1'),
          position: LatLng(value.latitude, value.longitude),
          infoWindow: const InfoWindow(title: "My current location")));
      CameraPosition cameraPosition = CameraPosition(
          target: LatLng(value.latitude, value.longitude), zoom: 14);

      final GoogleMapController controller = await mapController.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      setState(() {});
    });
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
                height: 30,
              ),
              SizedBox(
                height: 280,
                child: GoogleMap(
                    initialCameraPosition: kGooglePlex,
                    markers: Set<Marker>.of(_markers),
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
