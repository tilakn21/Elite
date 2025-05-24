import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/new_job_request_card.dart';
import '../widgets/sales_allocation_card.dart';
import '../widgets/job_requests_overview_card.dart';
import '../widgets/calendar_card.dart';
import '../widgets/topbar.dart';
import 'new_job_request_screen.dart';
import 'assign_salesperson_screen.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  Map<String, dynamic>? _selectedJob;

  List<Widget> _pages() => [
        _DashboardContent(
          onViewJobDetails: (job) {
            setState(() {
              _selectedJob = job;
              _selectedIndex = 1;
            });
          },
        ),
        _TabPage(
          tabIndex: 1,
          child: NewJobRequestScreen(
            showAppBars: false,
            jobDetails: _selectedJob,
          ),
          onBack: () {
            setState(() {
              _selectedJob = null;
              _selectedIndex = 0;
            });
          },
        ),
        _TabPage(
          tabIndex: 2,
          child: AssignSalespersonScreen(showAppBars: false),
          onBack: () {
            setState(() => _selectedIndex = 0);
          },
        ),
      ];

  void _onTabChanged(int index) {
    setState(() {
      if (index != 1) _selectedJob = null;
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = _pages();
    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FE),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Sidebar(selectedIndex: _selectedIndex, onTabChanged: _onTabChanged),
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 32),
                const TopBar(),
                const SizedBox(height: 8),
                Expanded(
                  child: pages[_selectedIndex],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final Function(Map<String, dynamic>)? onViewJobDetails;

  const _DashboardContent({
    Key? key,
    this.onViewJobDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void onNewRequest() {
      final dashboardState = context.findAncestorStateOfType<_DashboardPageState>();
      if (dashboardState != null) {
        dashboardState._onTabChanged(1);
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: constraints.maxWidth > 900
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 320,
                            child: NewJobRequestCard(
                              onNewRequest: onNewRequest,
                              onViewJobDetails: onViewJobDetails,
                            ),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            height: 320,
                            child: JobRequestsOverviewCard(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 40),
                    Expanded(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 320,
                            child: SalesAllocationCard(),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            height: 320,
                            child: CalendarCard(),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    SizedBox(
                      height: 320,
                      child: NewJobRequestCard(
                        onNewRequest: onNewRequest,
                        onViewJobDetails: onViewJobDetails,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 320,
                      child: SalesAllocationCard(),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 320,
                      child: JobRequestsOverviewCard(),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 320,
                      child: CalendarCard(),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

// Add a wrapper for tab pages with a back button
class _TabPage extends StatelessWidget {
  final Widget child;
  final int tabIndex;
  final VoidCallback? onBack;
  const _TabPage({required this.child, required this.tabIndex, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, bottom: 8),
            child: ElevatedButton.icon(
              onPressed: onBack ?? () {
                Navigator.of(context).maybePop();
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF101C2C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

// This should be in your main.dart or router setup, but for reference:
// routes: {
//   '/receptionist/dashboard': (context) => const DashboardPage(),
//   '/receptionist/new-job-request': (context) => const NewJobRequestScreen(),
// }
