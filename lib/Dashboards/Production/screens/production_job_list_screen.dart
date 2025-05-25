import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/top_bar.dart';
import '../models/production_job.dart';
import '../models/worker.dart';

class ProductionJobListScreen extends StatelessWidget {
  const ProductionJobListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4FF),
      body: Row(
        children: [
          ProductionSidebar(
            selectedIndex: 2,
            onItemTapped: (index) {
              if (index == 0) {
                Navigator.of(context)
                    .pushReplacementNamed('/production/dashboard');
              } else if (index == 1) {
                Navigator.of(context)
                    .pushReplacementNamed('/production/assignlabour');
              } else if (index == 2) {
                // Already on Job List
              } else if (index == 3) {
                Navigator.of(context)
                    .pushReplacementNamed('/production/updatejobstatus');
              }
            },
          ),
          Expanded(
            child: Column(
              children: [
                ProductionTopBar(),
                Expanded(
                  child: SafeArea(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            const Text('Job list',
                                style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF232B3E))),
                            const SizedBox(height: 20),
                            _CompletedListRow(),
                            const SizedBox(height: 24),
                            _JobDataTable(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletedCard extends StatelessWidget {
  final Worker worker;
  final String date;
  const _CompletedCard({required this.worker, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundImage: NetworkImage(worker.image), radius: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(worker.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text(worker.role,
                    style:
                        const TextStyle(fontSize: 13, color: Colors.black54)),
                if (date.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text('Date',
                      style: TextStyle(fontSize: 12, color: Colors.black45)),
                  Text(date,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 14)),
                ],
              ],
            ),
          ),
          if (date.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFD5F5E3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Completed',
                  style: TextStyle(
                      color: Color(0xFF27AE60),
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ),
        ],
      ),
    );
  }
}

class _CompletedListRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _CompletedCard(
                worker: Worker(
                    name: 'Brooklyn Simmons',
                    role: 'Dermatologists',
                    image: 'https://randomuser.me/api/portraits/men/1.jpg'),
                date: '21/12/2022')),
        const SizedBox(width: 16),
        Expanded(
            child: _CompletedCard(
                worker: Worker(
                    name: 'Kristin Watson',
                    role: 'Infectious disease',
                    image: 'https://randomuser.me/api/portraits/women/2.jpg'),
                date: '21/12/2022')),
        const SizedBox(width: 16),
        Expanded(
            child: _CompletedCard(
                worker: Worker(
                    name: 'Jacob Jones',
                    role: 'Ophthalmologists',
                    image: 'https://randomuser.me/api/portraits/men/3.jpg'),
                date: '')),
      ],
    );
  }
}

class _JobDataTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FA),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Row(
              children: const [
                Expanded(
                    flex: 2,
                    child: Text('Job no.',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black54))),
                Expanded(
                    flex: 3,
                    child: Text('Client Name',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black54))),
                Expanded(
                    flex: 3,
                    child: Text('Due date',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black54))),
                Expanded(
                    flex: 4,
                    child: Text('Description',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black54))),
                Expanded(
                    flex: 2,
                    child: Text('STATUS',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black54))),
                Expanded(flex: 3, child: SizedBox()),
              ],
            ),
          ),
          ..._jobRows(),
        ],
      ),
    );
  }

  List<Widget> _jobRows() {
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
          clientName: 'Jana Smith',
          dueDate: '23/12/2022\n12:40 PM',
          description: 'Window installation',
          status: JobStatus.inProgress,
          action: 'Assign labour'),
      ProductionJob(
          jobNo: '#1003',
          clientName: 'Ace Crop',
          dueDate: '22/12/2022\n05:30 PM',
          description: 'Office renovation',
          status: JobStatus.completed,
          action: 'Update status'),
      ProductionJob(
          jobNo: '#1004',
          clientName: 'Bob Jhonison',
          dueDate: '21/12/2022\n10:20 PM',
          description: 'kitchen remodel',
          status: JobStatus.pending,
          action: 'View job details'),
      ProductionJob(
          jobNo: '#1005',
          clientName: 'Broklin Fin',
          dueDate: '24/12/2022\n03:00 PM',
          description: 'Window installation',
          status: JobStatus.inProgress,
          action: 'Assign labour'),
      ProductionJob(
          jobNo: '#1006',
          clientName: 'Jhon Duow',
          dueDate: '23/12/2022\n10:40 PM',
          description: 'Window installation',
          status: JobStatus.inProgress,
          action: 'Assign labour'),
      ProductionJob(
          jobNo: '#1007',
          clientName: 'Sana Jin',
          dueDate: '22/12/2022\n05:30 PM',
          description: 'Window installation',
          status: JobStatus.inProgress,
          action: 'Assign labour'),
      ProductionJob(
          jobNo: '#1008',
          clientName: 'Fin otis',
          dueDate: '21/12/2022\n10:20 PM',
          description: 'Window installation',
          status: JobStatus.pending,
          action: 'Assign labour'),
    ];
    return jobs.map((job) {
      Color statusColor;
      Color statusBg;
      switch (job.status) {
        case JobStatus.completed:
          statusColor = const Color(0xFF27AE60);
          statusBg = const Color(0xFFD5F5E3);
          break;
        case JobStatus.pending:
          statusColor = const Color(0xFFF39C12);
          statusBg = const Color(0xFFFFF4E5);
          break;
        default:
          statusColor = const Color(0xFF5C6BC0);
          statusBg = const Color(0xFFE8EAF6);
      }
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: const BoxDecoration(
          border:
              Border(bottom: BorderSide(color: Color(0xFFF0F1F6), width: 1)),
        ),
        child: Row(
          children: [
            Expanded(
                flex: 2,
                child: Text(job.jobNo, style: const TextStyle(fontSize: 15))),
            Expanded(
                flex: 3,
                child:
                    Text(job.clientName, style: const TextStyle(fontSize: 15))),
            Expanded(
                flex: 3,
                child: Text(job.dueDate.replaceAll('\\n', '\n'),
                    style: const TextStyle(fontSize: 15))),
            Expanded(
                flex: 4,
                child: Text(job.description,
                    style: const TextStyle(fontSize: 15))),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(job.status.label,
                      style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: job.action == 'Update status'
                          ? const Color(0xFFD5F5E3)
                          : job.action == 'View job details'
                              ? const Color(0xFFFFF4E5)
                              : const Color(0xFF26A6A2),
                      foregroundColor: job.action == 'Update status'
                          ? const Color(0xFF27AE60)
                          : job.action == 'View job details'
                              ? const Color(0xFFF39C12)
                              : Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                    ),
                    child: Text(job.action,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_forward_ios_rounded,
                        size: 20, color: Color(0xFFBFC9D9)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
