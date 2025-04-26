import 'package:flutter/material.dart';

class JobListCard extends StatelessWidget {
  final void Function()? onTap;
  const JobListCard({Key? key, this.onTap}) : super(key: key);

  DataRow _buildJobRow(String name, String dueDate, String desc, String status, Color color) {
    return DataRow(
      cells: [
        DataCell(Text(name)),
        DataCell(Text(dueDate.replaceAll('\\n', '\n'))),
        DataCell(Text(desc, style: const TextStyle(fontWeight: FontWeight.w600))),
        DataCell(Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
        )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
                const Text('Job List', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                        constraints: BoxConstraints(minWidth: constraints.maxWidth, maxWidth: constraints.maxWidth),
                        child: DataTable(
                          columnSpacing: 32,
                          horizontalMargin: 12,
                          columns: const [
                            DataColumn(label: Text('Name')),
                            DataColumn(label: Text('Due Date')),
                            DataColumn(label: Text('Description')),
                            DataColumn(label: Text('Status')),
                          ],
                          rows: [
                            _buildJobRow('Jhon Due', '24/12/2022\n03:00 PM', 'Window installation', 'In progress', Colors.blue),
                            _buildJobRow('Jhon Due', '24/12/2022\n03:00 PM', 'Window installation', 'Pending', Colors.orange),
                            _buildJobRow('Jhon Due', '24/12/2022\n03:00 PM', 'Window installation', 'In progress', Colors.blue),
                            _buildJobRow('Jhon Due', '24/12/2022\n03:00 PM', 'Window installation', 'In progress', Colors.blue),
                            _buildJobRow('Jhon Due', '24/12/2022\n03:00 PM', 'Window installation', 'In progress', Colors.blue),
                            _buildJobRow('Jhon Due', '24/12/2022\n03:00 PM', 'Window installation', 'In progress', Colors.blue),
                            _buildJobRow('Jhon Due', '24/12/2022\n03:00 PM', 'Window installation', 'In progress', Colors.blue),
                          ],
                          headingRowColor: MaterialStateProperty.all(Colors.white),
                          dataRowColor: MaterialStateProperty.all(Colors.white),
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
