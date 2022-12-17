import 'dart:async';
import 'package:flutter/material.dart';
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
  const DriverMapScreen(
      {super.key,
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

  _addPolyLine() {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.blue,
        points: polylineCoordinates,
        width: 3);
    polylines[id] = polyline;
    setState(() {});
  }

  _getPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      'AIzaSyCsAFe-3nLf0PkH2NIxcNheXEGeu__n2ew',
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
      'AIzaSyCsAFe-3nLf0PkH2NIxcNheXEGeu__n2ew',
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

  @override
  void initState() {
    super.initState();
    initialPosition = CameraPosition(
      target: LatLng(widget.startPositionLat!, widget.startPositionLng!),
      zoom: 14.4746,
    );
  }

  @override
  Widget build(BuildContext context) {
    Set<Marker> markers = {
      Marker(
          markerId: const MarkerId('start'),
          infoWindow: const InfoWindow(title: "Starting point"),
          position: LatLng(widget.startPositionLat!, widget.startPositionLng!)),
      Marker(
          markerId: const MarkerId('Via'),
          infoWindow: const InfoWindow(title: "Via route"),
          position: LatLng(widget.midPositionLat!, widget.midPositionLng!)),
      Marker(
          markerId: const MarkerId('End'),
          infoWindow: const InfoWindow(title: "Destination"),
          position: LatLng(widget.endPositionLat!, widget.endPositionLng!)),
    };
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
        initialCameraPosition: initialPosition,
        markers: markers,
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
    );
  }
}
