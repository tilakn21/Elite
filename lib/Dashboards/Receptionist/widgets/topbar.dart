import 'package:flutter/material.dart';

/// Usage:
///   TopBar(isDashboard: true) // for dashboard
///   TopBar(isDashboard: false) // for all other screens
class TopBar extends StatelessWidget {
  final bool isDashboard;
  final bool showMenu;
  final VoidCallback? onMenuTap;
  const TopBar({Key? key, this.isDashboard = false, this.showMenu = false, this.onMenuTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sidebar color
    const sidebarColor = Color(0xFF112233);
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
            'Receptionist',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white, // Always white for visibility
              letterSpacing: 1.0,
            ),
          ),
          const Spacer(),
          // Branch badge to the left of notification icon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Color(0xFF7DE2D1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              // TODO: Replace with actual branch name from employee table after auth
              'Branch: Demo Branch',
              style: const TextStyle(
                color: Color(0xFF1B2330),
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: Icon(Icons.notifications_none, color: Colors.white, size: 28),
            onPressed: () {},
            splashRadius: 24,
          ),
          const SizedBox(width: 24),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 20,
                child: Text('J', style: TextStyle(color: sidebarColor, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name row
                  Text('John Doe', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.white)),
                  Text('Receptionist', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 11, color: Colors.white)),
                ],
              ),
            ],
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }
}
