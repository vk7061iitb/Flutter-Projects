// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pave_track_master/widget/custom_appbar.dart';
import 'package:pave_track_master/widget/custom_chart.dart';
import 'package:pave_track_master/widget/snack_bar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:sqflite/sqflite.dart';
import '../classes_functions.dart/data_point.dart';
import '../widget/buid_in_row.dart';

class BumpActivity extends StatefulWidget {
  const BumpActivity({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _BumpActivityState createState() => _BumpActivityState();
}

class _BumpActivityState extends State<BumpActivity> {
  static const int windowSize = 600;
  late StreamSubscription<AccelerometerEvent> accelerometerSubscription;
  late StreamSubscription<GyroscopeEvent> gyroscopeSubscription;
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
  List<double> _accelerometerReading = [0, 0, 0];
  // Database
  late Database _database;

  @override
  void initState() {
    super.initState();
    initializeDatabase();
    _getLocation();
    _requestStoragePermission();
    accelerometerEvents.listen((AccelerometerEvent event) {
      if (mounted && flagA) {
        setState(() {
          if (_aZraw.length >= windowSize ||
              _aXraw.length >= windowSize ||
              _aYraw.length >= windowSize) {
            _aZraw.removeAt(0);
            _aXraw.removeAt(0);
            _aYraw.removeAt(0);
            gyroscopeValues.removeAt(0);
          }
          _accelerometerReading = [event.x, event.y, event.z];
          bool hasAcceleration =
              _accelerometerReading.any((value) => value.abs() >= 0.1);
          if (flagA && hasAcceleration) {
            DateTime currentTime = DateTime.now();
            _aXraw.add(DataPoint(
                x: currentTime,
                y: double.parse(_accelerometerReading[0].toStringAsFixed(2))));
            _aYraw.add(DataPoint(
                x: currentTime,
                y: double.parse(_accelerometerReading[1].toStringAsFixed(2))));
            _aZraw.add(DataPoint(
                x: currentTime,
                y: double.parse(_accelerometerReading[2].toStringAsFixed(2))));
          }
        });
      }
    });

    gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        gyroscopeValues = <double>[event.x, event.y, event.z];
        if (flagA) {
          DateTime currentTime = DateTime.now();
          insertUser(
            _accelerometerReading[0],
            _accelerometerReading[1],
            _accelerometerReading[2],
            gyroscopeValues[0],
            gyroscopeValues[1],
            gyroscopeValues[2],
            currentTime,
          );
        }
      });
    });
  }

  Future<void> initializeDatabase() async {
    try {
      _database = await openDatabase(
        join(await getDatabasesPath(), 'automationForRD.db'),
        onCreate: (db, version) {
          return db.execute(
            'CREATE TABLE users(id INTEGER PRIMARY KEY, a_X REAL, a_Y REAL, a_Z REAL, g_X REAL, g_Y REAL, g_Z REAL, Time TIMESTAMP)',
          );
        },
        version: 1,
      );
    } catch (e) {
      print(e.toString());
      message = e.toString();
    }
  }

  Future<void> insertUser(double aX, double aY, double aZ, double gX, double gY,
      double gZ, DateTime time) async {
    await _database.transaction((txn) async {
      await txn.insert(
        'users',
        {
          'a_X': aX,
          'a_Y': aY,
          'a_Z': aZ,
          'g_X': gX,
          'g_Y': gY,
          'g_Z': gZ,
          'Time': time.toUtc().toString(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  // READ operation
  Future<List<Map<String, dynamic>>> getUsers() async {
    return await _database.transaction((txn) async {
      return txn.query('users');
    });
  }

  // UPDATE operation
  Future<void> updateUser(
      int id, double aX, double aY, double aZ, DateTime time) async {
    await _database.transaction((txn) async {
      await txn.update(
        'users',
        {'a_X': aX, 'a_Y': aY, 'a_Z': aZ, 'Time': time.toUtc().toString()},
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  Future<void> deleteAllUsers() async {
    await _database.transaction((txn) async {
      await txn.delete('users');
    });
  }


  Future<void> _getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        log('Location Access Denied');
        return Future.error('Location permissions are denied');
      }
    }
    if (flagA) {
      try {
        geolocator.Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: 0,
          ),
        ).listen((geolocator.Position newPosition) {
          setState(() {
            devicePosition = newPosition;
          });
        });
      } catch (e) {
        message = e.toString();
        print('Error: $e');
      }
    }
  }

  Future<void> _exportToCSV() async {
    try {
      _requestStoragePermission();
      await _requestStoragePermission();
      List<Map<String, dynamic>> queryRows = await _database.query('users');
      List<List<dynamic>> csvData = [
        ['X-acceleration', 'Y-acceleration', 'Z-acceleration', 'Time'],
        for (var row in queryRows)
          [row['a_X'], row['a_Y'], row['a_Z'], row['Time']],
      ];
      String csv = const ListToCsvConverter().convert(csvData);
      // Get the path to the documents directory
      Directory? documentDir = await getDownloadsDirectory();
      String filename =
          'acceleration_data${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}.csv';
      String path = '${documentDir!.path}/$filename';
      File file = File(path);
      await file.writeAsString(csv);
      message = "CSV file exported to $path";
      print(message);
    } catch (e) {
      print(e.toString());
      message = e.toString();
    }
  }

  Future<void> _requestStoragePermission() async {
    if (await Permission.storage.request().isGranted) {
      print("Storage Permission Granted");
    } else {
      message = "Storage Permission Denied";
      print("Storage Permission Denied");
    }
  }

  @override
  void dispose() {
    // Dispose of resources like controllers, animations, etc.
    accelerometerSubscription.cancel();
    gyroscopeSubscription.cancel();
    _database.close();
    super.dispose();
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
        buildInfoRow('Latitude', devicePosition.latitude.toStringAsFixed(3)),
        buildInfoRow('Longitude', devicePosition.longitude.toStringAsFixed(3)),
        buildInfoRow('Altitude', devicePosition.altitude.toStringAsFixed(3)),
        buildInfoRow('Accuracy', devicePosition.accuracy.toStringAsFixed(3)),
        buildInfoRow('Time', DateFormat('yyyy-MM-dd HH:mm:ss').format(time0)),
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
                    deleteAllUsers();
                    setState(() {
                      _getLocation();
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
              onPressed: () {
                setState(() {
                  _exportToCSV();
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
