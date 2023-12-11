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
  const CustomFlChart({super.key, required this.aXraw, required this.aYraw, required this.aZraw, required this.flagxAcceleration, required this.flagyAcceleration, required this.flagzAcceleration});

  @override
  Widget build(BuildContext context) {
    return LineChart(
                LineChartData(
                  borderData: FlBorderData(show: true),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: const SideTitles(
                        showTitles: false,
                      ),
                      axisNameWidget: Text(
                        'Time',
                        style: GoogleFonts.raleway(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: const SideTitles(
                        showTitles: true,
                        interval: 3,
                        reservedSize: 50,
                      ),
                      axisNameWidget: Text(
                        'aceleration(m/s2)',
                        style: GoogleFonts.raleway(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: flagzAcceleration
                          ? aZraw.map((point) {
                              return FlSpot(
                                  point.x.millisecondsSinceEpoch.toDouble() *
                                      1000,
                                  point.y);
                            }).toList()
                          : [],
                      isCurved: true,
                      curveSmoothness: 0.5,
                      barWidth: 1,
                      color: Colors.red,
                      dotData: const FlDotData(show: false),
                      /* belowBarData: BarAreaData(
                            show: true, color: Colors.black87.withOpacity(0.1)), */
                    ),

                    //

                    LineChartBarData(
                      spots: flagxAcceleration
                          ? aXraw.map((point) {
                              return FlSpot(
                                  point.x.millisecondsSinceEpoch.toDouble() *
                                      1000,
                                  point.y);
                            }).toList()
                          : [],
                      isCurved: true,
                      curveSmoothness: 0.5,
                      barWidth: 1,
                      color: Colors.black,
                      dotData: const FlDotData(show: false),
                      /* belowBarData: BarAreaData(
                            show: true, color: Colors.black87.withOpacity(0.1)), */
                    ),

                    //
                    LineChartBarData(
                      spots: flagyAcceleration
                          ? aYraw.map((point) {
                              return FlSpot(
                                  point.x.millisecondsSinceEpoch.toDouble() *
                                      1000,
                                  point.y);
                            }).toList()
                          : [],
                      isCurved: true,
                      curveSmoothness: 0.5,
                      barWidth: 1,
                      color: Colors.blue,
                      dotData: const FlDotData(show: false),
                      /* belowBarData: BarAreaData(
                            show: true, color: Colors.black87.withOpacity(0.1)), */
                    ),
                  ],
                ),
              );
  }
}
