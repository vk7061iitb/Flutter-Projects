import 'package:edialysis/pages/home_page.dart';
import 'package:edialysis/pages/logins/hp_login_page.dart';
import 'package:edialysis/pages/logins/hp_signup.dart';
import 'package:edialysis/pages/logins/hp_signup2.dart';
import 'package:edialysis/pages/logins/hp_signup3.dart';
import 'package:edialysis/pages/logins/login_page.dart';
import 'package:edialysis/pages/logins/signup.dart';
import 'package:edialysis/pages/logins/signup2.dart';
import 'package:edialysis/pages/splash_screen.dart';
import 'package:edialysis/themes/light_theme.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'E-Dialysis',
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      home: HomePage(),
    );
  }
}
