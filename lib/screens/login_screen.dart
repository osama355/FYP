import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        backgroundColor: const Color(0xff4BA0FE),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            Center(
                child: Image.asset(
              'assets/logo.png',
              height: 120,
              width: 120,
            )),
            const SizedBox(
              height: 50,
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
              height: 20,
            ),
            SizedBox(
              width: 100,
              child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(const Color(0xff4BA0FE))),
                  onPressed: () {},
                  child: const Text(
                    'Login',
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
