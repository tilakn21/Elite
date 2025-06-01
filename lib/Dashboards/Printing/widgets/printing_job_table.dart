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
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFF),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
              border: const Border(
                bottom: BorderSide(color: Color(0xFFE8ECF4), width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Job No.',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      'Client Name',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      'Approved Date',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      'Status',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      'Actions',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEDECF7)),          // Table Body
          Expanded(
            child: jobs.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(64),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFF),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.print_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No printing jobs found',
                          style: TextStyle(
                            color: const Color(0xFF6B7280),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Jobs will appear here once they are submitted for printing',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: jobs.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1, color: Color(0xFFEDECF7)),                    itemBuilder: (context, index) {
                      final job = jobs[index];
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeInOut,                        color: index % 2 == 0 ? Colors.white : const Color(0xFFF8FAFF),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 22),                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            hoverColor: const Color(0xFFF0F7FF).withOpacity(0.6),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/printing/assignlabour',
                                arguments: job,
                              );
                            },                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                            // Job Number Column
                            Expanded(
                              flex: 2,
                              child: Text(
                                job.jobNo,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: Color(0xFF232B3E),
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                            // Client Name Column
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16, right: 8),
                                child: Text(
                                  job.clientName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                    color: Color(0xFF232B3E),
                                    letterSpacing: 0.2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            // Approved Date Column
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16, right: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${job.submittedAt.day.toString().padLeft(2, '0')}/${job.submittedAt.month.toString().padLeft(2, '0')}/${job.submittedAt.year}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Color(0xFF232B3E),
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${job.submittedAt.hour.toString().padLeft(2, '0')}:${job.submittedAt.minute.toString().padLeft(2, '0')} ${job.submittedAt.hour >= 12 ? 'PM' : 'AM'}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        color: Color(0xFF6B7280),
                                        letterSpacing: 0.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Status Column
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16, right: 8),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: _getStatusBgColor(job.status.name),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: _getStatusTextColor(job.status.name).withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      _getStatusDisplayText(job.status.name),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                        color: _getStatusTextColor(job.status.name),
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Actions Column
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF57B9C6),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          minimumSize: const Size(0, 40),
                                        ),
                                        onPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            '/printing/assignlabour',
                                            arguments: job,
                                          );
                                        },
                                        child: const Text(
                                          'View Details',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFF),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: const Color(0xFFE8ECF4),
                                          width: 1,
                                        ),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
                                          color: Color(0xFF6B7280),
                                        ),
                                        padding: const EdgeInsets.all(8),
                                        constraints: const BoxConstraints(
                                          minWidth: 36,
                                          minHeight: 36,
                                        ),
                                        onPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            '/printing/assignlabour',
                                            arguments: job,
                                          );
                                        },
                                      ),
                                    ),
                                  ],                                ),                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'inprogress':
        return const Color(0xFFFEF3E2); // Orange background for In Progress
      case 'completed':
        return const Color(0xFFE6F7EF); // Green background for Completed
      case 'queued':
        return const Color(0xFFE3EAFE); // Blue background for Queued
      case 'failed':
        return const Color(0xFFFFE6E6); // Red background for Failed
      case 'onhold':
        return const Color(0xFFFFF8E6); // Yellow background for On Hold
      case 'review':
        return const Color(0xFFE3F2FD); // Light blue for Under Review
      case 'printed':
        return const Color(0xFFF3E6FF); // Purple background for Printed
      default:
        return const Color(0xFFF3EFFF);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'inprogress':
        return const Color(0xFFF57C00); // Orange text for In Progress
      case 'completed':
        return const Color(0xFF1BC47D); // Green text for Completed
      case 'queued':
        return const Color(0xFF1976D2); // Blue text for Queued
      case 'failed':
        return const Color(0xFFE74C3C); // Red text for Failed
      case 'onhold':
        return const Color(0xFFF39C12); // Yellow text for On Hold
      case 'review':
        return const Color(0xFF2196F3); // Blue text for Under Review
      case 'printed':
        return const Color(0xFF8E24AA); // Purple text for Printed
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
