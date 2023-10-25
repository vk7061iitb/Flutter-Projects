import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

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
  List <DataPoint> _accelerationData = [];

// Function to calculate net Acceleration
  double netAcceleration (List<double> acceleration){
    double ax = acceleration[0];
    double ay = acceleration[1];
    double az = acceleration[2];
    // Magnitute of Net acceleration
    double a = sqrt(ax*ax + ay*ay + az*az);
    return a;
  }

  @override
  void initState() {
    super.initState();
    // Listen to accelerometer events
    userAccelerometerEvents.listen((UserAccelerometerEvent event) { 
      if(mounted){
        setState(() {
        // Update accelerometer readings, rounded to one decimal place
        _accelerometerReading = <double>[
          double.parse(event.x.toStringAsFixed(1)),
          double.parse(event.y.toStringAsFixed(1)),
          double.parse(event.z.toStringAsFixed(1)),
        ];

        // Adding acceleration Datapoint for plotting
        _accelerationData.add(DataPoint(
          x: DateTime.now().millisecondsSinceEpoch.toDouble(), 
          y: netAcceleration(_accelerometerReading)));
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build (BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 100,
                    decoration:  BoxDecoration(
                      color: Colors.red,
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
                ),

              // Display Y-axis accelerometer reading
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      width: 100,
                      decoration:  BoxDecoration(
                        color: Colors.red,
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                    width: 100,
                    decoration:  BoxDecoration(
                      color: Colors.red,
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
                ),   
              ],
            ),
          
            Container(
              child: 
              LineChart(
                LineChartData(
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: calculateAcelerationData(),
                      isCurved: false,
                      barWidth: 2.5,
                      color: Colors.deepPurple,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  calculateAcelerationData() {

  }
}

// Datapoint class
class DataPoint {
  final double x;
  final double y;
  DataPoint({required this.x, required this.y});
}


