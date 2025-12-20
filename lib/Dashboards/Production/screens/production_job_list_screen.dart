import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/top_bar.dart';
import '../models/production_job.dart';
import '../models/worker.dart';
import 'package:provider/provider.dart';
import '../providers/production_job_provider.dart';

class ProductionJobListScreen extends StatefulWidget {
  const ProductionJobListScreen({Key? key}) : super(key: key);

  @override
  State<ProductionJobListScreen> createState() => _ProductionJobListScreenState();
}

class _ProductionJobListScreenState extends State<ProductionJobListScreen> {
  String _searchQuery = '';
  String _selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    // Fetch jobs on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductionJobProvider>(context, listen: false).fetchProductionJobs();
    });
  }

  @override
  void dispose() {
    // Fetch jobs on close
    Provider.of<ProductionJobProvider>(context, listen: false).fetchProductionJobs();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4FF),
      body: Row(
        children: [
          ProductionSidebar(
            selectedIndex: 2,
            onItemTapped: (index) {
              if (index == 0) {
                Navigator.of(context)
                    .pushReplacementNamed('/production/dashboard');
              } else if (index == 1) {
                Navigator.of(context)
                    .pushReplacementNamed('/production/assignlabour');
              } else if (index == 2) {
                // Already on Job List
              } else if (index == 3) {
                Navigator.of(context).pushReplacementNamed(
                  '/production/reimbursement_request',
                  arguments: {'employeeId': 'prod1001'},
                );
              }
            },
          ),
          Expanded(
            child: Column(
              children: [
                ProductionTopBar(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  child: Row(
                    children: [
                      // Search bar
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 16),
                              const Icon(Icons.search, color: Colors.grey, size: 22),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  onChanged: (value) => setState(() => _searchQuery = value),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Search jobs by client or job no...',
                                    hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Status filter dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedStatus,
                            items: [
                              'All',
                              'received',
                              'Assigned Labour',
                              'Forwarded for printing',
                              'Completed',
                              'On Hold',
                            ].map((status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status),
                                )).toList(),
                            onChanged: (value) => setState(() => _selectedStatus = value!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SafeArea(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            const Text('Job list',
                                style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF232B3E))),
                            const SizedBox(height: 20),
                            _CompletedListRow(),
                            const SizedBox(height: 24),
                            Consumer<ProductionJobProvider>(
                              builder: (context, jobProvider, child) {
                                final jobs = jobProvider.jobs.where((job) {
                                  final matchesSearch = job.clientName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                                      job.jobNo.toLowerCase().contains(_searchQuery.toLowerCase());
                                  // Use computedStatus for filtering
                                  if (_selectedStatus == 'All') return matchesSearch;
                                  if (_selectedStatus == 'received' && job.computedStatus == JobStatus.received) return matchesSearch;
                                  if (_selectedStatus == 'Assigned Labour' && job.computedStatus == JobStatus.assignedLabour) return matchesSearch;
                                  if (_selectedStatus == 'Forwarded for printing' &&
                                      (job.computedStatus == JobStatus.inProgress || job.computedStatus == JobStatus.processedForPrinting)) return matchesSearch;
                                  if (_selectedStatus == 'Completed' && job.computedStatus == JobStatus.completed) return matchesSearch;
                                  if (_selectedStatus == 'On Hold' && job.computedStatus == JobStatus.onHold) return matchesSearch;
                                  return false;
                                }).toList();
                                if (jobProvider.isLoading) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                if (jobProvider.errorMessage != null) {
                                  return Center(child: Text('Error: \\${jobProvider.errorMessage}'));
                                }
                                if (jobs.isEmpty) {
                                  return const Center(child: Text('No production jobs found.'));
                                }
                                return _JobDataTable(jobs: jobs);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
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

class _CompletedCard extends StatelessWidget {
  final Worker worker;
  final String date;
  const _CompletedCard({required this.worker, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundImage: NetworkImage(worker.image), radius: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(worker.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text(worker.role,
                    style:
                        const TextStyle(fontSize: 13, color: Colors.black54)),
                if (date.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text('Date',
                      style: TextStyle(fontSize: 12, color: Colors.black45)),
                  Text(date,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 14)),
                ],
              ],
            ),
          ),
          if (date.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFD5F5E3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Completed',
                  style: TextStyle(
                      color: Color(0xFF27AE60),
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ),
        ],
      ),
    );
  }
}

class _CompletedListRow extends StatelessWidget {
  Color getGradientColor(DateTime dueDate) {
    final now = DateTime.now();
    final days = dueDate.difference(now).inDays;
    if (days <= 0) {
      // Overdue or today
      return const Color(0xFFFFBABA); // light red
    } else if (days <= 2) {
      return const Color(0xFFFFF3B0); // light yellow
    } else if (days <= 7) {
      return const Color(0xFFB2FEFA); // light blue
    } else {
      return const Color(0xFFD5F5E3); // light green
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductionJobProvider>(
      builder: (context, provider, child) {
        final recentJobs = provider.jobs.toList()
          ..sort((a, b) => b.dueDate.compareTo(a.dueDate));
        final top3Jobs = recentJobs.take(3).toList();

        if (top3Jobs.isEmpty) {
          return const Center(child: Text('No recent jobs yet'));
        }

        Color getStatusBg(JobStatus status) {
          switch (status) {
            case JobStatus.received:
              return const Color(0xFFE3F2FD);
            case JobStatus.assignedLabour:
              return const Color(0xFFE8F5E8);
            case JobStatus.completed:
              return const Color(0xFFD5F5E3);
            case JobStatus.onHold:
              return const Color(0xFFFFECE9);
            case JobStatus.inProgress:
              // Change to forwarded for printing
              return const Color(0xFFE8EAF6);
            case JobStatus.processedForPrinting:
              return const Color(0xFFE8EAF6);
            default:
              return const Color(0xFFE8EAF6);
          }
        }

        Color getStatusColor(JobStatus status) {
          switch (status) {
            case JobStatus.received:
              return const Color(0xFF1976D2);
            case JobStatus.assignedLabour:
              return const Color(0xFF2E7D32);
            case JobStatus.completed:
              return const Color(0xFF27AE60);
            case JobStatus.onHold:
              return const Color(0xFFE74C3C);
            case JobStatus.inProgress:
              // Change to forwarded for printing
              return const Color(0xFF5C6BC0);
            case JobStatus.processedForPrinting:
              return const Color(0xFF5C6BC0);
            default:
              return const Color(0xFF5C6BC0);
          }
        }

        return Row(
          children: [
            ...top3Jobs.asMap().entries.map((entry) {
              final job = entry.value;
              return Expanded(
                child: Row(
                  children: [
                    if (entry.key > 0) const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(
                            context,
                            '/production/updatejobstatus',
                            arguments: job,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Icon(Icons.work, color: getStatusColor(job.computedStatus), size: 22),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(job.jobNo,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold, fontSize: 16, color: getStatusColor(job.computedStatus)),
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 14, color: Colors.black45),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        "${job.dueDate.day.toString().padLeft(2, '0')}/${job.dueDate.month.toString().padLeft(2, '0')}/${job.dueDate.year}",
                                        style: const TextStyle(fontSize: 12, color: Colors.black45),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: getStatusBg(job.computedStatus),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    (job.computedStatus == JobStatus.inProgress || job.computedStatus == JobStatus.processedForPrinting)
                                        ? 'Forwarded for printing'
                                        : job.computedStatus.label,
                                    style: TextStyle(
                                        color: getStatusColor(job.computedStatus),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13),
                                    overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            ...List.generate(3 - top3Jobs.length, (index) =>
              Expanded(
                child: Row(
                  children: [
                    if (top3Jobs.isNotEmpty || index > 0) const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Color(0xFFF0F1F6)),
                        ),
                        child: const Center(
                          child: Text('No Job', style: TextStyle(color: Colors.black38)),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ),
          ],
        );
      },
    );
  }
}

class _JobDataTable extends StatelessWidget {
  final List<ProductionJob> jobs;
  const _JobDataTable({required this.jobs});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FA),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: const [
                Expanded(
                    flex: 1,
                    child: Text('Job no.',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black54))),
                SizedBox(width: 16),
                Expanded(
                    flex: 2,
                    child: Text('Client Name',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black54))),
                SizedBox(width: 16),
                Expanded(
                    flex: 2,
                    child: Text('Due date',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black54))),
                SizedBox(width: 16),
                Expanded(
                    flex: 3,
                    child: Text('Description',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black54))),
                SizedBox(width: 16),
                Expanded(
                    flex: 1,
                    child: Text('STATUS',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black54))),
                SizedBox(width: 16),
                Expanded(flex: 2, child: SizedBox()),
              ],
            ),
          ),          ...jobs.map((job) {
            Color statusColor;
            Color statusBg;
            switch (job.computedStatus) {
              case JobStatus.received:
                statusColor = const Color(0xFF1976D2);
                statusBg = const Color(0xFFE3F2FD);
                break;
              case JobStatus.assignedLabour:
                statusColor = const Color(0xFF2E7D32);
                statusBg = const Color(0xFFE8F5E8);
                break;
              case JobStatus.completed:
                statusColor = const Color(0xFF27AE60);
                statusBg = const Color(0xFFD5F5E3);
                break;
              case JobStatus.onHold:
                statusColor = const Color(0xFFE74C3C);
                statusBg = const Color(0xFFFFECE9);
                break;
              case JobStatus.inProgress:
                statusColor = const Color(0xFF5C6BC0);
                statusBg = const Color(0xFFE8EAF6);
                break;
              default:
                statusColor = const Color(0xFF5C6BC0);
                statusBg = const Color(0xFFE8EAF6);
            }

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFF0F1F6), width: 1)),
              ),
              child: Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: Text(job.jobNo, 
                          style: const TextStyle(fontSize: 15),
                          overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 16),
                  Expanded(
                      flex: 2,
                      child: Text(job.clientName, 
                          style: const TextStyle(fontSize: 15),
                          overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 16),
                  Expanded(
                      flex: 2,
                      child: Text(
                          "${job.dueDate.day.toString().padLeft(2, '0')}/${job.dueDate.month.toString().padLeft(2, '0')}/${job.dueDate.year}",
                          style: const TextStyle(fontSize: 15))),
                  const SizedBox(width: 16),
                  Expanded(
                      flex: 3,
                      child: Text(job.description, 
                          style: const TextStyle(fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1)),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                          (job.computedStatus == JobStatus.inProgress || job.computedStatus == JobStatus.processedForPrinting)
                              ? 'Forwarded for printing'
                              : job.computedStatus.label,
                          style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  const SizedBox(width: 16),                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 36,
                            child: ElevatedButton(
                              onPressed: job.computedStatus == JobStatus.completed
                                  ? null
                                  : () {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        '/production/assignlabour',
                                        arguments: job,
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF26A6A2),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 0),
                              ),
                              child: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text('Assign Labour',
                                    style: TextStyle(fontSize: 13)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SizedBox(
                            height: 36,
                            child: ElevatedButton(
                              onPressed: job.computedStatus == JobStatus.completed
                                  ? null
                                  : () {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        '/production/updatejobstatus',
                                        arguments: job,
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD5F5E3),
                                foregroundColor: const Color(0xFF27AE60),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 0),
                              ),
                              child: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text('Update Status',
                                    style: TextStyle(fontSize: 13)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
