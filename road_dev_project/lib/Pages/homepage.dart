import 'package:flutter/material.dart';
import 'package:road_dev_project/Pages/location.dart';

class Homepage extends StatefulWidget {
  const Homepage ({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return const LocationActivity();
  }
}

