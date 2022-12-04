import 'package:drive_sharing_app/screens/driver/driverscreens/googlemap/driver_map_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:drive_sharing_app/screens/driver/driverscreens/driver_sidebar.dart';
import 'package:google_place/google_place.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart' show DateFormat;

class CreateRide extends StatefulWidget {
  const CreateRide({super.key});

  @override
  State<CreateRide> createState() => _CreateRideState();
}

class _CreateRideState extends State<CreateRide> {
  final startingPointController = TextEditingController();
  final middlePointController = TextEditingController();
  final destinationController = TextEditingController();
  final requirePessController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();

  DetailsResult? startPosition;
  DetailsResult? midPosition;
  DetailsResult? endPosition;

  late FocusNode startFocusNode;
  late FocusNode midFocusNode;
  late FocusNode endFocusNode;

  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    String apiKey = 'AIzaSyCsAFe-3nLf0PkH2NIxcNheXEGeu__n2ew';
    googlePlace = GooglePlace(apiKey);
    startFocusNode = FocusNode();
    midFocusNode = FocusNode();
    endFocusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    startFocusNode.dispose();
    midFocusNode.dispose();
    endFocusNode.dispose();
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
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
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
                    showCursor: false,
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
                TextField(
                  controller: startingPointController,
                  autofocus: false,
                  focusNode: startFocusNode,
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.only(top: 15.0, bottom: 15.0),
                    prefixIcon: const Icon(
                      Icons.location_on,
                      color: Colors.green,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Starting Point',
                    border: const OutlineInputBorder(),
                    suffixIcon: startingPointController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                predictions = [];
                                startingPointController.clear();
                              });
                            },
                            icon: const Icon(Icons.clear_outlined))
                        : null,
                  ),
                  onChanged: (value) {
                    if (_debounce?.isActive ?? false) _debounce!.cancel();
                    _debounce = Timer(const Duration(milliseconds: 1000), () {
                      if (value.isNotEmpty) {
                        autoCompleteSearch(value);
                      } else {
                        setState(() {
                          predictions = [];
                          startPosition = null;
                        });
                      }
                    });
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: middlePointController,
                  autofocus: false,
                  focusNode: midFocusNode,
                  enabled: startingPointController.text.isNotEmpty &&
                      startPosition != null,
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.only(top: 15.0, bottom: 15.0),
                    prefixIcon: const Icon(
                      Icons.location_on,
                      color: Colors.amber,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: Color(0xFFFFFFFF),
                    hintText: 'Via Route',
                    border: const OutlineInputBorder(),
                    suffixIcon: middlePointController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                predictions = [];
                                middlePointController.clear();
                              });
                            },
                            icon: const Icon(Icons.clear_outlined),
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    if (_debounce?.isActive ?? false) _debounce!.cancel();
                    _debounce = Timer(const Duration(milliseconds: 1000), () {
                      if (value.isNotEmpty) {
                        autoCompleteSearch(value);
                      } else {
                        setState(() {
                          predictions = [];
                          midPosition = null;
                        });
                      }
                    });
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: destinationController,
                  autofocus: false,
                  focusNode: endFocusNode,
                  enabled: middlePointController.text.isNotEmpty &&
                      startPosition != null,
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.only(top: 15.0, bottom: 15.0),
                    prefixIcon: const Icon(
                      Icons.location_on,
                      color: Colors.amber,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Destination',
                    border: const OutlineInputBorder(),
                    suffixIcon: destinationController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                predictions = [];
                                destinationController.clear();
                              });
                            },
                            icon: const Icon(Icons.clear_outlined),
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    if (_debounce?.isActive ?? false) _debounce!.cancel();
                    _debounce = Timer(const Duration(milliseconds: 1000), () {
                      if (value.isNotEmpty) {
                        autoCompleteSearch(value);
                      } else {
                        setState(() {
                          predictions = [];
                          endPosition = null;
                        });
                      }
                    });
                  },
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: predictions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(
                          Icons.pin_drop,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(predictions[index].description.toString()),
                      onTap: () async {
                        final placeId = predictions[index].placeId!;
                        final details = await googlePlace.details.get(placeId);
                        if (details != null &&
                            details.result != null &&
                            mounted) {
                          if (startFocusNode.hasFocus) {
                            setState(() {
                              startPosition = details.result;
                              startingPointController.text =
                                  details.result!.name!;
                              predictions = [];
                            });
                          } else if (midFocusNode.hasFocus) {
                            setState(() {
                              midPosition = details.result;
                              middlePointController.text =
                                  details.result!.name!;
                              predictions = [];
                            });
                          } else {
                            setState(() {
                              endPosition = details.result;
                              destinationController.text =
                                  details.result!.name!;
                              predictions = [];
                            });
                          }
                          if (startingPointController.text.isNotEmpty &&
                              middlePointController.text.isNotEmpty &&
                              destinationController.text.isNotEmpty &&
                              requirePessController.text.isNotEmpty &&
                              dateController.text.isNotEmpty &&
                              timeController.text.isNotEmpty) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DriverMapScreen(
                                        startPosition: startPosition,
                                        midPosition: midPosition,
                                        endPosition: endPosition)));
                          }
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ));
  }
}