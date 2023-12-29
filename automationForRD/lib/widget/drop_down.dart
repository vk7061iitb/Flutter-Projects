import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ModernRoundedDropdown extends StatefulWidget {
  const ModernRoundedDropdown({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ModernRoundedDropdownState createState() => _ModernRoundedDropdownState();
}

class _ModernRoundedDropdownState extends State<ModernRoundedDropdown> {
  String selectedValue = 'Raw Data';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButton<String>(
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
          'Band-Pass Filter Data'
        ].map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }
}
