import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SignUp"),
        backgroundColor: Color(0xff4BA0FE),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Center(
                child: Image.asset(
              'assets/logo.png',
              height: 120,
              width: 120,
            )),
            const SizedBox(
              height: 20,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 30, right: 30),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Email",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 17.0),
                  suffixIcon: Icon(
                    Icons.email,
                    color: Color(0xff4BA0FE),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 30, right: 30),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Phone Number",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 17.0),
                  suffixIcon: Icon(
                    Icons.phone,
                    color: Color(0xff4BA0FE),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 30, right: 30),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter your Name",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 17.0),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 30, right: 30),
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Password",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 17.0),
                  suffixIcon: Icon(
                    Icons.visibility_off,
                    color: Color(0xff4BA0FE),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 30, right: 30),
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Confirm Password",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 17.0),
                  suffixIcon: Icon(
                    Icons.visibility_off,
                    color: Color(0xff4BA0FE),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            SizedBox(
              width: 100,
              child: ElevatedButton(
                  onPressed: () {},
                  child: const Text(
                    'Sign up',
                    style: TextStyle(
                        fontSize: 18, letterSpacing: 1.0, color: Colors.white),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
