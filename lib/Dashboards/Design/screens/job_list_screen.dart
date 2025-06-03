import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/job_provider.dart';
import '../models/job.dart';
import '../utils/app_theme.dart';
import 'job_details_screen.dart';
import '../widgets/design_top_bar.dart';
import '../widgets/sidebar.dart';

class JobListScreen extends StatefulWidget {
  final bool showNavigation;
  
  const JobListScreen({Key? key, this.showNavigation = true}) : super(key: key);

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';
  bool _isRefreshingJobs = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _refreshJobs();
  }

  Future<void> _refreshJobs() async {
    setState(() => _isRefreshingJobs = true);
    await Provider.of<JobProvider>(context, listen: false).fetchJobs();
    setState(() => _isRefreshingJobs = false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);
    final filteredJobs = jobProvider.jobs.where((job) {
      // Determine display status based on latest draft in design JSONB
      String displayStatus = job.displayStatus;
      final design = job.design;
      if (design is List && design.isNotEmpty) {
        for (var i = design.length - 1; i >= 0; i--) {
          final draft = design[i];
          final status = draft is Map<String, dynamic> ? draft['status']?.toString().toLowerCase() : null;
          if (status == 'pending_approval' || status == 'pending for approval') {
            displayStatus = 'Pending for Approval';
            break;
          } else if (status == 'completed') {
            displayStatus = 'Design Completed';
            break;
          }
        }
      }
      final matchesSearch = job.clientName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          job.jobNo.toLowerCase().contains(_searchQuery.toLowerCase());
      if (_selectedFilter == 'All') return matchesSearch;
      if (_selectedFilter == 'Queued' && displayStatus == 'Queued') return matchesSearch;
      if (_selectedFilter == 'Pending for Approval' && displayStatus == 'Pending for Approval') return matchesSearch;
      if (_selectedFilter == 'Design Completed' && displayStatus == 'Design Completed') return matchesSearch;
      return false;
    }).toList();

    Widget content = Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showNavigation) const DesignTopBar(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with search and filter
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Job list',
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              tooltip: 'Refresh',
                              onPressed: _refreshJobs,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (value) => setState(() => _searchQuery = value),
                                  decoration: InputDecoration(
                                    hintText: 'Search jobs...',
                                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedFilter,
                                  items: [
                                    'All',
                                    'Queued',
                                    'Pending for Approval',
                                    'Design Completed',
                                  ]
                                      .map((filter) => DropdownMenuItem(
                                            value: filter,
                                            child: Text(filter),
                                          ))
                                      .toList(),
                                  onChanged: (value) => setState(() => _selectedFilter = value!),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Approved jobs section
                  if (jobProvider.approvedJobs.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Approved list',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () {
                                  // Handle view all
                                },
                                child: const Text('View all'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 120,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: jobProvider.approvedJobs.length,
                              separatorBuilder: (context, index) => const SizedBox(width: 16),
                              itemBuilder: (context, index) {
                                final job = jobProvider.approvedJobs[index];
                                return _buildApprovedJobCard(context, job);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                  ],

                  // Table header
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[200]!),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Row(
                      children: [
                        // Job ID column
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Job ID',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: AppTheme.textSecondaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                        // Client Name column
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Client Name',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: AppTheme.textSecondaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                        // Phone column
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              Icon(Icons.phone_outlined, size: 16, color: AppTheme.textSecondaryColor),
                              const SizedBox(width: 8),
                              Text(
                                'Phone',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: AppTheme.textSecondaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Date column
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_outlined, size: 16, color: AppTheme.textSecondaryColor),
                              const SizedBox(width: 8),
                              Text(
                                'Date added',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: AppTheme.textSecondaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Status column
                        Expanded(
                          flex: 2,
                          child: Text(
                            'STATUS',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppTheme.textSecondaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48), // Space for arrow
                      ],
                    ),
                  ),

                  // Job list
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refreshJobs,
                      child: filteredJobs.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'No jobs found',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            itemCount: filteredJobs.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final job = filteredJobs[index];
                              return _buildJobListItem(context, job);
                            },
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (_isRefreshingJobs)
          Container(
            color: Colors.black.withOpacity(0.1),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      
      ]);

    if (widget.showNavigation) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Row(
          children: [
            DesignSidebar(
              selectedIndex: 1,
              onItemTapped: (index) {
                if (index != 1) {
                  switch (index) {
                    case 0:
                      Navigator.pushReplacementNamed(context, '/design/dashboard');
                      break;
                    case 2:
                      Navigator.pushReplacementNamed(context, '/design/reimbursement');
                      break;
                    case 3:
                      Navigator.pushReplacementNamed(context, '/design/chats');
                      break;
                  }
                }
              },
            ),
            Expanded(child: content),
          ],
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: content,
      );
    }
  }

  Widget _buildApprovedJobCard(BuildContext context, Job job) {
    // Determine display status and color based on latest draft
    String statusText = job.displayStatus;
    Color statusColor = job.displayStatusColor;
    final design = job.design;
    if (design is List && design.isNotEmpty) {
      for (var i = design.length - 1; i >= 0; i--) {
        final draft = design[i];
        final status = draft is Map<String, dynamic> ? draft['status']?.toString().toLowerCase() : null;
        if (status == 'pending_approval' || status == 'pending for approval') {
          statusText = 'Pending for Approval';
          statusColor = AppTheme.pendingColor;
          break;
        } else if (status == 'completed') {
          statusText = 'Design Completed';
          statusColor = AppTheme.approvedColor;
          break;
        }
      }
    }
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobDetailsScreen(jobId: job.id),
          ),
        );
      },
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with job number and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '#${job.jobNo}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor.withAlpha(100)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Client info
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Text(
                      job.clientName.isNotEmpty ? job.clientName[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.clientName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          job.address.split(',').first,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Footer with date and contact
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd MMM yyyy').format(job.dateAdded),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.phone_outlined, size: 14, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        'Contact',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      )
      );
  }

  Widget _buildJobListItem(BuildContext context, Job job) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    // Determine display status and color based on latest draft
    String statusText = job.displayStatus;
    Color statusColor = job.displayStatusColor;
    final design = job.design;
    if (design is List && design.isNotEmpty) {
      for (var i = design.length - 1; i >= 0; i--) {
        final draft = design[i];
        final status = draft is Map<String, dynamic> ? draft['status']?.toString().toLowerCase() : null;
        if (status == 'pending_approval' || status == 'pending for approval') {
          statusText = 'Pending for Approval';
          statusColor = AppTheme.pendingColor;
          break;
        } else if (status == 'completed') {
          statusText = 'Design Completed';
          statusColor = AppTheme.approvedColor;
          break;
        }
      }
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[100]!),
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JobDetailsScreen(jobId: job.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Row(
            children: [
              // Job ID column
              Expanded(
                flex: 3,
                child: Text(
                  job.id,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              // Client Name column
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      child: Text(
                        job.clientName.isNotEmpty ? job.clientName[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        job.clientName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // Phone column
              Expanded(
                flex: 2,
                child: Text(
                  job.phoneNumber,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              // Date column
              Expanded(
                flex: 2,
                child: Text(
                  dateFormat.format(job.dateAdded),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ),
              // Status column
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: statusColor.withAlpha(100)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        statusText,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Arrow
              SizedBox(
                width: 48,
                child: Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
