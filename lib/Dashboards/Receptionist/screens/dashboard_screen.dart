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
import './new_job_request_screen.dart'; // Import for JobRequestContent

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  static Route<dynamic> route() =>
      MaterialPageRoute(builder: (_) => const DashboardPage());

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final jobRequestProvider = Provider.of<JobRequestProvider>(context);
    final salespersonProvider = Provider.of<SalespersonProvider>(context);
    
    final bool isLoading = jobRequestProvider.isLoading || salespersonProvider.isLoading;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    // Define the pages for IndexedStack
    final List<Widget> _pages = <Widget>[
      _DashboardView(
        jobRequests: jobRequestProvider.jobRequests,
        salesPeople: salespersonProvider.salespersons,
        isLoading: isLoading,
      ),
      JobRequestContent(
        isMobile: isMobile,
        formWidth: isMobile ? double.infinity : (screenWidth < 900 ? 500 : 800),
      ),
    ];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF6F3FE),
      drawer: isMobile
          ? Drawer(
              child: Sidebar(
                selectedIndex: _selectedIndex,
                isDrawer: true,
                onClose: () => Navigator.of(context).pop(),
                onItemSelected: _onItemTapped,
              ),
            )
          : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMobile) Sidebar(selectedIndex: _selectedIndex, onItemSelected: _onItemTapped),
          Expanded(
            child: Column(
              children: [
                TopBar(
                  isDashboard: true,
                  showMenu: isMobile,
                  onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: _pages,
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

// New widget to hold the original dashboard content
class _DashboardView extends StatelessWidget {
  final List<JobRequest> jobRequests;
  final List<Salesperson> salesPeople;
  final bool isLoading;

  const _DashboardView({
    Key? key,
    required this.jobRequests,
    required this.salesPeople,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : LayoutBuilder(
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
                                  child: NewJobRequestCard(jobRequests: jobRequests),
                                ),
                                const SizedBox(height: 32),
                                SizedBox(
                                  height: 320,
                                  child: JobRequestsOverviewCard(jobRequests: jobRequests),
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
                                  child: SalesAllocationCard(salesPeople: salesPeople),
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
          );
  }
}
