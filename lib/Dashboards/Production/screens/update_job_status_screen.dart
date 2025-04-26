import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/top_bar.dart';
import '../widgets/progress_bar.dart';

class UpdateJobStatusScreen extends StatefulWidget {
  const UpdateJobStatusScreen({Key? key}) : super(key: key);

  @override
  State<UpdateJobStatusScreen> createState() => _UpdateJobStatusScreenState();
}

class _UpdateJobStatusScreenState extends State<UpdateJobStatusScreen> {
  String selectedStatus = 'In progress';
  final List<String> statusOptions = [
    'In progress',
    'Processed for printing',
    'Completed',
    'On hold',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4FF),
      body: Row(
        children: [
          ProductionSidebar(
            selectedIndex: 3,
            onItemTapped: (index) {
              if (index == 0) {
                Navigator.of(context)
                    .pushReplacementNamed('/production/dashboard');
              } else if (index == 1) {
                Navigator.of(context)
                    .pushReplacementNamed('/production/assignlabour');
              } else if (index == 2) {
                Navigator.of(context)
                    .pushReplacementNamed('/production/joblist');
              } else if (index == 3) {
                // Already on Update Job Status
              }
            },
          ),
          Expanded(
            child: Column(
              children: [
                ProductionTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 48, vertical: 32),
                    child: Column(
                      children: [
                        const ProgressBar(),
                        const SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1st Column: Job Details Card
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
                                    const Text('Job Details',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20)),
                                    const SizedBox(height: 24),
                                    _jobDetail('Client Name', 'Jim Gorge'),
                                    const SizedBox(height: 8),
                                    _jobDetail('Phone no.', '+123 456-7890'),
                                    const SizedBox(height: 8),
                                    _jobDetail(
                                        'Address', 'House no. 12 ,chicago'),
                                    const SizedBox(height: 8),
                                    _jobDetail('Job description',
                                        'Custom the cabinetry'),
                                    const SizedBox(height: 8),
                                    _jobDetail(
                                        'Assigned date', '24,april,2024'),
                                    const SizedBox(height: 8),
                                    _jobDetail(
                                        'Current status', selectedStatus),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 36),
                            // 2nd Column: Feedback (row 1) and Update Status (row 2)
                            Expanded(
                              flex: 7,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Feedback Card
                                  Container(
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('Feedback',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20)),
                                        const SizedBox(height: 16),
                                        TextField(
                                          maxLines: 5,
                                          decoration: InputDecoration(
                                            hintText: 'Enter your feedback...',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                  color: Colors.grey),
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 10),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF57B9C6),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                            ),
                                            onPressed: () {
                                              // Submit feedback logic here
                                            },
                                            child: const Text('Submit Feedback',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 36),
                                  // Update Status Card
                                  Container(
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('Update Status',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20)),
                                        const SizedBox(height: 24),
                                        ...statusOptions
                                            .map((status) =>
                                                _statusOption(status))
                                            .toList(),
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
                                                        BorderRadius.circular(
                                                            8)),
                                              ),
                                              onPressed: () {
                                                // Save status logic here
                                              },
                                              child: const Text('Update',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w600)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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

  Widget _statusOption(String status) {
    return CheckboxListTile(
      value: selectedStatus == status,
      onChanged: (checked) {
        setState(() {
          selectedStatus = status;
        });
      },
      title: Text(status,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: const Color(0xFF57B9C6),
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
    );
  }
}
