import 'package:flutter/material.dart';

class DesignSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  const DesignSidebar({Key? key, this.selectedIndex = 0, required this.onItemTapped}) : super(key: key);

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
          // Logo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Image.asset('assets/images/elite_logo.png', height: 48),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // children: const [
                  //   Text(
                  //     'elite',
                  //     style: TextStyle(
                  //       color: Colors.white,
                  //       fontSize: 28,
                  //       fontWeight: FontWeight.w700,
                  //       letterSpacing: 1.2,
                  //     ),
                  //   ),
                  //   Text(
                  //     'CREATIVE PRINT SIGN DISPLAY',
                  //     style: TextStyle(
                  //       color: Color(0xFFB0B7C3),
                  //       fontSize: 10,
                  //       fontWeight: FontWeight.w500,
                  //       letterSpacing: 1.1,
                  //     ),
                  //   ),
                  // ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          _SidebarButton(
            icon: Icons.dashboard,
            label: 'Dashboard',
            selected: selectedIndex == 0,
            onTap: () => onItemTapped(0),
          ),
          _SidebarButton(
            icon: Icons.list_alt,
            label: 'Job details',
            selected: selectedIndex == 1,
            onTap: () => onItemTapped(1),
          ),
          _SidebarButton(
            icon: Icons.upload_file,
            label: 'Upload\nDesign Draft',
            selected: selectedIndex == 2,
            onTap: () => onItemTapped(2),
          ),
          _SidebarButton(
            icon: Icons.chat,
            label: 'Chat',
            selected: selectedIndex == 3,
            onTap: () => onItemTapped(3),
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
  const _SidebarButton({
    Key? key,
    required this.icon,
    required this.label,
    this.selected = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: selected ? Color(0xFF101C2C) : Colors.white, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? Color(0xFF101C2C) : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
