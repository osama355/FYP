import 'dart:async';
import 'package:drive_sharing_app/screens/driver/driverscreens/driver_sidebar.dart';
import 'package:drive_sharing_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverPost extends StatefulWidget {
  const DriverPost({super.key});

  @override
  State<DriverPost> createState() => _DriverPost();
}

class _DriverPost extends State<DriverPost> {
  final Completer<GoogleMapController> _controller = Completer();

  final CameraPosition _kGooglePlex =
      const CameraPosition(target: LatLng(24.839108, 67.186298), zoom: 14);

  final List<Marker> _markers = [];

  Future<Position> getCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {
      Utils().toastMessage(error.toString());
    });
    return await Geolocator.getCurrentPosition();
  }

  loadData() {
    getCurrentLocation().then((value) async {
      print("My current location");
      print("${value.latitude} ${value.longitude}");
      _markers.add(Marker(
          markerId: MarkerId("2"),
          position: LatLng(value.latitude, value.longitude),
          infoWindow: InfoWindow(title: "Current Location")));

      CameraPosition cameraPosition = CameraPosition(
          zoom: 14, target: LatLng(value.latitude, value.longitude));

      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DriverSidebar(),
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: GoogleMap(
        initialCameraPosition: _kGooglePlex,
        markers: Set<Marker>.of(_markers),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}
