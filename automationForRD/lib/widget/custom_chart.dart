import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pave_track_master/classes_functions.dart/data_point.dart';
class CustomFlChart extends StatelessWidget {
  final bool flagxAcceleration;
  final bool flagyAcceleration;
  final bool flagzAcceleration;
  final List<DataPoint> aXraw;
  final List<DataPoint> aYraw;
  final List<DataPoint> aZraw;
  const CustomFlChart(
      {super.key,
      required this.aXraw,
      required this.aYraw,
      required this.aZraw,
      required this.flagxAcceleration,
      required this.flagyAcceleration,
      required this.flagzAcceleration});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Shadow color
            spreadRadius: 2,
            blurRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: LineChart(
          LineChartData(
            borderData: FlBorderData(show: true),
            titlesData: FlTitlesData(
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: const SideTitles(
                  showTitles: false,
                ),
                axisNameWidget: Tooltip(
                  message: "Time",
                  child: Text(
                    'Time',
                    style: GoogleFonts.raleway(
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: const SideTitles(
                  showTitles: true,
                  interval: 5,
                  reservedSize: 25,
                ),
                axisNameWidget: Tooltip(
                  message:  'Acceleration (m/s²)',
                  child: Text(
                    'Acceleration (m/s²)',
                    style: GoogleFonts.raleway(
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
        
            lineBarsData: [
              /// Bar data for Z-acceleration
              LineChartBarData(
                spots: flagzAcceleration
                    ? aZraw.map((point) {
                        return FlSpot(
                            point.x.millisecondsSinceEpoch* 100,
                            point.y);
                      }).toList()
                    : [],
                isCurved: true,
                curveSmoothness: 0.1,
                barWidth: 1,
                color: Colors.red,
                dotData: const FlDotData(show: false),
              ),
        
              /// Bar data for X-acceleration
              LineChartBarData(
                spots: flagxAcceleration
                    ? aXraw.map((point) {
                        return FlSpot(
                            point.x.millisecondsSinceEpoch* 100,
                            point.y);
                      }).toList()
                    : [],
                isCurved: true,
                curveSmoothness: 0.5,
                barWidth: 1,
                color: Colors.black,
                dotData: const FlDotData(show: false),
              ),
        
              /// Bar data for Y-acceleration
              LineChartBarData(
                spots: flagyAcceleration
                    ? aYraw.map((point) {
                        return FlSpot(
                            point.x.millisecondsSinceEpoch* 100,
                            point.y);
                      }).toList()
                    : [],
                isCurved: true,
                curveSmoothness: 0.5,
                barWidth: 1,
                color: Colors.blue,
                dotData: const FlDotData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
