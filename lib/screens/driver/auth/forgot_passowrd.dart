import 'package:drive_sharing_app/utils/utils.dart';
import 'package:drive_sharing_app/widgets/round_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff4BA0FE),
        title: const Text("Forgot Password"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
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
              const SizedBox(
                height: 20,
              ),
              RoundButton(
                  title: "Forgot",
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      auth
                          .sendPasswordResetEmail(
                              email: emailController.text.toString())
                          .then((value) {
                        Utils().toastMessage(
                            "We have sent email to recover password, please check email");
                      }).onError((error, stackTrace) {
                        Utils().toastMessage(error.toString());
                      });
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }
}
