import 'package:flutter/material.dart';
import '../models/job_request.dart';

class NewJobRequestCard extends StatelessWidget {
  final List<JobRequest> jobRequests;
  const NewJobRequestCard({super.key, required this.jobRequests});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/receptionist/view-all-jobs');
      },
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        color: Colors.white,
        child: Container(
          // constraints: const BoxConstraints.expand(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(32, 28, 32, 28),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Jobs',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Color(0xFF1B2330))),
                  const SizedBox(height: 18),
                  Row(
                    children: const [
                      Expanded(child: _Header('Name')),
                      Expanded(child: _Header('Phone')),
                      Expanded(child: _Header('Status')),
                    ],
                  ),
                  const Divider(
                      height: 18, thickness: 1, color: Color(0xFFF2F2F2)),
                  ...jobRequests.map((job) => _JobRow(job)).toList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  const _Header(this.title);
  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF8A8D9F),
            fontSize: 15));
  }
}

class _JobRow extends StatelessWidget {
  final JobRequest job;
  const _JobRow(this.job);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Expanded(
            child: Row(children: [
              CircleAvatar(
                  backgroundColor: Colors.grey.shade200,
                  child: Icon(Icons.person, color: Colors.grey.shade500)),
              const SizedBox(width: 10),
              Flexible(
                  child: Text(job.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 15))),
            ]),
          ),
          Expanded(
              child: Text(job.phone,
                  style:
                      const TextStyle(fontSize: 14, color: Color(0xFF1B2330)))),
          Expanded(
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: _StatusChip(job.assigned == true ? 'Assigned' : 'Unassigned'))),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip(this.status);
  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'Assigned':
        color = const Color(0xFF7DE2D1);
        break;
      case 'Unassigned':
        color = const Color(0xFFFFAFAF);
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(28),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(status,
          style: TextStyle(
              color: status == 'Assigned' ? const Color(0xFF1B2330) : const Color(0xFFD32F2F), fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }
}
