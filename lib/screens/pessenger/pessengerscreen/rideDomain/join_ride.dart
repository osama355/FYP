// ignore_for_file: non_constant_identifier_names, avoid_function_literals_in_foreach_calls
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_sharing_app/constant.dart';
import 'package:drive_sharing_app/screens/pessenger/pessengerscreen/payment/payment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class JoinRide extends StatefulWidget {
  final String? driver_id;
  final String? driver_name;
  final String? driver_source;
  final double? driver_source_lat;
  final double? driver_source_lng;
  final String? driver_via;
  final double? driver_via_lat;
  final double? driver_via_lng;
  final String? driver_destination;
  final double? driver_destination_lat;
  final double? driver_destination_lng;
  final String? price;

  const JoinRide(
      {super.key,
      this.driver_id,
      this.driver_name,
      this.driver_source,
      this.driver_source_lat,
      this.driver_source_lng,
      this.driver_via,
      this.driver_via_lat,
      this.driver_via_lng,
      this.driver_destination,
      this.driver_destination_lat,
      this.driver_destination_lng,
      this.price});

  @override
  State<JoinRide> createState() => _JoinRideState();
}

class _JoinRideState extends State<JoinRide> {
  final Completer<GoogleMapController> _controller = Completer();

  List<LatLng> polylineCordinates = [];
  LocationData? currentLocation;

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor viaIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  Marker _currentLocationMarker = const Marker(
    markerId: MarkerId("currentLocation"),
    infoWindow: InfoWindow(
      title: 'Driver Location',
      snippet: '',
    ),
    icon: BitmapDescriptor.defaultMarker,
  );

  void getCurrentLocation() async {
    // Get the Firestore instance
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Fetch the location document from Firestore
    DocumentSnapshot locationDoc = await firestore
        .collection('app')
        .doc('user')
        .collection('driver')
        .doc(widget.driver_id)
        .get();

    // Extract the latitude and longitude values from the document
    double latitude = locationDoc['live_latitude'];
    double longitude = locationDoc['live_longitude'];

    // Update the currentLocation variable with the fetched values
    setState(() {
      currentLocation =
          LocationData.fromMap({'latitude': latitude, 'longitude': longitude});
      _currentLocationMarker = _currentLocationMarker.copyWith(
        positionParam: LatLng(latitude, longitude),
        iconParam: currentLocationIcon,
        infoWindowParam: InfoWindow(
          title: widget.driver_name,
          snippet: '$latitude, $longitude',
        ),
      );
    });

    // Animate the map camera to the current location
    GoogleMapController googleMapController = await _controller.future;
    googleMapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        zoom: 13.5,
        target: LatLng(latitude, longitude),
      ),
    ));
  }

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    // Get the route between the source and via points
    PolylineResult result1 = await polylinePoints.getRouteBetweenCoordinates(
        google_api_key,
        PointLatLng(widget.driver_source_lat!, widget.driver_source_lng!),
        PointLatLng(widget.driver_via_lat!, widget.driver_via_lng!));
    // Get the route between the via and destination points
    PolylineResult result2 = await polylinePoints.getRouteBetweenCoordinates(
        google_api_key,
        PointLatLng(widget.driver_via_lat!, widget.driver_via_lng!),
        PointLatLng(
            widget.driver_destination_lat!, widget.driver_destination_lng!));

    if (result1.points.isNotEmpty && result2.points.isNotEmpty) {
      polylineCordinates.clear(); // clear previous polyline coordinates
      result1.points.forEach((PointLatLng point) =>
          polylineCordinates.add(LatLng(point.latitude, point.longitude)));
      result2.points.forEach((PointLatLng point2) =>
          polylineCordinates.add(LatLng(point2.latitude, point2.longitude)));
      setState(() {});
    }
  }

  void setCustomMarkerIcon() async {
    await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(25, 25)), "assets/driver.png")
        .then((icon) {
      currentLocationIcon = icon;
    });

    await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(25, 25)), "assets/source.png")
        .then((icon) {
      sourceIcon = icon;
    });

    await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(25, 25)), "assets/via.png")
        .then((icon) {
      viaIcon = icon;
    });

    await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(25, 25)), "assets/dest.png")
        .then((icon) {
      destinationIcon = icon;
    });
  }

  @override
  void initState() {
    super.initState();
    setCustomMarkerIcon();
    getPolyPoints();
    Timer.periodic(const Duration(seconds: 3), (timer) {
      getCurrentLocation();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Track Driver',
        ),
        backgroundColor: const Color(0xff4BA0FE),
      ),
      body: currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: GoogleMap(
                      mapType: MapType.normal,
                      myLocationButtonEnabled: true,
                      myLocationEnabled: true,
                      trafficEnabled: true,
                      initialCameraPosition: CameraPosition(
                          target: LatLng(currentLocation!.latitude!,
                              currentLocation!.longitude!),
                          zoom: 13.5),
                      polylines: {
                        Polyline(
                            polylineId: const PolylineId('route'),
                            points: polylineCordinates,
                            color: primaryColor,
                            width: 8),
                      },
                      markers: {
                        _currentLocationMarker,
                        Marker(
                            markerId: const MarkerId("source"),
                            infoWindow: InfoWindow(title: widget.driver_source),
                            icon: sourceIcon,
                            position: LatLng(widget.driver_source_lat!,
                                widget.driver_source_lng!)),
                        Marker(
                            markerId: const MarkerId("via"),
                            infoWindow: InfoWindow(title: widget.driver_via),
                            icon: viaIcon,
                            position: LatLng(widget.driver_via_lat!,
                                widget.driver_via_lng!)),
                        Marker(
                            markerId: const MarkerId("destination"),
                            infoWindow:
                                InfoWindow(title: widget.driver_destination),
                            icon: destinationIcon,
                            position: LatLng(widget.driver_destination_lat!,
                                widget.driver_destination_lng!)),
                      },
                      onMapCreated: (mapController) {
                        _controller.complete(mapController);
                      },
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 50,
                    color: Colors.white,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            const Color(0xff4BA0FE)),
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Payment(
                                      price: widget.price,
                                      driver_id: widget.driver_id,
                                    )));
                      },
                      child: const Text('Payment',
                          style: TextStyle(color: Colors.white, fontSize: 20)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
