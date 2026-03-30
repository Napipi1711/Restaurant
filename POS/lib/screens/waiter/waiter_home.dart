import 'package:flutter/material.dart';
import 'Serving_screen.dart';
import 'profile_detail_screen.dart';
import 'summary_screen.dart';

class WaiterHome extends StatefulWidget {
  const WaiterHome({super.key});

  @override
  State<WaiterHome> createState() => _WaiterHomeState();
}

class _WaiterHomeState extends State<WaiterHome> {
  int _currentIndex = 0;

  final List<Widget> _screens = [

    const MyReservationsScreen(),   // 1. Reservations
    const WaiterSummaryScreen(),       // 2. Summary
    const ProfileDetailScreen(), // 3. Profile
  ];

  final List<String> _titles = [
    'Reservations',
    'Summary',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_currentIndex])),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Reservations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Summary',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
