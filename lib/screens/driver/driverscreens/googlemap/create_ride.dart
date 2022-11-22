import 'dart:async';
import 'dart:convert';
import 'package:drive_sharing_app/widgets/round_button.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

import '../driver_sidebar.dart';

class CreateRide extends StatefulWidget {
  const CreateRide({super.key});

  @override
  State<CreateRide> createState() => _CreateRideState();
}

class _CreateRideState extends State<CreateRide> {
  TextEditingController startingPointController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  TextEditingController requirePessController = TextEditingController();
  final Completer<GoogleMapController> mapController = Completer();

  final CameraPosition _kGooglePlex =
      CameraPosition(target: LatLng(24.839108, 67.186298), zoom: 14);

  final List<Marker> _markers = [];

  final List<Marker> _list = const [
    Marker(
        markerId: MarkerId("1"),
        position: LatLng(24.839108, 67.186298),
        infoWindow: InfoWindow(title: "Starting Point")),
    Marker(
        markerId: MarkerId("2"),
        position: LatLng(24.865767427714033, 67.07451124295166),
        infoWindow: InfoWindow(title: "Ending Point")),
  ];

  var uuid = Uuid();
  String _sessionToken = '123456';
  List<dynamic> _placesList = [];

  @override
  void initState() {
    super.initState();
    startingPointController.addListener(() {
      onChangeStarting();
    });
    destinationController.addListener(() {
      onChangeDestination();
    });
    _markers.addAll(_list);
  }

  void onChangeStarting() {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }
    getSuggestion(startingPointController.text);
  }

  void onChangeDestination() {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }
    getSuggestion(destinationController.text);
  }

  void getSuggestion(String input) async {
    String kPLACES_API_KEY = 'AIzaSyCsAFe-3nLf0PkH2NIxcNheXEGeu__n2ew';
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request =
        '$baseURL?input=$input&key=$kPLACES_API_KEY&sessiontoken=$_sessionToken';
    var response = await http.get(Uri.parse(request));
    var data = response.body.toString();
    print(data);

    if (response.statusCode == 200) {
      setState(() {
        _placesList = jsonDecode(response.body.toString())['predictions'];
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DriverSidebar(),
      appBar: AppBar(
        title: const Text("Create Ride"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            TextFormField(
              controller: startingPointController,
              keyboardType: TextInputType.text,
              decoration:
                  const InputDecoration(hintText: 'Enter Starting Point'),
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: destinationController,
              keyboardType: TextInputType.text,
              decoration:
                  const InputDecoration(hintText: 'Enter Destination Point'),
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: requirePessController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(hintText: 'Enter Required Pessengers'),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Pick Date"),
                TextButton(
                    onPressed: () {
                      showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2022),
                          lastDate: DateTime(2023));
                    },
                    child: const Text('Choose Date'))
              ],
            ),
            Expanded(
                child: ListView.builder(
              itemCount: _placesList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () async {
                    List<Location> locations = await locationFromAddress(
                        _placesList[index]['description']);
                    print(locations.last.latitude);
                    print(locations.last.longitude);
                    setState(() {
                      if (startingPointController.selection.isValid) {
                        setState(() {
                          startingPointController.text =
                              _placesList[index]['description'];
                        });
                      } else {
                        setState(() {
                          destinationController.text =
                              _placesList[index]['description'];
                        });
                      }
                    });
                  },
                  // Text(_placesList[index]['description'])
                  title: Text(requirePessController.selection.isValid
                      ? _placesList[index]['description'] = " "
                      : _placesList[index]['description']),
                );
              },
            )),
            RoundButton(title: "Create", onTap: () {})
          ],
        ),
      ),
    );
  }
}
