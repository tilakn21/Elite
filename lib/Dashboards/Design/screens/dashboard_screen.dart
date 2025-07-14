import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../providers/chat_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/job_list_card.dart';
import '../widgets/calendar_card.dart';
import '../widgets/sidebar.dart';
import '../widgets/design_top_bar.dart';
import 'job_list_screen.dart';
import 'active_chats_screen.dart';
import '../services/design_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with AutomaticKeepAliveClientMixin {
  int _selectedIndex = 0;
  String? _designerId;

  void _onSidebarTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchDesignerId();
  }

  Future<void> _fetchDesignerId() async {
    final user = await DesignService().getCurrentUser();
    setState(() {
      _designerId = user?.id;
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final jobProvider = Provider.of<JobProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1100;
    final isTablet = screenWidth >= 600 && screenWidth < 1100;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          const DesignTopBar(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DesignSidebar(
                  selectedIndex: _selectedIndex,
                  onItemTapped: _onSidebarTap,
                  employeeId: _designerId,
                ),
                Expanded(
                  child: _buildSelectedView(_selectedIndex, context, jobProvider,
                      chatProvider, isDesktop, isTablet, isMobile),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedView(
      int index,
      BuildContext context,
      JobProvider jobProvider,
      ChatProvider chatProvider,
      bool isDesktop,
      bool isTablet,
      bool isMobile) {
    switch (index) {
      case 0: // Dashboard Overview
        return _buildOverviewDashboard(
            context, jobProvider, chatProvider, isDesktop, isTablet, isMobile);
      case 1: // Job Details
        return const JobListScreen(showNavigation: false);
      case 2: // Upload Design Draft (Replaced with Job List)
        return const JobListScreen(showNavigation: false);
      case 3: // Chat
        return const ActiveChatsScreen();
      default:
        return _buildOverviewDashboard(
            context, jobProvider, chatProvider, isDesktop, isTablet, isMobile);
    }
  }

  Widget _buildOverviewDashboard(BuildContext context, JobProvider jobProvider,
      ChatProvider chatProvider, bool isDesktop, bool isTablet, bool isMobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Overview',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 24),

              // First row - Job List only (remove JobDetailsCard and Upload Draft Design)
              SizedBox(
                width: constraints.maxWidth,
                child: JobListCard(jobs: jobProvider.jobs),
              ),

              const SizedBox(height: 24),

              // Second row - Calendar only (Active Chats card removed)
              if (isMobile) ...[
                SizedBox(
                  width: constraints.maxWidth,
                  child: const CalendarCard(),
                ),
              ] else ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Only Calendar
                    Expanded(
                      flex: isDesktop ? 1 : 1,
                      child: const CalendarCard(),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
