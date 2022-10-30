import 'package:flutter/material.dart';
import 'package:drive_sharing_app/screens/driver/drive_signup_screen.dart';
import 'package:drive_sharing_app/screens/pessenger/pess_login.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xff4BA0FE),
          title: const Text("Register"),
          bottom: const TabBar(
            unselectedLabelColor: Colors.white,
            labelColor: Colors.white,
            indicatorColor: Colors.white,
            tabs: [
              Tab(
                child: Text("Passenger"),
              ),
              Tab(
                child: Text("Driver"),
              )
            ],
          ),
        ),
        body: const TabBarView(children: [
          PessengerLogin(),
          DriveSignUp(),
        ]),
      ),
    );
  }
}
