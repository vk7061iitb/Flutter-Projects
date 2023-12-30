// Helper method to create each row of information
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildInfoRow(String label, String data) {
  return Padding(
    padding: const EdgeInsets.only(left: 8, right: 8, bottom: 1),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.raleway(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        Text(
          data.toString(),
          style: GoogleFonts.raleway(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    ),
  );
}