import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/top_bar.dart';

class AssignLabourScreen extends StatelessWidget {
  const AssignLabourScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4FF),
      body: Row(
        children: [
          ProductionSidebar(
            selectedIndex: 1,
            onItemTapped: (index) {
              if (index == 0) {
                Navigator.of(context)
                    .pushReplacementNamed('/production/dashboard');
              } else if (index == 1) {
                // Already on Assign Labour
              } else if (index == 2) {
                Navigator.of(context)
                    .pushReplacementNamed('/production/joblist');
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 48, vertical: 32),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left: Job Details Card
                        Expanded(
                          flex: 5,
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(8),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Job details',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20)),
                                const SizedBox(height: 24),
                                _jobDetail('Client Name', 'Jim Gorge'),
                                const SizedBox(height: 8),
                                _jobDetail('Phone no.', '+123 456-7890'),
                                const SizedBox(height: 8),
                                _jobDetail('Address', 'House no. 12 ,chicago'),
                                const SizedBox(height: 8),
                                _jobDetail(
                                    'job discription', 'Custom the cabinetry'),
                                const SizedBox(height: 8),
                                _jobDetail('Assigned date', '24,april,2024'),
                                const SizedBox(height: 8),
                                const Text('Status',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        color: Color(0xFF232B3E))),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(6),
                                    color: Colors.white,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Text('In progress',
                                          style: TextStyle(fontSize: 15)),
                                      Icon(Icons.arrow_drop_down, size: 22),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 36),
                        // Right: Assign Worker Card
                        Expanded(
                          flex: 7,
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(8),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Assign worker',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20)),
                                const SizedBox(height: 24),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF7F4FF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: 'Cutting',
                                      items: const [
                                        DropdownMenuItem(
                                            value: 'Cutting',
                                            child: Text('Cutting')),
                                        DropdownMenuItem(
                                            value: 'Assembly',
                                            child: Text('Assembly')),
                                        DropdownMenuItem(
                                            value: 'Finishing',
                                            child: Text('Finishing')),
                                      ],
                                      onChanged: (value) {},
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Expanded(
                                  child: ListView(
                                    children: [
                                      _workerTile(
                                          'Cody Fisher', 'Available', false),
                                      _workerTile('Jacob Jones', 'Busy', false),
                                      _workerTile('Brooklyn Simmons',
                                          'Available', false),
                                      _workerTile('Brooklyn Simmons',
                                          'Available', false),
                                      _workerTile(
                                          'Brooklyn Simmons', 'Busy', false),
                                      _workerTile(
                                          'Kristin Watson', 'Busy', false),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF57B9C6),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                      onPressed: () {},
                                      child: const Text('Assign',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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

  Widget _jobDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Color(0xFF232B3E))),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      ],
    );
  }

  Widget _workerTile(String name, String status, bool selected) {
    Color statusColor =
        status == 'Available' ? const Color(0xFF57B9C6) : Colors.grey;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Checkbox(value: selected, onChanged: (_) {}),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15)),
              Text(status, style: TextStyle(fontSize: 12, color: statusColor)),
            ],
          ),
        ],
      ),
    );
  }
}
