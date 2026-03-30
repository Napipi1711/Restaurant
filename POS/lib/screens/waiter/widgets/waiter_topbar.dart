import 'package:flutter/material.dart';

class WaiterTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final VoidCallback? onLogout;
  final Color backgroundColor;

  const WaiterTopBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.onLogout,
    this.backgroundColor = Colors.orange,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: leading,
      backgroundColor: backgroundColor,
      elevation: 0,
      actions: [
        if (actions != null) ...actions!,
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Logout',
          onPressed: onLogout,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
