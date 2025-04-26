import 'package:flutter/material.dart';

class AccountsSidebar extends StatelessWidget {
  final int selectedIndex;
  const AccountsSidebar({Key? key, required this.selectedIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: const Color(0xFF19202E),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Image.asset('assets/images/elite_logo.png', height: 48),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _SidebarButton(
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  selected: selectedIndex == 0,
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed('/accounts/dashboard');
                  },
                ),
                _SidebarButton(
                  icon: Icons.receipt_long,
                  label: 'Invoice',
                  selected: selectedIndex == 1,
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed('/accounts/invoice');
                  },
                ),
                _SidebarButton(
                  icon: Icons.people,
                  label: 'Employee',
                  selected: selectedIndex == 2,
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed('/accounts/employee');
                  },
                ),
              ],
            ),
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
  final VoidCallback onTap;

  const _SidebarButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: Material(
        color: selected ? const Color(0xFFF1F0FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: Row(
              children: [
                Icon(icon, color: selected ? const Color(0xFF6C63FF) : Colors.white, size: 22),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? const Color(0xFF6C63FF) : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
