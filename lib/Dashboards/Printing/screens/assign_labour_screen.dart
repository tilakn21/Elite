import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/printing_sidebar.dart';
import '../widgets/printing_top_bar.dart';
import '../models/printing_job.dart';
import '../providers/printing_job_provider.dart';

class PrintingAssignLabourScreen extends StatefulWidget {
  const PrintingAssignLabourScreen({Key? key}) : super(key: key);

  @override
  State<PrintingAssignLabourScreen> createState() => _PrintingAssignLabourScreenState();
}

class _PrintingAssignLabourScreenState extends State<PrintingAssignLabourScreen> {
  bool _isStartingPrint = false;
  bool _isCompletingPrint = false;
  bool _isSubmittingReview = false;
  bool _isReprinting = false;
  final TextEditingController _feedbackController = TextEditingController();
  
  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }Future<void> _startPrinting(PrintingJob job) async {
    if (job.designImageUrl == null || job.designImageUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot start printing: No design image available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isStartingPrint = true;
    });

    try {
      // Get the provider and use it to update the job status
      final printingJobProvider = Provider.of<PrintingJobProvider>(context, listen: false);
      
      // Start printing job and get the updated job with new status
      final updatedJob = await printingJobProvider.startPrintingJob(job.id, job.designImageUrl!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Printing started successfully! Status: ${_getStatusDisplayText(updatedJob.status)}'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate back to printing dashboard
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start printing: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isStartingPrint = false;
        });
      }
    }
  }

  // Method to handle marking a print job as completed
  Future<void> _completePrinting(PrintingJob job) async {
    setState(() {
      _isCompletingPrint = true;
    });

    try {
      // Get the provider and use it to update the job status
      final printingJobProvider = Provider.of<PrintingJobProvider>(context, listen: false);
      
      // Complete the printing job
      final updatedJob = await printingJobProvider.completePrintingJob(job.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Printing completed successfully! Status: ${_getStatusDisplayText(updatedJob.status)}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete printing: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCompletingPrint = false;
        });
      }
    }
  }

  // Method to handle reprinting a completed job
  Future<void> _reprintJob(PrintingJob job) async {
    if (job.designImageUrl == null || job.designImageUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot reprint: No design image available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isReprinting = true;
    });

    try {
      // Get the provider and use it to update the job status
      final printingJobProvider = Provider.of<PrintingJobProvider>(context, listen: false);
      
      // Get feedback if provided
      final feedback = _feedbackController.text.isNotEmpty ? _feedbackController.text : null;
      
      // Reprint the job
      final updatedJob = await printingJobProvider.reprintJob(job.id, job.designImageUrl!, feedback: feedback);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Job sent for reprinting! Status: ${_getStatusDisplayText(updatedJob.status)}'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Clear feedback
        _feedbackController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reprint: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isReprinting = false;
        });
      }
    }
  }

  // Method to handle submitting a job for quality review
  Future<void> _submitForReview(PrintingJob job) async {
    setState(() {
      _isSubmittingReview = true;
    });

    try {
      // Get the provider and use it to update the job status
      final printingJobProvider = Provider.of<PrintingJobProvider>(context, listen: false);
      
      // Get feedback if provided
      final feedback = _feedbackController.text.isNotEmpty ? _feedbackController.text : null;
      
      // Submit for review
      final updatedJob = await printingJobProvider.submitJobForReview(job.id, feedback: feedback);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Job submitted as printed! Status: ${_getStatusDisplayText(updatedJob.status)}'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Clear feedback
        _feedbackController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit job: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingReview = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get job data from navigation arguments
    final PrintingJob? job = ModalRoute.of(context)?.settings.arguments as PrintingJob?;
    
    // If no job data is passed, show no jobs message
    if (job == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F5FF),
        body: Row(
          children: [
            // Sidebar
            const PrintingSidebar(selectedIndex: 1),
            // Main Content
            Expanded(
              child: Column(
                children: [
                  // Top Bar
                  const PrintingTopBar(),
                  Expanded(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(48),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.work_off_outlined,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'No Job Selected',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Please select a job from the printing dashboard to view details.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF47B3CE),
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Back to Dashboard',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
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

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FF),
      body: Row(
        children: [
          // Sidebar
          const PrintingSidebar(selectedIndex: 1),
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Bar
                const PrintingTopBar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 48, vertical: 32),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [                        // Left: Job Details Card
                        Expanded(
                          flex: 5,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.all(32),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Job details',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20)),
                                  const SizedBox(height: 24),                                  _jobDetail('Client Name', job.clientName),
                                  const SizedBox(height: 16),
                                  _jobDetail('Phone', job.clientPhone ?? 'N/A'),
                                  const SizedBox(height: 16),
                                  _jobDetail('Address', job.clientAddress ?? 'N/A'),
                                  const SizedBox(height: 16),
                                  _jobDetail('Shop Name', job.shopName ?? 'N/A'),
                                  const SizedBox(height: 16),
                                  _jobDetail('Job ID', job.jobNo),
                                  const SizedBox(height: 16),
                                  _jobDetail('Job Description', job.title),
                                  const SizedBox(height: 16),
                                  _jobDetail('Assigned Salesperson', job.assignedSalesperson ?? 'Unassigned'),
                                  const SizedBox(height: 16),
                                  _jobDetail('Submission Date',
                                      '${job.submittedAt.day}/${job.submittedAt.month}/${job.submittedAt.year}'),
                                  const SizedBox(height: 16),
                                  _jobDetail('Due Date',
                                      job.dueDate != null 
                                          ? '${job.dueDate!.day}/${job.dueDate!.month}/${job.dueDate!.year}'
                                          : 'N/A'),
                                  const SizedBox(height: 16),                                  Row(
                                    children: [
                                      const Text('Status',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16,
                                              color: Color(0xFF888FA6))),
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getStatusBgColor(job.status),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          _getStatusDisplayText(job.status),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                              color: _getStatusTextColor(job.status)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 36),                        // Right: Design Preview Card
                        Expanded(
                          flex: 6,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [                                const Text('DESIGN PREVIEW',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        letterSpacing: 1)),                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    if (job.designStatus != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getDesignStatusColor(job.designStatus!).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'Design: ${job.designStatus!}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                            color: _getDesignStatusColor(job.designStatus!),
                                          ),
                                        ),
                                      ),
                                    const SizedBox(width: 8),
                                    // Display printing status
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getStatusBgColor(job.status).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Printing: ${_getStatusDisplayText(job.status)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                          color: _getStatusTextColor(job.status),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD9D9D9),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: job.designImageUrl != null && job.designImageUrl!.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(6),
                                            child: Image.network(
                                              job.designImageUrl!,
                                              fit: BoxFit.contain,
                                              loadingBuilder: (context, child, loadingProgress) {
                                                if (loadingProgress == null) return child;
                                                return Center(
                                                  child: CircularProgressIndicator(
                                                    value: loadingProgress.expectedTotalBytes != null
                                                        ? loadingProgress.cumulativeBytesLoaded /
                                                            loadingProgress.expectedTotalBytes!
                                                        : null,
                                                  ),
                                                );
                                              },
                                              errorBuilder: (context, error, stackTrace) {
                                                return const Center(
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(Icons.error_outline, size: 48, color: Colors.grey),
                                                      SizedBox(height: 8),
                                                      Text('Failed to load image', 
                                                          style: TextStyle(color: Colors.grey)),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          )
                                        : Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.image_not_supported, 
                                                    size: 48, 
                                                    color: Colors.grey.shade400),
                                                const SizedBox(height: 8),
                                                Text('No design preview available', 
                                                    style: TextStyle(color: Colors.grey.shade600)),
                                              ],
                                            ),
                                          ),
                                  ),
                                ),                                const SizedBox(height: 24),
                                
                                // When status is queued, show Start Printing button
                                if (job.status == PrintingStatus.queued)
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF47B3CE),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                      onPressed: _isStartingPrint 
                                          ? null 
                                          : () => _startPrinting(job),
                                      child: _isStartingPrint
                                          ? const Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                Text('Starting...',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.w500)),
                                              ],
                                            )
                                          : const Text('Start printing',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w500)),
                                    ),
                                  ),
                                
                                // When status is in progress, show Complete button
                                if (job.status == PrintingStatus.inProgress)
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF4CAF50),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                      onPressed: _isCompletingPrint 
                                          ? null 
                                          : () => _completePrinting(job),
                                      child: _isCompletingPrint
                                          ? const Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                Text('Completing...',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.w500)),
                                              ],
                                            )
                                          : const Text('Complete printing',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w500)),
                                    ),
                                  ),
                                
                                // When status is completed, show feedback field and Reprint + Submit for Review buttons
                                if (job.status == PrintingStatus.completed)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Feedback (optional):',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
                                              color: Color(0xFF888FA6))),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller: _feedbackController,
                                        decoration: InputDecoration(
                                          hintText: 'Enter any comments or feedback...',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        ),
                                        maxLines: 2,
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          // Reprint button
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFFF59E0B),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8)),
                                              ),
                                              onPressed: _isReprinting 
                                                  ? null 
                                                  : () => _reprintJob(job),
                                              child: _isReprinting
                                                  ? const SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                      ),
                                                    )
                                                  : const Text('Reprint',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w500)),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          // Submit for Review button
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF3B82F6),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8)),
                                              ),
                                              onPressed: _isSubmittingReview 
                                                  ? null 
                                                  : () => _submitForReview(job),
                                              child: _isSubmittingReview
                                                  ? const SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                      ),
                                                    )                                                  : const Text('Submit',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w500)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  
                                // For other statuses, show a message or custom action
                                if (job.status == PrintingStatus.review)
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text(
                                        'This job is currently under quality review.',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF2196F3),
                                        ),
                                      ),
                                    ),
                                  ),
                                
                                if (job.status == PrintingStatus.failed)
                                  Center(
                                    child: Column(
                                      children: [
                                        const Text(
                                          'This job has failed. Please contact the production department.',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFFE74C3C),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 12),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFF59E0B),
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8)),
                                          ),
                                          onPressed: _isReprinting 
                                              ? null 
                                              : () => _reprintJob(job),
                                          child: const Text('Try Reprint',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500)),
                                        ),
                                      ],
                                    ),
                                  ),                                  
                                if (job.status == PrintingStatus.onHold)
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text(
                                        'This job is currently on hold. Please check with the production manager.',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFFF39C12),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  
                                if (job.status == PrintingStatus.printed)
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text(
                                        'This job has been printed and submitted.',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF039BE5),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    const Text('Deadline',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                            color: Color(0xFF888FA6))),
                                    const SizedBox(width: 12),
                                    Expanded(                                      child: Text(
                                          job.dueDate != null 
                                              ? '${job.dueDate!.day} ${_getMonthName(job.dueDate!.month)}, ${job.dueDate!.year}'
                                              : 'No deadline set',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Color(0xFF232B3E))),
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
                fontSize: 16,
                color: Color(0xFF888FA6))),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF232B3E))),
      ],
    );
  }

  Color _getDesignStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF1BC47D);
      case 'pending':
        return const Color(0xFFF39C12);
      case 'rejected':
        return const Color(0xFFE74C3C);
      case 'in_review':
        return const Color(0xFF3498DB);
      default:
        return const Color(0xFF888FA6);
    }
  }
  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }  // Helper methods for status display
  Color _getStatusBgColor(PrintingStatus status) {
    switch (status) {
      case PrintingStatus.inProgress:
        return const Color(0xFFF3EFFF);
      case PrintingStatus.queued:
        return const Color(0xFFEEF5FF);
      case PrintingStatus.completed:
        return const Color(0xFFE6F7EF);
      case PrintingStatus.failed:
        return const Color(0xFFFCE6E6);
      case PrintingStatus.onHold:
        return const Color(0xFFFFF8E6);
      case PrintingStatus.review:
        return const Color(0xFFE3F2FD);
      case PrintingStatus.printed:
        return const Color(0xFFE1F5FE); // Light blue for printed status
    }
  }  String _getStatusDisplayText(PrintingStatus status) {
    switch (status) {
      case PrintingStatus.inProgress:
        return 'In Progress';
      case PrintingStatus.queued:
        return 'Queued';
      case PrintingStatus.completed:
        return 'Completed';
      case PrintingStatus.failed:
        return 'Failed';
      case PrintingStatus.onHold:
        return 'On Hold';
      case PrintingStatus.review:
        return 'Under Review';
      case PrintingStatus.printed:
        return 'Printed';
    }
  }
  Color _getStatusTextColor(PrintingStatus status) {
    switch (status) {
      case PrintingStatus.inProgress:
        return const Color(0xFF9B6FF7);
      case PrintingStatus.queued:
        return const Color(0xFF5576BB);
      case PrintingStatus.completed:
        return const Color(0xFF1BC47D);
      case PrintingStatus.failed:
        return const Color(0xFFE74C3C);
      case PrintingStatus.onHold:
        return const Color(0xFFF39C12);
      case PrintingStatus.review:
        return const Color(0xFF2196F3);
      case PrintingStatus.printed:
        return const Color(0xFF039BE5);
    }
  }
}
