import 'dart:async';
import 'package:budget_tracker_02/Pages/balance_homepage.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    // After 5 seconds, change opacity to 1 and navigate
    Timer(
      const Duration(seconds: 4),
      () {
        setState(() {
          _opacity = 1.0;
        });

        Future.delayed(const Duration(seconds: 5), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const BudgetTrackerHomePage(),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 150),
              Padding(
                padding: const EdgeInsets.all(8.0),
                // ignore: avoid_unnecessary_containers
                child: Container(
                  child: Image.asset("assets/images/Manage money.gif"),
                ),
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: _opacity,
                child: const Text(
                  "Navigate Your Budget Like a Pro",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
