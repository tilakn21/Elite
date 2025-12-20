import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/production_job.dart';
import '../providers/production_job_provider.dart';
import 'package:provider/provider.dart';

class JobListCard extends StatelessWidget {
  final void Function()? onTap;
  const JobListCard({Key? key, this.onTap}) : super(key: key);
  Widget _buildStatusTag(JobStatus status) {
    Color bgColor;
    Color textColor;
    String label = status.label;

    switch (status) {
      case JobStatus.received:
        bgColor = const Color(0xFFFFF4E5);
        textColor = const Color(0xFFF39C12);
        break;
      case JobStatus.onHold:
        bgColor = const Color(0xFFFFECE9);
        textColor = const Color(0xFFE74C3C);
        break;
      case JobStatus.processedForPrinting:
        bgColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1976D2);
        break;
      case JobStatus.inProgress:
        bgColor = const Color(0xFFE8EAF6);
        textColor = const Color(0xFF5C6BC0);
        break;
      case JobStatus.completed:
        bgColor = const Color(0xFFD5F5E3);
        textColor = const Color(0xFF27AE60);
        break;
      case JobStatus.assignedLabour:
        bgColor = const Color(0xFFE8F5E8);
        textColor = const Color(0xFF2E7D32);
        break;
      case JobStatus.pending:
        bgColor = const Color(0xFFF3EFFF);
        textColor = const Color(0xFF888FA6);
        break;
      case JobStatus.printingCompleted:
        bgColor = const Color(0xFFE1F5FE); // Light blue for printing completed
        textColor = const Color(0xFF039BE5); // Blue accent
        break;
    }return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Production Jobs',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Color(0xFF232B3E),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                IconButton(
                  icon: Icon(Icons.refresh, color: Colors.grey[400]),
                  onPressed: () {
                    context.read<ProductionJobProvider>().fetchProductionJobs();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: Consumer<ProductionJobProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (provider.errorMessage != null) {
                    return Center(child: Text('Error: ${provider.errorMessage}', overflow: TextOverflow.ellipsis));
                  }
                  if (provider.jobs.isEmpty) {
                    return const Center(child: Text('No production jobs available', overflow: TextOverflow.ellipsis));
                  }
                  return Theme(
                    data: Theme.of(context).copyWith(
                      dataTableTheme: DataTableThemeData(
                        columnSpacing: 8,
                        horizontalMargin: 8,
                        headingTextStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF232B3E),
                        ),
                      ),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 400),
                          child: DataTable(
                            headingRowHeight: 40,
                            dataRowHeight: 48,
                            headingRowColor: MaterialStateColor.resolveWith(
                              (states) => const Color(0xFFF5F6FA),
                            ),
                            columns: const [
                              DataColumn(
                                label: Text(
                                  'Job ID',
                                  style: TextStyle(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Due Date',
                                  style: TextStyle(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Status',
                                  style: TextStyle(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                            rows: provider.jobs.map((job) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      '${job.jobNo.padLeft(3, '0')}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      DateFormat('dd/MM/yyyy').format(job.dueDate),
                                      style: const TextStyle(fontSize: 13),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  DataCell(_buildStatusTag(job.computedStatus)),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
