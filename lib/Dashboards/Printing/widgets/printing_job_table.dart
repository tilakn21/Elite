import 'package:flutter/material.dart';

class PrintingJobTable extends StatelessWidget {
  const PrintingJobTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final jobs = [
      {
        'jobNo': '#1001',
        'clientName': 'Jhon Due',
        'approvedDate': '24/12/2022\n03:00 PM',
        'design': 'Logo and Text',
        'status': 'Printing',
      },
      {
        'jobNo': '#1002',
        'clientName': 'Jena Smith',
        'approvedDate': '23/12/2022\n12:40 PM',
        'design': 'promotional graphics',
        'status': 'Printing',
      },
      {
        'jobNo': '#1003',
        'clientName': 'Ace Crop',
        'approvedDate': '22/12/2022\n05:20 PM',
        'design': 'Product Advertisement',
        'status': 'Completed',
      },
      {
        'jobNo': '#1004',
        'clientName': 'Bob Jhonrison',
        'approvedDate': '21/12/2022\n10:40 PM',
        'design': 'Logo and text',
        'status': 'Pending',
      },
      {
        'jobNo': '#1005',
        'clientName': 'Broklin Fin',
        'approvedDate': '24/12/2022\n03:00 PM',
        'design': 'Product Advertisement',
        'status': 'Printing',
      },
      {
        'jobNo': '#1006',
        'clientName': 'Jhon Duow',
        'approvedDate': '23/12/2022\n12:40 PM',
        'design': 'Logo and text',
        'status': 'Printing',
      },
      {
        'jobNo': '#1007',
        'clientName': 'Sana Jin',
        'approvedDate': '22/12/2022\n05:20 PM',
        'design': 'Product Advertisement',
        'status': 'Printing',
      },
      {
        'jobNo': '#1008',
        'clientName': 'Fin otis',
        'approvedDate': '21/12/2022\n10:40 PM',
        'design': 'Logo and text',
        'status': 'Pending',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
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
              children: const [
                _HeaderCell('Job no.', flex: 2),
                _HeaderCell('Client Name', flex: 3),
                _HeaderCell('Approved Date', flex: 3),
                _HeaderCell('Design', flex: 3),
                _HeaderCell('STATUS', flex: 2),
                Spacer(),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEDECF7)),
          Expanded(
            child: ListView.separated(
              itemCount: jobs.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFEDECF7)),
              itemBuilder: (context, index) {
                final job = jobs[index];
                return Container(
                  color: Colors.white,
                  child: Row(
                    children: [
                      _TableCell(job['jobNo']!, flex: 2),
                      _TableCell(job['clientName']!, flex: 3),
                      _TableCell(job['approvedDate']!, flex: 3),
                      _TableCell(job['design']!, flex: 3),
                      _StatusCell(status: job['status']!),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: SizedBox(
                          width: 130,
                          height: 36,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF57B9C6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {},
                            child: const Text('View print details', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, size: 18, color: Color(0xFF888FA6)),
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
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final int flex;
  const _HeaderCell(this.label, {this.flex = 1, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFFB1B5C9)),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String value;
  final int flex;
  const _TableCell(this.value, {this.flex = 1, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 4),
        child: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: Color(0xFF232B3E)),
        ),
      ),
    );
  }
}

class _StatusCell extends StatelessWidget {
  final String status;
  const _StatusCell({required this.status, Key? key}) : super(key: key);

  Color get _bgColor {
    switch (status) {
      case 'Printing':
        return const Color(0xFFEEE6FF);
      case 'Completed':
        return const Color(0xFFE6FFF5);
      case 'Pending':
        return const Color(0xFFFFE6E6);
      default:
        return const Color(0xFFEDECF7);
    }
  }

  Color get _textColor {
    switch (status) {
      case 'Printing':
        return const Color(0xFF9B6FF7);
      case 'Completed':
        return const Color(0xFF1BC47D);
      case 'Pending':
        return const Color(0xFFF57B7B);
      default:
        return const Color(0xFF888FA6);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            status,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: _textColor),
          ),
        ),
      ),
    );
  }
}
