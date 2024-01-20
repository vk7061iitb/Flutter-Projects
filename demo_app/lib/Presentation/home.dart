import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Database/db_helper.dart';
import '../Database/label_data.dart';
import 'custom_appbar.dart';
import 'custom_snackbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SQLDatabaseHelper dbHelper = SQLDatabaseHelper();
  List<LabelType> labelData = [];

  @override
  void initState() {
    super.initState();
    dbHelper.initializeDatabase();
  }

  Future<void> insertAllData() async {
    dbHelper.insertLabelData(labelData);
  }

  Future<void> showProgressBar() async {
    String message = '';
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  color: Colors.black,
                ),
                const SizedBox(height: 16),
                Text(
                  'Exporting CSV File',
                  style: GoogleFonts.raleway(
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    await dbHelper.deleteAllData();
    await insertAllData();
    if (context.mounted) Navigator.of(context).pop();
    message = await dbHelper.exportToCSV();
    setState(() {});
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(customSnackBar(message));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Road Quality',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: OutlinedButton(
              onPressed: () {
                labelData
                    .add(LabelType(currentTime: DateTime.now(), roadType: '1'));
                setState(() {});
              },
              child: const Text('1'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: OutlinedButton(
              onPressed: () {
                labelData
                    .add(LabelType(currentTime: DateTime.now(), roadType: '2'));
                setState(() {});
              },
              child: const Text('2'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: OutlinedButton(
              onPressed: () {
                labelData
                    .add(LabelType(currentTime: DateTime.now(), roadType: '3'));
                setState(() {});
              },
              child: const Text('3'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: OutlinedButton(
              onPressed: () {
                labelData
                    .add(LabelType(currentTime: DateTime.now(), roadType: '4'));
              },
              child: const Text('4'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: OutlinedButton(
              onPressed: () {
                labelData
                    .add(LabelType(currentTime: DateTime.now(), roadType: '5'));
                setState(() {});
              },
              child: const Text('5'),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: OutlinedButton(
                  onPressed: () {
                    labelData.clear();
                    setState(() {});
                  },
                  child: const Text('Start'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: OutlinedButton(
                  onPressed: () {
                    showProgressBar();
                    setState(() {});
                  },
                  child: const Text('End'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
