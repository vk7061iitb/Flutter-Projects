import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pave_track_master/Pages/bump_activity.dart';

class Customdrawer extends StatelessWidget {
  const Customdrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(topRight: Radius.circular(5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  // You can add an image or initials/avatar icon here
                ),
                const SizedBox(height: 10),
                Text(
                  'Vikash',
                  style: GoogleFonts.raleway(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.timeline, color: Colors.black),
            title: Text(
              'Acceleration',
              style: GoogleFonts.raleway(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const BumpActivity()));
            },
          ),
          // const Divider(), // Add a divider for separation
          // Add more ListTile items as needed
        ],
      ),
    );
  }
}
