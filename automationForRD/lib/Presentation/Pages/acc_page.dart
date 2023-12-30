// ignore_for_file: avoid_print
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pave_track_master/Database/sqlitedb_Helper.dart';
import 'package:pave_track_master/Classes/classes/acceleration_readings.dart';
import 'package:pave_track_master/Classes/classes/position_data.dart';
import 'package:pave_track_master/Presentation/widget/custom_appbar.dart';
import 'package:pave_track_master/Presentation/widget/custom_chart.dart';
import 'package:pave_track_master/Presentation/widget/drawer_widget.dart';
import 'package:pave_track_master/Presentation/widget/drop_down.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../Classes/classes/data_point.dart';
import '../../Classes/classes/send_data_to_server.dart';
import '../widget/elevated_button.dart';
import '../widget/snack_bar.dart';

class BumpActivity extends StatefulWidget {
  const BumpActivity({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BumpActivityState createState() => _BumpActivityState();
}

class _BumpActivityState extends State<BumpActivity> {
  static const int windowSize = 600;

  /// List to store the acceleration values with time stamp
  List<AccelerationReadindings> accelerationReadings = [];

  List<dynamic> pcaAccelerationsData = [];

  // Database
  late SQLDatabaseHelper database = SQLDatabaseHelper();
  SendDataToServer sendData = SendDataToServer();
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

  bool isRecordingData = false;

  DateTime time0 = DateTime.now();
  DateTime time1 = DateTime.now();

  /// List to store accleration values to show on chart (Not using to store values in Database)
  final List<DataPoint> _aXraw = [];
  final List<DataPoint> _aYraw = [];
  final List<DataPoint> _aZraw = [];

  @override
  void dispose() async {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    database.initializeDatabase();
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
      ),
    ).listen((Position currentPosition) {
      devicePosition = currentPosition;
    });

    /// Getting the stream of accelerations values and
    accelerometerEventStream(samplingPeriod: SensorInterval.gameInterval)
        .listen((AccelerometerEvent event) {
      if (mounted && isRecordingData) {
        setState(() {
          // A mechanism to maintain a rolling window of data in the lists _aXraw, _aYraw, and _aZraw.
          while (_aZraw.length >= windowSize ||
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
          }
        });
      }
    });
  }

  // Function to insert all the accelerations data into the database
  Future<void> insertAllData() async {
    await database.insertaccData(accelerationReadings);
    await database.insertPCAaccelerationData(pcaAccelerationsData);
    await database.insertpositionData(positionsData);
  }

  Future<void> showProgressBar() async {
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  color: Colors.black,
                ),
                const SizedBox(height: 16),
                Text(
                  'Exporting CSV File',
                  style: GoogleFonts.raleway(
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
    if (context.mounted) Navigator.of(context).pop();
    pcaAccelerationsData =
        await sendData.sendDataToServer(textFieldController.text);
    message = await database.exportToCSV();
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          // ignore: unnecessary_string_interpolations
          .showSnackBar(customSnackBar('${sendData.message}'));
    }
    Future.delayed(const Duration(seconds: 1));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(customSnackBar(message));
    }
  }

  // Text Editing Controller for the server URL field
  TextEditingController textFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Customdrawer(),
      resizeToAvoidBottomInset: false,
      appBar: const CustomAppBar(),
      body: Padding(
        padding:
            const EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 10),
        child: Stack(
          children: [
            // Chart for displaying acceleration data
            Positioned(
              left: 0,
              right: 0,
              top: 75,
              child: SizedBox(
                height: 220,
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
              left: 200,
              right: 10,
              top: 0,
              child: SizedBox(
                child: TextFormField(
                  controller: textFieldController,
                  style: GoogleFonts.raleway(
                    color: Colors.blue,
                    fontWeight: FontWeight.normal,
                    fontSize: 10,
                  ),
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    labelText: 'Enter Server URL',
                    hintText: 'https://20ef-103-21-127-80.ngrok-free.app',
                    hintStyle: GoogleFonts.raleway(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.normal,
                      fontSize: 10,
                    ),
                    labelStyle: GoogleFonts.raleway(
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      fontSize: 12,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    // You can add more styling options here
                  ),
                ),
              ),
            ),
 
            const Positioned(
                top: 0,
                left: 5,
                right: 170,
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: ModernRoundedDropdown(),
                )),

            Positioned(
              left: 0,
              right: 0,
              bottom: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Start button
                  buildElevatedButton(
                    onPressed: () async {
                      _aXraw.clear();
                      _aYraw.clear();
                      _aZraw.clear();
                      positionsData.clear();
                      accelerationReadings.clear();
                      await database.deleteAllData();
                      isRecordingData = true;
                      setState(() {
                        time0 = DateTime.now();
                      });
                    },
                    label: 'Start',
                  ),

                  // End Button
                  buildElevatedButton(
                    onPressed: () {
                      time0 = DateTime.now();
                      time1 = time0;
                      isRecordingData = false;
                      setState(() {});
                    },
                    label: 'End',
                  ),
                  // Export CSV Button
                  buildElevatedButton(
                    onPressed: () {
                      setState(() {});
                      showProgressBar();
                      setState(() {});
                    },
                    label: 'CSV',
                  ),
                ],
              ),
            ),

            Positioned(
              top: 300,
              bottom: 60,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 50,
                child: ListView(
                  children: List.generate(
                    20,
                    (index) => ListTile(
                      title: Text('Item $index'),
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
