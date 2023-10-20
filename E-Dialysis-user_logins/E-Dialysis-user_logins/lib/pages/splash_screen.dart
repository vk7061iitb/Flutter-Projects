import 'package:edialysis/pages/role_selection.dart';
import 'package:edialysis/pages/logins/signup.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'logins/login_page.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();

    // Add a delay of 4 seconds before navigating to the login page
    Future.delayed(Duration(seconds: 3), () {
      // Navigate to the login page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => RoleSelection()),
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Lottie.network('https://lottie.host/8577f454-f813-4d85-b1e1-22f4079753f6/8UHJ6x1SBv.json',
        height: 250),
      ),
    );
  }
}
