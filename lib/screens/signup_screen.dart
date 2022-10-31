import 'package:drive_sharing_app/screens/driver/driver_login_screen.dart';
import 'package:flutter/material.dart';
import 'package:drive_sharing_app/screens/driver/drive_signup_screen.dart';

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
