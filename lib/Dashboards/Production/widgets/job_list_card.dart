import 'package:flutter/material.dart';
import '../models/production_job.dart';

class JobListCard extends StatelessWidget {
  final void Function()? onTap;
  const JobListCard({Key? key, this.onTap}) : super(key: key);

  DataRow _buildJobRow(ProductionJob job, Color color) {
    return DataRow(
      cells: [
        DataCell(Text(job.clientName)),
        DataCell(Text(job.dueDate.replaceAll('\\n', '\n'))),
        DataCell(Text(job.description,
            style: const TextStyle(fontWeight: FontWeight.w600))),
        DataCell(Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withAlpha(31),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(job.status.label,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 13)),
        )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final jobs = [
      ProductionJob(
          jobNo: '#1001',
          clientName: 'Jhon Due',
          dueDate: '24/12/2022\n03:00 PM',
          description: 'Window installation',
          status: JobStatus.inProgress,
          action: 'Assign labour'),
      ProductionJob(
          jobNo: '#1002',
          clientName: 'Jhon Due',
          dueDate: '24/12/2022\n03:00 PM',
          description: 'Window installation',
          status: JobStatus.pending,
          action: 'Assign labour'),
      ProductionJob(
          jobNo: '#1003',
          clientName: 'Jhon Due',
          dueDate: '24/12/2022\n03:00 PM',
          description: 'Window installation',
          status: JobStatus.inProgress,
          action: 'Assign labour'),
      ProductionJob(
          jobNo: '#1004',
          clientName: 'Jhon Due',
          dueDate: '24/12/2022\n03:00 PM',
          description: 'Window installation',
          status: JobStatus.inProgress,
          action: 'Assign labour'),
      ProductionJob(
          jobNo: '#1005',
          clientName: 'Jhon Due',
          dueDate: '24/12/2022\n03:00 PM',
          description: 'Window installation',
          status: JobStatus.inProgress,
          action: 'Assign labour'),
    ];
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Job List',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Icon(Icons.more_horiz, color: Colors.grey[400]),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return ConstrainedBox(
                        constraints: BoxConstraints(
                            minWidth: constraints.maxWidth,
                            maxWidth: constraints.maxWidth),
                        child: DataTable(
                          columnSpacing: 32,
                          horizontalMargin: 12,
                          columns: const [
                            DataColumn(label: Text('Name')),
                            DataColumn(label: Text('Due Date')),
                            DataColumn(label: Text('Description')),
                            DataColumn(label: Text('Status')),
                          ],
                          rows: jobs.map((job) {
                            Color color = job.status == JobStatus.pending
                                ? Colors.orange
                                : Colors.blue;
                            return _buildJobRow(job, color);
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
