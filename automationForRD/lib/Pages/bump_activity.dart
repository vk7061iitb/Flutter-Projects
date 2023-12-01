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
  List<double> _accelerometerReading = [0];
  final List<DataPoint> _accelerationData = [];

// final List <DataPoint> velocityData = [];
  bool flagA = false;
  bool flagB = false;

  @override
  void initState() {
    super.initState();
    // Listen to accelerometer events
    userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      if (mounted) {
        setState(() {
          // Update accelerometer readings, rounded to one decimal place
          _accelerometerReading = <double>[
            event.z,
          ];
          flagB = (_accelerometerReading[0].abs() >= 0.1);
          // Adding acceleration Datapoint for plotting
          if (flagA && flagB) {
            _accelerationData.add(DataPoint(
                x: DateTime.now(), y: _accelerometerReading[0]));
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
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SizedBox(
                height: 250,
                child: SfCartesianChart(
                  series: <ChartSeries> [
                    SplineSeries<DataPoint, int>(
                      dataSource: _accelerationData, 
                      xValueMapper: (DataPoint data, _) => data.x.millisecondsSinceEpoch, 
                      yValueMapper: (DataPoint data, _) => data.y,
                      animationDuration: 1000,
                      )
                  ],

                  title: ChartTitle(
                    text: 'Bump Detection'
                  ),
                  borderColor: Colors.transparent,
                  backgroundColor: Colors.transparent,
                  primaryXAxis: NumericAxis(
                    isVisible: false,
                  ),
                  enableAxisAnimation: true,
                  
                )
              ),
            ),

            // Start button 
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
                          
                          _accelerationData.clear();
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

// Datapoint class to store time and Net acceleration value
class DataPoint {
  DateTime x;
  final double y;
  DataPoint({required this.x, required this.y});
}
