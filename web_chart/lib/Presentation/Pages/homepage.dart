import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web_chart/Classes%20&%20Functions/bin_search.dart';
import 'package:web_chart/Classes%20&%20Functions/csv_file_picker.dart';
import 'package:web_chart/Presentation/Widgets/custom_fl_chart.dart';

import '../../Classes & Functions/data_point.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<dynamic> csvData = [];
  List<DataPoint> xAcc = [];
  List<DataPoint> flxAcc = [];
  List<DataPoint> yAcc = [];
  List<DataPoint> flyAcc = [];
  List<DataPoint> zAcc = [];
  List<DataPoint> flzAcc = [];
  TextEditingController startController = TextEditingController();
  TextEditingController endController = TextEditingController();
  PickCSVfile csvFilePicker = PickCSVfile();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 5,
            left: 10,
            right: 3 * (MediaQuery.of(context).size.width / 4),
            child: OutlinedButton(
              onPressed: () async {
                csvData = await csvFilePicker.getCSV();
                xAcc = await csvFilePicker.getCSVdataByRow(0, 5, csvData);
                yAcc = await csvFilePicker.getCSVdataByRow(1, 5, csvData);
                zAcc = await csvFilePicker.getCSVdataByRow(2, 5, csvData);
              },
              child: Text(
                'Pick CSV File',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
          Positioned(
            top: 5,
            left: 3 * (MediaQuery.of(context).size.width / 4),
            right: 0,
            child: OutlinedButton(
              onPressed: () {
                int indexNo =
                    customLinearSearch(xAcc, startController.text);
                Future.delayed(const Duration(seconds: 1));
                if (kDebugMode) {
                  print('Hello');
                  print('$indexNo');
                }
                setState(() {});
              },
              child: Text(
                'Plot Data',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            child: SizedBox(
              width: 100,
              child: Column(
                children: [
                  TextFormField(
                    controller: startController,
                    style: GoogleFonts.raleway(
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      border: const UnderlineInputBorder(),
                      labelText: 'Start Time',
                      hintText: '10:04:24',
                      hintStyle: GoogleFonts.raleway(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      labelStyle: GoogleFonts.raleway(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      // You can add more styling options here
                    ),
                  ),
                  TextFormField(
                    controller: endController,
                    style: GoogleFonts.raleway(
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      border: const UnderlineInputBorder(),
                      labelText: 'End Time',
                      hintText: '10:04:24',
                      hintStyle: GoogleFonts.raleway(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      labelStyle: GoogleFonts.raleway(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      // You can add more styling options here
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 75,
            left: 10,
            right: 10,
            child: SizedBox(
              height: 0.7 * MediaQuery.of(context).size.height,
              width: 0.8 * MediaQuery.of(context).size.width,
              child: CustomFlChart(
                  aXraw: xAcc,
                  aYraw: yAcc,
                  aZraw: zAcc,
                  flagxAcceleration: true,
                  flagyAcceleration: true,
                  flagzAcceleration: true),
            ),
          ),
        ],
      ),
    );
  }
}
