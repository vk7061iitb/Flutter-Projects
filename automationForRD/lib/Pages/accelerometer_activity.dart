import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pave_track_master/classes_functions.dart/area_under_at_curve.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../classes_functions.dart/data_point.dart';

class AccelerometerActvity extends StatefulWidget {
  const AccelerometerActvity({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AccelerometerActivityState createState() => _AccelerometerActivityState();
}

class _AccelerometerActivityState extends State<AccelerometerActvity> {
// Storing accelerometer readings for X, Y, and Z axes
  List<double> _accelerometerReading = [0, 0, 0];
// Creating a list _accelerationDatapoint to store element of type DataPoint
  final List<DataPoint> _accelerationData = [];
// Variable area to store area of Acceleration - Time Graph
  double accArea = 0.0;
// final List <DataPoint> velocityData = [];
  bool flagA = false;
  bool flagB = true;
  double sampleFrequency = 0.0;
  DateTime time1 = DateTime.now();
  DateTime time2 = DateTime.now();

// Function to calculate net Acceleration
  double netAcceleration(List<double> acceleration) {
    double ax = acceleration[0]; // x value of acceleration
    double ay = acceleration[1]; // y value of acceleration
    double az = acceleration[2]; // z value of acceleration
    // Magnitute of Net acceleration
    double a = sqrt(ax * ax + ay * ay + az * az);
    return a;
  }

  @override
  void initState() {
    super.initState();
    // Listen to accelerometer events
    userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      if (mounted) {
        setState(() {
          // Update accelerometer readings, rounded to one decimal place
          _accelerometerReading = <double>[
            double.parse(event.x.toStringAsFixed(1)),
            double.parse(event.y.toStringAsFixed(1)),
            double.parse(event.z.toStringAsFixed(1)),
          ];

          // Adding acceleration Datapoint for plotting
          if (flagA && flagB) {
            _accelerationData.add(DataPoint(
                x: DateTime.now(), y: netAcceleration(_accelerometerReading)));
          }
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
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
        child: Column(
          children: [
            // Display X-axis accelerometer reading
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Center(
                      child: Text(
                        " X : ${_accelerometerReading[0]}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                // Display Y-axis accelerometer reading
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Center(
                        child: Text(
                          " Y : ${_accelerometerReading[1]}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Display Z-axis accelerometer reading
                Container(
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Center(
                      child: Text(
                        " Z : ${_accelerometerReading[2]}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    borderData: FlBorderData(show: true),
                    titlesData: const FlTitlesData(
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _accelerationData.map((point) {
                          return FlSpot(
                              point.x.millisecondsSinceEpoch.toDouble()*1000,
                              point.y);
                        }).toList(),
                        isCurved: true,
                        curveSmoothness: 0.5,
                        barWidth: 1,
                        color: Colors.black87,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                            show: true, color: Colors.black87.withOpacity(0.1)),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Start button : When pressed, calculation of average speed starts
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      onPressed: () {
                        time1 = DateTime.now();
                        flagA = true;
                        accArea = 0.0;
                        _accelerationData.clear();
                        setState(() {});
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.black87),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                      child: const Text('Start')),
                ),
                ElevatedButton(
                  onPressed: () {
                    flagA = false;
                    accArea = calculateAreaUnderLineChart(_accelerationData);
                    time2 = DateTime.now();
                    setState(() {
                      sampleFrequency = _accelerationData.length /
                          time2.difference(time1).inMilliseconds.toInt();
                      sampleFrequency = sampleFrequency * 1000;
                    });
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

            Container(
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(
                  child: Text(
                    "The Avg. Speed is: ${accArea.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // Showing the sample freequency
            /* Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Sample frequency =  $sampleFrequency'),
            ), */
          ],
        ),
      ),
    );
  }
}
