import 'package:flutter/material.dart';

class CustomInfoWindow extends StatelessWidget {
  final String title;
  final String snippet;
 

   const CustomInfoWindow({super.key, 
    required this.title,
    required this.snippet,

  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            /* Image(image: image, width: 100, height: 100, fit: BoxFit.cover),
            const SizedBox(height: 8), */
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(snippet),
          ],
        ),
      ),
    );
  }
}
