import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pave_track_master/Classes/classes/polyline_info.dart';

// Function to draw polylines based on positions, time, and set of polylines
void drawPolyline(List<Position> positionsList, List<DateTime> time, Set<Polyline> polylines) {
  // Lists to store processed data for polyline drawing
  List<Position> twoPositions = [];
  List<double> avgSpeedsList = [];
  List<DateTime> timeList = [];
  List<int> indexNo = [];
  List<PolylineInfo> polylinesObject = [];
  
  // Constants for determining polyline colors
  double minAvgSpeed = 5;
  double minDistanceForColor = 10.0;
  List<double> pathLengths = [];

  // Add the initial position to start the process
  twoPositions.add(positionsList[0]);
  indexNo.add(0);
  int i = 0;

  // Outer loop to iterate through positionsList
  while (i < positionsList.length - 1) {
    int j = i + 1; // Start the inner loop from the next position

    // Inner loop to find consecutive positions with distance >= 10 meters
    while (j < positionsList.length) {
      double d = Geolocator.distanceBetween(
        positionsList[i].latitude,
        positionsList[i].longitude,
        positionsList[j].latitude,
        positionsList[j].longitude,
      );

      // Check if the distance is >= 10 meters
      if (minDistanceForColor >= 10) {
        twoPositions.add(positionsList[j]);
        pathLengths.add(d);
        timeList.add(time[j]);
        int timeDifference = time[j].difference(time[i]).inSeconds;
        double avgSpeed = (d / timeDifference) * 18.0 / 5;
        avgSpeedsList.add(avgSpeed);
        indexNo.add(j);
        i = j; // Update the outer loop index to the current inner loop index
        break; // Break out of the inner loop once the distance is >= 10 meters
      }

      j++;
    }

    i++;
  }

  // Drawing the polylines
  for (int i = 0; i < avgSpeedsList.length; i++) {
    List<LatLng> points1 = [];
    
    // Creating LatLng points for the polyline
    for (int j = indexNo[i]; j <= indexNo[i + 1]; j++) {
      points1.add(LatLng(positionsList[j].latitude, positionsList[j].longitude));
    }

    // Creating a Polyline based on average speed and color
    Polyline polyline1 = Polyline(
      polylineId: PolylineId('1$i'),
      points: points1,
      color: (avgSpeedsList[i] > minAvgSpeed) ? Colors.black : Colors.red,
      width: 5,
      jointType: JointType.round,
    );

    // Creating a PolylineInfo object to store additional information
    polylinesObject.add(PolylineInfo(
        polyline: polyline1,
        points: points1,
        avgSpeed: avgSpeedsList[i],
        pathLength: pathLengths[i]));
  }

  // Clear existing polylines and add the newly created ones
  polylines.clear();
  for (int i = 0; i < polylinesObject.length; i++) {
    polylines.add(polylinesObject[i].polyline);
  }
}
