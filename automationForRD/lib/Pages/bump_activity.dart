// ignore_for_file: non_constant_identifier_names

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../classes_functions.dart/data_point.dart';

class BumpActvity extends StatefulWidget {
  const BumpActvity({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _BumpActvityState createState() => _BumpActvityState();
}

class _BumpActvityState extends State<BumpActvity> {
  static const int windowSize =
      600; // Number of data points to display in the window

  bool flagA = false;
  bool flagX = false;
  bool flagY = false;
  bool flagZ = false;
  DateTime time1 = DateTime.now();
  double noOfData = 20.0;

  // Lists to store acceleration data for X, Y, and Z axes
  final List<DataPoint> _accelerationData_X = [];
  final List<DataPoint> _accelerationData_Y = [];
  final List<DataPoint> _accelerationData_Z = [];
  final List<DataPoint> _accelerationData_Z1 = [];

  // List to store current accelerometer readings
  List<double> _accelerometerReading = [0, 0, 0];
  late TooltipBehavior _tooltipBehavior;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
    // Listen to accelerometer events
    userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      if (mounted) {
        setState(() {
          if (_accelerationData_Z.length >= windowSize &&
              _accelerationData_Z1.length >= windowSize) {
            _accelerationData_Z.removeAt(0);
            _accelerationData_Z1.removeAt(0);
          }
          _accelerometerReading = <double>[event.x, event.y, event.z];
          // Determine if any axis has significant acceleration
          bool hasAcceleration =
              _accelerometerReading.any((value) => value.abs() >= 0.1);
          if (flagA && hasAcceleration) {
            DateTime currentTime = DateTime.now();
            _accelerationData_X
                .add(DataPoint(x: currentTime, y: _accelerometerReading[0]));
            _accelerationData_Y
                .add(DataPoint(x: currentTime, y: _accelerometerReading[1]));
            _accelerationData_Z
                .add(DataPoint(x: currentTime, y: _accelerometerReading[2]));

            // Storing z component of acceleration rounded up to two decimal places
            _accelerationData_Z1.add(DataPoint(
                x: currentTime,
                y: double.parse(_accelerometerReading[2].toStringAsFixed(2))));
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: const Text(
          "Accelerometer",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            // Acceleration - Time Graph
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SizedBox(
                child: SfCartesianChart(
                  title: ChartTitle(
                    text: 'z-Acceleration',
                    textStyle: GoogleFonts.raleway(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  primaryXAxis: DateTimeAxis(
                    isVisible: false,
                    maximum: flagA ? DateTime.now() : time1,
                  ),
                  legend: Legend(
                    isVisible: true,
                    position: LegendPosition.top,
                  ),
                  borderColor: Colors.transparent,
                  backgroundColor: Colors.transparent,
                  enableAxisAnimation: true,
                  plotAreaBorderColor: Colors.black,
                  tooltipBehavior: _tooltipBehavior,
                  series: <ChartSeries>[
                    // Raw Data
                    LineSeries<DataPoint, DateTime>(
                      enableTooltip: true,
                      dataSource: _accelerationData_Z,
                      xValueMapper: (DataPoint data, _) => data.x,
                      yValueMapper: (DataPoint data, _) => data.y,
                      color: Colors.blue,
                      width: 1,
                      name: 'Raw data',
                      animationDuration: 2500,
                    ),

                    // Smoothed Data
                    LineSeries<DataPoint, DateTime>(
                      enableTooltip: true,
                      dataSource: simpleMovingAverage(
                          _accelerationData_Z1, noOfData.toInt()),
                      xValueMapper: (DataPoint data, _) => data.x,
                      yValueMapper: (DataPoint data, _) => data.y,
                      color: Colors.black,
                      width: 2,
                      name: 'Smoothed data',
                      animationDuration: 2500,
                      markerSettings: const MarkerSettings(
                        isVisible: false,
                        width: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Slider For Sensitivity (How many values to take for average)
            SfSlider(
              min: 5.0,
              max: 100.0,
              interval: 10,
              showTicks: true,
              showLabels: true,
              enableTooltip: true,
              value: noOfData,
              onChanged: (dynamic newValue) {
                setState(() {
                  noOfData = newValue;
                });
              },
            ),

            // Start and End buttons for data collection
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _accelerationData_X.clear();
                        _accelerationData_Y.clear();
                        _accelerationData_Z.clear();
                        _accelerationData_Z1.clear();
                        flagA = true;
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.black87),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                    child: const Text('Start'),
                  ),
                ),

                // End button
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      time1 = DateTime.now();
                      flagA = false;
                    });

                    // Calculate smoothed data and log it
                    List<DataPoint> smootheddata = simpleMovingAverage(
                        _accelerationData_Z1, noOfData.toInt());
                    log('Smoothed data $smootheddata');
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.black87),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                  child: const Text('End'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Simple moving average for acceleration value received
List<DataPoint> simpleMovingAverage(List<DataPoint> accData, int parameter) {
  List<DataPoint> smoothedData = [];
  int count = -1;
  for (int i = parameter - 1; i < accData.length; i++) {
    double avgValue = 0.0;
    count++;
    for (int j = i; j >= count; j--) {
      avgValue += accData[j].y;
    }
    smoothedData.add(DataPoint(x: accData[i].x, y: avgValue / parameter));
  }
  return smoothedData;
}

