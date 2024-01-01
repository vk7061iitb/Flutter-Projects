import 'package:flutter/material.dart';

class MapDropdown extends StatefulWidget {
  const MapDropdown({super.key});

  @override
  MapDropdownState createState() => MapDropdownState();
}

class MapDropdownState extends State<MapDropdown> {
  String selectedValue = 'Normal';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: Colors.blue,
          width: 2.0,
        ),
      ),
      child: DropdownButton<String>(
        value: selectedValue,
        icon: const Icon(Icons.arrow_drop_down),
        iconSize: 24,
        elevation: 16,
        style: const TextStyle(color: Colors.blue),
        onChanged: (String? newValue) {
          setState(() {
            selectedValue = newValue!;
          });
        },
        items: <String>['Normal', 'Hybrid', 'Satellite']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }
}