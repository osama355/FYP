import 'package:drive_sharing_app/screens/pessenger/pessengerscreen/pessenger_sidebar.dart';
import 'package:flutter/material.dart';

class PessePostScreen extends StatefulWidget {
  const PessePostScreen({super.key});

  @override
  State<PessePostScreen> createState() => _PessePostScreenState();
}

class _PessePostScreenState extends State<PessePostScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const PessengerSidebar(),
      appBar: AppBar(
        backgroundColor: const Color(0xff4BA0FE),
        centerTitle: false,
        title: const Text("Home"),
      ),
      body: const Center(
        child: Text("Pessenger"),
      ),
    );
  }
}
