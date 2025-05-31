import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/top_bar.dart';
import '../widgets/dynamic_progress_bar.dart';
import '../models/production_job.dart';
import '../providers/production_job_provider.dart';

class UpdateJobStatusScreen extends StatefulWidget {
  const UpdateJobStatusScreen({Key? key}) : super(key: key);

  @override
  State<UpdateJobStatusScreen> createState() => _UpdateJobStatusScreenState();
}

class _UpdateJobStatusScreenState extends State<UpdateJobStatusScreen> {
  ProductionJob? selectedJob;
  JobStatus selectedStatus = JobStatus.receiver;  final List<JobStatus> statusOptions = [
    JobStatus.receiver,
    JobStatus.assignedLabour,
    JobStatus.inProgress,
    JobStatus.completed,
  ];
  
  final TextEditingController _feedbackController = TextEditingController();
  
  @override
  void initState() {
    super.initState();    WidgetsBinding.instance.addPostFrameCallback((_) {
      final job = ModalRoute.of(context)?.settings.arguments as ProductionJob?;
      if (job != null) {
        setState(() {
          selectedJob = job;
          // If the job's current status is not in our statusOptions, default to the first available option
          selectedStatus = statusOptions.contains(job.status) ? job.status : statusOptions.first;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4FF),
      body: Row(
        children: [
          ProductionSidebar(
            selectedIndex: 3,
            onItemTapped: (index) {
              if (index == 0) {
                Navigator.of(context)
                    .pushReplacementNamed('/production/dashboard');
              } else if (index == 1) {
                Navigator.of(context)
                    .pushReplacementNamed('/production/assignlabour');
              } else if (index == 2) {
                Navigator.of(context)
                    .pushReplacementNamed('/production/joblist');
              } else if (index == 3) {
                // Already on Update Job Status
              }
            },
          ),
          Expanded(
            child: Column(
              children: [
                ProductionTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 48, vertical: 32),                    child: Column(
                      children: [
                        DynamicProgressBar(job: selectedJob),
                        const SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1st Column: Job Details Card
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
                                    const Text('Job Details',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20)),
                                    const SizedBox(height: 24),                                    _jobDetail('Job ID', selectedJob?.jobNo ?? 'N/A'),
                                    const SizedBox(height: 8),
                                    _jobDetail('Client Name', selectedJob?.clientName ?? 'N/A'),
                                    const SizedBox(height: 8),
                                    _jobDetail('Due Date', selectedJob != null 
                                        ? "${selectedJob!.dueDate.day.toString().padLeft(2, '0')}/${selectedJob!.dueDate.month.toString().padLeft(2, '0')}/${selectedJob!.dueDate.year}"
                                        : 'N/A'),
                                    const SizedBox(height: 8),
                                    _jobDetail('Job description', selectedJob?.description ?? 'N/A'),
                                    const SizedBox(height: 8),
                                    _jobDetail('Current status', selectedJob?.status.label ?? 'N/A'),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 36),
                            // 2nd Column: Feedback (row 1) and Update Status (row 2)
                            Expanded(
                              flex: 7,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Feedback Card
                                  Container(
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [                                        const Text('Feedback',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20)),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Add optional feedback that will be saved with the status update',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 16),TextField(
                                          controller: _feedbackController,
                                          maxLines: 5,
                                          decoration: InputDecoration(
                                            hintText: 'Enter optional feedback about this job status update...',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                  color: Colors.grey),
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 10),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF57B9C6),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                            ),                                            onPressed: () {
                                              if (_feedbackController.text.trim().isNotEmpty) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Feedback saved. It will be included when you update the job status.'),
                                                    backgroundColor: Color(0xFF57B9C6),
                                                  ),
                                                );
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Please enter feedback before saving'),
                                                    backgroundColor: Colors.orange,
                                                  ),
                                                );
                                              }
                                            },
                                            child: const Text('Save Feedback',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 36),
                                  // Update Status Card
                                  Container(
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('Update Status',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20)),
                                        const SizedBox(height: 24),
                                        DropdownButton<JobStatus>(
                                          value: selectedStatus,
                                          items: statusOptions.map((status) {
                                            return DropdownMenuItem<JobStatus>(
                                              value: status,
                                              child: Text(status.label),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            if (value != null) {
                                              setState(() {
                                                selectedStatus = value;
                                              });
                                            }
                                          },
                                        ),
                                        const SizedBox(height: 24),
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: SizedBox(
                                            width: double.infinity,
                                            height: 48,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xFF57B9C6),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8)),
                                              ),                                              onPressed: () async {
                                                if (selectedJob != null) {
                                                  try {
                                                    final jobProvider = Provider.of<ProductionJobProvider>(context, listen: false);
                                                    final feedback = _feedbackController.text.trim();
                                                      // Update job status with feedback if provided
                                                    await jobProvider.updateJobStatus(
                                                      selectedJob!.id, 
                                                      selectedStatus,
                                                      feedback: feedback.isNotEmpty ? feedback : null,
                                                    );
                                                    
                                                    // Get updated job data to refresh the progress bar
                                                    final updatedJobs = jobProvider.jobs;
                                                    final updatedJob = updatedJobs.firstWhere(
                                                      (job) => job.id == selectedJob!.id,
                                                      orElse: () => selectedJob!,
                                                    );
                                                    
                                                    setState(() {
                                                      selectedJob = updatedJob;
                                                    });
                                                    
                                                    // Clear feedback after successful update
                                                    _feedbackController.clear();
                                                    
                                                    final successMessage = feedback.isNotEmpty 
                                                        ? 'Job ${selectedJob!.jobNo} status updated to ${selectedStatus.label} with feedback'
                                                        : 'Job ${selectedJob!.jobNo} status updated to ${selectedStatus.label}';
                                                    
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text(successMessage),
                                                        backgroundColor: const Color(0xFF57B9C6),
                                                      ),
                                                    );
                                                    
                                                    // Show option to go back or continue updating
                                                    Future.delayed(const Duration(seconds: 2), () {
                                                      if (mounted) {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(
                                                            content: const Text('Continue updating or go back to job list'),
                                                            backgroundColor: Colors.blue.shade600,
                                                            action: SnackBarAction(
                                                              label: 'Go Back',
                                                              textColor: Colors.white,
                                                              onPressed: () {
                                                                Navigator.pushReplacementNamed(context, '/production/joblist');
                                                              },
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    });
                                                  } catch (e) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text('Failed to update job status: ${e.toString()}'),
                                                        backgroundColor: Colors.red,
                                                      ),
                                                    );
                                                  }
                                                } else {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text('No job selected'),
                                                      backgroundColor: Colors.red,
                                                    ),
                                                  );
                                                }
                                              },
                                              child: const Text('Update',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w600)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
  }
}
