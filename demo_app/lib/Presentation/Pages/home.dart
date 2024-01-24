import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../Classes/label_data.dart';
import '../../Database/db_helper.dart';
import '../Widgets/custom_appbar.dart';
import '../Widgets/custom_snackbar.dart';
import '../Widgets/pci_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SQLDatabaseHelper dbHelper = SQLDatabaseHelper();
  List<String> fileInfo = [
    '/storage/emulated/0/Android/data/com.example.demo_app/files/label Data',
    '2024-01-24 15:59:08-hello.csv'
  ];

  TextEditingController fileNameController = TextEditingController();
  String img1path = 'assets/Images/PCI01.png';
  String img2path = 'assets/Images/PCI02.png';
  String img3path = 'assets/Images/PCI03.png';
  String img4path = 'assets/Images/PCI04.png';
  String img5path = 'assets/Images/PCI05.png';
  String img6path = 'assets/Images/PCI06.png';
  bool isLoading = true;
  List<LabelType> labelData = [];
  String message = '';
  String roadScore1 = '1';
  String roadScore2 = '2';
  String roadScore3 = '3';
  String roadScore4 = '4';
  String roadScore5 = '5';
  String roadScore6 = '6';
  String roadType1 = 'Good';
  String roadType2 = 'Average';
  String roadType3 = 'Bad';
  String roadType4 = 'Very Bad';
  String roadType5 = 'Unpaved Road';
  String roadType6 = 'Type6';
  bool startTimer = false;
  Timer? timer;
  String timerText = 'Timer';

  @override
  void initState() {
    super.initState();
    dbHelper.initializeDatabase();
  }

  Future<void> insertAllData() async {
    dbHelper.insertLabelData(labelData);
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
                          controller: fileNameController,
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
                            await databaseOperation(fileNameController.text);
                            fileNameController.clear();
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
      await dbHelper.deleteAllData();
      await insertAllData();
      if (context.mounted) Navigator.of(context).pop();
      message = await dbHelper.exportToCSV(fileNameController.text);
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
      timeString = DateFormat('HH:mm:ss').format(DateTime.now());
    });
    return timeString;
  }

  void startTimerFunction() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        timerText = noteTimeFunction();
      });
    });
  }

  void stopTimerFunction() {
    timer?.cancel();
    timerText = 'Timer';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 10,
            child: Column(
              children: [
                PCIButton(
                  onPressed: () {
                    labelData.add(
                        LabelType(currentTime: DateTime.now(), roadType: '1'));
                  },
                  label: roadType1,
                  score: roadScore1,
                  imgPath: img1path,
                ),
                PCIButton(
                  onPressed: () {
                    labelData.add(
                        LabelType(currentTime: DateTime.now(), roadType: '2'));
                  },
                  label: roadType2,
                  score: roadScore2,
                  imgPath: img2path,
                ),
                const Gap(5),
                PCIButton(
                  onPressed: () {
                    labelData.add(
                        LabelType(currentTime: DateTime.now(), roadType: '3'));
                  },
                  label: roadType3,
                  score: roadScore3,
                  imgPath: img3path,
                ),
                PCIButton(
                  onPressed: () {
                    labelData.add(
                        LabelType(currentTime: DateTime.now(), roadType: '4'));
                  },
                  label: roadType4,
                  score: roadScore4,
                  imgPath: img4path,
                ),
                const Gap(5),
                PCIButton(
                  onPressed: () {
                    labelData.add(
                        LabelType(currentTime: DateTime.now(), roadType: '5'));
                  },
                  label: roadType5,
                  score: roadScore5,
                  imgPath: img5path,
                ),
                PCIButton(
                  onPressed: () {
                    labelData.add(
                        LabelType(currentTime: DateTime.now(), roadType: '6'));
                  },
                  label: roadType6,
                  score: roadScore6,
                  imgPath: img6path,
                ),
                const Gap(5),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: OutlinedButton(
                    onPressed: () async {
                      labelData.clear();
                      startTimer = true;
                      setState(() {
                        startTimerFunction();
                      });
                    },
                    child: Text(
                      'Start',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: OutlinedButton(
                    onPressed: () {
                      showProgressBar();
                      setState(() {
                        startTimer = false;
                        stopTimerFunction();
                      });
                    },
                    child: Text(
                      'End',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                /* Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: OutlinedButton(
                    onPressed: () {
                      openFilePicker();
                      setState(() {});
                    },
                    child: const Text('Pick A File'),
                  ),
                ), */
              ],
            ),
          ),
          Positioned(
            right: 10,
            top: 300,
            child: Text(
              '** Tap on Labels to see the Road Images',
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.red,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          Positioned(
            right: 10,
            top: 350,
            child: TextButton(
              onPressed: () async {
                //openMailCompose(fileInfo[0], fileInfo[1]);
               /*  final file = XFile('/storage/emulated/0/Download/22B0359_ID.pdf');
                await Share.shareXFiles([file],
                    subject: 'Sharing My File', text: 'Here you go!'); */

                /* String? filePath = await openFilePicker();
                print(filePath);

                //final file = File('/storage/emulated/0/Download/22B0359_ID.pdf');
                await Share.shareFiles([filePath!],
                    subject: 'Sharing My File', text: 'Here you go!'); */

                //downloadCSV(labelData, 'dkjbce');
                
                

                /* final result = await Share.shareWithResult(
                    'check out my website https://example.com');

                if (result.status == ShareResultStatus.success) {} */
              },
              child: Text(
                'Send Mail',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.blue,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
          Positioned(
              top: 0,
              right: 10,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.shade700)),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    startTimer ? noteTimeFunction() : 'Timer',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
