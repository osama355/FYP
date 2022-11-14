import 'package:drive_sharing_app/screens/pessenger/pessengerscreen/pessenger_home_screen.dart';
import 'package:drive_sharing_app/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../widgets/round_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VerifyMblCodeScreen extends StatefulWidget {
  final String verificationId;
  final TextEditingController phonenumber;
  final TextEditingController name;

  const VerifyMblCodeScreen(
      {super.key,
      required this.verificationId,
      required this.phonenumber,
      required this.name});

  @override
  State<VerifyMblCodeScreen> createState() => _VerifyMblCodeScreenState();
}

class _VerifyMblCodeScreenState extends State<VerifyMblCodeScreen> {
  bool loading = false;
  final verifyCodeController = TextEditingController();
  final auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void verifyCode() async {
    setState(() {
      loading = true;
    });
    final credentials = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: verifyCodeController.text.toString());
    try {
      await auth.signInWithCredential(credentials);
      final currentUser = auth.currentUser;
      final uid = currentUser?.uid;
      _firestore
          .collection("app")
          .doc("user")
          .collection("pessenger")
          .doc(uid)
          .set({
        'phone': widget.phonenumber.text,
        'name': widget.name.text,
        'status': 'pessenger',
        'dp': ""
      });

      // ignore: use_build_context_synchronously
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const PessePostScreen()));
    } catch (e) {
      setState(() {
        loading = false;
      });
      Utils().toastMessage(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 200,
            child: Column(
              children: [
                const SizedBox(
                  height: 100,
                ),
                TextFormField(
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(6),
                  ],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, letterSpacing: 5),
                  controller: verifyCodeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "6 digit code",
                    hintStyle: TextStyle(
                        color: Color.fromARGB(255, 162, 150, 150),
                        fontSize: 17.0),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                RoundButton(
                    title: "VERIFY",
                    loading: loading,
                    onTap: () {
                      verifyCode();
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
