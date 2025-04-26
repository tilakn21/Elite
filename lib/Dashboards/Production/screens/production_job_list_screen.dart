import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/top_bar.dart';

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
                Navigator.of(context).pushReplacementNamed('/production/dashboard');
              } else if (index == 1) {
                Navigator.of(context).pushReplacementNamed('/production/assignlabour');
              } else if (index == 2) {
                // Already on Job List
              } else if (index == 3) {
                Navigator.of(context).pushReplacementNamed('/production/updatejobstatus');
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
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            const Text('Job list', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF232B3E))),
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

class _CompletedListRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _CompletedCard(name: 'Brooklyn Simmons', role: 'Dermatologists', date: '21/12/2022', image: 'https://randomuser.me/api/portraits/men/1.jpg')),
        const SizedBox(width: 16),
        Expanded(child: _CompletedCard(name: 'Kristin Watson', role: 'Infectious disease', date: '21/12/2022', image: 'https://randomuser.me/api/portraits/women/2.jpg')),
        const SizedBox(width: 16),
        Expanded(child: _CompletedCard(name: 'Jacob Jones', role: 'Ophthalmologists', date: '', image: 'https://randomuser.me/api/portraits/men/3.jpg')),
      ],
    );
  }
}

class _CompletedCard extends StatelessWidget {
  final String name;
  final String role;
  final String date;
  final String image;
  const _CompletedCard({required this.name, required this.role, required this.date, required this.image});

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
          CircleAvatar(backgroundImage: NetworkImage(image), radius: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(role, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                if (date.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text('Date', style: TextStyle(fontSize: 12, color: Colors.black45)),
                  Text(date, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
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
              child: const Text('Completed', style: TextStyle(color: Color(0xFF27AE60), fontWeight: FontWeight.bold, fontSize: 13)),
            ),
        ],
      ),
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
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Row(
              children: const [
                Expanded(flex: 2, child: Text('Job no.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54))),
                Expanded(flex: 3, child: Text('Client Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54))),
                Expanded(flex: 3, child: Text('Due date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54))),
                Expanded(flex: 4, child: Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54))),
                Expanded(flex: 2, child: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54))),
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
      {'no': '#1001', 'name': 'Jhon Due', 'date': '24/12/2022\n03:00 PM', 'desc': 'Window installation', 'status': 'In progress', 'action': 'Assign labour'},
      {'no': '#1002', 'name': 'Jana Smith', 'date': '23/12/2022\n12:40 PM', 'desc': 'Window installation', 'status': 'In progress', 'action': 'Assign labour'},
      {'no': '#1003', 'name': 'Ace Crop', 'date': '22/12/2022\n05:30 PM', 'desc': 'Office renovation', 'status': 'Completed', 'action': 'Update status'},
      {'no': '#1004', 'name': 'Bob Jhonison', 'date': '21/12/2022\n10:20 PM', 'desc': 'kitchen remodel', 'status': 'Pending', 'action': 'View job details'},
      {'no': '#1005', 'name': 'Broklin Fin', 'date': '24/12/2022\n03:00 PM', 'desc': 'Window installation', 'status': 'In progress', 'action': 'Assign labour'},
      {'no': '#1006', 'name': 'Jhon Duow', 'date': '23/12/2022\n10:40 PM', 'desc': 'Window installation', 'status': 'In progress', 'action': 'Assign labour'},
      {'no': '#1007', 'name': 'Sana Jin', 'date': '22/12/2022\n05:30 PM', 'desc': 'Window installation', 'status': 'In progress', 'action': 'Assign labour'},
      {'no': '#1008', 'name': 'Fin otis', 'date': '21/12/2022\n10:20 PM', 'desc': 'Window installation', 'status': 'Pending', 'action': 'Assign labour'},
    ];
    return jobs.map((job) {
      Color statusColor;
      Color statusBg;
      String status = job['status']!;
      if (status == 'Completed') {
        statusColor = const Color(0xFF27AE60);
        statusBg = const Color(0xFFD5F5E3);
      } else if (status == 'Pending') {
        statusColor = const Color(0xFFF39C12);
        statusBg = const Color(0xFFFFF4E5);
      } else {
        statusColor = const Color(0xFF5C6BC0);
        statusBg = const Color(0xFFE8EAF6);
      }
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF0F1F6), width: 1)),
        ),
        child: Row(
          children: [
            Expanded(flex: 2, child: Text(job['no']!, style: const TextStyle(fontSize: 15))),
            Expanded(flex: 3, child: Text(job['name']!, style: const TextStyle(fontSize: 15))),
            Expanded(flex: 3, child: Text(job['date']!.replaceAll('\\n', '\n'), style: const TextStyle(fontSize: 15))),
            Expanded(flex: 4, child: Text(job['desc']!, style: const TextStyle(fontSize: 15))),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13)),
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
                      backgroundColor: job['action'] == 'Update status'
                          ? const Color(0xFFD5F5E3)
                          : job['action'] == 'View job details'
                              ? const Color(0xFFFFF4E5)
                              : const Color(0xFF26A6A2),
                      foregroundColor: job['action'] == 'Update status'
                          ? const Color(0xFF27AE60)
                          : job['action'] == 'View job details'
                              ? const Color(0xFFF39C12)
                              : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    ),
                    child: Text(job['action']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20, color: Color(0xFFBFC9D9)),
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
