import 'dart:async';
import 'package:drive_sharing_app/screens/pessenger/pessengerscreen/filter_rides.dart';
import 'package:drive_sharing_app/screens/pessenger/pessengerscreen/pessenger_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart' show DateFormat;

class SearchRide extends StatefulWidget {
  const SearchRide({super.key});

  @override
  State<SearchRide> createState() => _SearchRideState();
}

class _SearchRideState extends State<SearchRide> {
  TextEditingController searchStartController = TextEditingController();
  TextEditingController searchEndController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();

  late FocusNode searchStartFocusNode;
  late FocusNode searchEndFocusNode;

  DetailsResult? searchStartPosition;
  DetailsResult? searchEndPosition;

  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    String apiKey = 'AIzaSyCsAFe-3nLf0PkH2NIxcNheXEGeu__n2ew';
    googlePlace = GooglePlace(apiKey);
    searchStartFocusNode = FocusNode();
    searchEndFocusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    searchStartFocusNode.dispose();
    searchEndFocusNode.dispose();
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
        drawer: const PessengerSidebar(),
        appBar: AppBar(
          backgroundColor: const Color(0xff4BA0FE),
          title: const Text('Search Ride'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        double startLng =
                            searchStartPosition!.geometry!.location!.lng!;
                        double startLat =
                            searchStartPosition!.geometry!.location!.lat!;
                        double destLat =
                            searchEndPosition!.geometry!.location!.lat!;
                        double destLng =
                            searchEndPosition!.geometry!.location!.lng!;
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FilterRides(
                                    startLat: startLat,
                                    startLng: startLng,
                                    destLat: destLat,
                                    destLng: destLng,
                                    startSearchText: searchStartController.text,
                                    endSearchText: searchEndController.text,
                                    dateText: dateController.text,
                                    timeText: timeController.text)));
                      },
                      child: SizedBox(
                        height: 30,
                        child: Row(
                          children: const [
                            Text(
                              "Search",
                              style: TextStyle(
                                  fontSize: 20.0, color: Color(0xff4BA0FE)),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Icon(
                              Icons.search,
                              color: Color(0xff4BA0FE),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10.0,
                ),
                GestureDetector(
                  onTap: () async {
                    DateTime? datePicked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2025));
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
                  height: 10.0,
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
                  height: 10.0,
                ),
                TextFormField(
                  controller: searchStartController,
                  autofocus: false,
                  focusNode: searchStartFocusNode,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(
                        top: 15.0, bottom: 15.0, left: 10),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Your pickup point',
                    prefixIcon: const Icon(
                      Icons.location_on,
                      color: Colors.amber,
                      size: 20.0,
                    ),
                    border: const OutlineInputBorder(),
                    suffixIcon: searchStartController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                predictions = [];
                                searchStartController.clear();
                              });
                            },
                            icon: const Icon(Icons.clear_outlined),
                          )
                        : null,
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter Pickup point';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    if (_debounce?.isActive ?? false) _debounce!.cancel();
                    _debounce = Timer(const Duration(milliseconds: 1000), () {
                      if (value.isNotEmpty) {
                        autoCompleteSearch(value);
                        setState(() {
                          predictions = [];
                        });
                      } else {
                        setState(() {
                          predictions = [];
                          searchStartPosition = null;
                        });
                      }
                    });
                  },
                ),
                const SizedBox(
                  height: 10.0,
                ),
                TextFormField(
                  controller: searchEndController,
                  autofocus: false,
                  focusNode: searchEndFocusNode,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(
                        top: 15.0, bottom: 15.0, left: 10),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Your Destination',
                    prefixIcon: const Icon(
                      Icons.location_on,
                      color: Color(0xff4BA0FE),
                    ),
                    border: const OutlineInputBorder(),
                    suffixIcon: searchEndController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                predictions = [];
                                searchEndController.clear();
                              });
                            },
                            icon: const Icon(Icons.clear_outlined),
                          )
                        : null,
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter destination';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    if (_debounce?.isActive ?? false) _debounce!.cancel();
                    _debounce = Timer(const Duration(milliseconds: 1000), () {
                      if (value.isNotEmpty) {
                        autoCompleteSearch(value);
                        setState(() {
                          predictions = [];
                        });
                      } else {
                        setState(() {
                          predictions = [];
                          searchEndPosition = null;
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
                        if (details != null && mounted) {
                          if (searchStartFocusNode.hasFocus) {
                            setState(() {
                              searchStartPosition = details.result;
                              searchStartController.text =
                                  details.result!.name!;
                            });
                          } else if (searchEndFocusNode.hasFocus) {
                            setState(() {
                              searchEndPosition = details.result;
                              searchEndController.text = details.result!.name!;
                            });
                          }
                          predictions = [];
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
