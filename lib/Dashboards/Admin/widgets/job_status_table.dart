import 'package:flutter/material.dart';

class JobStatusTable extends StatelessWidget {
  final List<Map<String, dynamic>> jobs;
  const JobStatusTable({Key? key, required this.jobs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Job status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          const SizedBox(height: 14),
          DataTable(
            columnSpacing: 22,
            headingRowHeight: 34,
            dataRowHeight: 36,
            border: TableBorder(horizontalInside: BorderSide(color: Color(0xFFF1F1F1), width: 1)),
            columns: const [
              DataColumn(label: Text('Job no.', style: TextStyle(fontWeight: FontWeight.w600))),
              DataColumn(label: Text('Job and Client', style: TextStyle(fontWeight: FontWeight.w600))),
              DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.w600))),
              DataColumn(label: Text('View', style: TextStyle(fontWeight: FontWeight.w600))),
              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.w600))),
            ],
            rows: jobs.map((job) {
              return DataRow(cells: [
                DataCell(Text(job['no'], style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(job['title'], style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(job['client'], style: const TextStyle(fontSize: 11, color: Color(0xFFB0B3C7))),
                  ],
                )),
                DataCell(Text(job['date'])),
                DataCell(
                  InkWell(
                    onTap: () {/* TODO: Navigate to job details */},
                    child: Text('view Job', style: TextStyle(color: Color(0xFF1673FF), fontWeight: FontWeight.w600)),
                  ),
                ),
                DataCell(Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: job['status'] == 'Approved' ? const Color(0xFFE8FFF3) : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    job['status'],
                    style: TextStyle(
                      color: job['status'] == 'Approved' ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                )),
              ]);
            }).toList(),
          ),
        ],
      ),
    );
  }
}
