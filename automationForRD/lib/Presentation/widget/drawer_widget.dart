import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Pages/pci_page.dart';

class Customdrawer extends StatelessWidget {
  const Customdrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.black87,
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
                  'User Name',
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
            leading: const Icon(Icons.download, color: Colors.black),
            title: Text(
              'Exported Data',
              style: GoogleFonts.raleway(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
            onTap: () {
              // 
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.location_on, color: Colors.black),
            title: Text(
              'PCI Page',
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
                    builder: (context) => const PCIpage(),
                  ));
              
            },
          ),
          const Divider(),
          // Add more ListTile items as needed
        ],
      ),
    );
  }
}
