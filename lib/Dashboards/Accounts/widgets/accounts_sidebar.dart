import 'package:flutter/material.dart';

class AccountsSidebar extends StatelessWidget {
  final int selectedIndex;
  final String? accountantId;
  const AccountsSidebar({Key? key, required this.selectedIndex, this.accountantId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: const BoxDecoration(
        color: Color(0xFF101C2C),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Image.asset('assets/images/elite_logo.png', height: 48),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _SidebarButton(
                  icon: Icons.dashboard,
                  label: 'Jobs',
                  selected: selectedIndex == 0,
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed('/accounts/dashboard', arguments: {'accountantId': accountantId});
                  },
                ),
                _SidebarButton(
                  icon: Icons.people,
                  label: 'Employee',
                  selected: selectedIndex == 2,
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed('/accounts/employee', arguments: {'accountantId': accountantId});
                  },
                ),
                _SidebarButton(
                  icon: Icons.calendar_today,
                  label: 'Calendar',
                  selected: selectedIndex == 3,
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed('/accounts/calendar', arguments: {'accountantId': accountantId});
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              },
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
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
