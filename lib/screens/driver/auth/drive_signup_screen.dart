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
  bool obsecureText1 = true;
  bool obsecureText2 = true;
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final nicController = TextEditingController();
  final passController = TextEditingController();
  final conPassController = TextEditingController();
  final carNumController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    phoneController.dispose();
    nameController.dispose();
    nicController.dispose();
    carNumController.dispose();
    passController.dispose();
  }

  // _firestore.collection("driver/").doc(user?.uid).set({

  void signUp() {
    setState(() {
      loading = true;
    });
    _auth
        .createUserWithEmailAndPassword(
            email: emailController.text.toString(),
            password: passController.text.toString())
        .then((value) {
      setState(() {
        loading = false;
      });
      final user = _auth.currentUser;
      _firestore
          .collection("app")
          .doc("user")
          .collection("driver")
          .doc(user?.uid)
          .set({
        'email': emailController.text,
        'phone': phoneController.text,
        'name': nameController.text,
        'cnic': nicController.text,
        'car_number': carNumController.text,
      });
      emailController.clear();
      passController.clear();
      nameController.clear();
      conPassController.clear();
      phoneController.clear();
      nicController.clear();
      carNumController.clear();
      Utils().toastMessage("Successfully Registered");
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
                      size: 20,
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
                    if (!RegExp(r'(^(?:[+0]9)?[0-9]{11}$)').hasMatch(value)) {
                      return "Enter correct number";
                    }
                    if (value.startsWith("0")) {
                      return "Please start with country code";
                    }
                    return null;
                  },
                  controller: phoneController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "+923589637442",
                    hintStyle: TextStyle(
                        color: Color.fromARGB(255, 162, 150, 150),
                        fontSize: 17.0),
                    suffixIcon: Icon(
                      Icons.phone,
                      size: 20,
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
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter your CNIC";
                    }
                    if (!RegExp(r'^[0-9]{5}-[0-9]{7}-[0-9]$').hasMatch(value)) {
                      return "Enter correct CNIC ";
                    }

                    return null;
                  },
                  controller: nicController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "CNIC : xxxxx-xxxxxxx-x",
                    hintStyle: TextStyle(
                        color: Color.fromARGB(255, 162, 150, 150),
                        fontSize: 17.0),
                    suffixIcon: Icon(
                      Icons.perm_identity,
                      size: 20,
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
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please enter car number";
                    }
                    if (!RegExp(r'^[A-Z]{1,3}-[0-9]{1,4}$').hasMatch(value)) {
                      return "Enter correct car number";
                    }
                    return null;
                  },
                  controller: carNumController,
                  decoration: const InputDecoration(
                    suffixIcon: Icon(
                      Icons.car_rental,
                      color: Color(0xff4BA0FE),
                      size: 20,
                    ),
                    border: OutlineInputBorder(),
                    hintText: "Car Number",
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
                  obscureText: obsecureText1,
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: "Password",
                      hintStyle:
                          const TextStyle(color: Colors.grey, fontSize: 17.0),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            obsecureText1 = !obsecureText1;
                          });
                        },
                        child: Icon(
                          obsecureText1
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 20,
                          color: const Color(0xff4BA0FE),
                        ),
                      )),
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
                      return "Please confirm password";
                    }
                    if (value != passController.text) {
                      return "Password does not match";
                    }
                    return null;
                  },
                  controller: conPassController,
                  obscureText: obsecureText2,
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: "Confirm Password",
                      hintStyle:
                          const TextStyle(color: Colors.grey, fontSize: 17.0),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            obsecureText2 = !obsecureText2;
                          });
                        },
                        child: Icon(
                          obsecureText2
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 20,
                          color: const Color(0xff4BA0FE),
                        ),
                      )),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              RoundButton(
                title: "Register",
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
