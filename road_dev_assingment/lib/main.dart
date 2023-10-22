 import 'package:flutter/material.dart';
import 'package:road_dev_assingment/Pages/location_activity.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:Scaffold(
      appBar: AppBar(
        title: const Text("Location Activity"),
      ),
      body: const LocationActivity()
    )
    );
  }
}
