// ignore_for_file: non_constant_identifier_names
import 'dart:async';
import 'package:drive_sharing_app/screens/pessenger/pessengerscreen/requestDomain/request_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../utils/map_utils.dart';

class SeeCompleteRideInfo extends StatefulWidget {
  //props from get_ride
  final String? profile_url;
  final String? price;
  final String? driver_token;
  final String? ride_id;
  final String? driver_id;
  final String? driver_name;
  final String? car_name;
  final String? seats;
  final String? phone;
  final String? car_model;
  final String? car_number;
  final String? source;
  final String? via;
  final String? destination;
  final String? date;
  final String? time;
  final double? source_lat;
  final double? source_lng;
  final double? via_lat;
  final double? via_lng;
  final double? destination_lat;
  final double? destination_lng;

  const SeeCompleteRideInfo({
    super.key,
    this.profile_url,
    this.ride_id,
    this.driver_name,
    this.driver_token,
    this.driver_id,
    this.car_name,
    this.phone,
    this.seats,
    this.price,
    this.car_model,
    this.car_number,
    this.source,
    this.via,
    this.destination,
    this.date,
    this.time,
    this.source_lat,
    this.source_lng,
    this.via_lat,
    this.via_lng,
    this.destination_lat,
    this.destination_lng,
  });

  @override
  State<SeeCompleteRideInfo> createState() => _SeeCompleteRideInfoState();
}

class _SeeCompleteRideInfoState extends State<SeeCompleteRideInfo> {
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
      PointLatLng(widget.source_lat!, widget.source_lng!),
      PointLatLng(widget.via_lat!, widget.via_lng!),
      travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }

    PolylineResult result2 = await polylinePoints.getRouteBetweenCoordinates(
      'AIzaSyCsAFe-3nLf0PkH2NIxcNheXEGeu__n2ew',
      PointLatLng(widget.via_lat!, widget.via_lng!),
      PointLatLng(widget.destination_lat!, widget.destination_lng!),
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
      target: LatLng(widget.source_lat!, widget.source_lng!),
      zoom: 14.4746,
    );
  }

  @override
  Widget build(BuildContext context) {
    Set<Marker> markers = {
      Marker(
          markerId: const MarkerId('start'),
          infoWindow: const InfoWindow(title: "Starting point"),
          position: LatLng(widget.source_lat!, widget.source_lng!)),
      Marker(
          markerId: const MarkerId('Via'),
          infoWindow: const InfoWindow(title: "Via route"),
          position: LatLng(widget.via_lat!, widget.via_lng!)),
      Marker(
          markerId: const MarkerId('End'),
          infoWindow: const InfoWindow(title: "Destination"),
          position: LatLng(widget.destination_lat!, widget.destination_lng!)),
    };
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff4BA0FE),
        title: const Text("Ride Detail"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Row(
                children: [
                  ClipOval(
                    child: widget.profile_url != ""
                        ? Image.network(
                            widget.profile_url!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 60,
                            height: 60,
                            decoration:
                                const BoxDecoration(color: Color(0xff4BA0FE)),
                            child: const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.driver_name!,
                        style: const TextStyle(
                            fontSize: 15.0, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.car_name!,
                        style: const TextStyle(fontSize: 12.0),
                      ),
                      Text(
                        '${widget.car_model} | ${widget.car_number}',
                        style: const TextStyle(fontSize: 12.0),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              children: [
                const Icon(
                  Icons.circle,
                  color: Colors.green,
                  size: 10.0,
                ),
                const SizedBox(
                  width: 5,
                ),
                Text('Source : ${widget.source}'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              children: [
                const Icon(
                  Icons.circle,
                  color: Colors.blue,
                  size: 10.0,
                ),
                const SizedBox(
                  width: 5,
                ),
                Text('Via : ${widget.via}'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              children: [
                const Icon(
                  Icons.circle,
                  color: Colors.red,
                  size: 10.0,
                ),
                const SizedBox(
                  width: 5,
                ),
                Text('Destination : ${widget.destination}'),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              children: [
                const Icon(
                  Icons.phone,
                  size: 20,
                  color: Color(0xff4BA0FE),
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Phone'),
                    Text('${widget.phone}'),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              children: [
                const Icon(
                  Icons.date_range,
                  size: 20,
                  color: Color(0xff4BA0FE),
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Date'),
                    Text('${widget.date}'),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 20,
                  color: Color(0xff4BA0FE),
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Time'),
                    Text('${widget.time}'),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Estimated fare : ${widget.price}/seat'),
                Text("Total Seats : ${widget.seats}")
              ],
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          SizedBox(
            height: 250,
            child: GoogleMap(
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
          ),
          Container(
            height: 60,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xff4BA0FE),
            ),
            child: OutlinedButton(
                onPressed: () {
                  String driver_id = widget.driver_id!;
                  String driver_token = widget.driver_token!;
                  String ride_id = widget.ride_id!;
                  String profile_url = widget.profile_url!;
                  String driver_name = widget.driver_name!;
                  String car_name = widget.car_name!;
                  String phone = widget.phone!;
                  String car_model = widget.car_model!;
                  String car_number = widget.car_number!;
                  String source = widget.source!;
                  String via = widget.via!;
                  String destination = widget.destination!;
                  String date = widget.date!;
                  String time = widget.time!;
                  double source_lat = widget.source_lat!;
                  double source_lng = widget.source_lng!;
                  double via_lat = widget.via_lat!;
                  double via_lng = widget.via_lng!;
                  double destination_lat = widget.destination_lat!;
                  double destination_lng = widget.destination_lng!;
                  String price = widget.price!;

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RequestDetails(
                                driver_token: driver_token,
                                driver_id: driver_id,
                                ride_id: ride_id,
                                profile_url: profile_url,
                                driver_name: driver_name,
                                car_name: car_name,
                                phone: phone,
                                car_model: car_model,
                                car_number: car_number,
                                source: source,
                                via: via,
                                destination: destination,
                                date: date,
                                time: time,
                                source_lat: source_lat,
                                source_lng: source_lng,
                                via_lat: via_lat,
                                via_lng: via_lng,
                                destination_lat: destination_lat,
                                destination_lng: destination_lng,
                                price: price,
                              )));
                },
                child: const Text(
                  "Request",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                )),
          )
        ],
      ),
    );
  }
}
