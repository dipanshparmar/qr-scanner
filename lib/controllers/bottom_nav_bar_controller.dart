import 'package:flutter/material.dart';

// pages
import '../pages/pages.dart';

class BottomNavBarController extends StatefulWidget {
  const BottomNavBarController({Key? key}) : super(key: key);

  @override
  _BottomNavBarControllerState createState() => _BottomNavBarControllerState();
}

class _BottomNavBarControllerState extends State<BottomNavBarController> {
  // this will hold the index of currently selected tab
  int _currentIndex = 0;

  // our pages
  final List<Widget> _pages = [
    const HomePage(),
    const SavedPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).primaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.qr_code,
              // color: Colors.white,
            ),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.favorite_outline,
              // color: Colors.white,
            ),
            label: 'Saved',
          ),
        ],
      ),
    );
  }
}
