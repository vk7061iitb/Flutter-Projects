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
  final List<DataPoint> _accelerationData = [];
// Variable area to store area of Acceleration - Time Graph
  double accArea = 0.0;
// final List <DataPoint> velocityData = [];
  bool flagA = false;
  bool flagB = false;

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
          flagB = (netAcceleration(_accelerometerReading) >= 0.1);
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
                Container(
                  width: 100,
                  decoration: BoxDecoration(
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

                // Display Y-axis accelerometer reading
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 100,
                    decoration: BoxDecoration(
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
                Container(
                  width: 100,
                  decoration: BoxDecoration(
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
                              point.x.millisecondsSinceEpoch.toDouble(),
                              point.y);
                        }).toList(),
                        isCurved: true,
                        barWidth: 1,
                        color: Colors.black,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                            show: true, color: Colors.black.withOpacity(0.1)),
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
                        setState(() {
                          flagA = true;
                          //startTime = DateTime.now().hour.toDouble();
                          accArea = 0.0;
                          _accelerationData.clear();
                        });
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.red),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                      child: const Text('Start')),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      flagA = false;
                      //endTime = DateTime.now().hour.toDouble();
                      accArea = calculateAreaUnderLineChart(_accelerationData);
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red),
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
                color: Colors.red,
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
          ],
        ),
      ),
    );
  }
}

// Datapoint class to store time and Net acceleration value
class DataPoint {
  DateTime x;
  final double y;
  DataPoint({required this.x, required this.y});
}

// Function to caculate the avg. Speed
double calculateAreaUnderLineChart(List<DataPoint> accelerationData) {
  double accArea = 0.0;
  double velArea = 0.0;
  double totalDuration = 0.0;
  List<DataPoint> velocityData = [];

  for (int i = 0; i < accelerationData.length - 1; i++) {
    final y1 = accelerationData[i];
    final y2 = accelerationData[i + 1];
    double t2 = (y2.x.hour.toDouble() * 3600 * 1000 +
        y2.x.minute.toDouble() * 60 * 1000 +
        y2.x.second * 1000 +
        y2.x.millisecond);
    double t1 = (y1.x.hour.toDouble() * 3600 * 1000 +
        y1.x.minute.toDouble() * 60 * 1000 +
        y1.x.second * 1000 +
        y1.x.millisecond);
    double dx = (t2 - t1); // Time difference in milisecond
    totalDuration += dx; // total duration of the journey
    double avgAcceleration =
        (y1.y + y2.y) / 2; // avg. acceleration using midpoint rule
    accArea += dx * avgAcceleration; // This area is change in Velocity in mm/s.
    velocityData.add(DataPoint(
        x: y2.x,
        y: accArea / 1000.0)); // adding datapoints for velocity time graph
  }

  for (int i = 0; i < velocityData.length - 1; i++) {
    final x1 = velocityData[i];
    final x2 = velocityData[i + 1];
    Duration duration = x2.x.difference(x1.x);
    double dx1 = duration.inMilliseconds.toDouble();
    double avgVelocity = (x2.y + x1.y) / 2;
    velArea += dx1 * avgVelocity;
  }

  if (totalDuration > 0) {
    double averageSpeed = velArea / totalDuration;
    return averageSpeed;
  } else {
    return 0.0; // Avoid division by zero
  }
}
