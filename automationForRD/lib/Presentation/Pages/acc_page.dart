import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pave_track_master/Presentation/Pages/pci_page.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:tuple/tuple.dart';
import '../../Classes/classes/data_point.dart';
import '../../Classes/classes/raw_data.dart';
import '../../Classes/classes/send_data_to_server.dart';
import '../../Database/firebasedb_helper.dart';
import '../../Database/sqlitedb_helper.dart';
import '../widget/custom_appbar.dart';
import '../widget/custom_chart.dart';
import '../widget/drawer_widget.dart';
import '../widget/drop_down.dart';
import '../widget/build_outlined_button.dart';
import '../widget/snack_bar.dart';

class AccActivity extends StatefulWidget {
  const AccActivity({super.key});

  @override
  AccActivityState createState() => AccActivityState();
}

class AccActivityState extends State<AccActivity> {
  static const int windowSize = 600;

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

  TextEditingController filenameController = TextEditingController();
  FirestoreDatabaseHelper firebasedatabase = FirestoreDatabaseHelper();

  /// Flags for controlling the display of acceleration values on the chart
  bool flagxAcceleration = true;
  bool flagyAcceleration = true;
  bool flagzAcceleration = true;
  bool isLoading = true;
  bool isRecordingData = false;
  List<Tuple2<LatLng, LatLng>> latLngpairs = [];
  String message = '';
  DateTime noteTime = DateTime.now();
  List<dynamic> pcaAccelerationsData = [];
  List<RawDataReadings> rawdata = [];
  SendDataToServer sendData = SendDataToServer();
  // Text Editing Controller for the server URL field
  TextEditingController textFieldController = TextEditingController();

  DateTime time0 = DateTime.now();
  DateTime time1 = DateTime.now();
  List<Tuple2<String, DateTime>> timer = [];

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
    requestLocationPermission();

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
            noteTime = currentTime;
            rawdata.add(RawDataReadings(
                xAcc: double.parse(event.x.toStringAsFixed(3)),
                yAcc: double.parse(event.y.toStringAsFixed(3)),
                zAcc: double.parse(event.z.toStringAsFixed(3)),
                position: devicePosition,
                time: currentTime));

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

  void requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Handle permission denial
    } else if (permission == LocationPermission.deniedForever) {
      // Handle permanent denial
    } else {
      // Access granted
      geolocator.Geolocator.getPositionStream(
        locationSettings: const geolocator.LocationSettings(
          accuracy: geolocator.LocationAccuracy.best,
          distanceFilter: 0,
        ),
      ).listen((geolocator.Position currentPosition) {
        setState(() {
          devicePosition = currentPosition;
        });
      });

      // ignore: avoid_print
      print(
          "Latitude: ${devicePosition.latitude}, Longitude: ${devicePosition.longitude}");
    }
  }

  void addLatLngpairs() {
    latLngpairs.clear();
    List<LatLng> points = [];
    points.add(const LatLng(16.986452, 73.332489));
    points.add(const LatLng(16.986653, 73.331673));
    points.add(const LatLng(16.986565, 73.331345));
    points.add(const LatLng(16.986200, 73.330950));
    points.add(const LatLng(16.985848, 73.330634));
    points.add(const LatLng(16.985596, 73.330266));
    points.add(const LatLng(16.985370, 73.329673));
    points.add(const LatLng(16.985181, 73.329016));
    points.add(const LatLng(16.985080, 73.328384));
    points.add(const LatLng(16.985307, 73.326976));
    points.add(const LatLng(16.985534, 73.325700));

    for (int i = 1; i < points.length; i++) {
      latLngpairs.add(Tuple2(points[i - 1], points[i]));
    }
  }

  // Function to insert all the accelerations data into the database
  Future<void> insertAllData() async {
    addLatLngpairs();
    // await firebasedatabase.insertTransformedData(latLngpairs);
    // await firebasedatabase.insertrawData(rawdata);
    await database.insertPCAdata(pcaAccelerationsData);
    await database.insertRawData(rawdata);
    await database.insertTime(timer);
  }

  Future<void> showProgressBar() async {
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
            child: isLoading
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: TextFormField(
                          controller: filenameController,
                          style: GoogleFonts.poppins(
                            color: Colors.blue,
                            fontWeight: FontWeight.normal,
                            fontSize: 12,
                          ),
                          decoration: InputDecoration(
                            border: const UnderlineInputBorder(),
                            labelText: 'Enter File Name',
                            hintText: 'Road ID',
                            hintStyle: GoogleFonts.poppins(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                            ),
                            labelStyle: GoogleFonts.poppins(
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          setState(() async {
                            isLoading = false;
                            await databaseOperation(filenameController.text);
                            filenameController.clear();
                          });
                          setState(() {});
                        },
                        child: const Text('Submit'),
                      ),
                    ],
                  )
                : const SizedBox(),
          ),
        );
      },
    );
  }

  Future<void> databaseOperation(String fileName) async {
    if (!isLoading) {
      await database.deleteAllData();
      await insertAllData();
      if (context.mounted) Navigator.of(context).pop();
      message = await database.exportToCSV(fileName);
      setState(() {});
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(customSnackBar(message));
      }
      setState(() {
        isLoading = true;
      });
    }
  }

  String noteTimeFunction() {
    String timeString = '';
    setState(() {
      timeString = DateFormat('HH:mm:ss.SSS').format(DateTime.now());
    });
    return timeString;
  }

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
            // Dropdown for different plots
            const Positioned(
              top: 0,
              left: 5,
              right: 170,
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: ModernRoundedDropdown(),
              ),
            ),

            // Text formfield to get server link(URL)
            Positioned(
              left: 200,
              right: 10,
              top: 0,
              child: SizedBox(
                child: TextFormField(
                  controller: textFieldController,
                  style: GoogleFonts.poppins(
                    color: Colors.blue,
                    fontWeight: FontWeight.normal,
                    fontSize: 10,
                  ),
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    labelText: 'Enter Server URL',
                    hintText: 'https://20ef-103-21-127-80.ngrok-free.app',
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.normal,
                      fontSize: 10,
                    ),
                    labelStyle: GoogleFonts.poppins(
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
              top: 310,
              right: 10,
              child: Center(
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const PCIpage(),
                        maintainState: true,
                      ),
                    );
                  },
                  icon: const Icon(Icons.location_searching_outlined),
                  tooltip: 'Google Maps',
                  highlightColor: Colors.greenAccent,
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      const CircleBorder(
                        side: BorderSide(width: 0.5),
                      ),
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.transparent,
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              top: 310,
              left: 10,
              child: Row(
                children: [
                  Text(
                    'Time : ',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    noteTimeFunction(),
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Start button
                  buildOutlinedButton(
                    onPressed: () async {
                      requestLocationPermission();
                      _aXraw.clear();
                      _aYraw.clear();
                      _aZraw.clear();
                      timer.clear();
                      rawdata.clear();
                      await database.deleteAllData();
                      //await firebasedatabase.deleteAllData();
                      isRecordingData = true;
                      setState(() {
                        time0 = DateTime.now();
                      });
                    },
                    label: 'Start',
                  ),

                  // End OutlinedButton
                  buildOutlinedButton(
                    onPressed: () async {
                      time0 = DateTime.now();
                      time1 = time0;
                      isRecordingData = false;
                      setState(() {});
                    },
                    label: 'End',
                  ),
                  // Export CSV OutlinedButton
                  buildOutlinedButton(
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
          ],
        ),
      ),
    );
  }
}
