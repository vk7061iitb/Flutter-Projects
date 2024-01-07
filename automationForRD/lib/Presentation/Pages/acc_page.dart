// ignore_for_file: avoid_print
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
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

  double deviceSpeed = 0.0;
  double deviceSpeedAcurracy = 0.0;
  FirestoreDatabaseHelper firebasedatabase = FirestoreDatabaseHelper();

  /// Flags for controlling the display of acceleration values on the chart
  bool flagxAcceleration = true;
  bool flagyAcceleration = true;
  bool flagzAcceleration = true;
  bool isRecordingData = false;

  List<Tuple2<LatLng, LatLng>> latLngpairs = [];
  List<dynamic> pcaAccelerationsData = [];
  List<Tuple2<String, DateTime>> timer = [];
  List<RawDataReadings> rawdata = [];
  SendDataToServer sendData = SendDataToServer();
  // Text Editing Controller for the server URL field
  TextEditingController textFieldController = TextEditingController();
  DateTime time0 = DateTime.now();
  DateTime time1 = DateTime.now();
  DateTime noteTime = DateTime.now();

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
    requestLocationAccess();
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: geolocator.LocationAccuracy.best,
        distanceFilter: 0,
      ),
    ).listen((Position currentPosition) {
      setState(() {
        devicePosition = currentPosition;
        deviceSpeed = currentPosition.speed;
        deviceSpeedAcurracy = currentPosition.speedAccuracy;
      });
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

  // Function to request location access
  Future<void> requestLocationAccess() async {
    try{
          // Create a Location instance
    Location location = Location();

    // Variables to track service and permission status
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Check if location service is enabled
    serviceEnabled = await location.serviceEnabled();

    // If location service is not enabled, request the user to enable it
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      // If the user still doesn't enable the service, exit the function
      if (!serviceEnabled) {
        return;
      }
    }

    // Check the current location permission status
    permissionGranted = await location.hasPermission();

    // If permission is denied, request the user to grant permission
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      // If the user doesn't grant permission, exit the function
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    // Location access successfully granted
    } catch(error){
      print(error.toString());
    }
  }

  void addLatLngpairs() {
    latLngpairs.clear();
    List<LatLng> points = [];
    points.add(const LatLng(19.128698, 72.919805));
    points.add(const LatLng(19.124539, 72.914975));
    points.add(const LatLng(19.123853, 72.909285));
    points.add(const LatLng(19.119398, 72.903820));
    points.add(const LatLng(19.122659, 72.898428));
    points.add(const LatLng(19.124693, 72.894988));
    points.add(const LatLng(19.126105, 72.890695));
    points.add(const LatLng(19.128284, 72.887615));
    points.add(const LatLng(19.129307, 72.883667));

    for (int i = 1; i < points.length; i++) {
      latLngpairs.add(Tuple2(points[i - 1], points[i]));
    }
  }

  // Function to insert all the accelerations data into the database
  Future<void> insertAllData() async {
    addLatLngpairs();
    await firebasedatabase.insertTransformedData(latLngpairs);
    await firebasedatabase.insertrawData(rawdata);
    // await database.insertPCAdata(pcaAccelerationsData);
    //await database.insertRawData(rawdata);
    //await database.insertTime(timer);
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
    //await firebasedatabase.deleteAllData();
    await insertAllData();
    if (context.mounted) Navigator.of(context).pop();
    pcaAccelerationsData =
        await sendData.sendDataToServer(textFieldController.text);
    //message = await database.exportToCSV();
    firebasedatabase.exportToCSV();
    message = firebasedatabase.message;
    setState(() {});
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          // ignore: unnecessary_string_interpolations
          .showSnackBar(customSnackBar('${sendData.message}'));
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(customSnackBar(message));
    }
  }

  DateTime noteTimeFunction() {
    setState(() {
      noteTime = DateTime.now();
    });
    return noteTime;
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
              child: Text(
                'Time: ${noteTimeFunction().toString()}',
                style: GoogleFonts.sofiaSans(
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
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
                  // Start button
                  buildOutlinedButton(
                    onPressed: () async {
                      requestLocationAccess();
                      _aXraw.clear();
                      _aYraw.clear();
                      _aZraw.clear();
                      timer.clear();
                      rawdata.clear();
                      await database.deleteAllData();
                      await firebasedatabase.deleteAllData();
                      isRecordingData = true;
                      setState(() {
                        time0 = DateTime.now();
                      });
                    },
                    label: 'Start',
                  ),

                  // End Button
                  buildOutlinedButton(
                    onPressed: () async {
                      time0 = DateTime.now();
                      time1 = time0;
                      isRecordingData = false;
                      setState(() {});
                    },
                    label: 'End',
                  ),
                  // Export CSV Button
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

            Positioned(
                top: 350,
                left: 10,
                child: Row(
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        timer.add(Tuple2('Bump', noteTime));
                      },
                      child: Text(
                        'Bump',
                        style: GoogleFonts.raleway(
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    )
                  ],
                )),

            /* const Positioned(
              top: 300,
              bottom: 60,
              left: 0,
              right: 0,
              child: PCIpage()
            ), */
          ],
        ),
      ),
    );
  }
}
