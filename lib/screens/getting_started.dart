import 'package:drive_sharing_app/screens/pessenger/auth/pess_login.dart';
import 'package:drive_sharing_app/screens/driver/auth/main_driver_signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GettingStarted extends StatefulWidget {
  const GettingStarted({super.key});

  @override
  State<GettingStarted> createState() => _GettingStartedState();
}

class _GettingStartedState extends State<GettingStarted> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(
                  height: 200,
                ),
                Center(
                  child: Image.asset(
                    'assets/logo.png',
                    height: 150,
                    width: 150,
                  ),
                ),
                const Text(
                  "Unite On Wheel",
                  style: TextStyle(
                      fontSize: 35,
                      color: Color(0xff4BA0FE),
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(
                  height: 120,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(const Color(0xff4BA0FE)),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)))),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PessengerLogin()));
                  },
                  child: const SizedBox(
                    height: 50,
                    child: Center(
                      child: Text(
                        "CONTINUE AS PASSENGER",
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(const Color(0xff4BA0FE)),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)))),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignUp()));
                  },
                  child: const SizedBox(
                    height: 50,
                    child: Center(
                      child: Text(
                        "CONTINUE AS DRIVER",
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
