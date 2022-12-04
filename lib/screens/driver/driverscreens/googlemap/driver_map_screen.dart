// ignore_for_file: no_leading_underscores_for_local_identifiers
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import '../../../../utils/map_utils.dart';

class DriverMapScreen extends StatefulWidget {
  final DetailsResult? startPosition;
  final DetailsResult? midPosition;
  final DetailsResult? endPosition;
  const DriverMapScreen(
      {super.key, this.startPosition, this.midPosition, this.endPosition});

  @override
  State<DriverMapScreen> createState() => _DriverMapScreenState();
}

class _DriverMapScreenState extends State<DriverMapScreen> {
  late CameraPosition initialPosition;
  final Completer<GoogleMapController> _controller = Completer();
  // Map<PolylineId, Polyline> polylines = {};
  // List<LatLng> polylineCoordinates = [];
  // PolylinePoints polylinePoints = PolylinePoints();

  final Set<Marker> _markers = {};
  final Set<Polyline> _polyLine = {};
  List<LatLng> latlng = [];

  @override
  void initState() {
    super.initState();
    initialPosition = CameraPosition(
      target: LatLng(widget.startPosition!.geometry!.location!.lat!,
          widget.startPosition!.geometry!.location!.lng!),
      zoom: 11,
    );
    List<LatLng> latlng = [
      LatLng(widget.startPosition!.geometry!.location!.lat!,
          widget.startPosition!.geometry!.location!.lng!),
      LatLng(widget.midPosition!.geometry!.location!.lat!,
          widget.midPosition!.geometry!.location!.lng!),
      LatLng(widget.endPosition!.geometry!.location!.lat!,
          widget.endPosition!.geometry!.location!.lng!),
    ];

    for (int i = 0; i < latlng.length; i++) {
      _markers.add(Marker(
        markerId: MarkerId(i.toString()),
        position: latlng[i],
        infoWindow: InfoWindow(title: 'spots', snippet: ''),
        icon: BitmapDescriptor.defaultMarker,
      ));
      setState(() {});
      _polyLine.add(
        Polyline(
            polylineId: PolylineId('1'),
            points: latlng,
            width: 3,
            color: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Set<Marker> _markers = {
    //   Marker(
    //       markerId: const MarkerId('start'),
    //       position: LatLng(widget.startPosition!.geometry!.location!.lat!,
    //           widget.startPosition!.geometry!.location!.lng!)),
    //   Marker(
    //       markerId: const MarkerId('end'),
    //       position: LatLng(widget.endPosition!.geometry!.location!.lat!,
    //           widget.endPosition!.geometry!.location!.lng!))
    // };
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
            )),
      ),
      body: GoogleMap(
        // polylines: Set<Polyline>.of(polylines.values),
        initialCameraPosition: initialPosition,
        markers: _markers,
        polylines: _polyLine,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          // Future.delayed(const Duration(milliseconds: 2000), () {
          //   controller.animateCamera(CameraUpdate.newLatLngBounds(
          //       MapUtils.boundsFromLatLngList(
          //           _markers.map((loc) => loc.position).toList()),
          //       1));
          //   // _getPolyline();
          // });
        },
      ),
    );
  }
}

//  _addPolyLine() {
//     PolylineId id = PolylineId("poly");
//     Polyline polyline = Polyline(
//         polylineId: id,
//         color: Colors.red,
//         points: polylineCoordinates,
//         width: 3);
//     polylines[id] = polyline;
//     setState(() {});
//   }

//   _getPolyline() async {
//     PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//       'AIzaSyCsAFe-3nLf0PkH2NIxcNheXEGeu__n2ew',
//       PointLatLng(widget.startPosition!.geometry!.location!.lat!,
//           widget.startPosition!.geometry!.location!.lng!),
//       PointLatLng(widget.endPosition!.geometry!.location!.lat!,
//           widget.endPosition!.geometry!.location!.lng!),
//       travelMode: TravelMode.driving,
//     );
//     if (result.points.isNotEmpty) {
//       result.points.forEach((PointLatLng point) {
//         polylineCoordinates.add(LatLng(point.latitude, point.longitude));
//       });
//     }
//     _addPolyLine();
//   }

// polylines: Set<Polyline>.of(polylines.values),
