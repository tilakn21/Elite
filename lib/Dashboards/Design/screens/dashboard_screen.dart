import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../providers/chat_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/job_list_card.dart';
import '../widgets/job_details_card.dart';
import '../widgets/active_chats_card.dart';
import '../widgets/calendar_card.dart';
import '../widgets/sidebar.dart';
import 'job_list_screen.dart';
import 'active_chats_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with AutomaticKeepAliveClientMixin {
  int _selectedIndex = 0;

  void _onSidebarTap(int index) {
    setState(() {
      _selectedIndex = index;
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
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DesignSidebar(
              selectedIndex: _selectedIndex, onItemTapped: _onSidebarTap),
          Expanded(
            child: _buildSelectedView(_selectedIndex, context, jobProvider,
                chatProvider, isDesktop, isTablet, isMobile),
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
        return const JobListScreen();
      case 2: // Upload Design Draft (Replaced with Job List)
        return const JobListScreen();
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

              // First row - Job List and Job Details
              if (isMobile) ...[
                // Mobile layout - Stack widgets vertically
                SizedBox(
                  width: constraints.maxWidth,
                  child: JobListCard(jobs: jobProvider.jobs),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: constraints.maxWidth,
                  child: JobDetailsCard(
                    job: jobProvider.jobs.isNotEmpty
                        ? jobProvider.jobs.first
                        : null,
                  ),
                ),
              ] else ...[
                // Tablet/Desktop layout - Side by side
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left column - Job List
                    Expanded(
                      flex: isDesktop ? 1 : 1,
                      child: JobListCard(jobs: jobProvider.jobs),
                    ),
                    const SizedBox(width: 16),
                    // Right column - Job Details
                    Expanded(
                      flex: isDesktop ? 1 : 1,
                      child: JobDetailsCard(
                        job: jobProvider.jobs.isNotEmpty
                            ? jobProvider.jobs.first
                            : null,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 24),

              // Second row - Active Chats and Calendar
              if (isMobile) ...[
                // Mobile layout - Stack widgets vertically
                SizedBox(
                  width: constraints.maxWidth,
                  child: ActiveChatsCard(chats: chatProvider.activeChats),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: constraints.maxWidth,
                  child: const CalendarCard(),
                ),
              ] else ...[
                // Tablet/Desktop layout - Side by side
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left column - Active Chats
                    Expanded(
                      flex: isDesktop ? 1 : 1,
                      child: ActiveChatsCard(chats: chatProvider.activeChats),
                    ),
                    const SizedBox(width: 16),
                    // Right column - Calendar
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
