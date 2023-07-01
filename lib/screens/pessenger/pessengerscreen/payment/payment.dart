// ignore_for_file: must_be_immutable
import 'dart:convert';
import 'package:drive_sharing_app/screens/pessenger/pessengerscreen/pass/pessenger_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class Payment extends StatefulWidget {
  String? price;
  Payment({super.key, required this.price});

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  Map<String, dynamic>? paymentINtent;
  String? selectedPaymentOption;

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
      await Stripe.instance.presentPaymentSheet();
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
