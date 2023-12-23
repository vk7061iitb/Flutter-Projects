// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pave_track_master/Database/sqflite_db.dart';
import 'package:pave_track_master/classes_functions.dart/acceleration_readings.dart';
import 'package:pave_track_master/classes_functions.dart/get_location.dart';
import 'package:pave_track_master/widget/custom_appbar.dart';
import 'package:pave_track_master/widget/custom_chart.dart';
import 'package:pave_track_master/widget/snack_bar.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../classes_functions.dart/data_point.dart';
import '../widget/buid_in_row.dart';

class BumpActivity extends StatefulWidget {
  const BumpActivity({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BumpActivityState createState() => _BumpActivityState();
}

class _BumpActivityState extends State<BumpActivity> {
  static const int windowSize = 600;
  // ignore: unused_field
  static const int slidingwindowSize = 5;
  // Database
  late SQLDatabaseHelper database = SQLDatabaseHelper();

  late geolocator.Position devicePosition = geolocator.Position(
    latitude: 0.0,
    longitude: 0.0,
    altitude: 0.0,
    accuracy: 0.0,
    timestamp: DateTime.now(),
    altitudeAccuracy: 0.0,
    heading: 0.0,
    headingAccuracy: 0.0,
    speed: 0,
    speedAccuracy: 0,
  );

  bool flagA = false;
  bool flagxAcceleration = true;
  bool flagyAcceleration = true;
  bool flagzAcceleration = true;
  List<double> gyroscopeValues = [0, 0, 0];
  String message = '';
  double noOfData = 20.0;
  DateTime time0 = DateTime.now();
  DateTime time1 = DateTime.now();

  final List<DataPoint> _aXraw = [];
  final List<DataPoint> _aYraw = [];
  final List<DataPoint> _aZraw = [];
  final List<DataPoint> aZraw = [];
  List<AccelerationReadindings> accelerationReadings = [];
  late Stream<AccelerometerEvent> accReadings;
  double showAvgacc = 0.0;

  @override
  void dispose() {
/*     // Dispose of resources like controllers, animations, etc.
    accelerometerSubscription.cancel();
    gyroscopeSubscription.cancel(); */
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    database.initializeDatabase();
    getLocation(flagA, devicePosition);
    database.requestStoragePermission();
    //
    accelerometerEventStream(samplingPeriod: SensorInterval.normalInterval)
        .listen((AccelerometerEvent event) {
      if (mounted && flagA) {
        setState(() {
          if (_aZraw.length >= windowSize ||
              _aXraw.length >= windowSize ||
              _aYraw.length >= windowSize) {
            _aXraw.removeAt(0);
            _aYraw.removeAt(0);
            _aZraw.removeAt(0);
          }

          if (flagA) {
            DateTime currentTime = DateTime.now();
            accelerationReadings.add(AccelerationReadindings(
                aX: double.parse(event.x.toStringAsFixed(3)),
                aY: double.parse(event.y.toStringAsFixed(3)),
                aZ: double.parse(event.z.toStringAsFixed(3)),
                time: currentTime));

            // For plotting the graph
            _aXraw.add(DataPoint(
                x: currentTime, y: double.parse(event.x.toStringAsFixed(3))));
            _aYraw.add(DataPoint(
                x: currentTime, y: double.parse(event.y.toStringAsFixed(3))));
            _aZraw.add(DataPoint(
                x: currentTime, y: double.parse(event.z.toStringAsFixed(3))));
            aZraw.add(DataPoint(
                x: currentTime, y: double.parse(event.z.toStringAsFixed(3))));
          }

          /* if (aZraw.length >= slidingwindowSize) {
            double windowDataValue = 0;
            for (int i = 0; i < slidingwindowSize; i++) {
              double coefficient = 0.1;
              if (i == (slidingwindowSize - 1) / 2) {
                coefficient = 0.6;
              }
              windowDataValue += coefficient * aZraw[i].y;
            }
            showAvgacc = double.parse(windowDataValue.toStringAsFixed(3));
            windowDataValue = 0;
            aZraw.removeAt(0);
          } */
        });
      }
    });
  }

    // Function to insert all the accelerations data into the database
    void insertAllData() {
      for (int i = 0; i < accelerationReadings.length; i++) {
        database.insertTestData(
            accelerationReadings[i].aX,
            accelerationReadings[i].aY,
            accelerationReadings[i].aZ,
            accelerationReadings[i].time);
      }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Padding(
        padding:
            const EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 20),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () {
                      flagxAcceleration = !flagxAcceleration;
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color:
                              flagxAcceleration ? Colors.black12 : Colors.white,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'X-acc',
                          style: GoogleFonts.sofiaSans(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      flagyAcceleration = !flagyAcceleration;
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color:
                              flagyAcceleration ? Colors.black12 : Colors.white,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Y-acc',
                          style: GoogleFonts.sofiaSans(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      flagzAcceleration = !flagzAcceleration;
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color:
                              flagzAcceleration ? Colors.black12 : Colors.white,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Z-acc',
                          style: GoogleFonts.sofiaSans(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 200,
              child: CustomFlChart(
                  aXraw: _aXraw,
                  aYraw: _aYraw,
                  aZraw: _aZraw,
                  flagxAcceleration: flagxAcceleration,
                  flagyAcceleration: flagyAcceleration,
                  flagzAcceleration: flagzAcceleration),
            ),
            const Gap(10),
            Card(
              elevation: 5, // Adjust the elevation for a shadow effect
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildInfoRow(
                        'Latitude', devicePosition.latitude.toStringAsFixed(3)),
                    buildInfoRow('Longitude',
                        devicePosition.longitude.toStringAsFixed(3)),
                    buildInfoRow(
                        'Altitude', devicePosition.altitude.toStringAsFixed(3)),
                    buildInfoRow(
                        'Accuracy', devicePosition.accuracy.toStringAsFixed(3)),
                    buildInfoRow('Time',
                        DateFormat('yyyy-MM-dd HH:mm:ss').format(time0)),
                    buildInfoRow('windowData', showAvgacc.toString()),
                  ],
                ),
              ),
            ),
            const Gap(10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _aXraw.clear();
                    _aYraw.clear();
                    _aZraw.clear();
                    gyroscopeValues.clear();
                    flagA = true;
                    database.deleteAllTestData();
                    setState(() {
                      getLocation(flagA, devicePosition);
                      time0 = DateTime.now();
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.black87),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  child: Text(
                    'Start',
                    style: GoogleFonts.sofiaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                      fontSize: 18,
                    ),
                  ),
                ),
                const Gap(10),
                ElevatedButton(
                  onPressed: () {
                    time0 = DateTime.now();
                    time1 = time0;
                    flagA = false;
                    setState(() {});
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.black87),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  child: Text(
                    'End',
                    style: GoogleFonts.sofiaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            
            ElevatedButton(
              onPressed: () async {
                insertAllData();
                print(
                    'accelerationReading length : ${accelerationReadings.length}');
                Future.delayed(const Duration(seconds: 5));
                database.exportToCSV();
                setState(() {
                  // Showing SnackBar
                  ScaffoldMessenger.of(context)
                      .showSnackBar(customSnackBar(message));
                });
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.black87),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              child: Text(
                'Export CSV',
                style: GoogleFonts.sofiaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
