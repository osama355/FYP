import 'package:drive_sharing_app/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController conPassController = TextEditingController();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void registerUser(BuildContext context) async {
    _firebaseAuth.createUserWithEmailAndPassword(
        email: emailController.text, password: passController.text);

    Map userData = {
      "name": nameController.text.trim(),
      "email": emailController.text.trim(),
      "phone": phoneController.text.trim()
    };
    databaseRef.child("users").set(userData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SignUp"),
        backgroundColor: const Color(0xff4BA0FE),
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
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: TextField(
                controller: emailController,
                decoration: const InputDecoration(
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
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: TextField(
                controller: phoneController,
                decoration: const InputDecoration(
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
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Name",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 17.0),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: TextField(
                controller: passController,
                obscureText: true,
                decoration: const InputDecoration(
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
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: TextField(
                controller: conPassController,
                obscureText: true,
                decoration: const InputDecoration(
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
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(const Color(0xff4BA0FE))),
                  onPressed: () {
                    if (nameController.text.length < 3) {
                      Fluttertoast.showToast(msg: "Name must be of 3 char");
                    }
                    if (!emailController.text.contains("@")) {
                      Fluttertoast.showToast(msg: "Email must be correct");
                    }
                    if (phoneController.text.length != 11) {
                      Fluttertoast.showToast(msg: "Phone must be 11 digits");
                    }
                    if (passController.text.length < 6) {
                      Fluttertoast.showToast(
                          msg: "Password must have 6 character");
                    }
                    if (passController.text != conPassController.text) {
                      Fluttertoast.showToast(msg: "Password must be same");
                    } else {
                      registerUser(context);
                      emailController.clear();
                      phoneController.clear();
                      nameController.clear();
                      passController.clear();
                      conPassController.clear();
                      Fluttertoast.showToast(msg: "Successfully screated");
                    }
                  },
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
