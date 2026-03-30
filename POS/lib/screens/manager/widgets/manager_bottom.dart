import 'package:flutter/material.dart';

class ManagerBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap; // Sử dụng ValueChanged thay cho Function(int) theo chuẩn Flutter

  const ManagerBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).primaryColor, // Tự động lấy màu chủ đạo
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true, // Hiển thị label ngay cả khi không chọn (nhìn cân đối hơn)
      items: _buildNavItems(),
    );
  }

  // Tách danh sách items ra riêng để dễ quản lý và bảo trì
  List<BottomNavigationBarItem> _buildNavItems() {
    return const [
      BottomNavigationBarItem(
        icon: Icon(Icons.dashboard_outlined),
        activeIcon: Icon(Icons.dashboard), // Icon đậm hơn khi được chọn
        label: 'Dashboard',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.table_bar_outlined),
        activeIcon: Icon(Icons.table_bar),
        label: 'Table',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.restaurant_menu_outlined),
        activeIcon: Icon(Icons.restaurant_menu),
        label: 'Food',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.people_outline),
        activeIcon: Icon(Icons.people),
        label: 'Staff',
      ),
    ];
  }
}