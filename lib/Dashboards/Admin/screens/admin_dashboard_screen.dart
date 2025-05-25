import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/admin_top_bar.dart';
import '../widgets/branch_stats_cards.dart';
import '../widgets/summary_card.dart';
import '../widgets/job_status_table.dart';
import '../widgets/sales_performance_chart.dart';
import '../providers/admin_dashboard_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  void _onSidebarItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminDashboardProvider(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F6FF),
        body: Row(
          children: [
            AdminSidebar(selectedIndex: _selectedIndex, onItemTapped: _onSidebarItemTapped),
            Expanded(
              child: Column(
                children: const [
                  AdminTopBar(),
                  Expanded(
                    child: _AdminDashboardContent(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminDashboardContent extends StatelessWidget {
  const _AdminDashboardContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminDashboardProvider>(
      builder: (context, provider, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 1100;
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Branch cards row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 18),
                        child: DropdownButton<String>(
                          value: provider.selectedBranch.name,
                          items: provider.branches.map((b) => DropdownMenuItem<String>(
                            value: b.name,
                            child: Text(b.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          )).toList(),
                          onChanged: (val) {
                            final idx = provider.branches.indexWhere((b) => b.name == val);
                            if (idx != -1) provider.setSelectedBranch(idx);
                          },
                          style: const TextStyle(fontSize: 15, color: Color(0xFF101C2C)),
                          underline: Container(),
                          icon: const Icon(Icons.keyboard_arrow_down),
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      SizedBox(
                        height: 92,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(provider.branches.length, (index) =>
                              Container(
                                margin: EdgeInsets.only(right: 12),
                                width: 180,
                                child: BranchStatsCard(
                                  branch: provider.branches[index].toJson(),
                                  selected: provider.selectedBranchIndex == index,
                                  onTap: () => provider.setSelectedBranch(index),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Active jobs',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: SummaryCard(
                            label: 'Total pending',
                            value: 34,
                            color: Colors.orange,
                            icon: Icons.access_time,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: SummaryCard(
                            label: 'In process',
                            value: 28,
                            color: Colors.blue,
                            icon: Icons.autorenew,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: SummaryCard(
                            label: 'Completed',
                            value: 137,
                            color: Colors.green,
                            icon: Icons.check_circle,
                            highlight: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Job status section with divider
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Job status',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          height: 2,
                          width: 44,
                          decoration: BoxDecoration(
                            color: Color(0xFF1673FF).withOpacity(0.22),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  isNarrow
                      ? Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: JobStatusTable(jobs: provider.jobs),
                            ),
                            SalesPerformanceChart(data: provider.salesData.data),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: JobStatusTable(jobs: provider.jobs),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: SalesPerformanceChart(data: provider.salesData.data),
                            ),
                          ],
                        ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

