import 'package:clock_app/homepage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const clockApp());
}

// ignore: camel_case_types
class clockApp extends StatelessWidget {
  const clockApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Homepage(),
    );
  }
}
