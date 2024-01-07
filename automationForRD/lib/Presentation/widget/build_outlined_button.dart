import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

OutlinedButton buildOutlinedButton({
  required VoidCallback onPressed,
  required String label,
}) {
  return OutlinedButton(
    onPressed: onPressed,
    style: ButtonStyle(
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.black, width: 1),
        ),
      ),
    ),
    child: Text(
      label,
      style: GoogleFonts.raleway(
        color: Colors.black,
        fontWeight: FontWeight.normal,
        fontSize: 16,
      ),
    ),
  );
}
