// ignore_for_file: avoid_print

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../classes_functions.dart/acceleration_readings.dart';
import '../classes_functions.dart/position_data.dart';
import '../classes_functions.dart/request_storage_permission.dart';

class FirestoreDatabaseHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> insertAccelerationData(
      List<AccelerationReadindings> accelerationReadings) async {
    WriteBatch batch = _firestore.batch();

    for (var data in accelerationReadings) {
      DocumentReference documentReference =
          _firestore.collection('accelerationData').doc();

      batch.set(documentReference, {
        'a_X': data.aX,
        'a_Y': data.aY,
        'a_Z': data.aZ,
        'time':
            data.time,
      });
    }

    await batch.commit();
  }

  Future<void> insertPositionData(List<PositionData> positionsData) async {
    WriteBatch batch = _firestore.batch();

    for (var posData in positionsData) {
      DocumentReference documentReference =
          _firestore.collection('positionData').doc();

      batch.set(documentReference, {
        'Latitude': posData.currentPosition.latitude,
        'Longitude': posData.currentPosition.longitude,
        'Time': posData.currentTime
      });
    }

    await batch.commit();
  }

  Future<void> insertFFTTransformData(
      double acceleration, double frequency, DateTime time) async {
    await _firestore.collection('fftTransformData').add({
      'acceleration': acceleration,
      'frequency': frequency,
      'Time': DateFormat('yyyy-MM-dd HH:mm:ss:S').format(time).toString(),
    });
  }

  Future<List<DocumentSnapshot>> getAccelerationData() async {
    QuerySnapshot querySnapshot =
        await _firestore.collection('accelerationData').get();

    return querySnapshot.docs;
  }

  Future<void> deleteAllData() async {
    WriteBatch batch = _firestore.batch();

    QuerySnapshot accDataSnapshot =
        await _firestore.collection('accelerationData').get();
    for (QueryDocumentSnapshot documentSnapshot in accDataSnapshot.docs) {
      batch.delete(documentSnapshot.reference);
    }

    QuerySnapshot posDataSnapshot =
        await _firestore.collection('positionData').get();
    for (QueryDocumentSnapshot documentSnapshot in posDataSnapshot.docs) {
      batch.delete(documentSnapshot.reference);
    }

    QuerySnapshot fftDataSnapshot =
        await _firestore.collection('fftTransformData').get();
    for (QueryDocumentSnapshot documentSnapshot in fftDataSnapshot.docs) {
      batch.delete(documentSnapshot.reference);
    }

    await batch.commit();
  }

  Future<String> exportToCSV() async {
    try {
      await requestStoragePermission();

      String accFoldername = "Acceleration Data";
      String posFoldername = "Position Data";
      Directory? appExternalStorageDir = await getExternalStorageDirectory();
      Directory accDirectory =
          await Directory(join(appExternalStorageDir!.path, accFoldername))
              .create(recursive: true);
      Directory posDirectory =
          await Directory(join(appExternalStorageDir.path, posFoldername))
              .create(recursive: true);

      if (await accDirectory.exists()) {
        print('Folder Already Exists');
        print("$accDirectory.path");
      } else {
        print('Folder Created');
      }
      print('problem 1');
      List<DocumentSnapshot> accData = await _firestore
          .collection('accelerationData')
          .get()
          .then((value) => value.docs);
      List<DocumentSnapshot> posData = await _firestore
          .collection('positionData')
          .get()
          .then((value) => value.docs);
      print('problem 2');
      List<List<dynamic>> accCsvData = [
        ['X-acceleration', 'Y-acceleration', 'Z-acceleration', 'Time'],
        for (var doc in accData)
          [doc['a_X'], doc['a_Y'], doc['a_Z'], doc['time']],
      ];

      List<List<dynamic>> posCsvData = [
        ['Latitude', 'Longitude', 'Time'],
        for (var doc in posData)
          [doc['Latitude'], doc['Longitude'], doc['Time']],
      ];

      String accCsv = const ListToCsvConverter().convert(accCsvData);
      String posCsv = const ListToCsvConverter().convert(posCsvData);

      String accFileName =
          'acceleration_data${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}.csv';
      String posFileName =
          'pos_data${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}.csv';
      String accPath = '${accDirectory.path}/$accFileName';
      String posPath = '${posDirectory.path}/$posFileName';

      File accFile = File(accPath);
      File posFile = File(posPath);

      await accFile.writeAsString(accCsv);
      await posFile.writeAsString(posCsv);

      print('CSV files exported to path: ${accDirectory.path}');
      return 'CSV files exported to path: ${accDirectory.path}';
    } catch (e) {
      print(e.toString());
      return e.toString();
    }
  }
}
