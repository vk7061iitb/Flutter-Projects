import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class AccelerometerActvity extends StatefulWidget {
  const AccelerometerActvity({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AccelerometerActivityState createState() => _AccelerometerActivityState();
  
}

class _AccelerometerActivityState extends State<AccelerometerActvity> {
  List<double> _accelerometerReading = [0, 0, 0];

  @override
  void initState() {
    super.initState();
    userAccelerometerEvents.listen((UserAccelerometerEvent event) { 
      if(mounted){
        setState(() {
        _accelerometerReading = <double>[
          double.parse(event.x.toStringAsFixed(1)),
          double.parse(event.y.toStringAsFixed(1)),
          double.parse(event.z.toStringAsFixed(1)),
        ];
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

      body: Column(
        children: [
          Text(" X : ${_accelerometerReading[0]}"),
          Text(" Y : ${_accelerometerReading[1]}"),
          Text(" Z : ${_accelerometerReading[2]}"),
        ],
      ),
    );
  }
}
