import 'package:custom_switch_button/custom_switch_button.dart';
import 'package:drive_sharing_app/screens/driver/driverscreens/driver_sidebar.dart';
import 'package:flutter/material.dart';

class DriverPost extends StatefulWidget {
  const DriverPost({super.key});

  @override
  State<DriverPost> createState() => _DriverPost();
}

class _DriverPost extends State<DriverPost> {
  bool isSwitched = false;
  String activeStatus = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DriverSidebar(),
      appBar: AppBar(
        backgroundColor: const Color(0xff4BA0FE),
        centerTitle: false,
        title: const Text("Home"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Container(
              margin: const EdgeInsets.only(left: 250),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      activeStatus,
                      style: const TextStyle(color: Color(0xff4BA0FE)),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isSwitched = !isSwitched;
                        });
                        if (isSwitched == true) {
                          activeStatus = "Active";
                        } else {
                          activeStatus = "";
                        }
                      },
                      child: CustomSwitchButton(
                          backgroundColor: Colors.grey,
                          checked: isSwitched,
                          checkedColor: const Color(0xff4BA0FE),
                          unCheckedColor: Colors.white,
                          animationDuration: const Duration(milliseconds: 400)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
