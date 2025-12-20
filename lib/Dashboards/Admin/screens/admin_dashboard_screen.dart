import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/admin_top_bar.dart';
import '../widgets/branch_stats_cards.dart';
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
    final isMobile = MediaQuery.of(context).size.width < 800;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      drawer: isMobile
          ? Drawer(
              child: SafeArea(
                child: AdminSidebar(
                  selectedIndex: _selectedIndex,
                  onItemTapped: (index) {
                    _onSidebarItemTapped(index);
                    Navigator.of(context).pop();
                  },
                ),
              ),
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            AdminSidebar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onSidebarItemTapped,
            ),
          Expanded(
            child: Column(
              children: [
                // Responsive Top Bar
                Builder(
                  builder: (context) => AdminTopBar(
                    showHamburger: isMobile,
                    onHamburgerTap: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                const Expanded(
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
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF)],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
                strokeWidth: 3,
              ),
              SizedBox(height: 16),
              Text(
                'Loading Dashboard...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (adminProvider.errorMessage != null) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF)],
          ),
        ),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Color(0xFFEF4444),
                ),
                const SizedBox(height: 16),
                Text(
                  'Error Loading Dashboard',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  adminProvider.errorMessage!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentBranches = adminProvider.branchStats;
    final currentAdminJobs = adminProvider.adminJobs;
    final currentSalesData = adminProvider.salesPerformance;    if (currentBranches.isEmpty && currentAdminJobs.isEmpty && currentSalesData.isEmpty && !adminProvider.isLoading) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF)],
          ),
        ),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.dashboard_outlined,
                    size: 48,
                    color: Color(0xFF4F46E5),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'No Data Available',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'There is no admin data to display at the moment.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    final Branch? currentSelectedBranch = currentBranches.isNotEmpty && selectedBranch < currentBranches.length 
                                          ? currentBranches[selectedBranch] 
                                          : null;    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isNarrow = constraints.maxWidth < 1100;
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF)],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings,
                          size: 28,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Admin Dashboard',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Monitor and manage your business operations',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Branch Statistics Section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.business,
                              size: 20,
                              color: Color(0xFF10B981),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Branch Performance',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      BranchStatsCards(
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
                    ],
                  ),
                ),                const SizedBox(height: 32),
                
                // Business Analytics Section
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFAFBFC), Color(0xFFF1F5F9)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE1E7EF), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0EA5E9).withOpacity(0.35),
                                  blurRadius: 15,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.insights_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 18),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Business Analytics',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                    color: Color(0xFF0F172A),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Real-time job status and sales performance insights',
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      if (adminProvider.isLoading)
                        Container(
                          height: 320,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0EA5E9)),
                                    strokeWidth: 3,
                                  ),
                                ),
                                SizedBox(height: 20),
                                Text(
                                  'Loading analytics data...',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (currentAdminJobs.isEmpty && currentSalesData.isEmpty)
                        Container(
                          height: 240,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        const Color(0xFFF1F5F9),
                                        const Color(0xFFE2E8F0).withOpacity(0.7),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.insights_rounded,
                                    size: 36,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'No Analytics Data Available',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Job status and sales data will appear here once available',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: const Color(0xFF64748B),
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else                        isNarrow
                            ? Column(
                                children: [
                                  if (currentAdminJobs.isNotEmpty)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 28),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.06),
                                            blurRadius: 20,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: JobStatusTable(jobs: currentAdminJobs),
                                    )
                                  else if (!adminProvider.isLoading)
                                    Container(
                                      padding: const EdgeInsets.all(24),
                                      margin: const EdgeInsets.only(bottom: 28),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: const Color(0xFFE2E8F0)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.04),
                                            blurRadius: 15,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: const Center(
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.table_chart_outlined,
                                              size: 32,
                                              color: Color(0xFF94A3B8),
                                            ),
                                            SizedBox(height: 12),
                                            Text(
                                              "No job data to display",
                                              style: TextStyle(
                                                color: Color(0xFF64748B),
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  if (currentSalesData.isNotEmpty)
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.08),
                                            blurRadius: 25,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: SalesPerformanceChart(
                                        data: currentSalesData.map((e) => FlSpot(e.x, e.y)).toList(),
                                        maxY: adminProvider.salesChartMaxY,
                                      ),
                                    )
                                  else if (!adminProvider.isLoading)
                                    Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: const Color(0xFFE2E8F0)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.04),
                                            blurRadius: 15,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: const Center(
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.trending_up_rounded,
                                              size: 32,
                                              color: Color(0xFF94A3B8),
                                            ),
                                            SizedBox(height: 12),
                                            Text(
                                              "No sales data to display",
                                              style: TextStyle(
                                                color: Color(0xFF64748B),
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 20),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.06),
                                            blurRadius: 20,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: currentAdminJobs.isNotEmpty 
                                             ? JobStatusTable(jobs: currentAdminJobs)
                                             : (!adminProvider.isLoading ? 
                                                 Container(
                                                   padding: const EdgeInsets.all(24),
                                                   decoration: BoxDecoration(
                                                     color: Colors.white,
                                                     borderRadius: BorderRadius.circular(20),
                                                     border: Border.all(color: const Color(0xFFE2E8F0)),
                                                   ),
                                                   child: const Center(
                                                     child: Column(
                                                       mainAxisAlignment: MainAxisAlignment.center,
                                                       children: [
                                                         Icon(
                                                           Icons.table_chart_outlined,
                                                           size: 36,
                                                           color: Color(0xFF94A3B8),
                                                         ),
                                                         SizedBox(height: 16),
                                                         Text(
                                                           "No job data to display",
                                                           style: TextStyle(
                                                             color: Color(0xFF64748B),
                                                             fontSize: 16,
                                                             fontWeight: FontWeight.w500,
                                                           ),
                                                         ),
                                                       ],
                                                     ),
                                                   ),
                                                 ) : Container()),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.08),
                                            blurRadius: 25,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: currentSalesData.isNotEmpty
                                             ? SalesPerformanceChart(
                                                 data: currentSalesData.map((e) => FlSpot(e.x, e.y)).toList(),
                                                 maxY: adminProvider.salesChartMaxY,
                                               )
                                             : (!adminProvider.isLoading ? 
                                                 Container(
                                                   padding: const EdgeInsets.all(24),
                                                   decoration: BoxDecoration(
                                                     color: Colors.white,
                                                     borderRadius: BorderRadius.circular(20),
                                                     border: Border.all(color: const Color(0xFFE2E8F0)),
                                                   ),
                                                   child: const Center(
                                                     child: Column(
                                                       mainAxisAlignment: MainAxisAlignment.center,
                                                       children: [
                                                         Icon(
                                                           Icons.trending_up_rounded,
                                                           size: 36,
                                                           color: Color(0xFF94A3B8),
                                                         ),
                                                         SizedBox(height: 16),
                                                         Text(
                                                           "No sales data to display",
                                                           style: TextStyle(
                                                             color: Color(0xFF64748B),
                                                             fontSize: 16,
                                                             fontWeight: FontWeight.w500,
                                                           ),
                                                         ),
                                                       ],
                                                     ),
                                                   ),
                                                 ) : Container()),
                                    ),
                                  ),
                                ],
                              ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
