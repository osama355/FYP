// ignore_for_file: depend_on_referenced_packages
import 'package:drive_sharing_app/screens/driver/driverscreens/googlemap/set_route.dart';
import 'package:drive_sharing_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

class CreateRide extends StatefulWidget {
  const CreateRide({super.key});

  @override
  State<CreateRide> createState() => _CreateRideState();
}

class _CreateRideState extends State<CreateRide> {
  final requirePessController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final priceController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    requirePessController.dispose();
    priceController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xff4BA0FE),
          automaticallyImplyLeading: false,
          title: const Text("Create Ride"),
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back),
          ),
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
                      onTap: () async {
                        if (dateController.text.isNotEmpty &&
                            timeController.text.isNotEmpty &&
                            requirePessController.text.isNotEmpty &&
                            priceController.text.isNotEmpty) {
                          String date = dateController.text;
                          String time = timeController.text;
                          String seats = requirePessController.text;
                          String price = priceController.text;
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SetRoute(
                                      date: date,
                                      time: time,
                                      seats: seats,
                                      price: price)));
                        } else {
                          Utils().toastMessage("Please fill all fields");
                        }
                      },
                      child: const SizedBox(
                        height: 30,
                        child: Row(
                          children: [
                            Text(
                              "Set Route",
                              style: TextStyle(
                                  fontSize: 20.0, color: Color(0xff4BA0FE)),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Icon(
                              Icons.location_on,
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
                        lastDate: DateTime(2024));
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
                TextFormField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                      prefixIcon: Icon(
                        Icons.attach_money,
                        color: Color(0xff4BA0FE),
                        size: 20,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Price Per Seat',
                      border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
        ));
  }
}
