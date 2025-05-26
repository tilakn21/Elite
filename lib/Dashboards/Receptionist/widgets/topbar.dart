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
              color: isDashboard ? Color(0xFF1B2330) : Colors.white,
              letterSpacing: 1.0,
            ),
          ),
          const Spacer(),
          if (isDashboard)
            Container(
              width: 320,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search data for this page',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ),
            ),
          if (isDashboard) const SizedBox(width: 32),
          IconButton(
            icon: Icon(Icons.bar_chart_rounded, color: isDashboard ? Color(0xFF9BA8B7) : Colors.white, size: 28),
            onPressed: () {},
            splashRadius: 24,
          ),
          IconButton(
            icon: Icon(Icons.notifications_none, color: isDashboard ? Color(0xFF9BA8B7) : Colors.white, size: 28),
            onPressed: () {},
            splashRadius: 24,
          ),
          const SizedBox(width: 24),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: isDashboard ? Color(0xFF24344D) : Colors.white,
                radius: 20,
                child: Text('J', style: TextStyle(color: isDashboard ? Colors.white : sidebarColor, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('John Doe', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: isDashboard ? Color(0xFF1B2330) : Colors.white)),
                  Text('Receptionist', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 11, color: isDashboard ? Color(0xFF1B2330) : Colors.white)),
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
