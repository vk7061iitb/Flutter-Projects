import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class BumpActvity extends StatefulWidget {
  const BumpActvity({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _BumpActvityState createState() => _BumpActvityState();
}

class _BumpActvityState extends State<BumpActvity> {
  List<double> _accelerometerReading = [0, 0, 0];
  // ignore: non_constant_identifier_names
  final List<DataPoint> _accelerationData_X = [];
  // ignore: non_constant_identifier_names
  final List<DataPoint> _accelerationData_Y = [];
  // ignore: non_constant_identifier_names
  final List<DataPoint> _accelerationData_Z = [];

  bool flagA = false;
  bool flagX = false;
  bool flagY = false;
  bool flagZ = false;
  DateTime time1 = DateTime.now();
  late TooltipBehavior _tooltipBehavior;


   static const int windowSize = 20; // Number of data points to display in the window
  // static const int updateInterval = 1000; // Update interval in milliseconds

  @override
  void initState() {
    _tooltipBehavior  = TooltipBehavior(enable: true);
    super.initState();
    // Listen to accelerometer events
    userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      if (mounted) {
        setState(() {
          if(_accelerationData_Z.length >= windowSize){
            _accelerationData_Z.removeAt(0);
          }
          _accelerometerReading = <double>[event.x, event.y, event.z];
          // Determine if any axis has significant acceleration
          bool hasAcceleration =
              _accelerometerReading.any((value) => value.abs() >= 0.1);
          if (flagA && hasAcceleration) {
            DateTime currentTime = DateTime.now();
            _accelerationData_X.add(
                DataPoint(x: currentTime, y: _accelerometerReading[0]));
            _accelerationData_Y.add(
                DataPoint(x: currentTime, y: _accelerometerReading[1]));
            _accelerationData_Z.add(
                DataPoint(x: currentTime, y: _accelerometerReading[2]));
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
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SizedBox(
                  height: 250,
                  child: SfCartesianChart(
                    tooltipBehavior: _tooltipBehavior,
                    primaryXAxis: DateTimeAxis(
                      isVisible: false,
                      maximum: flagA? DateTime.now(): time1
                    ),
                    series: <ChartSeries>[
                      LineSeries<DataPoint, DateTime>(
                        enableTooltip: true,
                        dataSource: _accelerationData_Z,
                        xValueMapper: (DataPoint data, _) =>
                            data.x,
                        yValueMapper: (DataPoint data, _) => data.y,
                        animationDuration: 1,
                      )
                    ],
                    title: ChartTitle(text: 'a_z(Raw Data)'),
                    borderColor: Colors.transparent,
                    backgroundColor: Colors.transparent,
                    enableAxisAnimation: true,
                  )),
            ),

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

// Datapoint class to store time and acceleration value
class DataPoint {
  DateTime x;
  final double y;
  DataPoint({required this.x, required this.y});
}
