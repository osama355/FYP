import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [navigationOption()],
      )),
    );
  }

  Widget navigationOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () {},
          child: const Text(
            'SignUp',
            style: TextStyle(color: Color(0xff4BA0FE), fontSize: 25),
          ),
        ),
        InkWell(
          onTap: () {},
          child: const Text(
            'Login',
            style: TextStyle(color: Color(0xff4BA0FE), fontSize: 25),
          ),
        )
      ],
    );
  }
}
