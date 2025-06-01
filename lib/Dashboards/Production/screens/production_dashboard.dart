import 'package:flutter/material.dart';
import '../widgets/job_list_card.dart';
import '../widgets/assign_labour_card.dart';
import '../widgets/progress_bar.dart';
import '../widgets/sidebar.dart';
import '../widgets/top_bar.dart';
import '../widgets/worker_stats_row.dart';
import '../providers/worker_provider.dart';
import 'package:provider/provider.dart';

class ProductionDashboard extends StatelessWidget {
  const ProductionDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ensure WorkerProvider fetches latest data when dashboard is opened
    Future.microtask(() => context.read<WorkerProvider>().fetchWorkers());

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4FF),
      body: Row(
        children: [
          // Sidebar
          ProductionSidebar(
            selectedIndex: 0,
            onItemTapped: (index) {
              if (index == 0) {
                // Already on Dashboard
              } else if (index == 1) {
                Navigator.of(context).pushReplacementNamed('/production/assignlabour');
              } else if (index == 2) {
                Navigator.of(context).pushReplacementNamed('/production/joblist');
              } else if (index == 3) {
                Navigator.of(context).pushReplacementNamed('/production/reimbursement');
              }
            },
          ),
          // Main Content
          Expanded(
            child: Column(
              children: [
                ProductionTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [                          const SizedBox(height: 10),
                          const Text('Production', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF232B3E))),
                          const SizedBox(height: 24),
                          const WorkerStatsRow(),
                          const SizedBox(height: 24),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              double cardHeight = 350;
                              if (constraints.maxWidth < 900) cardHeight = 420;
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    flex: 5,
                                    child: SizedBox(
                                      height: cardHeight,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).pushNamed('/production/joblist');
                                        },
                                        child: JobListCard(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  Flexible(
                                    flex: 4,
                                    child: SizedBox(
                                      height: cardHeight,
                                      child: AssignLabourCard(),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
