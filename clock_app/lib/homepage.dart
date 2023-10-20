import 'package:clock_app/clock_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();
    var formattedTime = DateFormat('HH:mm').format(now);
    var formattedDate = DateFormat('EEE, d MMM').format(now);
    // ignore: non_constant_identifier_names
    var OffsetSign = '';
    var timezoneString = now.timeZoneOffset.toString().split('.').first;
    if(!timezoneString.startsWith('-')){
      OffsetSign = '+';
    }
    return Scaffold(
      backgroundColor: const Color(0xFF2D2F41),
      body: Row(
        children:<Widget>[
          Column(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Clock',
                      style: TextStyle(
                        color: Colors.white, fontSize: 24
                      ),
                      ),
                      const SizedBox(
                        height: 32,
                      ),
              
                      Text(formattedTime,
                      style: const TextStyle(
                        color: Colors.white, fontSize: 64
                      ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(formattedDate,
                      style: const TextStyle(
                        color: Colors.white, fontSize: 20
                      ),
                      ),
                      const ClockView(),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text('TimeZone',
                      style: TextStyle(
                        color: Colors.white, fontSize: 24
                      ),
                      ),
                      
                      Row(
                        children: [
                          const Icon(
                            Icons.language,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 10,),
                          Text('UTC$OffsetSign$timezoneString',
                          style: const TextStyle(
                            color: Colors.white, fontSize: 16
                          ),
                          ),
                        ],
                      ),
              
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}