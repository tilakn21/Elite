import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SalespersonTopBar extends StatelessWidget {
  final bool isDashboard;
  final bool showMenu;
  final VoidCallback? onMenuTap;
  const SalespersonTopBar({Key? key, this.isDashboard = false, this.showMenu = false, this.onMenuTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const sidebarColor = Color(0xFF0D223F);
    return Container(
      height: 70,
      color: sidebarColor,
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showMenu)
            IconButton(
              icon: Icon(Icons.menu, color: Colors.white, size: 28),
              onPressed: onMenuTap,
              tooltip: 'Open menu',
            ),
          if (!showMenu) const SizedBox(width: 32),
          Text(
            'Salesperson',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: isDashboard ? Color(0xFF1B2330) : Colors.white,
              letterSpacing: 1.0,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white, size: 26),
            tooltip: 'Log Out',
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              } else {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
          ),
        ],
      ),
    );
  }
}
