import 'dart:async';

import 'package:drive_sharing_app/screens/driver/driverscreens/driver_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OfferRide extends StatefulWidget {
  const OfferRide({super.key});

  @override
  State<OfferRide> createState() => _OfferRideState();
}

class _OfferRideState extends State<OfferRide> {
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex =
      const CameraPosition(target: LatLng(24.839108, 67.186298), zoom: 14.4749);

  List<Marker> _marker = [];
  List<Marker> _list = const [
    Marker(
        markerId: MarkerId("1"),
        position: LatLng(24.839108, 67.186298),
        infoWindow: InfoWindow(title: "Starting Point")),
    Marker(
        markerId: MarkerId("2"),
        position: LatLng(24.865767427714033, 67.07451124295166),
        infoWindow: InfoWindow(title: "Ending Point")),
  ];

  @override
  void initState() {
    super.initState();
    _marker.addAll(_list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DriverSidebar(),
      appBar: AppBar(
        title: const Text("Offer Ride"),
      ),
      body: GoogleMap(
        initialCameraPosition: _kGooglePlex,
        markers: Set<Marker>.of(_marker),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}
