import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../login_screen.dart';

class ManagerTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const ManagerTopBar({
    super.key,
    required this.title,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.bottomCenter, // Đảm bảo nội dung căn dưới nếu cần
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: kToolbarHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLogo(),
              _buildLogoutButton(context),
            ],
          ),
        ),
      ),
    );
  }

  // Tách nhỏ UI Logo
  Widget _buildLogo() {
    return const Text(
      "POS System",
      style: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Tách nhỏ UI Logout và xử lý logic
  Widget _buildLogoutButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout, color: Colors.white),
      tooltip: 'Đăng xuất',
      onPressed: () => _handleLogout(context),
    );
  }

  // Logic đăng xuất tách riêng để code build() sạch sẽ
  Future<void> _handleLogout(BuildContext context) async {
    await AuthService.logout();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }
}