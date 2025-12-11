import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';

class FlashScreen extends StatefulWidget {
  const FlashScreen({super.key});

  @override
  FlashScreenState createState() => FlashScreenState();
}

class FlashScreenState extends State<FlashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 1), () {
      context.go('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/img/aposicon.png',
              width: 80,
              height: 80,
            ),
            SizedBox(height: 3),
            Text(
              'ಅಪೊಸ್ತಲಿಕ ಕ್ರೈಸ್ತತ್ವ',
              style: TextStyle(
                fontSize: 32,
                color: Colors.black,
                fontFamily: 'BalooTamma2ExtraBold',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
