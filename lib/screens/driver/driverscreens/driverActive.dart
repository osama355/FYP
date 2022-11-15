import 'package:flutter/material.dart';

class Driveractive extends StatefulWidget {
  const Driveractive({super.key});

  @override
  State<Driveractive> createState() => _DriveractiveState();
}

class _DriveractiveState extends State<Driveractive> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        title: const Text("Driver"),
      ),
      body: Column(children: [
        Text("Edit Profile"),
      ]),
    );
  }
}
