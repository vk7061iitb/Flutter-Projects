import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Classes & Functions/datapoint2.dart';

class CustomFlChart2 extends StatelessWidget {
  final bool flagxAcceleration;
  final bool flagyAcceleration;
  final bool flagzAcceleration;
  final List<DataPoint2> aXraw;
  final List<DataPoint2> aYraw;
  final List<DataPoint2> aZraw;
  const CustomFlChart2(
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
        child: LineChart(
          LineChartData(
            lineTouchData: const LineTouchData(
              enabled: true,
            ),
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
              // bottom titles
              bottomTitles: AxisTitles(
                axisNameSize: 20,
                sideTitles: SideTitles(
                    getTitlesWidget: (value, meta) =>
                        customGetBottomTitleWidget(value, meta),
                    showTitles: true,
                    reservedSize: 40),
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

              // right titles
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              // left titles
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
                        return FlSpot(point.timeDifference, point.accValue);
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
                        return FlSpot(point.timeDifference, point.accValue);
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
                        return FlSpot(point.timeDifference, point.accValue);
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
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget customGetBottomTitleWidget(double value, TitleMeta meta) {
    return SideTitleWidget(
      space: 10,
      angle: 0,
      axisSide: meta.axisSide,
      child: Text(
        meta.formattedValue,
        style: GoogleFonts.raleway(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
