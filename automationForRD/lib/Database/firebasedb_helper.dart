// ignore_for_file: avoid_print
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pave_track_master/Classes/classes/raw_data.dart';
import 'package:tuple/tuple.dart';
import '../Classes/classes/request_storage_permission.dart';

class FirestoreDatabaseHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String message = '';
  /// NOTE : In Flutter batch insertion with Firebase Firestore, the order of insertion is not guaranteed to be preserved when
  /// using the WriteBatch API. 
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
          'Time': DateFormat('yyyy-MM-dd HH:mm:ss:S').format(data.time),
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

  Future<void> insertTransformedData(List<Tuple2<LatLng, LatLng>> pairs) async {
    try {
      WriteBatch batch = _firestore.batch();
      for (var pair in pairs) {
        DocumentReference documentReference =
            _firestore.collection('transformedData').doc();

        batch.set(documentReference, {
          'point1': {
            'latitude': pair.item1.latitude,
            'longitude': pair.item1.longitude,
          },
          'point2': {
            'latitude': pair.item2.latitude,
            'longitude': pair.item2.longitude,
          },
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

  Future<List<DocumentSnapshot>> getRawData() async {
    QuerySnapshot querySnapshot = await _firestore.collection('RawData').get();
    return querySnapshot.docs;
  }

  Future<List<Tuple2<LatLng, LatLng>>> retrieveTransformedData() async {
    List<Tuple2<LatLng, LatLng>> dataList = [];

    try {
      // Retrieve documents from the "transformedData" collection
      QuerySnapshot querySnapshot =
          await _firestore.collection('transformedData').get();

      // Process the documents
      for (QueryDocumentSnapshot document in querySnapshot.docs) {
        // Access data from each document
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;

        // Extract LatLng values from the document data
        LatLng point1 =
            LatLng(data['point1']['latitude'], data['point1']['longitude']);
        LatLng point2 =
            LatLng(data['point2']['latitude'], data['point2']['longitude']);

        // Add Tuple2 to the list
        dataList.add(Tuple2<LatLng, LatLng>(point1, point2));
      }

      return dataList;
    } catch (error) {
      // Handle errors
      print('Error retrieving data: $error');
      return dataList; // Return an empty list or handle errors as needed
    }
  }

  Future<void> deleteAllData() async {
    WriteBatch batch = _firestore.batch();

    QuerySnapshot rawDataSnapshot =
        await _firestore.collection('RawData').get();
    for (QueryDocumentSnapshot documentSnapshot in rawDataSnapshot.docs) {
      batch.delete(documentSnapshot.reference);
    }

    QuerySnapshot fftDataSnapshot =
        await _firestore.collection('transformedData').get();
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

      List<DocumentSnapshot> rawData =
          (await _firestore.collection('RawData').orderBy('Time').get()).docs;

      /* List<Map<String, dynamic>> rawDataList =
          rawData.map((doc) => doc.data() as Map<String, dynamic>).toList();
      String printRawData = jsonEncode(rawDataList);
      print(printRawData); */

      List<List<dynamic>> rawDataCsvData = [
        ['x_acc', 'y_acc', 'z_acc', 'longitude', 'latitude', 'Time'],
        for (var doc in rawData)
          [
            //  The ?? '' syntax is the null-aware operator, which provides a default value ('' in this case) when a field is null
            doc['x_acc'] ?? '',
            doc['y_acc'] ?? '',
            doc['z_acc'] ?? '',
            doc['latitude'] ?? '',
            doc['longitude'] ?? '',
            doc['Time'] ?? '',
          ],
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
      print(message);
    } on FileSystemException catch (e) {
      message = 'Error creating or writing CSV file: $e';
      print(message);
    } catch (e) {
      message = 'Unexpected error during CSV export: $e';
      print(message);
    }
  }
}
