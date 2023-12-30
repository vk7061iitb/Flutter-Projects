import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pave_track_master/Classes/classes/data_point.dart';

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
    double barWidth = 1.5;
    Color xAccPlotColor = Colors.black;
    Color yAccPlotColor = Colors.blue;
    Color zAccPlotColor = Colors.red;
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
        child: SizedBox(
          width: MediaQuery.of(context).size.height * 2,
          child: LineChart(
            LineChartData(
              borderData: FlBorderData(
                show: false,
                
              ),
              gridData: const FlGridData(
                drawHorizontalLine: true,
                horizontalInterval: 2,
                drawVerticalLine: false,
              ),
              titlesData: FlTitlesData(
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  drawBelowEverything: false,
                  axisNameSize: 20,
                  sideTitles: const SideTitles(
                    showTitles: false,
                  ),
                  axisNameWidget: Tooltip(
                    message: "Time",
                    child: Text(
                      'Time',
                      style: GoogleFonts.raleway(
                        color: Colors.blueGrey.shade600,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  axisNameSize: 20,
                  sideTitles: SideTitles(
                    getTitlesWidget: (value, meta) =>
                        customGetLeftTitleWidget(value, meta),
                    showTitles: true,
                    interval: 10,
                    reservedSize: 30,
                  ),
                  axisNameWidget: Tooltip(
                    message: 'Acceleration (m/s²)',
                    child: Text(
                      'Acceleration (m/s²)',
                      style: GoogleFonts.raleway(
                        color: Colors.blueGrey.shade600,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
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
                              point.x.microsecondsSinceEpoch.toDouble()*100, point.y);
                        }).toList()
                      : [],
                  isCurved: true,
                  curveSmoothness: 0,
                  barWidth: barWidth,
                  color: zAccPlotColor,
                  dotData: const FlDotData(show: false),
                ),

                /// Bar data for X-acceleration
                LineChartBarData(
                  spots: flagxAcceleration
                      ? aXraw.map((point) {
                          return FlSpot(
                              point.x.microsecondsSinceEpoch.toDouble()*100, point.y);
                        }).toList()
                      : [],
                  isCurved: true,
                  curveSmoothness: 0,
                  barWidth: barWidth,
                  color: xAccPlotColor,
                  dotData: const FlDotData(show: false),
                ),

                /// Bar data for Y-acceleration
                LineChartBarData(
                  spots: flagyAcceleration
                      ? aYraw.map((point) {
                          return FlSpot(
                              point.x.microsecondsSinceEpoch.toDouble()*100, point.y);
                        }).toList()
                      : [],
                  isCurved: true,
                  curveSmoothness: 0,
                  barWidth: barWidth,
                  color: yAccPlotColor,
                  dotData: const FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget customGetLeftTitleWidget(double value, TitleMeta meta) {
    return SideTitleWidget(
      space: 10,
      angle: 0,
      axisSide: meta.axisSide,
      child: Text(
        meta.formattedValue,
        style: GoogleFonts.raleway(
          color: Colors.blueGrey,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
