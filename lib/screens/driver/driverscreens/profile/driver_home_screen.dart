// ignore_for_file: avoid_print
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_sharing_app/screens/driver/driverscreens/profile/driver_sidebar.dart';
import 'package:drive_sharing_app/screens/driver/driverscreens/googlemap/create_ride.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../firebase_services/local_push_notification.dart';
import 'package:location/location.dart' as loc;

class DriverPost extends StatefulWidget {
  const DriverPost({super.key});

  @override
  State<DriverPost> createState() => _DriverPost();
}

class _DriverPost extends State<DriverPost> {
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
            .collection('driver')
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
      final user = auth.currentUser;
      String? token = await FirebaseMessaging.instance.getToken();
      await FirebaseFirestore.instance
          .collection('app')
          .doc('user')
          .collection('driver')
          .doc(user!.uid)
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
      drawer: const DriverSidebar(),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xff4BA0FE)),
        title: const Text(
          "Ride Node",
          style: TextStyle(fontSize: 25, color: Color(0xff4BA0FE)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 5.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
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
                        style: TextStyle(fontSize: 20.0, color: Colors.white),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 120,
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: const Color(0xff4BA0FE)),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.mode_of_travel,
                        size: 60,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Share and travel",
                        style: TextStyle(fontSize: 20.0, color: Colors.white),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CreateRide(),
                          fullscreenDialog: true));
                },
                autofocus: false,
                showCursor: false,
                keyboardType: TextInputType.none,
                decoration: InputDecoration(
                    hintText: 'Create ride',
                    hintStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: InputBorder.none),
              ),
              const SizedBox(
                height: 40,
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
