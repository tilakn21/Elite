import 'package:flutter/material.dart';

class SalespersonSidebar extends StatelessWidget {
  final String selectedRoute;
  final Function(String) onItemSelected;

  const SalespersonSidebar({
    Key? key,
    required this.selectedRoute,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF0D223F),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Home Tab
              _SidebarButton(
                icon: Icons.apps,
                label: 'Home',
                selected: selectedRoute == 'home',
                onTap: () => onItemSelected('home'),
              ),
              const SizedBox(height: 28),
              // Profile
              _SidebarButton(
                icon: Icons.person,
                label: 'Profile',
                selected: selectedRoute == 'profile',
                onTap: () => onItemSelected('profile'),
              ),
              const Spacer(),
              // Settings Icon at bottom
              Align(
                alignment: Alignment.bottomLeft,
                child: IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white, size: 28),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
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
    Key? key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: selected
            ? BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              )
            : null,
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? Color(0xFF5A6CEA) : Colors.white,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: selected ? Color(0xFF5A6CEA) : Colors.white,
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
