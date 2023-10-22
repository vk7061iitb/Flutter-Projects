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

      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 150,
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
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),),
                    ),
                  ),
                  ),   
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 150,
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
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),),
                      ),
                    ),
                    ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                              Container(
                  width: 150,
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
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),),
                    ),
                  ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
