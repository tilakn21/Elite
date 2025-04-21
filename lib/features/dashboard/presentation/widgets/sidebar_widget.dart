import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/dashboard_providers.dart';

class SidebarWidget extends ConsumerWidget {
  const SidebarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(dashboardIndexProvider);

    return Container(
      width: 250,
      color: Colors.grey[
          900], // TODO: Replace with your actual dark theme color (e.g., AppTheme.darkBackground)
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Image.asset(
              'assets/images/logo_placeholder.png', // Replace with your actual logo asset
              height: 40,
            ),
          ),
          const SizedBox(height: 32),
          _buildMenuItem(
            context: context,
            ref: ref,
            index: 0,
            icon: Icons.dashboard_outlined,
            text: 'Dashboard',
            isSelected: selectedIndex == 0,
          ),
          _buildMenuItem(
            context: context,
            ref: ref,
            index: 2, // Matching JobsDashboard index
            icon: Icons.work_outline,
            text: 'Job Details',
            isSelected: selectedIndex == 2,
          ),
          _buildMenuItem(
            context: context,
            ref: ref,
            index: 6, // Placeholder index for Upload
            icon: Icons.cloud_upload_outlined,
            text: 'Upload Design Draft',
            isSelected: selectedIndex == 6,
          ),
          _buildMenuItem(
            context: context,
            ref: ref,
            index: 7, // Placeholder index for Chat
            icon: Icons.chat_bubble_outline,
            text: 'Chat',
            isSelected: selectedIndex == 7,
          ),
          // Add other menu items based on your design...
          // Remember to update indices and icons
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required WidgetRef ref,
    required int index,
    required IconData icon,
    required String text,
    required bool isSelected,
  }) {
    final color = isSelected ? AppTheme.white : Colors.grey[400];
    final bgColor =
        isSelected ? AppTheme.primaryBlue.withOpacity(0.2) : Colors.transparent;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ref.read(dashboardIndexProvider.notifier).state = index;
          },
          borderRadius: BorderRadius.circular(8.0),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 16),
                Text(
                  text,
                  style: TextStyle(
                    color: color,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
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
