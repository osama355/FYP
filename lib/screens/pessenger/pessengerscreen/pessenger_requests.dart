import 'package:drive_sharing_app/screens/pessenger/pessengerscreen/previous_request.dart';
import 'package:drive_sharing_app/screens/pessenger/pessengerscreen/requested.dart';
import 'package:drive_sharing_app/screens/pessenger/pessengerscreen/upcoming_requests.dart';
import 'package:flutter/material.dart';

class PassengerRequests extends StatefulWidget {
  const PassengerRequests({super.key});

  @override
  State<PassengerRequests> createState() => _PassengerRequestsState();
}

class _PassengerRequestsState extends State<PassengerRequests> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xff4BA0FE),
            leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back),
            ),
            title: const Text("My Trips"),
            bottom: const TabBar(
              unselectedLabelColor: Colors.white,
              labelColor: Colors.white,
              indicatorColor: Colors.white,
              tabs: [
                Tab(
                  child: Text("Requested"),
                ),
                Tab(
                  child: Text("Upcoming"),
                ),
                Tab(
                  child: Text("Past"),
                )
              ],
            ),
          ),
          body: const TabBarView(
            children: [Requested(), UpcomingRequests(), PreviousRequests()],
          ),
        ));
  }
}
