import 'package:flutter/material.dart';
import 'package:notes_app/pages/list_view.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: NotesList(),
        )
      ),
    );
  }
}
