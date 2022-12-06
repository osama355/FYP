// ignore_for_file: no_leading_underscores_for_local_identifiers
import 'dart:async';
import 'package:flutter/material.dart';
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

  final Set<Marker> _markers = {};
  final Set<Polyline> _polyLine = {};
  List<LatLng> latlng = [];

  @override
  void initState() {
    super.initState();
    initialPosition = CameraPosition(
      target: LatLng(widget.startPositionLat!, widget.startPositionLng!),
      zoom: 11,
    );
    List<LatLng> latlng = [
      LatLng(widget.startPositionLat!, widget.startPositionLng!),
      LatLng(widget.midPositionLat!, widget.midPositionLng!),
      LatLng(widget.endPositionLat!, widget.endPositionLng!),
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
        markers: _markers,
        polylines: _polyLine,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          Future.delayed(const Duration(milliseconds: 2000), () {
            controller.animateCamera(CameraUpdate.newLatLngBounds(
                MapUtils.boundsFromLatLngList(
                    _markers.map((loc) => loc.position).toList()),
                1));
          });
        },
      ),
    );
  }
}
