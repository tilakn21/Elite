import 'package:flutter/material.dart';

class ProductionSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  const ProductionSidebar({Key? key, this.selectedIndex = 0, required this.onItemTapped}) : super(key: key);

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
          // Navigation
          _SidebarButton(
            icon: Icons.dashboard,
            label: 'Dashboard',
            selected: selectedIndex == 0,
            onTap: () => onItemTapped(0),
          ),
          _SidebarButton(
            icon: Icons.list_alt,
            label: 'Job List',
            selected: selectedIndex == 2,
            onTap: () => onItemTapped(2),
          ),
          _SidebarButton(
            icon: Icons.people_alt_outlined,
            label: 'Assign labour',
            selected: selectedIndex == 1,
            onTap: () => onItemTapped(1),
          ),          _SidebarButton(
            icon: Icons.calendar_today,
            label: 'Calendar',
            selected: selectedIndex == 4,
            onTap: () {
              if (ModalRoute.of(context)?.settings.name != '/production/calendar') {
                Navigator.of(context).pushReplacementNamed('/production/calendar');
              }
              onItemTapped(4);
            },
          ),
          _SidebarButton(
            icon: Icons.receipt_long,
            label: 'Reimbursement',
            selected: selectedIndex == 3,
            onTap: () async {
              // Fetch employee id (production id)
              String employeeId = 'prod1001'; // TODO: Replace with authenticated id later
              if (ModalRoute.of(context)?.settings.name != '/production/reimbursement_request') {
                Navigator.of(context).pushReplacementNamed(
                  '/production/reimbursement_request',
                  arguments: {'employeeId': employeeId},
                );
              }
              onItemTapped(3);
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

class _SidebarButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  const _SidebarButton({required this.icon, required this.label, this.selected = false, this.onTap});
  @override
  State<_SidebarButton> createState() => _SidebarButtonState();
}

class _SidebarButtonState extends State<_SidebarButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    if (widget.selected) {
      bgColor = Colors.white;
    } else if (_hovering) {
      bgColor = Colors.white.withOpacity(0.08);
    } else {
      bgColor = Colors.transparent;
    }
    Color iconColor = widget.selected ? const Color(0xFF101C2C) : Colors.white;
    Color textColor = widget.selected ? const Color(0xFF101C2C) : Colors.white;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(widget.icon, color: iconColor, size: 24),
          title: Text(
            widget.label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          dense: true,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          selected: widget.selected,
          selectedTileColor: Colors.white,
          hoverColor: Colors.transparent,
          onTap: widget.onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        ),
      ),
    );
  }
}
