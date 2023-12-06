import 'package:flutter/material.dart';
import 'package:road_dev_project/Pages/location.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LocationActivity(),
    );
  }
}
