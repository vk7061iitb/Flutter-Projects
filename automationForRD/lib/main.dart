import 'package:flutter/material.dart';
import 'package:pave_track_master/Pages/bump_activity.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const BumpActivity(),
        // MyRoutes.locationRoute :(context) => const LocationActivity(),
        // MyRoutes.accelerometerRoute :(context) => const AccelerometerActvity(),
      },
    );
  }
}


