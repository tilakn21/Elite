import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/new_job_request_card.dart';
import '../widgets/sales_allocation_card.dart';
import '../widgets/job_requests_overview_card.dart';
import '../widgets/calendar_card.dart';
import '../widgets/topbar.dart';
import 'new_job_request_screen.dart';
import '../models/job_request.dart';
import '../models/salesperson.dart';
import '../providers/job_request_provider.dart';
import '../providers/salesperson_provider.dart';
import '../services/receptionist_service.dart';

class DashboardPage extends StatefulWidget {
  final String? receptionistId;
  const DashboardPage({Key? key, this.receptionistId}) : super(key: key);

  static Route<dynamic> route({String? receptionistId}) =>
      MaterialPageRoute(builder: (_) => DashboardPage(receptionistId: receptionistId));

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  String _receptionistName = '';
  String _branchName = '';
  String _receptionistId = ''; // Will be set from widget parameter

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Set receptionistId from widget parameter, or use empty string if null
    _receptionistId = widget.receptionistId ?? '';
    print('[DASHBOARD] Using receptionist ID: $_receptionistId');
    // Refresh job requests and salespersons when screen is opened
    Future.microtask(() {
      Provider.of<JobRequestProvider>(context, listen: false).fetchJobRequests();
      Provider.of<SalespersonProvider>(context, listen: false).fetchSalespersons();
    });
    _fetchReceptionistAndBranch();
  }

  Future<void> _fetchReceptionistAndBranch() async {
    if (_receptionistId.isEmpty) {
      print('[DASHBOARD] Warning: Receptionist ID is empty');
      setState(() {
        _receptionistName = 'Unknown';
        _branchName = 'Unknown';
      });
      return;
    }
    
    final service = ReceptionistService();
    try {
      final details = await service.fetchReceptionistDetails(receptionistId: _receptionistId);
      String name = details?['full_name'] ?? '';
      String branchName = '';
      
      if (details != null && details['branch_id'] != null) {
        branchName = await service.fetchBranchName(int.parse(details['branch_id'].toString())) ?? '';
      }
      
      setState(() {
        _receptionistName = name;
        _branchName = branchName;
      });
      print('[DASHBOARD] Fetched details: name=$_receptionistName, branch=$_branchName');
    } catch (e) {
      print('[DASHBOARD] Error fetching receptionist details: $e');
      setState(() {
        _receptionistName = 'Error';
        _branchName = 'Error';
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Provider.of<JobRequestProvider>(context, listen: false).fetchJobRequests();
      Provider.of<SalespersonProvider>(context, listen: false).fetchSalespersons();
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobRequestProvider = Provider.of<JobRequestProvider>(context);
    final salespersonProvider = Provider.of<SalespersonProvider>(context);
    final List<JobRequest> jobRequests = jobRequestProvider.jobRequests;
    final List<Salesperson> salesPeople = salespersonProvider.salespersons;
    final bool isLoading = jobRequestProvider.isLoading || salespersonProvider.isLoading;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFF6F3FE),
      drawer: isMobile
          ? Drawer(
              child: Sidebar(
                selectedIndex: 0,
                isDrawer: true,
                onClose: () => Navigator.of(context).pop(),
                employeeId: _receptionistId,
              ),
            )
          : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMobile) Sidebar(selectedIndex: 0, employeeId: _receptionistId.isNotEmpty ? _receptionistId : 'unknown'),
          Expanded(
            child: Column(
              children: [
                TopBar(
                  isDashboard: true,
                  showMenu: isMobile,
                  onMenuTap: () => scaffoldKey.currentState?.openDrawer(),
                  receptionistName: _receptionistName.isNotEmpty ? _receptionistName : 'Receptionist',
                  branchName: _branchName.isNotEmpty ? _branchName : 'Branch',
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
