import 'package:flutter/material.dart';
import '../models/printing_job.dart';

class PrintingJobTable extends StatelessWidget {
  const PrintingJobTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final jobs = [
      PrintingJob(
        id: '1',
        jobNo: '#1001',
        title: 'Logo and Text',
        clientName: 'Jhon Due',
        submittedAt: DateTime(2022, 12, 24, 15, 0),
        status: PrintingStatus.inProgress,
        specifications: const [],
        assignedPrinter: 'Printer 1',
        copies: 1,
        progress: 0.5,
      ),
      PrintingJob(
        id: '2',
        jobNo: '#1002',
        title: 'Promotional Graphics',
        clientName: 'Jena Smith',
        submittedAt: DateTime(2022, 12, 23, 12, 40),
        status: PrintingStatus.inProgress,
        specifications: const [],
        assignedPrinter: 'Printer 2',
        copies: 1,
        progress: 0.3,
      ),
      PrintingJob(
        id: '3',
        jobNo: '#1003',
        title: 'Product Advertisement',
        clientName: 'Ace Crop',
        submittedAt: DateTime(2022, 12, 22, 17, 20),
        status: PrintingStatus.completed,
        specifications: const [],
        assignedPrinter: 'Printer 1',
        copies: 1,
        progress: 1.0,
      ),
      PrintingJob(
        id: '4',
        jobNo: '#1004',
        title: 'Logo and Text',
        clientName: 'Bob Jhonrison',
        submittedAt: DateTime(2022, 12, 21, 22, 40),
        status: PrintingStatus.queued,
        specifications: const [],
        assignedPrinter: 'Printer 3',
        copies: 1,
        progress: 0.0,
      ),
      PrintingJob(
        id: '5',
        jobNo: '#1005',
        title: 'Product Advertisement',
        clientName: 'Broklin Fin',
        submittedAt: DateTime(2022, 12, 24, 15, 0),
        status: PrintingStatus.inProgress,
        specifications: const [],
        assignedPrinter: 'Printer 2',
        copies: 1,
        progress: 0.6,
      ),
      PrintingJob(
        id: '6',
        jobNo: '#1006',
        title: 'Logo and text',
        clientName: 'Jhon Duow',
        submittedAt: DateTime(2022, 12, 23, 12, 40),
        status: PrintingStatus.inProgress,
        specifications: const [],
        assignedPrinter: 'Printer 1',
        copies: 1,
        progress: 0.4,
      ),
      PrintingJob(
        id: '7',
        jobNo: '#1007',
        title: 'Product Advertisement',
        clientName: 'Sana Jin',
        submittedAt: DateTime(2022, 12, 22, 17, 20),
        status: PrintingStatus.inProgress,
        specifications: const [],
        assignedPrinter: 'Printer 3',
        copies: 2,
        progress: 0.8,
      ),
      PrintingJob(
        id: '8',
        jobNo: '#1008',
        title: 'Logo and text',
        clientName: 'Fin otis',
        submittedAt: DateTime(2022, 12, 21, 22, 40),
        status: PrintingStatus.queued,
        specifications: const [],
        assignedPrinter: 'Printer 2',
        copies: 3,
        progress: 0.1,
      ),
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
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: Color(0xFFEDECF7)),
              itemBuilder: (context, index) {
                final job = jobs[index];
                return Container(
                  color: Colors.white,
                  child: Row(
                    children: [
                      _TableCell(job.jobNo, flex: 2),
                      _TableCell(job.clientName, flex: 3),
                      _TableCell(
                        '${job.submittedAt.day}/${job.submittedAt.month}/${job.submittedAt.year}\n'
                        '${job.submittedAt.hour}:${job.submittedAt.minute} ${job.submittedAt.hour >= 12 ? 'PM' : 'AM'}',
                        flex: 3,
                      ),
                      _TableCell(job.title, flex: 3),
                      _StatusCell(status: job.status.name),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: SizedBox(
                          width: 130,
                          height: 36,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF57B9C6),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {},
                            child: const Text('View print details',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14)),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios,
                            size: 18, color: Color(0xFF888FA6)),
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
        style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFFB1B5C9)),
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
          style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
              color: Color(0xFF232B3E)),
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
      case 'inProgress':
        return const Color(0xFFEEE6FF);
      case 'completed':
        return const Color(0xFFE6FFF5);
      case 'pending':
        return const Color(0xFFFFE6E6);
      default:
        return const Color(0xFFEDECF7);
    }
  }

  Color get _textColor {
    switch (status) {
      case 'inProgress':
        return const Color(0xFF9B6FF7);
      case 'completed':
        return const Color(0xFF1BC47D);
      case 'pending':
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
            style: TextStyle(
                fontWeight: FontWeight.w600, fontSize: 13, color: _textColor),
          ),
        ),
      ),
    );
  }
}
