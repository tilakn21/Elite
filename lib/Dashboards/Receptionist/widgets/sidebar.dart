import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: const Color(0xFF112233),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Image.asset('assets/images/elite_logo.png', height: 54),
                // Elite text and subtitle removed as per user request
              ],
            ),
          ),
          const SizedBox(height: 36),
          SidebarButton(
            icon: Icons.dashboard,
            label: 'Dashboard',
            selected: false,
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/receptionist/dashboard');
            },
          ),
          SidebarButton(
            icon: Icons.add_circle_outline,
            label: 'New Request',
            selected: false,
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/receptionist/new-job-request');
            },
          ),
          SidebarButton(
            icon: Icons.person_add_alt,
            label: 'Assign salesperson',
            selected: false,
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/receptionist/assign-salesperson');
            },
          ),
          // SidebarButton(
          //   icon: Icons.bar_chart_outlined,
          //   label: 'Job progress',
          //   selected: false,
          // ),
          // SidebarButton(
          //   icon: Icons.calendar_month_outlined,
          //   label: 'Calendar',
          //   selected: false,
          // ),
          const Spacer(),
        ],
      ),
    );
  }
}

class SidebarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const SidebarButton({
    super.key,
    required this.icon,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: selected
          ? BoxDecoration(
              color: const Color(0xFF24344D),
              borderRadius: BorderRadius.circular(10),
            )
          : null,
      child: ListTile(
        leading: Icon(icon, color: selected ? Color(0xFF4A6CF7) : Colors.white, size: 26),
        title: Text(
          label,
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: selected ? FontWeight.bold : FontWeight.normal),
        ),
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        selected: selected,
        selectedTileColor: const Color(0xFF24344D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onTap: onTap,
      ),
    );
  }
}
