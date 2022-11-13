import 'package:drive_sharing_app/screens/driver/driverscreens/driver_sidebar.dart';
import 'package:flutter/material.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DriverSidebar(),
      appBar: AppBar(
        centerTitle: false,
        title: const Text("Profile"),
      ),
      body: Container(
        child: Column(),
      ),
    );
  }
}
