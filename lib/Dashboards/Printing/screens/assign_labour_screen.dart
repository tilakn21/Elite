import 'package:flutter/material.dart';
import '../widgets/printing_sidebar.dart';
import '../widgets/printing_top_bar.dart';
import '../models/printing_job.dart';

class PrintingAssignLabourScreen extends StatelessWidget {
  const PrintingAssignLabourScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sample job for demonstration. Replace with actual job data as needed.
    final PrintingJob job = PrintingJob(
      id: '1',
      jobNo: '#1001',
      title: 'Custom the cabinetry',
      clientName: 'Jim Gorge',
      submittedAt: DateTime(2024, 4, 24),
      status: PrintingStatus.inProgress,
      specifications: const [],
      assignedPrinter: 'Printer 1',
      copies: 1,
      progress: 0.5,
      notes: '+123 456-7890', // Use notes for phone number for demo
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FF),
      body: Row(
        children: [
          // Sidebar
          const PrintingSidebar(selectedIndex: 1),
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Bar
                const PrintingTopBar(),
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
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Job details',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20)),
                                const SizedBox(height: 24),
                                _jobDetail('Client Name', job.clientName),
                                const SizedBox(height: 16),
                                _jobDetail('Phone no.', job.notes ?? ''),
                                const SizedBox(height: 16),
                                _jobDetail('Worker', job.assignedPrinter),
                                const SizedBox(height: 16),
                                _jobDetail('Job Description', job.title),
                                const SizedBox(height: 16),
                                _jobDetail('Due date',
                                    '${job.submittedAt.day}, ${job.submittedAt.month}, ${job.submittedAt.year}'),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    const Text('Status',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                            color: Color(0xFF888FA6))),
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3EFFF),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        job.status.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                            color: Color(0xFF9B6FF7)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 36),
                        // Right: Design Preview Card
                        Expanded(
                          flex: 6,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('DESIGN PREVIEW',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        letterSpacing: 1)),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD9D9D9),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: CustomPaint(
                                      painter: _PreviewPainter(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF47B3CE),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                    onPressed: () {},
                                    child: const Text('Start printing',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500)),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: const [
                                    Text('Dead line',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                            color: Color(0xFF888FA6))),
                                    SizedBox(width: 12),
                                    Text('30april,2024',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Color(0xFF232B3E))),
                                  ],
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
                fontSize: 16,
                color: Color(0xFF888FA6))),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF232B3E))),
      ],
    );
  }
}

class _PreviewPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB3B3B3)
      ..strokeWidth = 2;
    canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
