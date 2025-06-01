import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final sidebarWidth = isMobile ? double.infinity : 220.0;
        return Container(
          width: sidebarWidth,
          height: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF0D223F),
            borderRadius: isMobile
                ? null
                : const BorderRadius.only(
                    topRight: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
            boxShadow: [
              if (!isMobile)
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 16,
                  offset: const Offset(2, 0),
                ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16.0 : 24.0,
                vertical: isMobile ? 16.0 : 32.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo or Avatar
                  Padding(
                    padding: const EdgeInsets.only(bottom: 28),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/elite_logo.png',
                          height: isMobile ? 38 : 48,
                          fit: BoxFit.contain,
                        ),
                        if (!isMobile)
                          const SizedBox(width: 14),
                        if (!isMobile)
                          const Text(
                            'Elite',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              letterSpacing: 1.2,
                            ),
                          ),
                      ],
                    ),
                  ),
                  _SidebarButton(
                    icon: Icons.apps,
                    label: 'Home',
                    selected: selectedRoute == 'home',
                    onTap: () => onItemSelected('home'),
                    isMobile: isMobile,
                  ),
                  const SizedBox(height: 20),
                  _SidebarButton(
                    icon: Icons.person,
                    label: 'Profile',
                    selected: selectedRoute == 'profile',
                    onTap: () => onItemSelected('profile'),
                    isMobile: isMobile,
                  ),
                  const SizedBox(height: 20),
                  _SidebarButton(
                    icon: Icons.attach_money,
                    label: 'Reimbursement',
                    selected: selectedRoute == 'reimbursement',
                    onTap: () => onItemSelected('reimbursement'),
                    isMobile: isMobile,
                  ),

                  const Spacer(),
                  Divider(color: Colors.white.withOpacity(0.15)),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white, size: 28),
                      onPressed: () {},
                      tooltip: 'Settings',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // Log out using Supabase and navigate to login
                        await Supabase.instance.client.auth.signOut();
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                        } else {
                          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                        }
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
            ),
          ),
        );
      },
    );
  }
}

class _SidebarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isMobile;

  const _SidebarButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.isMobile = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        splashColor: selected ? const Color(0xFF5A6CEA).withOpacity(0.15) : Colors.white24,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 10 : 14,
            vertical: isMobile ? 10 : 14,
          ),
          decoration: selected
              ? BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                )
              : null,
          child: Row(
            children: [
              Icon(
                icon,
                color: selected ? const Color(0xFF5A6CEA) : Colors.white,
                size: isMobile ? 22 : 24,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: selected ? const Color(0xFF5A6CEA) : Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: isMobile ? 15 : 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
