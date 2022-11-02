import 'package:drive_sharing_app/screens/driver/auth/driver_login_screen.dart';
import 'package:drive_sharing_app/screens/getting_started.dart';
import 'package:flutter/material.dart';
import 'package:drive_sharing_app/screens/driver/auth/drive_signup_screen.dart';

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
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xff4BA0FE),
          leading: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const GettingStarted()));
            },
            child: const Icon(Icons.arrow_back),
          ),
          title: const Text("Driver"),
          bottom: const TabBar(
            unselectedLabelColor: Colors.white,
            labelColor: Colors.white,
            indicatorColor: Colors.white,
            tabs: [
              Tab(
                child: Text("Login"),
              ),
              Tab(
                child: Text("Sign up"),
              )
            ],
          ),
        ),
        body: const TabBarView(children: [
          DriveLoginScreen(),
          DriveSignUp(),
        ]),
      ),
    );
  }
}
