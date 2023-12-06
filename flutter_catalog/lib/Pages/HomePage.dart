// ignore_for_file: file_names

import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final int days = 30;
  final name = "Codepur";

  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Catalog App"),
      ),
      body: const Center(child: Text("Welcome To $days Days of Flutter by $name")),
      drawer: const Drawer(),
    );
  }
}
