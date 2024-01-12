import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'homepage.dart';

void main() {
  runApp(const MyNotesApp());
}

class MyNotesApp extends StatelessWidget {
  const MyNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Notes App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const CounterScreen(),
    );
  }
}

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  CounterScreenState createState() => CounterScreenState();
}

class CounterScreenState extends State<CounterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Notes App',
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
        ),
        body: const NotesHomePage());
  }
}
