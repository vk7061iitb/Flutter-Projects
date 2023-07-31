import 'package:budget_tracker/Pages/balance_homepage.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(const BudgetTrackerApp()); // Run the BudgetTrackerApp
}

class BudgetTrackerApp extends StatelessWidget {
  const BudgetTrackerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget Tracker',
      theme: ThemeData(fontFamily: 'Lexend'),
      routes: {
        "/": (context) => const BudgetTrackerHomePage(),
      },
    );
  }
}
