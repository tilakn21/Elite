import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/top_bar.dart';
import '../models/production_job.dart';
import '../models/worker.dart';
import 'package:provider/provider.dart';
import '../providers/production_job_provider.dart';

class ProductionJobListScreen extends StatelessWidget {
  const ProductionJobListScreen({Key? key}) : super(key: key);

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
                Navigator.of(context)
                    .pushReplacementNamed('/production/updatejobstatus');
              }
            },
          ),
          Expanded(
            child: Column(
              children: [
                ProductionTopBar(),
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
                                if (jobProvider.isLoading) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                if (jobProvider.errorMessage != null) {
                                  return Center(child: Text('Error: ${jobProvider.errorMessage}'));
                                }
                                if (jobProvider.jobs.isEmpty) {
                                  return const Center(child: Text('No production jobs found.'));
                                }
                                return _JobDataTable(jobs: jobProvider.jobs);
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
  @override
  Widget build(BuildContext context) {
    return Consumer<ProductionJobProvider>(
      builder: (context, provider, child) {
        final completedJobs = provider.jobs
            .where((job) => job.status == JobStatus.completed)
            .take(3)
            .toList();

        if (completedJobs.isEmpty) {
          return const Center(child: Text('No completed jobs yet'));
        }

        return Row(
          children: [
            ...completedJobs.asMap().entries.map((entry) {
              final job = entry.value;
              final assignedWorker = Worker(
                id: job.id,
                name: job.clientName,
                phone: 'N/A', // Since this is just for display
                role: 'Production Worker',
                image: 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(job.clientName)}&background=random',
                isAvailable: false // Worker is not available since they are assigned to a completed job
              );
              
              return Expanded(
                child: Row(
                  children: [
                    if (entry.key > 0) const SizedBox(width: 16),
                    Expanded(
                      child: _CompletedCard(
                        worker: assignedWorker,
                        date: "${job.dueDate.day.toString().padLeft(2, '0')}/${job.dueDate.month.toString().padLeft(2, '0')}/${job.dueDate.year}"
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            ...List.generate(3 - completedJobs.length, (index) => 
              Expanded(
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: _CompletedCard(
                        worker: Worker(
                          id: 'empty',
                          name: 'No Worker Assigned',
                          phone: 'N/A',
                          role: 'Production Worker',
                          image: 'https://ui-avatars.com/api/?name=NA&background=random',
                          isAvailable: true // Empty slot is available
                        ),
                        date: ''
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
            switch (job.status) {
              case JobStatus.receiver:
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
              case JobStatus.pending:
                statusColor = const Color(0xFFF39C12);
                statusBg = const Color(0xFFFFF4E5);
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
                      child: Text(job.status.label,
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
                            child: ElevatedButton(                              onPressed: () {
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
                            height: 36,                            child: ElevatedButton(
                              onPressed: () {
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
