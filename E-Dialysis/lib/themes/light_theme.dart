import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    background: Colors.white,
    primary: Color.fromRGBO(246, 82, 19, 1),
    secondary: Colors.grey.shade400,
    inversePrimary: Colors.grey.shade800
  )
);
