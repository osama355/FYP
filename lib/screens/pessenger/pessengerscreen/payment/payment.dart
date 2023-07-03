// ignore_for_file: must_be_immutable, avoid_print
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_sharing_app/screens/pessenger/pessengerscreen/pass/pessenger_home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class Payment extends StatefulWidget {
  String? price;
  String? driver_id;
  Payment({super.key, required this.price, required this.driver_id});

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  Map<String, dynamic>? paymentINtent;
  String? selectedPaymentOption;

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  sendNotification1(
      String title, String token, String passName, String price) async {
    final data = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'id': 1,
      'status': 'done',
      'message': title
    };
    try {
      http.Response response =
          await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: <String, String>{
                'Content-Type': 'application/json',
                'Authorization':
                    'key=AAAADnkker0:APA91bEJO2ufASuDfJNV6yaKiiAES-O0X-jkQW2UL1ciN8hVCgXkCKSsKAQ4jO_7UNUzwrwVAC0iX3Ihu4xvLwsJifoYkVzo1QbYMyJyBXNj4_5f-S39WR9AI2QsYGzBc_jz5myyY5re'
              },
              body: jsonEncode(<String, dynamic>{
                'notification': <String, dynamic>{
                  'title': title,
                  'body': 'You have recieved Rs $price from $passName'
                },
                'priority': 'high',
                'data': data,
                'to': token
              }));

      if (response.statusCode == 200) {
        print("Notification has been send");
      } else {
        print("Somethin went wrong");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void makePayment() async {
    try {
      paymentINtent = await createPaymentIntent();
      var gpay = const PaymentSheetGooglePay(
          merchantCountryCode: "PK", currencyCode: "PKR", testEnv: true);
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentINtent!['client_secret'],
              merchantDisplayName: 'Osama',
              googlePay: gpay,
              style: ThemeMode.light));

      displyPaymentSheet();
    } catch (e) {
      print(e.toString());
    }
  }

  displyPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) async {
        var driverDocSnapshot = await firestore
            .collection('app')
            .doc('user')
            .collection('driver')
            .doc(widget.driver_id)
            .get();
        var token = await driverDocSnapshot.data()?['token'];

        var passDocSnapshot = await firestore
            .collection('app')
            .doc('user')
            .collection('pessenger')
            .doc(auth.currentUser!.uid)
            .get();
        var passName = await passDocSnapshot.data()?['name'];
        sendNotification1('Payment', token, passName, widget.price!);
      }).onError((error, stackTrace) {
        print('Error is:--->$error $stackTrace');
      });
      print("done");
    } catch (e) {
      print('Failed');
    }
  }

  createPaymentIntent() async {
    try {
      Map<String, dynamic> body = {
        "amount": "${widget.price}00",
        "currency": "PKR",
      };

      http.Response response = await http.post(
          Uri.parse("https://api.stripe.com/v1/payment_intents"),
          body: body,
          headers: {
            "Authorization":
                "Bearer sk_test_51KBPsTJa2WHpSkDzIPZjqZ0Ns4Y53xPPLYmMBYZxQ2Y5bA9r74fGqKjyCaVG8tJfSzZb3Wr70azWmse7wLljowAK00XSx7slAZ",
            "Content-Type": "application/x-www-form-urlencoded",
          });
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stripe Payment'),
        backgroundColor: const Color(0xff4BA0FE),
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 20.0),
              child: const Text(
                'Select Payment Option',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            RadioListTile(
              title: const Text('Cash'),
              value: 'Cash',
              groupValue: selectedPaymentOption,
              onChanged: (value) {
                setState(() {
                  selectedPaymentOption = value.toString();
                });
              },
            ),
            RadioListTile(
              title: const Text('Online Payment'),
              value: 'Online Payment',
              groupValue: selectedPaymentOption,
              onChanged: (value) {
                setState(() {
                  selectedPaymentOption = value.toString();
                  makePayment(); // Call makePayment function when "Online Payment" is selected
                });
              },
            ),
            const SizedBox(height: 40.0),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const PessePostScreen())); // Go back to the previous screen
                },
                icon: const Icon(Icons.home),
                label: const Text('Go Back to the Home Screen'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff4BA0FE),
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 20.0),
                  textStyle: const TextStyle(
                    fontSize: 18.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
