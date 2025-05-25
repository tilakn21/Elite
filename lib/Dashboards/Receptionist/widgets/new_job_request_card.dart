import 'package:flutter/material.dart';

class NewJobRequestCard extends StatelessWidget {
  const NewJobRequestCard({super.key});

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
                  const Text('New Job Request',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Color(0xFF1B2330))),
                  const SizedBox(height: 18),
                  Row(
                    children: const [
                      Expanded(child: _Header('Name')),
                      Expanded(child: _Header('Phone')),
                      Expanded(child: _Header('Email')),
                      Expanded(child: _Header('Status')),
                    ],
                  ),
                  const Divider(
                      height: 18, thickness: 1, color: Color(0xFFF2F2F2)),
                  ..._jobRequests.map((job) => _JobRow(job)).toList(),
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
  final Map<String, dynamic> job;
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
                  child: Text(job['name'],
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 15))),
            ]),
          ),
          Expanded(
              child: Text(job['phone'],
                  style:
                      const TextStyle(fontSize: 14, color: Color(0xFF1B2330)))),
          Expanded(
              child: Text(job['email'],
                  style:
                      const TextStyle(fontSize: 14, color: Color(0xFF1B2330)),
                  overflow: TextOverflow.ellipsis)),
          Expanded(
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: _StatusChip(job['status']))),
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
      case 'Approved':
        color = const Color(0xFF4CAF50);
        break;
      case 'Declined':
        color = const Color(0xFFF44336);
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
              color: color, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }
}

const List<Map<String, dynamic>> _jobRequests = [
  {
    'name': 'Jane Cooper',
    'phone': '(225) 555-0118',
    'email': 'jane@microsoft.com',
    'status': 'Approved',
  },
  {
    'name': 'Floyd Miles',
    'phone': '(205) 555-0100',
    'email': 'floyd@yahoo.com',
    'status': 'Declined',
  },
  {
    'name': 'Ronald Richards',
    'phone': '(302) 555-0107',
    'email': 'ronald@adobex.com',
    'status': 'Approved',
  },
  {
    'name': 'Marvin McKinney',
    'phone': '(252) 555-0028',
    'email': 'marvin@tesla.com',
    'status': 'Approved',
  },
];
