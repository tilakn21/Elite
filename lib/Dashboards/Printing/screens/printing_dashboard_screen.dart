import 'package:flutter/material.dart';
import '../widgets/printing_sidebar.dart';
import '../widgets/printing_top_bar.dart';
import '../widgets/printing_job_table.dart';

class PrintingDashboardScreen extends StatelessWidget {
  const PrintingDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FF),
      body: Row(
        children: [
          // Sidebar
          const PrintingSidebar(selectedIndex: 0),
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Bar
                const PrintingTopBar(),
                // Page Title & Tabs
                Padding(
                  padding: const EdgeInsets.only(left: 40, top: 32, right: 40, bottom: 0),
                  child: Row(
                    children: const [
                      Text('Print jobs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Color(0xFF232B3E))),
                    ],
                  ),
                ),
                // Tabs
                Padding(
                  padding: const EdgeInsets.only(left: 40, top: 12, right: 40, bottom: 0),
                  child: Row(
                    children: [
                      _DashboardTab(label: 'Pending', selected: true),
                      const SizedBox(width: 16),
                      _DashboardTab(label: 'Printing', selected: false),
                      const SizedBox(width: 16),
                      _DashboardTab(label: 'Completed', selected: false),
                    ],
                  ),
                ),
                // Section Title
                Padding(
                  padding: const EdgeInsets.only(left: 40, top: 32, right: 40, bottom: 0),
                  child: Row(
                    children: const [
                      Text('Approved designs ready for print', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Color(0xFF888FA6))),
                    ],
                  ),
                ),
                // Job Table
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 40, right: 40, top: 16, bottom: 0),
                    child: PrintingJobTable(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  final String label;
  final bool selected;
  const _DashboardTab({required this.label, required this.selected, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF232B3E) : const Color(0xFFEDECF7),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : const Color(0xFF232B3E),
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }
}
