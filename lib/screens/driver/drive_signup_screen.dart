import 'package:drive_sharing_app/screens/driver/driver_login_screen.dart';
import 'package:drive_sharing_app/utils/utils.dart';
import 'package:drive_sharing_app/widgets/round_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DriveSignUp extends StatefulWidget {
  const DriveSignUp({super.key});

  @override
  State<DriveSignUp> createState() => _DriveSignUp();
}

class _DriveSignUp extends State<DriveSignUp> {
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final passController = TextEditingController();
  final conPassController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    phoneController.dispose();
    nameController.dispose();
    passController.dispose();
  }

  void signUp() {
    setState(() {
      loading = true;
    });
    _auth
        .createUserWithEmailAndPassword(
            email: emailController.text.toString(),
            password: passController.text.toString())
        .then((value) {
      final user = _auth.currentUser;
      _firestore.collection("driver/").doc(user?.uid).set({
        'email': emailController.text,
        'phone': phoneController.text,
        'name': nameController.text,
      });
      setState(() {
        loading = false;
      });

      emailController.clear();
      passController.clear();
      nameController.clear();
      conPassController.clear();
      passController.clear();
      phoneController.clear();
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const DriveLoginScreen()));
    }).onError((error, stackTrace) {
      Utils().toastMessage(error.toString());
      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(
                height: 20,
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
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter your email';
                    }
                    if (!RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+$')
                        .hasMatch(value)) {
                      return 'Enter correct email';
                    }
                    return null;
                  },
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
                child: TextFormField(
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
                  controller: phoneController,
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
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  controller: passController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter Password";
                    }
                    return null;
                  },
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
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "confirm password";
                    }
                    if (value != passController.text) {
                      return "Password does not match";
                    }
                    return null;
                  },
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
              RoundButton(
                title: "CONTINUE",
                loading: loading,
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    signUp();
                  }
                },
              ),
              const SizedBox(
                height: 30,
              )
            ],
          ),
        ),
      ),
    );
  }
}
