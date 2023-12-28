// Function to send data to the server
// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<List<Map<String, dynamic>>> sendDataToServer(String httpString) async {
  // Define the URL of the Flask server
  // Adjust the URL based on your Flask server configuration
  final url = Uri.parse(join(httpString, 'rotation_matrix'));

  // Open the database
  final Database database = await openDatabase('test.db');

  // Fetch accelerometer data from the accData table
  final List<Map<String, dynamic>> databaseData =
      await database.rawQuery('SELECT * FROM accData');

  // Create a List to store data for all rows
  List<Map<String, dynamic>> dataList = [];

  if (databaseData.isNotEmpty) {
    for (var row in databaseData) {
      // Iterate through all rows in the databaseData list
      Map<String, dynamic> data = {
        'x_acc': row['a_X'],
        'y_acc': row['a_Y'],
        'z_acc': row['a_Z'],
        'time': row['Time'],
      };

      // Add the data for the current row to the dataList
      dataList.add(data);
    }
  }

  try {
    // Send a POST request to the server with JSON-encoded data
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dataList),
    );

    // Check the HTTP response status code
    if (response.statusCode == 200) {
      // Successful response, process the data
      final responseData = jsonDecode(response.body);
      print('Received Data from Server: $responseData');
      return jsonDecode(responseData);
      // Handle the received data as needed
    } else {
      // Handle other status codes
      print('Error: ${response.statusCode}');
      return [
        {'error': '${response.statusCode}'}
      ];
    }
  } catch (e) {
    // Handle network or server errors
    print('Error: $e');
    return [
      {'error': '$e'}
    ];
  }
}
