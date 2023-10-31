import 'package:assingment_1/Pages/location_activity.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
Widget build(BuildContext context) {
  return Directionality(
    textDirection: TextDirection.ltr, // or TextDirection.rtl for right-to-left languages
    child: MaterialApp(
      routes: {
        '/': (context) => const LocationActivity(),
        //MyRoutes.locationRoute :(context) => const LocationActivity(),
        //MyRoutes.accelerometerRoute :(context) => const AccelerometerActvity(),

      },
    ),
  );
}
}
