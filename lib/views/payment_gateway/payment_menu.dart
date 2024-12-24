import 'package:flutter/material.dart';
import 'package:kenorider_driver/utiles/index.dart';
import 'package:kenorider_driver/views/payment_gateway/credit_card.dart';

class PaymentMenuScreen extends StatefulWidget {
  const PaymentMenuScreen({super.key});

  @override
  PaymentMenuScreenState createState() => PaymentMenuScreenState();
}

class PaymentMenuScreenState extends State<PaymentMenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Payment Method'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_sharp),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.only(left: vww(context, 4), right: vww(context, 4), top: vww(context, 2)),
        child: ListView(
          children: [
            ListTile(
              visualDensity: const VisualDensity(vertical: -4),
              leading: const Icon(Icons.credit_card, color: Colors.teal, size: 24),
              title: const Text('Credit or Debit Card'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const CreditCardScreen(),
                ));
              },
            ),
            const Divider(),
            ListTile(
              visualDensity: const VisualDensity(vertical: -4),
              leading: const Icon(Icons.paypal, color: Colors.teal, size: 24),
              title: const Text('PayPal'),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              visualDensity: const VisualDensity(vertical: -4),
              leading: const Icon(Icons.wallet, color: Colors.teal, size: 24),
              title: const Text('Google Pay'),
              onTap: () {},
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
