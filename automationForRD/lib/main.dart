import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pave_track_master/Presentation/Pages/acc_page.dart';
import 'package:pave_track_master/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const AccActivity(),
      },
    );
  }
}
