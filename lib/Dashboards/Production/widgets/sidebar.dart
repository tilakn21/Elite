import 'package:flutter/material.dart';

class ProductionSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  const ProductionSidebar({Key? key, this.selectedIndex = 0, required this.onItemTapped}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Color(0xFF142433),
        borderRadius: BorderRadius.only(topRight: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 36),
          // Logo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Image.asset('assets/images/elite_logo.png', height: 70),
          ),
          const SizedBox(height: 36),
          // Navigation
          _SidebarButton(
            icon: Icons.dashboard,
            label: 'Dashboard',
            selected: selectedIndex == 0,
            onTap: () => onItemTapped(0),
          ),
          _SidebarButton(
            icon: Icons.people_alt_outlined,
            label: 'Assign labour',
            selected: selectedIndex == 1,
            onTap: () => onItemTapped(1),
          ),
          _SidebarButton(
            icon: Icons.list_alt,
            label: 'Job List',
            selected: selectedIndex == 2,
            onTap: () => onItemTapped(2),
          ),
          _SidebarButton(
            icon: Icons.bar_chart,
            label: 'Update job status',
            selected: selectedIndex == 3,
            onTap: () => onItemTapped(3),
          ),
        ],
      ),
    );
  }
}

class _SidebarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  const _SidebarButton({required this.icon, required this.label, this.selected = false, this.onTap});
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: selected
              ? BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                )
              : null,
          child: ListTile(
            leading: Icon(icon, color: selected ? Color(0xFF2B3A55) : Colors.white, size: 28),
            title: Text(label, style: TextStyle(color: selected ? Color(0xFF2B3A55) : Colors.white, fontWeight: FontWeight.w600)),
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            hoverColor: Colors.white24,
          ),
        ),
      ),
    );
  }
}
