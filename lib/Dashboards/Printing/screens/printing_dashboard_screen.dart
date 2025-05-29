import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Added Provider
import '../providers/printing_job_provider.dart'; // Added PrintingJobProvider
import '../widgets/printing_sidebar.dart';
import '../widgets/printing_top_bar.dart';
import '../widgets/printing_job_table.dart';

class PrintingDashboardScreen extends StatelessWidget {
  const PrintingDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final printingJobProvider = Provider.of<PrintingJobProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FF),
      body: Row(
        children: [
          // Sidebar
          const PrintingSidebar(selectedIndex: 0),
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Bar
                const PrintingTopBar(),                // Page Title & Tabs
                Padding(
                  padding: const EdgeInsets.only(left: 40, top: 32, right: 40, bottom: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Print jobs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Color(0xFF232B3E))),
                      ElevatedButton.icon(
                        onPressed: () {
                          printingJobProvider.refreshPrintingJobs();
                        },
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Refresh'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF57B9C6),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                ),
                // Tabs
                Padding(
                  padding: const EdgeInsets.only(left: 40, top: 12, right: 40, bottom: 0),
                  child: Row(
                    children: [
                      _DashboardTab(label: 'Pending', selected: true),
                      const SizedBox(width: 16),
                      _DashboardTab(label: 'Printing', selected: false),
                      const SizedBox(width: 16),
                      _DashboardTab(label: 'Completed', selected: false),
                    ],
                  ),
                ),                // Section Title
                Padding(
                  padding: const EdgeInsets.only(left: 40, top: 32, right: 40, bottom: 0),
                  child: Row(
                    children: [
                      const Text('Jobs with approved designs ready for printing', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Color(0xFF888FA6))),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF57B9C6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Consumer<PrintingJobProvider>(
                          builder: (context, provider, child) {
                            return Text(
                              '${provider.printingJobs.length} jobs',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Color(0xFF57B9C6),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Job Table
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 40, right: 40, top: 16, bottom: 0),
                    child: _buildJobContent(printingJobProvider),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobContent(PrintingJobProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }    if (provider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading printing jobs',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 8),
            Text(
              'Error: ${provider.errorMessage}',
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                provider.refreshPrintingJobs();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF57B9C6),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (provider.printingJobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.print_disabled, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No printing jobs found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Jobs with approved designs will appear here.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                provider.refreshPrintingJobs();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF57B9C6),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }
    return PrintingJobTable(jobs: provider.printingJobs);
  }
}

class _DashboardTab extends StatelessWidget {
  final String label;
  final bool selected;
  const _DashboardTab({required this.label, required this.selected, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF232B3E) : const Color(0xFFEDECF7),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : const Color(0xFF232B3E),
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }
}
