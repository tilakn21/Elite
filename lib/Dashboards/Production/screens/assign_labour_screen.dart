import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/top_bar.dart';
import '../providers/worker_provider.dart';
import '../models/worker.dart';
import '../models/production_job.dart';
import 'package:provider/provider.dart';

class AssignLabourScreen extends StatefulWidget {
  const AssignLabourScreen({Key? key}) : super(key: key);

  @override
  State<AssignLabourScreen> createState() => _AssignLabourScreenState();

  static Route<void> route(Object? arguments) {
    return MaterialPageRoute(
      builder: (context) {
        final job = arguments as ProductionJob?;
        return AssignLabourScreen(key: ValueKey(job?.id));
      },
    );
  }
}

class _AssignLabourScreenState extends State<AssignLabourScreen> {  final ScrollController _scrollController = ScrollController();
  ProductionJob? selectedJob;
  final Set<Worker> selectedWorkers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final job = ModalRoute.of(context)?.settings.arguments as ProductionJob?;
      if (job != null) {
        setState(() {
          selectedJob = job;
        });
      }
      
      // Initialize workers list
      final workerProvider = Provider.of<WorkerProvider>(context, listen: false);
      workerProvider.fetchWorkers();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  Color _getStatusColor(JobStatus status) {
    switch (status) {
      case JobStatus.received:
        return const Color(0xFFE3F2FD);
      case JobStatus.assignedLabour:
        return const Color(0xFFE8F5E8);
      case JobStatus.completed:
        return const Color(0xFFD5F5E3);
      case JobStatus.pending:
        return const Color(0xFFFFF4E5);
      case JobStatus.onHold:
        return const Color(0xFFFFECE9);
      case JobStatus.inProgress:
        return const Color(0xFFE8EAF6);
      default:
        return const Color(0xFFE8EAF6);
    }
  }

  Color _getStatusTextColor(JobStatus status) {
    switch (status) {
      case JobStatus.received:
        return const Color(0xFF1976D2);
      case JobStatus.assignedLabour:
        return const Color(0xFF2E7D32);
      case JobStatus.completed:
        return const Color(0xFF27AE60);
      case JobStatus.pending:
        return const Color(0xFFF39C12);
      case JobStatus.onHold:
        return const Color(0xFFE74C3C);
      case JobStatus.inProgress:
        return const Color(0xFF5C6BC0);
      default:
        return const Color(0xFF5C6BC0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4FF),
      body: Row(
        children: [
          ProductionSidebar(
            selectedIndex: 1,
            onItemTapped: (index) {
              if (index == 0) {
                Navigator.of(context).pushReplacementNamed('/production/dashboard');
              } else if (index == 1) {
                // Already on Assign Labour
              } else if (index == 2) {
                Navigator.of(context).pushReplacementNamed('/production/joblist');
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left: Job Details Card
                        Expanded(
                          flex: 5,
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(8),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Job details',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20)),
                                const SizedBox(height: 24),
                                if (selectedJob != null) ...[
                                  _jobDetail('Job No.', selectedJob!.jobNo),
                                  const SizedBox(height: 8),
                                  _jobDetail('Client Name', selectedJob!.clientName),
                                  const SizedBox(height: 8),
                                  _jobDetail('Description', selectedJob!.description),
                                  const SizedBox(height: 8),
                                  _jobDetail('Due Date', 
                                    "${selectedJob!.dueDate.day.toString().padLeft(2, '0')}/${selectedJob!.dueDate.month.toString().padLeft(2, '0')}/${selectedJob!.dueDate.year}"),
                                  const SizedBox(height: 16),
                                  const Text('Status',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                          color: Color(0xFF232B3E))),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(selectedJob!.computedStatus),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      selectedJob!.computedStatus.label,
                                      style: TextStyle(
                                        color: _getStatusTextColor(selectedJob!.computedStatus),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ] else
                                  const Center(
                                    child: Text('No job selected', 
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      )
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 36),
                        // Right: Assign Worker Card
                        Expanded(
                          flex: 7,
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(8),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Assign worker',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                ),
                                const SizedBox(height: 24),
                                Expanded(
                                  child: Consumer<WorkerProvider>(
                                    builder: (context, workerProvider, child) {
                                      if (workerProvider.isLoading) {
                                        return const Center(child: CircularProgressIndicator());
                                      }
                                      
                                      if (workerProvider.errorMessage != null) {
                                        return Center(
                                          child: Text(
                                            'Error: ${workerProvider.errorMessage}',
                                            style: const TextStyle(color: Colors.red),
                                          ),
                                        );
                                      }
                                      
                                      if (workerProvider.workers.isEmpty) {
                                        return const Center(child: Text('No production workers found'));
                                      }

                                      return Scrollbar(
                                        controller: _scrollController,
                                        thumbVisibility: true,
                                        child: ListView.builder(
                                          controller: _scrollController,
                                          itemCount: workerProvider.workers.length,
                                          itemBuilder: (context, index) {
                                            final worker = workerProvider.workers[index];
                                            // Use only numberOfJobs and isAvailable for status and selection
                                            return _workerTile(
                                              worker,
                                              worker.numberOfJobs >= 4
                                                ? 'Unavailable (Max jobs reached)'
                                                : (worker.isAvailable ? 'Available' : 'Unavailable'),
                                              selectedWorkers.contains(worker),
                                              onSelect: (worker.numberOfJobs < 4 && worker.isAvailable)
                                                ? () {
                                                    setState(() {
                                                      if (selectedWorkers.contains(worker)) {
                                                        selectedWorkers.remove(worker);
                                                      } else {
                                                        selectedWorkers.add(worker);
                                                      }
                                                    });
                                                  }
                                                : null,
                                            );
                                          },
                                        ), // End of ListView.builder
                                      ); // End of Scrollbar
                                    },
                                  ),
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF57B9C6),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),                                    onPressed: (selectedJob != null && selectedWorkers.isNotEmpty) ? () async {
                                      final workerProvider = Provider.of<WorkerProvider>(context, listen: false);                                      try {
                                        // Assign all selected workers to the job
                                        List<String> errors = [];
                                        for (final worker in selectedWorkers) {
                                          try {
                                            await workerProvider.assignWorker(worker.id, selectedJob!.id);
                                          } catch (workerError) {
                                            errors.add('${worker.name}: ${workerError.toString()}');
                                          }
                                        }
                                        
                                        if (errors.isEmpty) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('${selectedWorkers.length} worker(s) assigned successfully'),
                                              backgroundColor: const Color(0xFF57B9C6),
                                            ),
                                          );
                                          Navigator.pushReplacementNamed(context, '/production/joblist');
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Errors assigning workers:\n${errors.join('\n')}'),
                                              backgroundColor: Colors.red,
                                              duration: const Duration(seconds: 5),
                                            ),
                                          );
                                          // Refresh the workers list to update availability status
                                          await workerProvider.fetchWorkers();
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Failed to assign workers: ${e.toString()}'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    } : null,
                                    child: const Text(
                                      'Assign',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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

  Widget _jobDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Color(0xFF232B3E))),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      ],
    );
  }  Widget _workerTile(Worker worker, String status, bool selected, {VoidCallback? onSelect}) {
    // Determine status color based on worker's actual status
    Color statusColor;
    if (worker.numberOfJobs >= 4) {
      statusColor = Colors.red; // Unavailable (max jobs)
    } else if (worker.isAvailable) {
      statusColor = Colors.green; // Available workers
    } else {
      statusColor = Colors.red; // Unavailable workers
    }

    // Determine the actual status text
    String statusText;
    if (worker.numberOfJobs >= 4) {
      statusText = 'Unavailable (Max jobs reached)';
    } else if (worker.isAvailable) {
      statusText = 'Available';
    } else {
      statusText = 'Unavailable';
    }

    return InkWell(
      onTap: (worker.numberOfJobs >= 4 || !worker.isAvailable) ? null : onSelect, // Disable tap if max jobs or unavailable
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE3F2FD) : Colors.white,
          border: Border.all(
            color: selected ? const Color(0xFF57B9C6) : const Color(0xFFE0E0E0),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/images/avatars/default_avatar.png'),
              radius: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    worker.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Jobs assigned: ${worker.numberOfJobs}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (worker.numberOfJobs < 4 && worker.isAvailable && onSelect != null)
              Icon(
                selected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: selected ? const Color(0xFF57B9C6) : Colors.grey,
              ),
          ],
        ),
      ),
    );
  }
}
