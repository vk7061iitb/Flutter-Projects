import 'dart:math';

import 'package:flutter/material.dart';

class ClockView extends StatefulWidget {
  const ClockView({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ClockViewState createState() => _ClockViewState();
}

class _ClockViewState extends State<ClockView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      child: CustomPaint(
        painter: ClockPainter(),
      ),
    );
  }
}

class ClockPainter extends CustomPainter {
  @override
  void paint (Canvas canvas, Size size) {
    var CenterX = size.width/2;
    var CenterY = size.height/2;
    var Center = Offset(CenterX, CenterY);
    var Radius = min(CenterX,CenterY);

    var fillBrush = Paint()
    ..color = const Color(0xFF444974);

    var outlineBrush = Paint()
    ..color = const Color(0xFFEAECFF);

    canvas.drawCircle(Center, Radius - 40, fillBrush);
    canvas.drawCircle(Center, Radius - 40, outlineBrush);

  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}