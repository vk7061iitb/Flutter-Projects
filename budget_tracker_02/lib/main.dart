import 'package:budget_tracker_02/Pages/login_page.dart';
import 'package:budget_tracker_02/Pages/signup_page.dart';
import 'package:budget_tracker_02/Pages/splash_screen.dart';
import 'package:budget_tracker_02/utils/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'Pages/balance_homepage.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const BudgetTrackerApp()); // Run the BudgetTrackerApp
}

class BudgetTrackerApp extends StatelessWidget {
  const BudgetTrackerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Budget Tracker',
      theme: ThemeData(fontFamily: 'Lexend'),
      routes: {
        "/": (context) => (FirebaseAuth.instance.currentUser != null)
            ? const SplashScreen()
            : const LoginPage(),
        MyRoutes.homeRoute: (context) => const BudgetTrackerHomePage(),
        MyRoutes.signupRoute: (context) => const SignUpScreen(),
      },
    );
  }
}
