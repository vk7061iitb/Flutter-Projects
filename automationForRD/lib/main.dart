import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:pave_track_master/Presentation/Pages/acc_page.dart';
import 'package:pave_track_master/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Initialized Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;
  firestore.settings =
      const Settings(persistenceEnabled: false, sslEnabled: false);

  //Initialize Logging
  await FlutterLogs.initLogs(
      logLevelsEnabled: [
        LogLevel.INFO,
        LogLevel.WARNING,
        LogLevel.ERROR,
        LogLevel.SEVERE
      ],
      timeStampFormat: TimeStampFormat.TIME_FORMAT_READABLE,
      directoryStructure: DirectoryStructure.FOR_DATE,
      logTypesEnabled: ["device", "network", "errors"],
      logFileExtension: LogFileExtension.LOG,
      logsWriteDirectoryName: "MyLogs",
      logsExportDirectoryName: "MyLogs/Exported",
      debugFileOperations: true,
      isDebuggable: true);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const AccActivity(),
      },
    );
  }
}
