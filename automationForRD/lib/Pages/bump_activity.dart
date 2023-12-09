// ignore_for_file: avoid_print
import 'dart:developer';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:sqflite/sqflite.dart';
import '../classes_functions.dart/data_point.dart';

class BumpActivity extends StatefulWidget {
  const BumpActivity({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _BumpActivityState createState() => _BumpActivityState();
}

class _BumpActivityState extends State<BumpActivity> {
  static const int windowSize = 600;

  // ignore: non_constant_identifier_names
  String SMAbutton = 'Smooth';
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
  double noOfData = 20.0;
  bool flagxAcceleration = true;
  bool flagyAcceleration = true;
  bool flagzAcceleration = true;
  DateTime time1 = DateTime.now();
  DateTime time0 = DateTime.now();

  final List<DataPoint> _aXraw = [];
  final List<DataPoint> _aYraw = [];
  final List<DataPoint> _aZraw = [];
  final List<DataPoint> _aZsmoothed = [];
  List<double> _accelerometerReading = [0, 0, 0];
  String error = '';
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
          if (_aZraw.length >= windowSize && _aZsmoothed.length >= windowSize) {
            _aZraw.removeAt(0);
            _aZsmoothed.removeAt(0);
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
            insertUser(_accelerometerReading[0], _accelerometerReading[1],
                _accelerometerReading[2], currentTime);
          }
        });
      }
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
        error = e.toString();
        print('Error: $e');
      }
    }
  }

  Future<void> initializeDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'automationForRD.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE users(id INTEGER PRIMARY KEY, a_X REAL, a_Y REAL, a_Z REAL, Time TIMESTAMP)',
        );
      },
      version: 1,
    );
  }

  // CREATE operation
  Future<void> insertUser(
      double aX, double aY, double aZ, DateTime time) async {
    await _database.insert(
      'users',
      {'a_X': aX, 'a_Y': aY, 'a_Z': aZ, 'Time': time.toUtc().toString()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // READ operation
  Future<List<Map<String, dynamic>>> getUsers() async {
    return await _database.query('users');
  }

  // UPDATE operation
  Future<void> updateUser(
      int id, double aX, double aY, double aZ, DateTime time) async {
    await _database.update(
      'users',
      {'a_X': aX, 'a_Y': aY, 'a_Z': aZ, 'Time': time.toUtc().toString()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllUsers() async {
    await _database.delete('users');
  }

  Future<void> _exportToCSV() async {
    _requestStoragePermission();
    await _requestStoragePermission();
    List<Map<String, dynamic>> queryRows = await _database.query('users');
    List<List<dynamic>> csvData = [
      ['X-acceleration', 'Y-acceleration', 'Z-acceleration', 'Time'],
      for (var row in queryRows)
        [
          row['a_X'],
          row['a_Y'],
          row['a_Z'],
          row['Time']
        ],
    ];
    String csv = const ListToCsvConverter().convert(csvData);
    String fileName = "acceleration_data.csv";
    String path = '/storage/emulated/0/Download/$fileName';

    File file = File(path);
    await file.writeAsString(csv);

    print("CSV file exported to Downloads folder");
  }

  Future<void> _requestStoragePermission() async {
    if (await Permission.storage.request().isGranted) {
      print("Storage Permission Granted");
    } else {
      print("Storage Permission Denied");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text(
          "Accelerations",
          style: GoogleFonts.raleway(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
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
                          style: GoogleFonts.raleway(
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
                          style: GoogleFonts.raleway(
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
                          style: GoogleFonts.raleway(
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
              child: LineChart(
                LineChartData(
                  borderData: FlBorderData(show: true),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: const SideTitles(
                        showTitles: false,
                      ),
                      axisNameWidget: Text(
                        'Time',
                        style: GoogleFonts.raleway(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: const SideTitles(
                        showTitles: true,
                        interval: 3,
                        reservedSize: 50,
                      ),
                      axisNameWidget: Text(
                        'aceleration(m/s2)',
                        style: GoogleFonts.raleway(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: flagzAcceleration
                          ? _aZraw.map((point) {
                              return FlSpot(
                                  point.x.millisecondsSinceEpoch.toDouble() *
                                      1000,
                                  point.y);
                            }).toList()
                          : [],
                      isCurved: true,
                      curveSmoothness: 0.5,
                      barWidth: 1,
                      color: Colors.red,
                      dotData: const FlDotData(show: false),
                      /* belowBarData: BarAreaData(
                            show: true, color: Colors.black87.withOpacity(0.1)), */
                    ),

                    //

                    LineChartBarData(
                      spots: flagxAcceleration
                          ? _aXraw.map((point) {
                              return FlSpot(
                                  point.x.millisecondsSinceEpoch.toDouble() *
                                      1000,
                                  point.y);
                            }).toList()
                          : [],
                      isCurved: true,
                      curveSmoothness: 0.5,
                      barWidth: 1,
                      color: Colors.black,
                      dotData: const FlDotData(show: false),
                      /* belowBarData: BarAreaData(
                            show: true, color: Colors.black87.withOpacity(0.1)), */
                    ),

                    //
                    LineChartBarData(
                      spots: flagyAcceleration
                          ? _aYraw.map((point) {
                              return FlSpot(
                                  point.x.millisecondsSinceEpoch.toDouble() *
                                      1000,
                                  point.y);
                            }).toList()
                          : [],
                      isCurved: true,
                      curveSmoothness: 0.5,
                      barWidth: 1,
                      color: Colors.blue,
                      dotData: const FlDotData(show: false),
                      /* belowBarData: BarAreaData(
                            show: true, color: Colors.black87.withOpacity(0.1)), */
                    ),
                  ],
                ),
              ),
            ),
            const Gap(10),
            Container(
              decoration: const BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Text(
                    'Latitude: ${double.parse(devicePosition.latitude.toStringAsFixed(3))}',
                    style: GoogleFonts.raleway(
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Longitude: ${double.parse(devicePosition.longitude.toStringAsFixed(3))}',
                    style: GoogleFonts.raleway(
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Altitude: ${double.parse(devicePosition.altitude.toStringAsFixed(3))}',
                    style: GoogleFonts.raleway(
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Accuracy: ${double.parse(devicePosition.accuracy.toStringAsFixed(3))}',
                    style: GoogleFonts.raleway(
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Time: $time0',
                    style: GoogleFonts.raleway(
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Error: $error',
                    style: GoogleFonts.raleway(
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _aXraw.clear();
                      _aYraw.clear();
                      _aZraw.clear();
                      // _aZsmoothed.clear();
                      flagA = true;
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
                    style: GoogleFonts.raleway(
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
                    style: GoogleFonts.raleway(
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
                    _exportToCSV();
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
                    'Export CSV',
                    style: GoogleFonts.raleway(
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                      fontSize: 18,
                    ),
                  ),
                ),

                ElevatedButton(
                  onPressed: () {
                    
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
                    'Delete All Data',
                    style: GoogleFonts.raleway(
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
