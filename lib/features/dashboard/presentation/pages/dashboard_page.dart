import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../models/user_model.dart';
import '../../../../models/user_role.dart';
import '../providers/dashboard_providers.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final selectedIndex = ref.watch(dashboardIndexProvider);

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1200;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    final isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${currentUser.fullName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Show notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Show profile
            },
          ),
        ],
      ),
      body: Row(
        children: [
          if (isDesktop || isTablet)
            NavigationRail(
              extended: isDesktop,
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) {
                ref.read(dashboardIndexProvider.notifier).state = index;
              },
              labelType: isDesktop
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.selected,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.calendar_today),
                  label: Text('Appointments'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.work),
                  label: Text('Jobs'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people),
                  label: Text('Employees'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.shopping_cart),
                  label: Text('Orders'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.analytics),
                  label: Text('Reports'),
                ),
              ],
            ),
          if (isDesktop || isTablet)
            const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _buildContent(selectedIndex),
          ),
        ],
      ),
      bottomNavigationBar: isMobile
          ? NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) {
                ref.read(dashboardIndexProvider.notifier).state = index;
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_today),
                  label: 'Appointments',
                ),
                NavigationDestination(
                  icon: Icon(Icons.work),
                  label: 'Jobs',
                ),
                NavigationDestination(
                  icon: Icon(Icons.people),
                  label: 'Employees',
                ),
                NavigationDestination(
                  icon: Icon(Icons.shopping_cart),
                  label: 'Orders',
                ),
                NavigationDestination(
                  icon: Icon(Icons.analytics),
                  label: 'Reports',
                ),
              ],
            )
          : null,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new item based on selected tab
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent(int index) {
    switch (index) {
      case 0:
        return const AdminDashboard();
      case 1:
        return const AppointmentsDashboard();
      case 2:
        return const JobsDashboard();
      case 3:
        return const EmployeesDashboard();
      case 4:
        return const OrdersDashboard();
      case 5:
        return const ReportsDashboard();
      default:
        return const Center(child: Text('Select a section'));
    }
  }
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1200;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    final isMobile = screenWidth < 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overview',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Add new item
                },
                icon: const Icon(Icons.add),
                label: const Text('Add New'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: AppTheme.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = isDesktop
                  ? (constraints.maxWidth - 48) / 4
                  : isTablet
                      ? (constraints.maxWidth - 32) / 2
                      : constraints.maxWidth;
              return Wrap(
                spacing: isMobile ? 0 : 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: isMobile ? double.infinity : cardWidth,
                    child: _buildStatCard(
                      context,
                      'Total Jobs',
                      '24',
                      Icons.work,
                      AppTheme.primaryBlue,
                    ),
                  ),
                  SizedBox(
                    width: isMobile ? double.infinity : cardWidth,
                    child: _buildStatCard(
                      context,
                      'Active Orders',
                      '12',
                      Icons.shopping_cart,
                      AppTheme.primaryPink,
                    ),
                  ),
                  SizedBox(
                    width: isMobile ? double.infinity : cardWidth,
                    child: _buildStatCard(
                      context,
                      'Today\'s Appointments',
                      '5',
                      Icons.calendar_today,
                      AppTheme.primaryBlue,
                    ),
                  ),
                  SizedBox(
                    width: isMobile ? double.infinity : cardWidth,
                    child: _buildStatCard(
                      context,
                      'Pending Tasks',
                      '8',
                      Icons.task,
                      AppTheme.primaryPink,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: () {
                  // View all activities
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildActivityList(),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityList() {
    final activities = [
      {'title': 'New order received', 'time': '2 hours ago'},
      {'title': 'Design approved', 'time': '4 hours ago'},
      {'title': 'Production started', 'time': '6 hours ago'},
      {'title': 'Delivery scheduled', 'time': '1 day ago'},
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryBlue,
              child: Icon(
                Icons.notifications,
                color: AppTheme.white,
                size: 20,
              ),
            ),
            title: Text(
              activity['title']!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              activity['time']!,
              style: TextStyle(color: Colors.grey[600]),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ),
        );
      },
    );
  }
}

class AppointmentsDashboard extends StatelessWidget {
  const AppointmentsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Appointments',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Add new appointment
                },
                icon: const Icon(Icons.add),
                label: const Text('New Appointment'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAppointmentList(),
          const SizedBox(height: 24),
          Text(
            'Upcoming Appointments',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          _buildUpcomingAppointments(),
        ],
      ),
    );
  }

  Widget _buildAppointmentList() {
    final appointments = [
      {
        'time': '09:00 AM',
        'client': 'ABC Corporation',
        'purpose': 'Initial Consultation',
        'status': 'Confirmed',
      },
      {
        'time': '11:30 AM',
        'client': 'XYZ Industries',
        'purpose': 'Design Review',
        'status': 'Pending',
      },
      {
        'time': '02:00 PM',
        'client': '123 Company',
        'purpose': 'Site Visit',
        'status': 'Confirmed',
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryBlue,
              child: Text(
                appointment['time']!.split(' ')[0],
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              appointment['client']!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(appointment['purpose']!),
            trailing: Chip(
              label: Text(
                appointment['status']!,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: appointment['status'] == 'Confirmed'
                  ? AppTheme.primaryBlue
                  : AppTheme.primaryPink,
            ),
          ),
        );
      },
    );
  }

  Widget _buildUpcomingAppointments() {
    final upcoming = [
      {
        'date': 'Tomorrow',
        'time': '10:00 AM',
        'client': 'DEF Ltd',
        'purpose': 'Project Discussion',
      },
      {
        'date': 'Mar 15',
        'time': '03:00 PM',
        'client': 'GHI Corp',
        'purpose': 'Final Approval',
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: upcoming.length,
      itemBuilder: (context, index) {
        final appointment = upcoming[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryPink,
              child: const Icon(Icons.calendar_today, color: Colors.white),
            ),
            title: Text(
              appointment['client']!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appointment['purpose']!),
                Text(
                  '${appointment['date']} at ${appointment['time']}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // Show options
              },
            ),
          ),
        );
      },
    );
  }
}

class JobsDashboard extends StatelessWidget {
  const JobsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Jobs',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Add new job
                },
                icon: const Icon(Icons.add),
                label: const Text('New Job'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: AppTheme.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildJobStatusCards(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Jobs',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: () {
                  // View all jobs
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildJobList(),
        ],
      ),
    );
  }

  Widget _buildJobStatusCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatusCard(
            'In Progress',
            '8',
            AppTheme.primaryBlue,
            Icons.build,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatusCard(
            'Pending Review',
            '4',
            AppTheme.primaryPink,
            Icons.pending_actions,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatusCard(
            'Completed',
            '12',
            AppTheme.primaryBlue,
            Icons.check_circle,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(
    String title,
    String count,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobList() {
    final jobs = <Map<String, dynamic>>[
      {
        'id': 'JOB-001',
        'client': 'ABC Corporation',
        'type': 'Signage Installation',
        'status': 'In Progress',
        'progress': 0.6,
        'dueDate': 'Mar 20, 2024',
      },
      {
        'id': 'JOB-002',
        'client': 'XYZ Industries',
        'type': 'Vehicle Wrap',
        'status': 'Pending Review',
        'progress': 0.8,
        'dueDate': 'Mar 18, 2024',
      },
      {
        'id': 'JOB-003',
        'client': '123 Company',
        'type': 'Banner Design',
        'status': 'In Progress',
        'progress': 0.3,
        'dueDate': 'Mar 22, 2024',
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      job['id'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                    Chip(
                      label: Text(
                        job['status'] as String,
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: job['status'] == 'In Progress'
                          ? AppTheme.primaryBlue
                          : AppTheme.primaryPink,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  job['client'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  job['type'] as String,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: job['progress'] as double,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    job['status'] == 'In Progress'
                        ? AppTheme.primaryBlue
                        : AppTheme.primaryPink,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Due: ${job['dueDate'] as String}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // View details
                      },
                      child: const Text('View Details'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class EmployeesDashboard extends StatelessWidget {
  const EmployeesDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Employees Dashboard'));
  }
}

class OrdersDashboard extends StatelessWidget {
  const OrdersDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Orders Dashboard'));
  }
}

class ReportsDashboard extends StatelessWidget {
  const ReportsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Reports Dashboard'));
  }
}
