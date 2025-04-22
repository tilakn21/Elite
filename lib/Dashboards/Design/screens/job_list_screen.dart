import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/job_provider.dart';
import '../models/job.dart';
import '../utils/app_theme.dart';
import 'job_details_screen.dart';

class JobListScreen extends StatefulWidget {
  const JobListScreen({Key? key}) : super(key: key);

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Job list',
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Approved list',
                  style: Theme.of(context).textTheme.titleLarge,
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
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  'Job no.',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const Spacer(flex: 1),
                Text(
                  'Client Name',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const Spacer(flex: 2),
                Text(
                  'Email',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const Spacer(flex: 2),
                Text(
                  'Phone number',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const Spacer(flex: 1),
                Text(
                  'Date added',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const Spacer(flex: 1),
                Text(
                  'STATUS',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(width: 48), // Space for the arrow icon
              ],
            ),
          ),
          const Divider(height: 24),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: jobProvider.jobs.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final job = jobProvider.jobs[index];
                return _buildJobListItem(context, job);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovedJobCard(BuildContext context, Job job) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppTheme.dividerColor),
      ),
      child: Container(
        width: 240,
        height: 100, // Reduced height
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // First row with avatar and name
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 12, // Smaller radius
                    backgroundColor: Colors.grey[200],
                    child: Text(
                      job.clientName.isNotEmpty ? job.clientName.substring(0, 1) : '?',
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10, // Smaller font
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Client name and address
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          job.clientName,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          job.address.split(',').first,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const Spacer(flex: 1),
              
              // Date row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Date',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    DateFormat('dd/MM/yyyy').format(job.dateAdded),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 4),
              
              // Status indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.approvedColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  'Approved',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.approvedColor,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobListItem(BuildContext context, Job job) {
    final dateFormat = DateFormat('dd/MM/yyyy\nhh:mm a');
    
    Color statusColor;
    String statusText;
    
    switch (job.status) {
      case JobStatus.approved:
        statusColor = AppTheme.approvedColor;
        statusText = 'Approved';
        break;
      case JobStatus.pending:
        statusColor = AppTheme.pendingColor;
        statusText = 'Pending';
        break;
      case JobStatus.inProgress:
        statusColor = AppTheme.inProgressColor;
        statusText = 'In progress';
        break;
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Text(
              job.jobNo,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Spacer(flex: 1),
            Text(
              job.clientName,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Spacer(flex: 2),
            Text(
              job.email,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Spacer(flex: 2),
            Text(
              job.phoneNumber,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Spacer(flex: 1),
            Text(
              dateFormat.format(job.dateAdded),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Spacer(flex: 1),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                statusText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: statusColor,
                ),
              ),
            ),
            const SizedBox(width: 16),
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