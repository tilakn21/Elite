import 'package:flutter/material.dart';
import '../models/printing_job.dart';

class PrintingJobTable extends StatelessWidget {
  final List<PrintingJob> jobs;

  const PrintingJobTable({Key? key, required this.jobs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F5FF),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 140,
                  child: Text(
                    'Job no.',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFFB1B5C9),
                    ),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: Text(
                    'Client Name',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFFB1B5C9),
                    ),
                  ),
                ),
                SizedBox(
                  width: 160,
                  child: Text(
                    'Approved Date',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFFB1B5C9),
                    ),
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: Text(
                    'STATUS',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFFB1B5C9),
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEDECF7)),
          // Table Body
          Expanded(
            child: ListView.separated(
              itemCount: jobs.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: Color(0xFFEDECF7)),
              itemBuilder: (context, index) {
                final job = jobs[index];
                return Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Row(
                    children: [
                      // Job Number Column
                      SizedBox(
                        width: 140,
                        child: Text(
                          job.jobNo,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: Color(0xFF232B3E),
                          ),
                        ),
                      ),
                      // Client Name Column
                      SizedBox(
                        width: 200,
                        child: Text(
                          job.clientName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: Color(0xFF232B3E),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Approved Date Column
                      SizedBox(
                        width: 160,
                        child: Text(
                          '${job.submittedAt.day.toString().padLeft(2, '0')}/${job.submittedAt.month.toString().padLeft(2, '0')}/${job.submittedAt.year}\n'
                          '${job.submittedAt.hour.toString().padLeft(2, '0')}:${job.submittedAt.minute.toString().padLeft(2, '0')} ${job.submittedAt.hour >= 12 ? 'PM' : 'AM'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: Color(0xFF232B3E),
                          ),
                        ),
                      ),
                      // Status Column
                      SizedBox(
                        width: 120,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),                          decoration: BoxDecoration(
                            color: _getStatusBgColor(job.status.name),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              _getStatusDisplayText(job.status.name),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: _getStatusTextColor(job.status.name),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),                      // Action Buttons
                      SizedBox(
                        width: 130,
                        height: 36,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF57B9C6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/printing/assignlabour',
                              arguments: job,
                            );
                          },
                          child: const Text(
                            'View print details',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: Color(0xFF888FA6),
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'inprogress':
        return const Color(0xFFF3EFFF);
      case 'completed':
        return const Color(0xFFE6F7EF);
      case 'queued':
        return const Color(0xFFEEF5FF);
      case 'failed':
        return const Color(0xFFFCE6E6);
      case 'onhold':
        return const Color(0xFFFFF8E6);
      case 'review':
        return const Color(0xFFE3F2FD);
      case 'printed':
        return const Color(0xFFE1F5FE);
      default:
        return const Color(0xFFF3EFFF);
    }
  }
  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'inprogress':
        return const Color(0xFF9B6FF7);
      case 'completed':
        return const Color(0xFF1BC47D);
      case 'queued':
        return const Color(0xFF5576BB);
      case 'failed':
        return const Color(0xFFE74C3C);
      case 'onhold':
        return const Color(0xFFF39C12);
      case 'review':
        return const Color(0xFF2196F3);
      case 'printed':
        return const Color(0xFF039BE5);
      default:
        return const Color(0xFF888FA6);
    }
  }
  String _getStatusDisplayText(String status) {
    switch (status.toLowerCase()) {
      case 'inprogress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'queued':
        return 'Queued';
      case 'failed':
        return 'Failed';
      case 'onhold':
        return 'On Hold';
      case 'review':
        return 'Under Review';
      case 'printed':
        return 'Printed';
      default:
        return status;
    }
  }
}
