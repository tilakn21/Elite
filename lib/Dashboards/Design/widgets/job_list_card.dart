import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/job.dart';
import '../utils/app_theme.dart';
import '../screens/job_details_screen.dart';

class JobListCard extends StatefulWidget {
  final List<Job> jobs;

  const JobListCard({
    Key? key,
    required this.jobs,
  }) : super(key: key);

  @override
  State<JobListCard> createState() => _JobListCardState();
}

class _JobListCardState extends State<JobListCard> {
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<String> get _filters => [
        'All',
        'Queued',
        'Pending for Approval',
        'Design Completed',
      ];

  String _getDisplayStatus(Job job) {
    String displayStatus = 'Queued';
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
    return displayStatus;
  }

  List<Job> get _filteredJobs {
    return widget.jobs.where((job) {
      final displayStatus = _getDisplayStatus(job);
      final matchesSearch = job.clientName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          job.jobNo.toLowerCase().contains(_searchQuery.toLowerCase());
      if (_selectedFilter == 'All') return matchesSearch;
      if (_selectedFilter == 'Queued' && displayStatus == 'Queued') return matchesSearch;
      if (_selectedFilter == 'Pending for Approval' && displayStatus == 'Pending for Approval') return matchesSearch;
      if (_selectedFilter == 'Design Completed' && displayStatus == 'Design Completed') return matchesSearch;
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(20.0).copyWith(bottom: 23.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Job List',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
            ),
            const SizedBox(height: 20),
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
                      items: _filters
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
            const SizedBox(height: 12),
            if (!isMobile) _buildJobListHeader(context),
            if (!isMobile)
              const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 12),
            _filteredJobs.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.work_outline,
                            size: 48,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No jobs available',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppTheme.textSecondaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: _filteredJobs.length > 4 ? 400 : _filteredJobs.length * 80.0,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _filteredJobs.length > 4 ? 4 : _filteredJobs.length,
                      separatorBuilder: (context, index) => const Divider(
                          height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                      itemBuilder: (context, index) {
                        final job = _filteredJobs[index];
                        return _buildJobListItem(context, job, isMobile: isMobile);
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovedJobsSection(BuildContext context) {
    final approvedJobs = widget.jobs.where((job) => job.displayStatus == 'Approved').toList();

    if (approvedJobs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Approved list',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryColor,
              ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: approvedJobs.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final job = approvedJobs[index];
              return _buildApprovedJobCard(context, job);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildApprovedJobCard(BuildContext context, Job job) {
    final statusColor = job.displayStatusColor;
    final statusText = job.displayStatus;
    return InkWell(
      onTap: () => _navigateToJobDetails(context, job),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 240,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[200],
                  child: Text(
                    job.clientName.isNotEmpty
                        ? job.clientName.substring(0, 1).toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
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
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        job.address.split(',').first,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondaryColor,
                              fontSize: 12,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Date',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 12,
                      ),
                ),
                Text(
                  DateFormat('dd/MM/yyyy').format(job.dateAdded),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withAlpha(26),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                statusText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobListHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            'Name',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'Phone',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'Date',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            'Status',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
          ),
        ),
        const SizedBox(width: 24), // Space for the arrow icon
      ],
    );
  }

  void _navigateToJobDetails(BuildContext context, Job job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobDetailsScreen(jobId: job.id),
      ),
    );
  }

  Widget _buildJobListItem(BuildContext context, Job job,
      {bool isMobile = false}) {
    final dateFormat =
        isMobile ? DateFormat('dd/MM/yy') : DateFormat('dd/MM/yyyy\nhh:mm a');
    final displayStatus = _getDisplayStatus(job);
    Color statusColor;
    switch (displayStatus) {
      case 'Pending for Approval':
        statusColor = AppTheme.inProgressColor;
        break;
      case 'Design Completed':
        statusColor = Colors.green;
        break;
      default:
        statusColor = AppTheme.pendingColor;
    }
    final statusText = displayStatus;

    if (isMobile) {
      // Mobile layout - card style
      return InkWell(
        onTap: () {
          _navigateToJobDetails(context, job);
        },
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        job.clientName,
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(26),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        statusText,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: statusColor,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.phone,
                        size: 16, color: AppTheme.textSecondaryColor),
                    const SizedBox(width: 4),
                    Text(
                      job.phoneNumber,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 16, color: AppTheme.textSecondaryColor),
                    const SizedBox(width: 4),
                    Text(
                      dateFormat.format(job.dateAdded),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // Desktop layout - row style
      return InkWell(
        onTap: () {
          _navigateToJobDetails(context, job);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  job.clientName,
                  style: Theme.of(context).textTheme.bodyLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  job.phoneNumber,
                  style: Theme.of(context).textTheme.bodyLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  dateFormat.format(job.dateAdded),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: statusColor,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                color: AppTheme.textSecondaryColor,
              ),
            ],
          ),
        ),
      );
    }
  }
}
