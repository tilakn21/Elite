import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/new_job_request_card.dart';
import '../widgets/sales_allocation_card.dart';
import '../widgets/job_requests_overview_card.dart';
import '../widgets/calendar_card.dart';
import '../widgets/topbar.dart'; 
import 'new_job_request_screen.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  static Route<dynamic> route() => MaterialPageRoute(builder: (_) => const DashboardPage());

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    // Compute max width for content area (subtract sidebar and padding)
    final double sidebarWidth = 250;
    final double horizontalPadding = 0; // Top-level padding already handled
    final double maxContentWidth = 1200;
    final double contentWidth = (screenWidth - sidebarWidth - horizontalPadding).clamp(600, maxContentWidth);
    final double cardWidth = (contentWidth - 40) / 2;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FE),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Sidebar(),
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 32),
                // Top bar
                const TopBar(isDashboard: true),
                const SizedBox(height: 8),
                // Responsive, scrollable dashboard content
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: constraints.maxWidth > 900
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Both columns take up equal width
                                Expanded(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 320,
                                        child: NewJobRequestCard(),
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
                                  child: NewJobRequestCard(),
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

// This should be in your main.dart or router setup, but for reference:
// routes: {
//   '/receptionist/dashboard': (context) => const DashboardPage(),
//   '/receptionist/new-job-request': (context) => const NewJobRequestScreen(),
// }
