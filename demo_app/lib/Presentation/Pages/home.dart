import 'package:demo_app/Functions/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../Database/db_helper.dart';
import '../../Classes/label_data.dart';
import '../Widgets/custom_appbar.dart';
import '../Widgets/custom_snackbar.dart';
import '../Widgets/pci_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SQLDatabaseHelper dbHelper = SQLDatabaseHelper();
  String img1path = 'assets/Images/PCI01.png';
  String img2path = 'assets/Images/PCI02.png';
  String img3path = 'assets/Images/PCI03.png';
  String img4path = 'assets/Images/PCI04.png';
  String img5path = 'assets/Images/PCI05.png';
  String img6path = 'assets/Images/PCI06.png';
  List<LabelType> labelData = [];
  String roadType1 = 'Good-1';
  String roadType2 = 'Average-2';
  String roadType3 = 'Bad-3';
  String roadType4 = 'Very Bad-4';
  String roadType5 = 'Unpaved Road-5';
  String roadType6 = 'Type-6';

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
          PCIButton(
            onPressed: () {},
            label: roadType1,
            imgPath: img1path,
          ),
          PCIButton(
            onPressed: () {},
            label: roadType2,
            imgPath: img2path,
          ),
          const Gap(5),
          PCIButton(
            onPressed: () {},
            label: roadType3,
            imgPath: img3path,
          ),
          PCIButton(
            onPressed: () {},
            label: roadType4,
            imgPath: img4path,
          ),
          const Gap(5),
          PCIButton(
            onPressed: () {},
            label: roadType5,
            imgPath: img5path,
          ),
          PCIButton(
            onPressed: () {},
            label: roadType6,
            imgPath: img6path,
          ),
          const Gap(5),
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: OutlinedButton(
              onPressed: () {
                openFilePicker();
                setState(() {});
              },
              child: const Text('Pick A File'),
            ),
          ),
        ],
      ),
    );
  }
}
