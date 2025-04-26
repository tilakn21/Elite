import 'package:flutter/material.dart';
import '../widgets/printing_sidebar.dart';
import '../widgets/printing_top_bar.dart';

class PrintingAssignLabourScreen extends StatelessWidget {
  const PrintingAssignLabourScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
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
                                const Text('Job details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                const SizedBox(height: 24),
                                _jobDetail('Client Name', 'Jim Gorge'),
                                const SizedBox(height: 16),
                                _jobDetail('Phone no.', '+123 456-7890'),
                                const SizedBox(height: 16),
                                _jobDetail('Worker', 'Alice-jhonson'),
                                const SizedBox(height: 16),
                                _jobDetail('job discription', 'Custom the cabinetry'),
                                const SizedBox(height: 16),
                                _jobDetail('Due date', '24,april,2024'),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    const Text('Status', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Color(0xFF888FA6))),
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3EFFF),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text('Printing', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF9B6FF7))),
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
                                const Text('DESIGN PREVIEW', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
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
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () {},
                                    child: const Text('Start printing', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: const [
                                    Text('Dead line', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Color(0xFF888FA6))),
                                    SizedBox(width: 12),
                                    Text('30april,2024', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF232B3E))),
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
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Color(0xFF888FA6))),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF232B3E))),
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
