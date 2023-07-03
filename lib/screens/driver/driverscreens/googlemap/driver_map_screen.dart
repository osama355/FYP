// ignore_for_file: use_build_context_synchronously, avoid_function_literals_in_foreach_calls
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_sharing_app/constant.dart';
import 'package:drive_sharing_app/screens/driver/driverscreens/profile/driver_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../utils/map_utils.dart';

class DriverMapScreen extends StatefulWidget {
  final double? startPositionLat;
  final double? startPositionLng;
  final double? midPositionLat;
  final double? midPositionLng;
  final double? endPositionLat;
  final double? endPositionLng;
  final String? rideId;
  const DriverMapScreen(
      {super.key,
      this.rideId,
      this.startPositionLat,
      this.startPositionLng,
      this.midPositionLat,
      this.midPositionLng,
      this.endPositionLat,
      this.endPositionLng});

  @override
  State<DriverMapScreen> createState() => _DriverMapScreenState();
}

class _DriverMapScreenState extends State<DriverMapScreen> {
  late CameraPosition initialPosition;
  final Completer<GoogleMapController> _controller = Completer();
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final Set<Marker> _markers = {};

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor viaIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  _addPolyLine() {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        color: primaryColor,
        points: polylineCoordinates,
        width: 8);
    polylines[id] = polyline;
    setState(() {});
  }

  _getPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      google_api_key,
      PointLatLng(widget.startPositionLat!, widget.startPositionLng!),
      PointLatLng(widget.midPositionLat!, widget.midPositionLng!),
      travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }
    PolylineResult result2 = await polylinePoints.getRouteBetweenCoordinates(
      google_api_key,
      PointLatLng(widget.midPositionLat!, widget.midPositionLng!),
      PointLatLng(widget.endPositionLat!, widget.endPositionLng!),
      travelMode: TravelMode.driving,
    );
    if (result2.points.isNotEmpty) {
      for (var point in result2.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }
    _addPolyLine();
  }

  updateRideStatus() async {
    await firestore
        .collection('rides')
        .doc(widget.rideId)
        .update({'status': 'completed'});
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const DriverPost()));
  }

  Future<BitmapDescriptor> getCustomMarkerIcon() async {
    return await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(25, 25)),
      'assets/pass.png',
    );
  }

  void _fetchPassengerLocations() async {
    QuerySnapshot snapshot = await firestore.collection('requests').get();
    snapshot.docs.forEach((doc) async {
      String passengerId = doc['pass_id'];
      String requestStatus = doc['request_status'];
      String rideId = doc['ride_id'];
      if (rideId == widget.rideId) {
        if (requestStatus == 'Accepted' || requestStatus == 'Join') {
          DocumentSnapshot passengerDoc = await firestore
              .collection('app')
              .doc('user')
              .collection('pessenger')
              .doc(passengerId)
              .get();

          double lat = passengerDoc['live_latitude'];
          double lng = passengerDoc['live_longitude'];
          String passName = passengerDoc['name'];
          BitmapDescriptor passLocationIcon = await getCustomMarkerIcon();

          setState(() {
            LatLng location = LatLng(lat, lng);
            Marker marker = Marker(
              markerId: MarkerId(passengerId),
              position: location,
              icon: passLocationIcon,
              infoWindow: InfoWindow(title: passName, snippet: '$lat , $lng'),
            );
            _markers.add(marker);
          });
        }
      }
    });
  }

  void setCustomMarkerIcon() async {
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

  Future<ByteData> getBytesFromAsset(String path) {
    return rootBundle.load(path);
  }

  @override
  void initState() {
    super.initState();
    initialPosition = CameraPosition(
      target: LatLng(widget.startPositionLat!, widget.startPositionLng!),
      zoom: 14.4746,
    );
    setCustomMarkerIcon();
    Timer.periodic(const Duration(seconds: 3), (timer) {
      _fetchPassengerLocations();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Set<Marker> markers = {
      Marker(
          icon: sourceIcon,
          markerId: const MarkerId('start'),
          infoWindow: const InfoWindow(title: "Starting point"),
          position: LatLng(widget.startPositionLat!, widget.startPositionLng!)),
      Marker(
          icon: viaIcon,
          markerId: const MarkerId('Via'),
          infoWindow: const InfoWindow(title: "Via route"),
          position: LatLng(widget.midPositionLat!, widget.midPositionLng!)),
      Marker(
          icon: destinationIcon,
          markerId: const MarkerId('End'),
          infoWindow: const InfoWindow(title: "Destination"),
          position: LatLng(widget.endPositionLat!, widget.endPositionLng!)),
    };

    _markers.addAll(markers);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff4BA0FE),
        title: const Text("Ride Node"),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.arrow_back),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: initialPosition,
              markers: _markers,
              mapType: MapType.normal,
              myLocationEnabled: true,
              trafficEnabled: true,
              myLocationButtonEnabled: true,
              polylines: Set<Polyline>.of(polylines.values),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                Future.delayed(const Duration(milliseconds: 2000), () {
                  controller.animateCamera(CameraUpdate.newLatLngBounds(
                      MapUtils.boundsFromLatLngList(
                          markers.map((loc) => loc.position).toList()),
                      1));
                  _getPolyline();
                });
              },
            ),
          ),
          Container(
            width: double.infinity,
            height: 50,
            color: Colors.white,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(const Color(0xff4BA0FE)),
              ),
              onPressed: () {
                updateRideStatus();
              },
              child: const Text('Complete Ride',
                  style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
          ),
        ],
      ),
    );
  }
}


















// Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(0xff4BA0FE),
//         title: const Text("Ride Node"),
//         leading: IconButton(
//             onPressed: () {
//               Navigator.push(context,
//                   MaterialPageRoute(builder: (context) => const MyRides()));
//             },
//             icon: const CircleAvatar(
//               backgroundColor: Colors.white,
//               child: Icon(
//                 Icons.arrow_back,
//               ),
//             )),
//       ),
//       body: GoogleMap(
//         initialCameraPosition: initialPosition,
//         markers: markers,
//         polylines: Set<Polyline>.of(polylines.values),
//         onMapCreated: (GoogleMapController controller) {
//           _controller.complete(controller);
//           Future.delayed(const Duration(milliseconds: 2000), () {
//             controller.animateCamera(CameraUpdate.newLatLngBounds(
//                 MapUtils.boundsFromLatLngList(
//                     markers.map((loc) => loc.position).toList()),
//                 1));
//             _getPolyline();
//           });
//         },
//       ),
//     );
