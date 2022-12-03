import 'package:flutter/material.dart';
import 'dart:async';
import 'package:drive_sharing_app/screens/driver/driverscreens/driver_sidebar.dart';
import 'package:drive_sharing_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:intl/intl.dart' show DateFormat;

class CreateRide extends StatefulWidget {
  const CreateRide({super.key});

  @override
  State<CreateRide> createState() => _CreateRideState();
}

class _CreateRideState extends State<CreateRide> {
  final startingPointController = TextEditingController();
  final destinationController = TextEditingController();
  final requirePessController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();

  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];
  Timer? _debounce;

  void initState() {
    super.initState();
    String apiKey = 'AIzaSyCsAFe-3nLf0PkH2NIxcNheXEGeu__n2ew';
    googlePlace = GooglePlace(apiKey);
  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlace.autocomplete.get(value);
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        predictions = result.predictions!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const DriverSidebar(),
        appBar: AppBar(
          title: const Text("Create Ride"),
        ),
        body: Column(
          children: [
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
                showCursor: false,
                decoration: const InputDecoration(
                    contentPadding: EdgeInsets.only(top: 15.0, bottom: 15.0),
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
                  String setTime = "${timePicked.hour}:${timePicked.minute}:00";
                  setState(() {
                    timeController.text = DateFormat.jm()
                        .format(DateFormat("hh:mm:ss").parse(setTime));
                  });
                }
              },
              child: TextFormField(
                controller: timeController,
                enabled: false,
                showCursor: false,
                decoration: const InputDecoration(
                    contentPadding: EdgeInsets.only(top: 15.0, bottom: 15.0),
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
            TextFormField(
              controller: requirePessController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(top: 15.0, bottom: 15.0),
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
            TextFormField(
              controller: startingPointController,
              autofocus: false,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  prefixIcon: Icon(
                    Icons.location_on,
                    color: Colors.green,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Enter Starting Point',
                  border: OutlineInputBorder()),
              onChanged: (value) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 1000), () {
                  if (value.isNotEmpty) {
                    autoCompleteSearch(value);
                  } else {
                    //clear the result
                  }
                });
              },
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: destinationController,
              autofocus: false,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  prefixIcon: Icon(
                    Icons.location_on,
                    color: Colors.amber,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Destination',
                  border: OutlineInputBorder()),
              onChanged: (value) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 1000), () {
                  if (value.isNotEmpty) {
                    autoCompleteSearch(value);
                  } else {
                    //clear the result
                  }
                });
              },
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: predictions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(predictions[index].description.toString()),
                );
              },
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
        ));
  }
}
