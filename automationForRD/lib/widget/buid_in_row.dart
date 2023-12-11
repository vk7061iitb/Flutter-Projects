// Helper method to create each row of information
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildInfoRow(String label, dynamic value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.sofiaSans(
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 16,
          ),
        ),
        Text(
          value.toString(),
          style: GoogleFonts.sofiaSans(
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ],
    ),
  );
}