import 'package:flutter/material.dart';

class MyText extends StatelessWidget {

  final String text;
  final TextStyle textStyle;
  const MyText({super.key, required this.text, required this.textStyle});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      softWrap: false,
      overflow: TextOverflow.fade,
      style: textStyle,
    );
  }
}
