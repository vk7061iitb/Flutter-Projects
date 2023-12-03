import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

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

  // ignore: non_constant_identifier_names
  final List<DataPoint> _accelerationData_X = [];

  // ignore: non_constant_identifier_names
  final List<DataPoint> _accelerationData_Y = [];

  // ignore: non_constant_identifier_names
  final List<DataPoint> _accelerationData_Z = [];

  // ignore: non_constant_identifier_names
  final List<DataPoint> _accelerationData_Z1 = [];

  List<double> _accelerometerReading = [0, 0, 0];
  late TooltipBehavior _tooltipBehavior;

  @override
  void dispose() {
    super.dispose();
  }

  // static const int updateInterval = 1000; // Update interval in milliseconds

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

            // Storing z component of acceleration rounded upto two decimal place
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
                    // offset: const Offset(0, 20)
                    position: LegendPosition.top,
                  ),
                  borderColor: Colors.transparent,
                  backgroundColor: Colors.transparent,
                  enableAxisAnimation: true,
                  plotAreaBorderColor: Colors.black,
                  tooltipBehavior: _tooltipBehavior,
                  series: <ChartSeries>[
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
                    LineSeries<DataPoint, DateTime>(
                      enableTooltip: true,
                      dataSource: simpleMovingAverage(_accelerationData_Z1, noOfData.toInt()),
                      xValueMapper: (DataPoint data, _) => data.x,
                      yValueMapper: (DataPoint data, _) => data.y,
                      color: Colors.red,
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

            /* Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SizedBox(
                height: 250,
                child: SfCartesianChart(
                  tooltipBehavior: _tooltipBehavior,
                  primaryXAxis: DateTimeAxis(
                      isVisible: false,
                      maximum: flagA ? DateTime.now() : time1),
                  series: <ChartSeries>[
                    LineSeries<DataPoint, DateTime>(
                      enableTooltip: true,
                      dataSource: simpleMovingAverage(_accelerationData_Z1, 30),
                      xValueMapper: (DataPoint data, _) => data.x,
                      yValueMapper: (DataPoint data, _) => data.y,

                      /* markerSettings: const MarkerSettings(
                        isVisible: true,
                        width: 5,
                      ), */
                    ),

                    
                  ],
                  title: ChartTitle(text: 'a_z(Smoothed Data)'),
                  borderColor: Colors.transparent,
                  backgroundColor: Colors.transparent,
                  enableAxisAnimation: true,
                ),
              ),
            ), */

            /* Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SizedBox(
                height: 250,
                child: SfCartesianChart(
                  primaryXAxis: DateTimeAxis(
                        isVisible: false,
                        maximum: flagA? DateTime.now(): time1
                      ),
                  series: <ChartSeries>[
                    SplineSeries<DataPoint, DateTime>(
                      dataSource: _accelerationData_Y,
                      xValueMapper: (DataPoint data, _) =>
                          data.x,
                      yValueMapper: (DataPoint data, _) => data.y,
                      animationDuration: 1000,
                    )
                  ],
                  title: ChartTitle(text: 'y-acceleration'),
                  borderColor: Colors.transparent,
                  backgroundColor: Colors.transparent,
                  
                  enableAxisAnimation: true,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SizedBox(
                  height: 250,
                  child: SfCartesianChart(
                    primaryXAxis: DateTimeAxis(
                        isVisible: false,
                        maximum: flagA? DateTime.now(): time1
                      ),
                    series: <ChartSeries>[
                      SplineSeries<DataPoint, DateTime>(
                        dataSource: _accelerationData_Z,
                        xValueMapper: (DataPoint data, _) =>
                            data.x,
                        yValueMapper: (DataPoint data, _) => data.y,
                        animationDuration: 1000,
                      )
                    ],
                    title: ChartTitle(text: 'z-acceleration'),
                    borderColor: Colors.transparent,
                    backgroundColor: Colors.transparent,
                    enableAxisAnimation: true,
                  )),
            ), */

            // Start button
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
                    setState(() {
                      time1 = DateTime.now();
                      flagA = false;
                    });

                    List<DataPoint> smootheddata =
                        simpleMovingAverage(_accelerationData_Z1, noOfData.toInt());
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

// Datapoint class to store time and acceleration value
class DataPoint {
  DataPoint({required this.x, required this.y});

  DateTime x;
  final double y;
}
