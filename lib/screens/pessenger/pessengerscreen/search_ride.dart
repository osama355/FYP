import 'dart:async';
import 'package:drive_sharing_app/screens/pessenger/pessengerscreen/filter_rides.dart';
import 'package:drive_sharing_app/screens/pessenger/pessengerscreen/pessenger_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';

class SearchRide extends StatefulWidget {
  const SearchRide({super.key});

  @override
  State<SearchRide> createState() => _SearchRideState();
}

class _SearchRideState extends State<SearchRide> {
  TextEditingController searchEndController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late FocusNode searchEndFocusNode;

  DetailsResult? searchEndPosition;

  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    String apiKey = 'AIzaSyCsAFe-3nLf0PkH2NIxcNheXEGeu__n2ew';
    googlePlace = GooglePlace(apiKey);
    searchEndFocusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
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
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            double destLat =
                                searchEndPosition!.geometry!.location!.lat!;
                            double destLng =
                                searchEndPosition!.geometry!.location!.lng!;
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FilterRides(
                                          destLat: destLat,
                                          destLng: destLng,
                                          endSearchText:
                                              searchEndController.text,
                                          dateText: dateController.text,
                                        )));
                          }
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
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please select Date";
                        }
                        return null;
                      },
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
                          final details =
                              await googlePlace.details.get(placeId);
                          if (details != null && mounted) {
                            if (searchEndFocusNode.hasFocus) {
                              setState(() {
                                searchEndPosition = details.result;
                                searchEndController.text =
                                    details.result!.name!;
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
          ),
        ));
  }
}
