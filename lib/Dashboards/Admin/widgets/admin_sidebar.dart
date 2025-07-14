import 'package:flutter/material.dart';

class AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  const AdminSidebar({Key? key, this.selectedIndex = 0, required this.onItemTapped}) : super(key: key);

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
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(2, 0),
          ),
        ],
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
          const SizedBox(height: 16),
          const Divider(color: Color(0xFF25304A), thickness: 1, indent: 24, endIndent: 24),
          const SizedBox(height: 24),
          _SidebarButton(
            icon: Icons.dashboard,
            label: 'Dashboard',
            selected: selectedIndex == 0,
            onTap: () {
              if (ModalRoute.of(context)?.settings.name != '/admin/dashboard') {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/admin/dashboard',
                  (route) => false,
                );
              }
              onItemTapped(0);
            },
          ),
          _SidebarButton(
            icon: Icons.people_alt,
            label: 'Employee',
            selected: selectedIndex == 1,
            onTap: () {
              if (ModalRoute.of(context)?.settings.name != '/admin/employees') {
                Navigator.pushReplacementNamed(context, '/admin/employees');
              }
              onItemTapped(1);
            },
          ),
          // _SidebarButton(
          //   icon: Icons.person_add_alt_1,
          //   label: 'Assign salesperson',
          //   selected: selectedIndex == 2,
          //   onTap: () {
          //     if (ModalRoute.of(context)?.settings.name != '/admin/assign-salesperson') {
          //       Navigator.pushReplacementNamed(context, '/admin/assign-salesperson');
          //     }
          //     onItemTapped(2);
          //   },
          // ),
          // _SidebarButton(
          //   icon: Icons.track_changes,
          //   label: 'Job progress',
          //   selected: selectedIndex == 3,
          //   onTap: () {
          //     if (ModalRoute.of(context)?.settings.name != '/admin/job-progress') {
          //       Navigator.pushReplacementNamed(context, '/admin/job-progress');
          //     }
          //     onItemTapped(3);
          //   },
          // ),
          _SidebarButton(
            icon: Icons.track_changes,
            label: 'Jobs',
            selected: selectedIndex == 3,
            onTap: () {
              if (ModalRoute.of(context)?.settings.name != '/admin/jobs') {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/admin/jobs',
                  (route) => false,
                );
              }
              onItemTapped(3);
            },
          ),
          _SidebarButton(
            icon: Icons.calendar_today,
            label: 'Calendar',
            selected: selectedIndex == 4,
            onTap: () {
              if (ModalRoute.of(context)?.settings.name != '/admin/calendar') {
                Navigator.pushReplacementNamed(context, '/admin/calendar');
              }
              onItemTapped(4);
            },
          ),
          _SidebarButton(
            icon: Icons.currency_pound,
            label: 'Reimbursements',
            selected: selectedIndex == 5,
            onTap: () {
              if (ModalRoute.of(context)?.settings.name != '/admin/reimbursements') {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/admin/reimbursements',
                  (route) => false,
                );
              }
              onItemTapped(5);
            },
          ),
          const Spacer(),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

class _SidebarButton extends StatefulWidget {
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
  State<_SidebarButton> createState() => _SidebarButtonState();
}

class _SidebarButtonState extends State<_SidebarButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final bool isSelected = widget.selected;
    final bool isHovering = _hovering;
    Color bgColor;
    if (isSelected) {
      bgColor = Colors.white;
    } else if (isHovering) {
      bgColor = Colors.white.withOpacity(0.08);
    } else {
      bgColor = Colors.transparent;
    }
    Color iconColor = isSelected ? const Color(0xFF101C2C) : Colors.white;
    Color textColor = isSelected ? const Color(0xFF101C2C) : Colors.white;
    FontWeight fontWeight = isSelected ? FontWeight.bold : FontWeight.w600;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.ease,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        child: ListTile(
          leading: Icon(widget.icon, color: iconColor, size: 24),
          title: Text(
            widget.label,
            style: TextStyle(
              color: textColor,
              fontWeight: fontWeight,
              fontSize: 15,
              letterSpacing: 0.2,
            ),
          ),
          dense: true,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          selected: isSelected,
          selectedTileColor: Colors.white,
          hoverColor: Colors.transparent,
          onTap: widget.onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        ),
      ),
    );
  }
}
