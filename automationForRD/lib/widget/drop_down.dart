import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ModernRoundedDropdown extends StatefulWidget {
  const ModernRoundedDropdown({super.key});

  @override
  ModernRoundedDropdownState createState() => ModernRoundedDropdownState();
}

class ModernRoundedDropdownState extends State<ModernRoundedDropdown> {
  String selectedValue = 'Raw Data';

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      isExpanded: true,
      value: selectedValue,
      icon: const Icon(Icons.arrow_drop_down_sharp),
      iconSize: 24,
      elevation: 16,
      style: GoogleFonts.raleway(
        color: Colors.black,
        fontWeight: FontWeight.normal,
        fontSize: 12,
      ),
      underline: const SizedBox(),
      onChanged: (String? newValue) {
        setState(() {
          selectedValue = newValue!;
        });
      },
      items: <String>[
        'Raw Data',
        'Aligned Data',
        'Low-Pass Filter Data',
        'Band-Pass Filter Data',
        'High-Pass Filter Data',
        'Energy Band Data',
      ].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: selectedValue == value
                      ? Colors.black.withOpacity(0.2)
                      : Colors.transparent, // Shadow color
                  spreadRadius: 2,
                  blurRadius: 2,
                ),
              ],
              borderRadius: BorderRadius.circular(25),
              color: selectedValue == value ? Colors.green : Colors.transparent,
              border: Border.all(
                  color: selectedValue == value
                      ? Colors.white
                      : Colors.transparent,
                  width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Text(
                value,
                style: GoogleFonts.raleway(
                  color: selectedValue == value ? Colors.white : Colors.black,
                  fontWeight: FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
