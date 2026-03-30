import 'package:flutter/material.dart';
import 'table/table_screen.dart';
import 'food/food_screen.dart';
import 'staff/check_on_staff_screen.dart';
import 'widgets/manager_bottom.dart';
import 'widgets/manager_topbar.dart';
import 'dashboard_screen.dart';
class ManagerHome extends StatefulWidget {
  const ManagerHome({super.key});

  @override
  State<ManagerHome> createState() => _ManagerHomeState();
}

class _ManagerHomeState extends State<ManagerHome> {
  int _index = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    TableScreen(),
    FoodScreen(),
    CheckOnStaffScreen(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Table Management',
    'Food Management',
    'Staff Check',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: ManagerTopBar(title: _titles[_index]),


      body: _screens[_index],


      bottomNavigationBar: ManagerBottomNav(
        currentIndex: _index,
        onTap: (i) {
          setState(() => _index = i);
        },
      ),
    );
  }
}
