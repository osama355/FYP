import 'package:drive_sharing_app/screens/driver/auth/forgot_passowrd.dart';
import 'package:drive_sharing_app/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:drive_sharing_app/screens/driver/driverscreens/driver_post_screen.dart';
import 'package:drive_sharing_app/widgets/round_button.dart';

class DriveLoginScreen extends StatefulWidget {
  const DriveLoginScreen({super.key});

  @override
  State<DriveLoginScreen> createState() => _DriveLoginScreenState();
}

class _DriveLoginScreenState extends State<DriveLoginScreen> {
  bool loading = false;
  bool obsecureText = true;
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passController.dispose();
  }

  void login() {
    setState(() {
      loading = true;
    });
    _auth
        .signInWithEmailAndPassword(
            email: emailController.text.toString(),
            password: passController.text.toString())
        .then((value) {
      Utils().toastMessage(value.user!.email.toString());
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const DriverPost()));
      setState(() {
        loading = false;
      });
    }).onError((error, stackTrace) {
      debugPrint(error.toString());
      Utils().toastMessage(error.toString());
      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
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
                    keyboardType: TextInputType.text,
                    controller: passController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Enter Password";
                      }
                      return null;
                    },
                    obscureText: obsecureText,
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: "Password",
                        hintStyle:
                            const TextStyle(color: Colors.grey, fontSize: 17.0),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              obsecureText = !obsecureText;
                            });
                          },
                          child: Icon(
                            obsecureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: const Color(0xff4BA0FE),
                          ),
                        )),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                RoundButton(
                  title: 'Login',
                  loading: loading,
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      login();
                    }
                  },
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ForgotPasswordScreen()));
                      },
                      child: const Text(
                        "Forgot Password ?",
                        style: TextStyle(color: Color(0xff4BA0FE)),
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
