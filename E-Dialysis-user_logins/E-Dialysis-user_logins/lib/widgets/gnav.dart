import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MyGNav extends StatelessWidget {
  const MyGNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          child: GNav(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              gap: 8,
              haptic: true,
              color: Colors.grey[800],
              activeColor: Color.fromRGBO(246, 82, 19, 1),
              tabBackgroundColor: Color.fromRGBO(246, 82, 19, 0.1),
              iconSize: 24,
              padding: EdgeInsets.all(16),
              tabs: const [
                GButton(
                  icon: Icons.home_rounded,
                  text: 'Home',
                ),
                GButton(
                  icon: Icons.list_alt_rounded,
                  text: 'Bookings',
                ),
                GButton(
                  icon: Icons.person,
                  text: 'Profile',
                )
              ]
          ),
        ),
      ),
    );
  }
}
