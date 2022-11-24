import 'dart:async';
import 'package:drive_sharing_app/screens/driver/driverscreens/driver_sidebar.dart';
import 'package:drive_sharing_app/utils/utils.dart';
import 'package:drive_sharing_app/widgets/round_button.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart' show DateFormat;

class DriverPost extends StatefulWidget {
  const DriverPost({super.key});

  @override
  State<DriverPost> createState() => _DriverPost();
}

class _DriverPost extends State<DriverPost> {
  final Completer<GoogleMapController> _controller = Completer();
  TextEditingController startingPointController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  TextEditingController requirePessController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();

  final CameraPosition _kGooglePlex =
      const CameraPosition(target: LatLng(24.839108, 67.186298), zoom: 14);

  final List<Marker> _markers = [];

  Future<Position> getCurrentLocation() async {
    try {
      await Geolocator.requestPermission()
          .then((value) {})
          .onError((error, stackTrace) {
        Utils().toastMessage(error.toString());
      });
    } catch (e) {
      Utils().toastMessage(e.toString());
    }
    return await Geolocator.getCurrentPosition();
  }

  loadData() {
    try {
      getCurrentLocation().then((value) async {
        // print("My current location");
        // print("${value.latitude} ${value.longitude}");
        _markers.add(Marker(
            markerId: const MarkerId("2"),
            position: LatLng(value.latitude, value.longitude),
            infoWindow: const InfoWindow(title: "Current Location")));

        CameraPosition cameraPosition = CameraPosition(
            zoom: 14, target: LatLng(value.latitude, value.longitude));

        final GoogleMapController controller = await _controller.future;
        controller
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
        setState(() {});
      });
    } catch (e) {
      Utils().toastMessage(e.toString());
    }
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
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _kGooglePlex,
            markers: Set<Marker>.of(_markers),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          Positioned(
              top: 50,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  TextFormField(
                    controller: startingPointController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                        contentPadding:
                            EdgeInsets.only(top: 15.0, bottom: 15.0),
                        prefixIcon: Icon(
                          Icons.location_on,
                          color: Colors.green,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Enter Starting Point',
                        border: OutlineInputBorder()),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: destinationController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                        contentPadding:
                            EdgeInsets.only(top: 15.0, bottom: 15.0),
                        prefixIcon: Icon(
                          Icons.location_on,
                          color: Colors.amber,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Destination',
                        border: OutlineInputBorder()),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: destinationController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        contentPadding:
                            EdgeInsets.only(top: 15.0, bottom: 15.0),
                        prefixIcon: Icon(
                          Icons.event_seat_sharp,
                          color: Color(0xff4BA0FE),
                          size: 20,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Required Seats',
                        border: OutlineInputBorder()),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () async {
                      DateTime? datePicked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100));
                      if (datePicked != null) {
                        setState(() {
                          dateController.text =
                              '${datePicked.day}-${datePicked.month}-${datePicked.year}';
                        });
                      }
                    },
                    child: TextFormField(
                      controller: dateController,
                      enabled: false,
                      decoration: const InputDecoration(
                          contentPadding:
                              EdgeInsets.only(top: 15.0, bottom: 15.0),
                          prefixIcon: Icon(
                            Icons.date_range,
                            color: Color(0xff4BA0FE),
                            size: 20,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Select Date',
                          border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () async {
                      TimeOfDay? timePicked = await showTimePicker(
                          context: context, initialTime: TimeOfDay.now());
                      if (timePicked != null) {
                        String setTime =
                            "${timePicked.hour}:${timePicked.minute}:00";
                        setState(() {
                          timeController.text = DateFormat.jm()
                              .format(DateFormat("hh:mm:ss").parse(setTime));
                        });
                      }
                    },
                    child: TextFormField(
                      controller: timeController,
                      enabled: false,
                      decoration: const InputDecoration(
                          contentPadding:
                              EdgeInsets.only(top: 15.0, bottom: 15.0),
                          prefixIcon: Icon(
                            Icons.timer,
                            color: Color(0xff4BA0FE),
                            size: 20,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Select Time',
                          border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: 120,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              const Color(0xff4BA0FE))),
                      child: const Text("Create"),
                    ),
                  )
                ],
              ))
        ],
      ),
    );
  }
}
