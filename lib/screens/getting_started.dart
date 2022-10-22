import 'package:drive_sharing_app/screens/login_screen.dart';
import 'package:flutter/material.dart';

class GettingStarted extends StatefulWidget {
  const GettingStarted({super.key});

  @override
  State<GettingStarted> createState() => _GettingStartedState();
}

class _GettingStartedState extends State<GettingStarted> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
              height: 180,
            ),
            ElevatedButton(
              style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)))),
              onPressed: () {},
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  SizedBox(
                    height: 50,
                    width: 100,
                  ),
                  Text(
                    "Get Started",
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(
                    height: 50,
                    width: 80,
                  ),
                  Icon(
                    Icons.arrow_forward,
                    size: 24,
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Already have an account ?",
                  style: TextStyle(fontSize: 15),
                ),
                TextButton(
                  child: const Text(
                    'Login',
                    style: TextStyle(color: Color(0xff4BA0FE), fontSize: 15),
                  ),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginScreen()));
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
