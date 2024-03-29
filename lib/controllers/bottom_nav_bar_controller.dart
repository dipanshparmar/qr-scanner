import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// pages
import '../pages/pages.dart';

// providers
import '../providers/providers.dart';

class BottomNavBarController extends StatefulWidget {
  const BottomNavBarController({Key? key}) : super(key: key);

  @override
  State<BottomNavBarController> createState() => _BottomNavBarControllerState();
}

class _BottomNavBarControllerState extends State<BottomNavBarController> {
  // current index
  int _currentIndex = 0;

  // pages
  final List<Widget> _pages = const [
    HomePage(),
    SavedScansPage(),
  ];

  // method to fetch the data
  Future<void> _fetchData() async {
    //  getting the data from the database
    await Provider.of<SavedScansProvider>(context, listen: false)
        .fetchSavedScans();
  }

  @override
  void initState() {
    super.initState();

    // fetching the data
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).primaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            label: 'Saved',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 1 &&
              Provider.of<SavedScansProvider>(context).savedScans.isNotEmpty
          ? FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchPage(),
                  ),
                );
              },
            )
          : null,
    );
  }
}
