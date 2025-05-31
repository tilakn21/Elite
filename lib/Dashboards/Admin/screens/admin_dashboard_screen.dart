import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/admin_top_bar.dart';
import '../widgets/branch_stats_cards.dart';
import '../widgets/summary_card.dart';
import '../widgets/job_status_table.dart';
import '../widgets/sales_performance_chart.dart';
import '../models/branch.dart'; // Branch is used for currentSelectedBranch type
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';

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
  int selectedBranch = 0; // Index for the selected branch in the Dropdown

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchAdminData().then((_) {
        if (mounted) {
          final provider = Provider.of<AdminProvider>(context, listen: false);
          if (selectedBranch >= provider.branchStats.length && provider.branchStats.isNotEmpty) {
            setState(() {
              selectedBranch = 0;
            });
          } else if (provider.branchStats.isEmpty) {
            setState(() {
              selectedBranch = 0; 
            });
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);

    if (adminProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (adminProvider.errorMessage != null) {
      return Center(child: Text('Error: ${adminProvider.errorMessage}'));
    }

    final currentBranches = adminProvider.branchStats;
    final currentAdminJobs = adminProvider.adminJobs;
    final currentSalesData = adminProvider.salesPerformance;

    if (currentBranches.isEmpty && currentAdminJobs.isEmpty && currentSalesData.isEmpty && !adminProvider.isLoading) {
        return const Center(child: Text('No admin data available.'));
    }
    
    final Branch? currentSelectedBranch = currentBranches.isNotEmpty && selectedBranch < currentBranches.length 
                                          ? currentBranches[selectedBranch] 
                                          : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isNarrow = constraints.maxWidth < 1100;
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: BranchStatsCards(
                      branches: currentBranches,
                      selectedBranch: currentSelectedBranch?.name ?? (currentBranches.isNotEmpty ? currentBranches.first.name : ''),
                      selectedBranchIndex: selectedBranch,
                      onBranchChanged: (String? newValue) {
                        if (newValue != null) {
                          final int idx = currentBranches.indexWhere((b) => b.name == newValue);
                          if (idx != -1) {
                            setState(() {
                              selectedBranch = idx;
                            });
                          }
                        }
                      },
                      onSelect: (int index) {
                        setState(() {
                          selectedBranch = index;
                        });
                      },
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
                        value: currentAdminJobs.where((j) => (j.status.toLowerCase() == 'pending' || j.status.toLowerCase() == 'approved')).length,
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
                        value: currentAdminJobs.where((j) => j.status.toLowerCase() == 'in progress').length,
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
                        value: currentAdminJobs.where((j) => j.status.toLowerCase() == 'completed').length,
                        color: Colors.green,
                        icon: Icons.check_circle,
                        highlight: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
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
              if (currentAdminJobs.isEmpty && currentSalesData.isEmpty && !adminProvider.isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text("No job or sales data available.")))
              else
                isNarrow
                    ? Column(
                        children: [
                          if (currentAdminJobs.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: JobStatusTable(jobs: currentAdminJobs),
                            )
                          else if (!adminProvider.isLoading)
                             const Center(child: Padding(padding: EdgeInsets.all(8.0), child: Text("No jobs to display."))),
                          if (currentSalesData.isNotEmpty)
                            SalesPerformanceChart(data: currentSalesData.map((e) => FlSpot(e.x, e.y)).toList())
                          else if (!adminProvider.isLoading)
                             const Center(child: Padding(padding: EdgeInsets.all(8.0), child: Text("No sales data to display."))),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: currentAdminJobs.isNotEmpty 
                                     ? JobStatusTable(jobs: currentAdminJobs)
                                     : (!adminProvider.isLoading ? const Center(child: Padding(padding: EdgeInsets.all(8.0), child: Text("No jobs to display."))) : Container()),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: currentSalesData.isNotEmpty
                                   ? SalesPerformanceChart(data: currentSalesData.map((e) => FlSpot(e.x, e.y)).toList())
                                   : (!adminProvider.isLoading ? const Center(child: Padding(padding: EdgeInsets.all(8.0), child: Text("No sales data to display."))) : Container()),
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
