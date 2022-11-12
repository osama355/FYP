import 'package:drive_sharing_app/screens/getting_started.dart';
import 'package:drive_sharing_app/screens/pessenger/auth/verify_mbl_code.dart';
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
  final _formKey = GlobalKey<FormState>();
  final phoneNumberController = TextEditingController(text: "+92");
  final nameController = TextEditingController();
  final auth = FirebaseAuth.instance;

  @override
  void dispose() {
    super.dispose();
    phoneNumberController.dispose();
    nameController.dispose();
  }

  void loginWithPhone() async {
    int? resendCode;
    setState(() {
      loading = true;
    });
    await auth.verifyPhoneNumber(
        phoneNumber: phoneNumberController.text,
        timeout: const Duration(seconds: 120),
        verificationCompleted: (_) {
          setState(() {
            loading = false;
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            loading = false;
          });
          Utils().toastMessage(e.toString());
          if (e.code == 'invalid-phone-number') {
            Utils().toastMessage('The provided phone number is invalid');
          }
        },
        codeSent: (
          String verificationId,
          int? token,
        ) {
          resendCode = token;
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => VerifyMblCodeScreen(
                        verificationId: verificationId,
                        phonenumber: phoneNumberController,
                        name: nameController,
                      )));
          setState(() {
            loading = false;
          });
        },
        forceResendingToken: resendCode,
        codeAutoRetrievalTimeout: (String verificationId) {
          verificationId = verificationId;
          setState(() {
            loading = false;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xff4BA0FE),
        title: const Text("Passenger"),
        leading: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const GettingStarted()));
          },
          child: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(
                height: 70,
              ),
              Center(
                  child: Image.asset(
                'assets/logo.png',
                height: 150,
                width: 150,
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
                    if (!RegExp(r'(^(?:[+0]9)?[0-9]{11}$)').hasMatch(value)) {
                      return "Enter correct number";
                    }
                    if (value.startsWith("0")) {
                      return "please start with country code";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "+923012587759",
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
                  controller: nameController,
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
                  title: "LOGIN",
                  loading: loading,
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      loginWithPhone();
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
