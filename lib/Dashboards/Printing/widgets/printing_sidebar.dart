import 'package:flutter/material.dart';

class PrintingSidebar extends StatelessWidget {
  final int selectedIndex;
  const PrintingSidebar({Key? key, this.selectedIndex = 0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: const Color(0xFF19202E),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          // Logo
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
                    Navigator.of(context).pushReplacementNamed('/printing/dashboard');
                  },
                ),
                _SidebarButton(
                  icon: Icons.print,
                  label: 'Print Job details',
                  selected: selectedIndex == 1,
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed('/printing/assignlabour');
                  },
                ),
                _SidebarButton(
                  icon: Icons.bar_chart,
                  label: 'Quality check',
                  selected: selectedIndex == 2,
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed('/printing/qualitycheck');
                  },
                ),
              ],
            ),
          ),
          const Spacer(),
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
  const _SidebarButton({required this.icon, required this.label, required this.selected, required this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? const Color(0xFF232B3E) : Colors.white, size: 22),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: selected ? const Color(0xFF232B3E) : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
