import 'package:flutter/material.dart';
import'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pave_track_master/classes_functions.dart/polyline_info.dart';

  void drawPolyline(List<Position> positionsList, List<DateTime> time, Set<Polyline>polylines) {
    List<Position> twoPositions = [];
    List<double> avgSpeedsList = [];
    List<DateTime> timeList = [];
    List<int> indexNo = [];
    List<PolylineInfo> polylinesObject = [];
    double minAvgSpeed = 5;
    double minDistanceForColor = 10.0;
    List<double> pathLengths = [];

    twoPositions.add(positionsList[0]); // Add the initial position
    indexNo.add(0);
    int i = 0;

    while (i < positionsList.length - 1) {
      int j = i + 1; // Start the inner loop from the next position

      while (j < positionsList.length) {
        double d = Geolocator.distanceBetween(
            positionsList[i].latitude,
            positionsList[i].longitude,
            positionsList[j].latitude,
            positionsList[j].longitude);

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
      for (int j = indexNo[i]; j <= indexNo[i + 1]; j++) {
        points1
            .add(LatLng(positionsList[j].latitude, positionsList[j].longitude));
      }

      Polyline polyline1 = Polyline(
        polylineId: PolylineId('1$i'),
        points: points1,
        color: (avgSpeedsList[i] > minAvgSpeed) ? Colors.black : Colors.red,
        width: 5,
        jointType: JointType.round,
      );

      polylinesObject.add(PolylineInfo(
          polyline: polyline1,
          points: points1,
          avgSpeed: avgSpeedsList[i],
          pathLength: pathLengths[i]));
    }

    polylines.clear();
      for (int i = 0; i < polylinesObject.length; i++) {
        polylines.add(polylinesObject[i].polyline);
      }
  }