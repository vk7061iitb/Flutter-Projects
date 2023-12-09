import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pave_track_master/classes_functions.dart/data_point.dart';

class CustomFlChart extends StatelessWidget {
  final List<DataPoint> aXdata;
  final List<DataPoint> aYdata;
  final List<DataPoint> aZdata;
  const CustomFlChart(
      {super.key,
      required this.aXdata,
      required this.aYdata,
      required this.aZdata});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.23,
      child: Stack(
        children: <Widget>[
          Column(
            children: [
              const SizedBox(
                height: 37,
              ),
              Text(
                'Accelerations',
                style: GoogleFonts.raleway(
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 37,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomFlChart(
                    aXdata: aXdata,
                    aYdata: aYdata,
                    aZdata: aZdata,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
