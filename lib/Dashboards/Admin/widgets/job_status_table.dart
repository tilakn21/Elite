import 'package:flutter/material.dart';
import '../models/admin_job.dart';
import '../screens/job_listing_screen_new.dart';

class JobStatusTable extends StatelessWidget {
  final List<AdminJob> jobs;
  const JobStatusTable({Key? key, required this.jobs}) : super(key: key);  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const JobListingScreen(),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1673FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.table_chart_rounded,
                        color: Color(0xFF1673FF),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Job Status Overview',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF101C2C),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: DataTable(
                  columnSpacing: 24,
                  headingRowHeight: 48,
                  dataRowHeight: 56,
                  headingRowColor: MaterialStateColor.resolveWith(
                    (states) => Colors.grey.shade50,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  border: TableBorder.all(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  columns: const [
                    DataColumn(
                      label: Text(
                        'Job No.',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Job & Client',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Date',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Action',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Status',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                  rows: jobs.map((job) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1673FF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              job.no,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Color(0xFF1673FF),
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                job.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Color(0xFF101C2C),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                job.client,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        DataCell(
                          Text(
                            job.date,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ),
                        DataCell(
                          InkWell(
                            onTap: () {/* TODO: Navigate to job details */},
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Text(
                                'View Job',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: job.status == 'Approved' 
                                  ? Colors.green.shade50 
                                  : Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: job.status == 'Approved' 
                                    ? Colors.green.shade200 
                                    : Colors.orange.shade200,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  job.status == 'Approved' 
                                      ? Icons.check_circle_rounded 
                                      : Icons.schedule_rounded,
                                  size: 12,
                                  color: job.status == 'Approved' 
                                      ? Colors.green.shade600 
                                      : Colors.orange.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  job.status,
                                  style: TextStyle(
                                    color: job.status == 'Approved' 
                                        ? Colors.green.shade700 
                                        : Colors.orange.shade700,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
