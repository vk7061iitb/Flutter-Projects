// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pave_track_master/Database/sqflite_db.dart';
import 'package:pave_track_master/classes_functions.dart/acceleration_readings.dart';
import 'package:pave_track_master/classes_functions.dart/get_location.dart';
import 'package:pave_track_master/classes_functions.dart/position_data.dart';
import 'package:pave_track_master/widget/custom_appbar.dart';
import 'package:pave_track_master/widget/custom_chart.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../classes_functions.dart/data_point.dart';
import '../widget/buid_in_row.dart';
import '../widget/snack_bar.dart';

class BumpActivity extends StatefulWidget {
  const BumpActivity({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BumpActivityState createState() => _BumpActivityState();
}

class _BumpActivityState extends State<BumpActivity> {
  // ignore: unused_field
  static const int slidingwindowSize = 5;

  static const int windowSize = 500;

  final List<DataPoint> aZraw = [];

  /// List to store the acceleration values with time stamp
  List<AccelerationReadindings> accelerationReadings = [];

  // Database
  late SQLDatabaseHelper database = SQLDatabaseHelper();

  // initializing the device position
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

  // List to store device positions with timestamp
  List<PositionData> positionsData = [];

  /// Flags for controlling the display of acceleration values on the chart
  bool flagxAcceleration = true;

  bool flagyAcceleration = true;
  bool flagzAcceleration = true;

  /// List to store gyroscope values
  List<double> gyroscopeValues = [0, 0, 0];

  bool isRecordingData = false;
  bool showCircularIndicator = false;

  double noOfData = 20.0;
  double showAvgacc = 0.0;
  DateTime time0 = DateTime.now();
  DateTime time1 = DateTime.now();

  /// List to store accleration values to show on chart (Not using to store values in Database)
  final List<DataPoint> _aXraw = [];

  final List<DataPoint> _aYraw = [];
  final List<DataPoint> _aZraw = [];

  @override
  void dispose() async {
    database.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    database.initializeDatabase();
    getLocation(isRecordingData, devicePosition);
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
      ),
    ).listen((Position currentPosition) {
      devicePosition = currentPosition;
    });

    /// Getting the stream of accelerations values and
    accelerometerEventStream(samplingPeriod: SensorInterval.normalInterval)
        .listen((AccelerometerEvent event) {
      if (mounted && isRecordingData) {
        setState(() {
          /// A mechanism to maintain a rolling window of data in the lists _aXraw, _aYraw, and _aZraw.
          /// The purpose of this rolling window is to limit the size of these lists to a maximum value
          /// (windowSize) and remove the oldest data points when new data points are added.
          if (_aZraw.length >= windowSize ||
              _aXraw.length >= windowSize ||
              _aYraw.length >= windowSize) {
            _aXraw.removeAt(0);
            _aYraw.removeAt(0);
            _aZraw.removeAt(0);
          }

          if (isRecordingData) {
            DateTime currentTime = DateTime.now();
            accelerationReadings.add(AccelerationReadindings(
                aX: double.parse(event.x.toStringAsFixed(3)),
                aY: double.parse(event.y.toStringAsFixed(3)),
                aZ: double.parse(event.z.toStringAsFixed(3)),
                time: currentTime));

            positionsData.add(PositionData(
                currentPosition: devicePosition, currentTime: currentTime));

            /// Adding datapoint in lists For plotting the graph
            _aXraw.add(DataPoint(
                x: currentTime, y: double.parse(event.x.toStringAsFixed(0))));
            _aYraw.add(DataPoint(
                x: currentTime, y: double.parse(event.y.toStringAsFixed(0))));
            _aZraw.add(DataPoint(
                x: currentTime, y: double.parse(event.z.toStringAsFixed(0))));
            aZraw.add(DataPoint(
                x: currentTime, y: double.parse(event.z.toStringAsFixed(4))));
          }
        });
      }
    });
  }

  // Function to insert all the accelerations data into the database
  Future<void> insertAllData() async {
    await database.insertaccData(accelerationReadings);
    await database.insertpositionData(positionsData);
  }

  Future<void> showProgressBar() async {
    showCircularIndicator = true;
    String message = '';
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: Colors.black,
                ),
                SizedBox(height: 16),
                Text(
                  'Exporting CSV File',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    await database.deleteAllData();
    await insertAllData();
    message = await database.exportToCSV();
    if (context.mounted) Navigator.of(context).pop();
    showCircularIndicator = false;
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(customSnackBar(message));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Padding(
        padding:
            const EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 10),
        child: Stack(
          children: [
            // Display options for X, Y, and Z acceleration
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Padding(
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
                            color: flagxAcceleration
                                ? Colors.black12
                                : Colors.white,
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
                            color: flagyAcceleration
                                ? Colors.black12
                                : Colors.white,
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
                            color: flagzAcceleration
                                ? Colors.black12
                                : Colors.white,
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
            ),
            // Chart for displaying acceleration data
            Positioned(
              left: 0,
              right: 0,
              top: 50,
              child: SizedBox(
                height: 200,
                child: CustomFlChart(
                    aXraw: _aXraw,
                    aYraw: _aYraw,
                    aZraw: _aZraw,
                    flagxAcceleration: flagxAcceleration,
                    flagyAcceleration: flagyAcceleration,
                    flagzAcceleration: flagzAcceleration),
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              top: 280,
              child: Card(
                elevation: 5, // Adjust the elevation for a shadow effect
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildInfoRow('Latitude',
                          devicePosition.latitude.toStringAsFixed(3)),
                      buildInfoRow('Longitude',
                          devicePosition.longitude.toStringAsFixed(3)),
                      buildInfoRow('Altitude',
                          devicePosition.altitude.toStringAsFixed(3)),
                      buildInfoRow('Accuracy',
                          devicePosition.accuracy.toStringAsFixed(3)),
                      buildInfoRow('Time',
                          DateFormat('yyyy-MM-dd HH:mm:ss').format(time0)),
                      buildInfoRow('windowData', showAvgacc.toString()),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      _aXraw.clear();
                      _aYraw.clear();
                      _aZraw.clear();
                      await database.deleteAllData();
                      accelerationReadings.clear();
                      positionsData.clear();
                      gyroscopeValues.clear();
                      isRecordingData = true;
                      setState(() {
                        getLocation(isRecordingData, devicePosition);
                        time0 = DateTime.now();
                      });
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(
                                color: Colors.black, width: 2)),
                      ),
                    ),
                    child: Text(
                      'Start',
                      style: GoogleFonts.sofiaSans(
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      time0 = DateTime.now();
                      time1 = time0;
                      isRecordingData = false;
                      setState(() {});
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(
                                color: Colors.black, width: 2)),
                      ),
                    ),
                    child: Text(
                      'End',
                      style: GoogleFonts.sofiaSans(
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {});
                      showProgressBar();
                      setState(() {});
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(
                                color: Colors.black, width: 2)),
                      ),
                    ),
                    child: Text(
                      'CSV',
                      style: GoogleFonts.sofiaSans(
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
