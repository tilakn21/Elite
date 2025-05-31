import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/new_job_request_card.dart';
import '../widgets/sales_allocation_card.dart';
import '../widgets/job_requests_overview_card.dart';
import '../widgets/calendar_card.dart';
import '../widgets/topbar.dart';
import '../models/job_request.dart';
import '../models/salesperson.dart';
import '../providers/job_request_provider.dart';
import '../providers/salesperson_provider.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  static Route<dynamic> route() =>
      MaterialPageRoute(builder: (_) => const DashboardPage());

  @override
  Widget build(BuildContext context) {
    final jobRequestProvider = Provider.of<JobRequestProvider>(context);
    final salespersonProvider = Provider.of<SalespersonProvider>(context);
    final List<JobRequest> jobRequests = jobRequestProvider.jobRequests;
    final List<Salesperson> salesPeople = salespersonProvider.salespersons;
    final bool isLoading = jobRequestProvider.isLoading || salespersonProvider.isLoading;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFF6F3FE),
      drawer: isMobile
          ? Drawer(
              child: Sidebar(
                selectedIndex: 0,
                isDrawer: true,
                onClose: () => Navigator.of(context).pop(),
              ),
            )
          : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMobile) Sidebar(selectedIndex: 0),
          Expanded(
            child: Column(
              children: [
                TopBar(
                  isDashboard: true,
                  showMenu: isMobile,
                  onMenuTap: () => scaffoldKey.currentState?.openDrawer(),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 8),
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
                                                    jobRequests: jobRequests),
                                              ),
                                              const SizedBox(height: 32),
                                              SizedBox(
                                                height: 320,
                                                child: JobRequestsOverviewCard(
                                                    jobRequests: jobRequests),
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
                                                child: SalesAllocationCard(
                                                    salesPeople: salesPeople),
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
                                        NewJobRequestCard(jobRequests: jobRequests),
                                        const SizedBox(height: 32),
                                        JobRequestsOverviewCard(jobRequests: jobRequests),
                                        const SizedBox(height: 32),
                                        SalesAllocationCard(salesPeople: salesPeople),
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

// This should be in your main.dart or router setup, but for reference:
// routes: {
//   '/receptionist/dashboard': (context) => const DashboardPage(),
//   '/receptionist/new-job-request': (context) => const NewJobRequestScreen(),
// }
