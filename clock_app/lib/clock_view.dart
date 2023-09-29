import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class ClockView extends StatefulWidget {
  const ClockView({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ClockViewState createState() => _ClockViewState();
}

class _ClockViewState extends State<ClockView> {
  @override void initState(){
    super.initState();
    Timer.periodic( const Duration(seconds: 1), (timer) {
      setState(() {
        
      }
      );
    }
    );
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      child: Transform.rotate(
        angle: -pi/2,
        child: CustomPaint(
          painter: ClockPainter(),
        ),
      ),
    );
  }
}

class ClockPainter extends CustomPainter {
  var dateTime = DateTime.now();
  // 60sec => 360deg, 1sec => 6deg
  @override
  void paint (Canvas canvas, Size size) {
    var CenterX = size.width/2;
    var CenterY = size.height/2;
    var Center = Offset(CenterX, CenterY);
    var Radius = min(CenterX, CenterY);

    var fillBrush = Paint()
    ..color = const Color(0xFF444974);

    var outlineBrush = Paint()
    ..color = const Color(0xFFEAECFF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 16;  

    var centreFillBrush = Paint()
    ..color = const Color(0xFFEAECFF);

    var secHandBrush = Paint()
    ..color = Colors.orange
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 8;

    var minHandBrush = Paint()
    ..shader = const RadialGradient(colors: [Colors.lightBlue, Colors.pink]).createShader(Rect.fromCircle(center: Center, radius: Radius))
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 16;

    var hourHandBrush = Paint()
    ..shader = const RadialGradient(colors: [Colors.red, Colors.pink]).createShader(Rect.fromCircle(center: Center, radius: Radius))
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 16;

    canvas.drawCircle(Center, Radius-40 , fillBrush);
    canvas.drawCircle(Center, Radius-40 , outlineBrush);

    var minHandX = CenterX + 70*cos((dateTime.minute*6)*pi/180);
    var minHandY = CenterY + 70*sin((dateTime.minute*6)*pi/180);
    canvas.drawLine(Center, Offset(minHandX,minHandY), minHandBrush);
    
    var hourHandX = CenterX - 60*cos((dateTime.hour*30 + dateTime.minute*0.5)*pi/360);    
    var hourHandY = CenterY - 60*sin((dateTime.hour*30 + dateTime.minute*0.5)*pi/360);
    canvas.drawLine(Center, Offset(hourHandX,hourHandY), hourHandBrush);

    var secHandX = CenterX + 80*cos(dateTime.second*6*pi/180);
    var secHandY = CenterY + 80*sin(dateTime.second*6*pi/180);
    canvas.drawLine(Center, Offset(secHandX,secHandY), secHandBrush);

    canvas.drawCircle(Center, 16 , centreFillBrush);

  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}