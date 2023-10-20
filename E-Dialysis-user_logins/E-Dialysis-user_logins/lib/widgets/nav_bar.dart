import 'package:flutter/material.dart';

class MyBottomNavigationBar extends StatefulWidget {
  const MyBottomNavigationBar({super.key});

  @override
  State<MyBottomNavigationBar> createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      elevation: 0,
      currentIndex: _currentIndex,
      backgroundColor: Colors.white,
      items: [
        BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded,color: Colors.grey[600],),
          label: '',
          backgroundColor: Colors.white
        ),
        BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.grey[600],),
          label: ''
        )
      ],
      onTap: (index){
          setState(() {
            _currentIndex = index;
            print('$index , $_currentIndex');
          });
      },
    );
  }
}
