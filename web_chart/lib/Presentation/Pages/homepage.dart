import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web_chart/Classes%20&%20Functions/csv_download.dart';
import 'package:web_chart/Classes%20&%20Functions/csv_file_picker.dart';
import '../../Classes & Functions/datapoint2.dart';
import '../../Classes & Functions/linear_search.dart';
import '../Widgets/fl_chart.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<dynamic> csvData = [];
  PickCSVfile csvFilePicker = PickCSVfile();
  TextEditingController endController = TextEditingController();
  bool flag = false;
  List<DataPoint2> flxAcc = [];
  List<DataPoint2> flyAcc = [];
  List<DataPoint2> flzAcc = [];
  // Sample list data
  List<List<dynamic>> myData = [
    ['z_acc', 'Time'],
  ];

  TextEditingController startController = TextEditingController();
  List<DataPoint2> xAcc = [];
  List<DataPoint2> yAcc = [];
  List<DataPoint2> zAcc = [];

  void zoomIn() {
    int startIndex = customLinearSearch2(zAcc, startController.text);
    int endIndex = customLinearSearch2(zAcc, endController.text);
    flzAcc.clear();

    for (int i = startIndex; i <= endIndex; i++) {
      flzAcc.add(zAcc[i]);
    }
  }

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
                // Getting The Data
                csvData = await csvFilePicker.getCSV();
                zAcc = await csvFilePicker.getCSVdataByRow(1, 0, csvData);
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
              onPressed: () async {
                setState(() {
                  flag = !flag;
                });
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
            bottom: 10,
            left: 150,
            child: OutlinedButton(
              onPressed: () async {
                setState(() {});
                flag = false;
                zoomIn();
                setState(() {});
              },
              child: Text(
                'Zoom In',
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
            right: 10,
            child: OutlinedButton(
              onPressed: () async {
                for (int i = 0; i < flzAcc.length; i++) {
                  myData.add([flzAcc[i].accValue, flzAcc[i].timeDifference]);
                }
                downloadCSV(myData, 'zommedData');
                setState(() {});
              },
              child: Text(
                'Export Data',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
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
              child: CustomFlChart2(
                  aXraw: flag ? xAcc : flxAcc,
                  aYraw: flag ? yAcc : flyAcc,
                  aZraw: flag ? zAcc : flzAcc,
                  flagxAcceleration: false,
                  flagyAcceleration: false,
                  flagzAcceleration: true),
            ),
          ),
        ],
      ),
    );
  }
}
