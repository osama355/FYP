import 'package:drive_sharing_app/screens/driver/driverscreens/driver_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

class ConvertLatLngToAddress extends StatefulWidget {
  const ConvertLatLngToAddress({super.key});

  @override
  State<ConvertLatLngToAddress> createState() => _ConvertLatLngToAddressState();
}

class _ConvertLatLngToAddressState extends State<ConvertLatLngToAddress> {
  String cord = '';
  String strAdd = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DriverSidebar(),
      appBar: AppBar(
        title: const Text("Convert"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Coordinates : $cord"),
          Text("Address : $strAdd"),
          GestureDetector(
            onTap: () async {
              List<Location> locations =
                  await locationFromAddress("Gronausestraat 710, Enschede");
              List<Placemark> placemarks =
                  await placemarkFromCoordinates(24.839108, 67.186298);
              var complt = placemarks.last;

              setState(() {
                cord = "${locations.last.latitude} ${locations.last.longitude}";
                strAdd =
                    "${complt.subLocality} ${complt.locality} ${complt.administrativeArea} ${complt.country}";
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 50,
                decoration: const BoxDecoration(color: Colors.green),
                child: const Center(
                  child: Text('Convert'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
