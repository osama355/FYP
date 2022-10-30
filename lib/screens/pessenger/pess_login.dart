import 'package:drive_sharing_app/screens/pessenger/verify_mbl_code.dart';
import 'package:drive_sharing_app/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:drive_sharing_app/widgets/round_button.dart';

class PessengerLogin extends StatefulWidget {
  const PessengerLogin({super.key});

  @override
  State<PessengerLogin> createState() => _PessengerLoginState();
}

class _PessengerLoginState extends State<PessengerLogin> {
  bool loading = false;
  final phoneNumberController = TextEditingController();
  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 70,
            ),
            Center(
                child: Image.asset(
              'assets/logo.png',
              height: 100,
              width: 100,
            )),
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: TextFormField(
                controller: phoneNumberController,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Enter phone number";
                  }
                  if (!RegExp(r'^\+?0[0-9]{10}$').hasMatch(value)) {
                    return "Enter correct number";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Phone Number",
                  hintStyle: TextStyle(
                      color: Color.fromARGB(255, 162, 150, 150),
                      fontSize: 17.0),
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
              child: TextFormField(
                keyboardType: TextInputType.name,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Enter your name";
                  }
                  if (!RegExp(r'^[a-z A-Z]+$').hasMatch(value)) {
                    return "Enter correct name";
                  }
                  return null;
                },
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
            const SizedBox(
              height: 15,
            ),
            RoundButton(
                title: "CONTINUE",
                loading: loading,
                onTap: () {
                  setState(() {
                    loading = true;
                  });
                  auth.verifyPhoneNumber(
                      phoneNumber: phoneNumberController.text,
                      verificationCompleted: (_) {
                        setState(() {
                          loading = false;
                        });
                      },
                      verificationFailed: (e) {
                        setState(() {
                          loading = false;
                        });
                        Utils().toastMessage(e.toString());
                      },
                      codeSent: (String verificationId, int? token) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VerifyMblCodeScreen(
                                      verificationId: verificationId,
                                    )));
                        setState(() {
                          loading = false;
                        });
                      },
                      codeAutoRetrievalTimeout: (e) {
                        Utils().toastMessage(e.toString());
                        setState(() {
                          loading = false;
                        });
                      });
                })
          ],
        ),
      ),
    );
  }
}
