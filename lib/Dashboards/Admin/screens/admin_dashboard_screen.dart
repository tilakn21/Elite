import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/admin_top_bar.dart';
import '../widgets/branch_stats_cards.dart';
import '../widgets/summary_card.dart';
import '../widgets/job_status_table.dart';
import '../widgets/sales_performance_chart.dart';
import '../models/branch.dart';
import '../models/admin_job.dart';
import '../models/sales_data.dart';

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
    // TODO: Implement navigation or screen switching logic for other tabs
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FF),
      body: Row(
        children: [
          AdminSidebar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onSidebarItemTapped),
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
    );
  }
}

class _AdminDashboardContent extends StatefulWidget {
  const _AdminDashboardContent({Key? key}) : super(key: key);

  @override
  State<_AdminDashboardContent> createState() => _AdminDashboardContentState();
}

class _AdminDashboardContentState extends State<_AdminDashboardContent> {
  int selectedBranch = 0;

  final List<Branch> branches = [
    Branch(name: 'Branch A', completed: 281, revenue: '\u0000250,000', delays: 2),
    Branch(name: 'Branch B', completed: 281, revenue: '\u0000250,000', delays: 4),
    Branch(name: 'Branch C', completed: 281, revenue: '\u0000250,000', delays: 3),
  ];

  final List<AdminJob> jobs = List.generate(
      5,
      (i) => AdminJob(
            no: '#1001',
            title: i % 2 == 0 ? 'Office renovation' : 'Window installation',
            client: 'Brooklyn Simmons',
            date: '22/04/24',
            status: 'Approved',
          ));

  final List<SalesData> salesData = [
    SalesData(0, 200),
    SalesData(1, 350),
    SalesData(2, 400),
    SalesData(3, 500),
    SalesData(4, 300),
    SalesData(5, 600),
    SalesData(6, 450),
    SalesData(7, 500),
    SalesData(8, 600),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isNarrow = constraints.maxWidth < 1100;
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
                      value: branches[selectedBranch].name,
                      items: branches
                          .map((b) => DropdownMenuItem<String>(
                                value: b.name,
                                child: Text(b.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                              ))
                          .toList(),
                      onChanged: (val) {
                        final int idx =
                            branches.indexWhere((b) => b.name == val);
                        if (idx != -1) setState(() => selectedBranch = idx);
                      },
                      style: const TextStyle(
                          fontSize: 15, color: Color(0xFF101C2C)),
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
                        children: List.generate(
                          branches.length,
                          (index) => Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 180,
                            child: BranchStatsCard(
                              branch: branches[index],
                              selected: selectedBranch == index,
                              onTap: () =>
                                  setState(() => selectedBranch = index),
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
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      height: 2,
                      width: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1673FF).withOpacity(0.22),
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
                          child: JobStatusTable(jobs: jobs),
                        ),
                        // When passing sales data to SalesPerformanceChart, convert SalesData to FlSpot:
                        SalesPerformanceChart(data: salesData.map((e) => FlSpot(e.x, e.y)).toList()),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: JobStatusTable(jobs: jobs),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: SalesPerformanceChart(data: salesData.map((e) => FlSpot(e.x, e.y)).toList()),
                        ),
                      ],
                    ),
            ],
          ),
        );
      },
    );
  }
}
