import 'package:drive_sharing_app/screens/signup_screen.dart';
import 'package:drive_sharing_app/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:drive_sharing_app/screens/home.dart';
import 'package:drive_sharing_app/widgets/round_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool loading = false;
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
          context, MaterialPageRoute(builder: (context) => const Home()));
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
        appBar: AppBar(
          title: const Text("Login"),
          backgroundColor: const Color(0xff4BA0FE),
        ),
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
                        return 'Email Address';
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
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignUp()));
                        },
                        child: const Text("Singup"))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
