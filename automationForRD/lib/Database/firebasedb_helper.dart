// ignore_for_file: avoid_print

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pave_track_master/Classes/classes/raw_data.dart';
import '../Classes/classes/request_storage_permission.dart';

class FirestoreDatabaseHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String message = '';
  Future<void> insertrawData(List<RawDataReadings> rawDataReadings) async {
    try {
      WriteBatch batch = _firestore.batch();
      for (var data in rawDataReadings) {
        DocumentReference documentReference =
            _firestore.collection('RawData').doc();

        batch.set(documentReference, {
          'x_acc': data.xAcc,
          'y_acc': data.yAcc,
          'z_acc': data.zAcc,
          'latitude': data.position.latitude,
          'longitude': data.position.longitude,
          'time': DateFormat('yyyy-MM-dd HH:mm:ss:S').format(data.time),
        });
      }
      await batch.commit();
    } on FirebaseException catch (e) {
      print('Error writing to Firestore: ${e.code} - ${e.message}');
      message = 'Error writing to Firestore: ${e.code} - ${e.message}';
    } catch (e) {
      print('Unexpected error: $e');
      message = 'Unexpected error: $e';
    }
  }

  Future<void> insertFFTTransformData(
      double acceleration, double frequency, DateTime time) async {
    await _firestore.collection('fftTransformData').add({
      'acceleration': acceleration,
      'frequency': frequency,
      'Time': DateFormat('yyyy-MM-dd HH:mm:ss:S').format(time).toString(),
    });
  }

  Future<List<DocumentSnapshot>> getRawData() async {
    QuerySnapshot querySnapshot = await _firestore.collection('RawData').get();
    return querySnapshot.docs;
  }

  Future<void> deleteAllData() async {
    WriteBatch batch = _firestore.batch();

    QuerySnapshot rawDataSnapshot =
        await _firestore.collection('RawData').get();
    for (QueryDocumentSnapshot documentSnapshot in rawDataSnapshot.docs) {
      batch.delete(documentSnapshot.reference);
    }

    QuerySnapshot fftDataSnapshot =
        await _firestore.collection('fftTransformData').get();
    for (QueryDocumentSnapshot documentSnapshot in fftDataSnapshot.docs) {
      batch.delete(documentSnapshot.reference);
    }

    await batch.commit();
  }

  Future<void> exportToCSV() async {
    try {
      await requestStoragePermission();
      String rawDataFoldername = "RawData";
      Directory? appExternalStorageDir = await getExternalStorageDirectory();
      Directory rawDataDirectory =
          await Directory(join(appExternalStorageDir!.path, rawDataFoldername))
              .create(recursive: true);

      if (await rawDataDirectory.exists()) {
        print('Folder Already Exists at path : $rawDataDirectory.path');
      } else {
        print('Folder Created');
      }

      List<DocumentSnapshot> rawData = await _firestore
          .collection('RawData')
          .get()
          .then((value) => value.docs);

      List<List<dynamic>> rawDataCsvData = [
        ['X-acceleration', 'Y-acceleration', 'Z-acceleration', 'Time'],
        for (var doc in rawData)
          [doc['a_X'], doc['a_Y'], doc['a_Z'], doc['time']],
      ];

      String rawDataCsv = const ListToCsvConverter().convert(rawDataCsvData);
      String rawDataFileName =
          'RawData${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}.csv';

      String rawDataPath = '${rawDataDirectory.path}/$rawDataFileName';
      File accFile = File(rawDataPath);
      await accFile.writeAsString(rawDataCsv);
      print('CSV files exported to path: ${rawDataDirectory.path}');
      message = 'CSV files exported to path: ${rawDataDirectory.path}';
    } on FirebaseException catch (e) {
      message = 'Error fetching data from Firestore: ${e.code} - ${e.message}';
    } on FileSystemException catch (e) {
      message = 'Error creating or writing CSV file: $e';
    } catch (e) {
      message = 'Unexpected error during CSV export: $e';
    }
  }
}
