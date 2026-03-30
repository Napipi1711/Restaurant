import 'package:flutter/material.dart';

class WaiterBottomNav extends StatefulWidget {
  final List<Widget> screens;
  final List<BottomNavigationBarItem> items;
  final Color selectedColor;

  const WaiterBottomNav({
    super.key,
    required this.screens,
    required this.items,
    this.selectedColor = Colors.orange,
  });

  @override
  State<WaiterBottomNav> createState() => _WaiterBottomNavState();
}

class _WaiterBottomNavState extends State<WaiterBottomNav> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: widget.selectedColor,
        items: widget.items,
      ),
    );
  }
}
