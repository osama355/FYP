// ignore_for_file: avoid_print
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_sharing_app/firebase_services/local_push_notification.dart';
import 'package:drive_sharing_app/screens/pessenger/pessengerscreen/rideDomain/get_ride.dart';
import 'package:drive_sharing_app/screens/pessenger/pessengerscreen/pass/pessenger_sidebar.dart';
import 'package:drive_sharing_app/screens/pessenger/pessengerscreen/rideDomain/search_ride.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;

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
  StreamSubscription<Position>? positionStreamSubscription;

  initStatefCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {
      print("error$error");
    });

    positionStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) async {
      try {
        print("My current location");
        print("${position.latitude} ${position.longitude}");
        _markers.add(Marker(
            markerId: const MarkerId('1'),
            position: LatLng(position.latitude, position.longitude),
            infoWindow: const InfoWindow(title: "My current location")));
        CameraPosition cameraPosition = CameraPosition(
            target: LatLng(position.latitude, position.longitude), zoom: 14);

        await FirebaseFirestore.instance
            .collection('app')
            .doc('user')
            .collection('pessenger')
            .doc(auth.currentUser!.uid)
            .update({
          'live_latitude': position.latitude,
          'live_longitude': position.longitude,
        });

        final GoogleMapController controller = await mapController.future;
        controller
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
        setState(() {});
      } catch (e) {
        print(e);
      }
    });
  }

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
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: [
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
                        child: const Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
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
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                height: 70,
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
