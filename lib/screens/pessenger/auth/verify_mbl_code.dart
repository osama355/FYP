import 'package:drive_sharing_app/screens/pessenger/pessengerscreen/pessenger_home_screen.dart';
import 'package:drive_sharing_app/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../widgets/round_button.dart';

class VerifyMblCodeScreen extends StatefulWidget {
  final String verificationId;

  const VerifyMblCodeScreen({
    super.key,
    required this.verificationId,
  });

  @override
  State<VerifyMblCodeScreen> createState() => _VerifyMblCodeScreenState();
}

class _VerifyMblCodeScreenState extends State<VerifyMblCodeScreen> {
  bool loading = false;
  final verifyCodeController = TextEditingController();
  final auth = FirebaseAuth.instance;

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
                    onTap: () async {
                      setState(() {
                        loading = true;
                      });
                      final credentials = PhoneAuthProvider.credential(
                          verificationId: widget.verificationId,
                          smsCode: verifyCodeController.text.toString());
                      try {
                        await auth.signInWithCredential(credentials);
                        // ignore: use_build_context_synchronously
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const PessePostScreen()));
                      } catch (e) {
                        setState(() {
                          loading = false;
                        });
                        Utils().toastMessage(e.toString());
                      }
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
