import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/new_job_request_card.dart';
import '../widgets/sales_allocation_card.dart';
import '../widgets/job_requests_overview_card.dart';
import '../widgets/calendar_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

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
                // Top bar with search and user controls
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Overview',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 24,
                          color: Color(0xFF1B2330),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 320,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Icon(Icons.search, color: Color(0xFF8A8D9F)),
                                ),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Search data for this page',
                                      hintStyle: TextStyle(color: Color(0xFF8A8D9F)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          IconButton(
                            icon: const Icon(Icons.bar_chart_rounded, color: Color(0xFF8A8D9F), size: 26),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.notifications_none, color: Color(0xFF8A8D9F), size: 26),
                            onPressed: () {},
                          ),
                          const SizedBox(width: 24),
                          CircleAvatar(
                            backgroundColor: Color(0xFFEDF0F9),
                            radius: 20,
                            child: Text('J', style: TextStyle(color: Color(0xFF1B2330), fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('John Doe', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1B2330))),
                              Text('Admin', style: TextStyle(fontSize: 12, color: Color(0xFF8A8D9F))),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
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
                                Expanded(
                                  child: Column(
                                    children: [
                                      NewJobRequestCard(),
                                      const SizedBox(height: 32),
                                      JobRequestsOverviewCard(),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 40),
                                Expanded(
                                  child: Column(
                                    children: [
                                      SalesAllocationCard(),
                                      const SizedBox(height: 32),
                                      CalendarCard(),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                NewJobRequestCard(),
                                const SizedBox(height: 32),
                                SalesAllocationCard(),
                                const SizedBox(height: 32),
                                JobRequestsOverviewCard(),
                                const SizedBox(height: 32),
                                CalendarCard(),
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
