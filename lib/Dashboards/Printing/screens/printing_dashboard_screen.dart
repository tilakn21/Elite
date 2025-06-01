import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Added Provider
import '../providers/printing_job_provider.dart'; // Added PrintingJobProvider
import '../widgets/printing_sidebar.dart';
import '../widgets/printing_job_table.dart';
import '../models/printing_job.dart';

class PrintingDashboardScreen extends StatefulWidget {
  const PrintingDashboardScreen({Key? key}) : super(key: key);

  @override
  State<PrintingDashboardScreen> createState() => _PrintingDashboardScreenState();
}

class _PrintingDashboardScreenState extends State<PrintingDashboardScreen> {
  String _searchQuery = '';
  @override
  Widget build(BuildContext context) {
    final printingJobProvider = Provider.of<PrintingJobProvider>(context);
    final jobs = printingJobProvider.printingJobs.where((job) {
      final matchesSearch = _searchQuery.isEmpty || 
          job.jobNo.toLowerCase().contains(_searchQuery.toLowerCase()) || 
          job.clientName.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // Sidebar
          const PrintingSidebar(selectedIndex: 0),
          // Main Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar
                const PrintingTopBar(),
                // Header Section with improved design
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(40, 32, 40, 24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFFFFFF),
                        Color(0xFFF8FAFC),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Page Title and Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Print Jobs Dashboard',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 32,
                                  color: Color(0xFF1E293B),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Text(
                                    'Manage approved designs ready for printing',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF059669).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFF059669).withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF059669),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${jobs.length} Active Jobs',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: Color(0xFF059669),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      printingJobProvider.refreshPrintingJobs();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.refresh_rounded,
                                            size: 20,
                                            color: printingJobProvider.isLoading 
                                                ? const Color(0xFF94A3B8) 
                                                : const Color(0xFF57B9C6),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Refresh',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              color: printingJobProvider.isLoading 
                                                  ? const Color(0xFF94A3B8) 
                                                  : const Color(0xFF57B9C6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),                      // Enhanced Search Section
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFF),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: const Color(0xFFE8ECF4),
                                      width: 1,
                                    ),
                                  ),
                                  child: TextField(
                                    onChanged: (query) => setState(() => _searchQuery = query),
                                    decoration: InputDecoration(
                                      prefixIcon: Container(
                                        margin: const EdgeInsets.all(14),
                                        child: const Icon(
                                          Icons.search_rounded,
                                          color: Color(0xFF6B7280),
                                          size: 22,
                                        ),
                                      ),
                                      suffixIcon: _searchQuery.isNotEmpty
                                          ? Container(
                                              margin: const EdgeInsets.all(10),
                                              child: Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  borderRadius: BorderRadius.circular(10),
                                                  onTap: () => setState(() => _searchQuery = ''),
                                                  child: Container(
                                                    padding: const EdgeInsets.all(6),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFE8ECF4),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: const Icon(                                                      Icons.clear_rounded,
                                                      color: Color(0xFF6B7280),
                                                      size: 18,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : null,
                                      border: InputBorder.none,                                      hintText: 'Search by job number, client name, or status...',
                                      hintStyle: const TextStyle(
                                        color: Color(0xFF9CA3AF),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 0.1,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 0),
                                    ),                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF232B3E),
                                      letterSpacing: 0.1,
                                    ),
                                  ),
                                ),
                              ),                              if (_searchQuery.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(left: 16),
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF57B9C6).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFF57B9C6).withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF57B9C6),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${jobs.length} result${jobs.length != 1 ? 's' : ''}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          color: Color(0xFF57B9C6),
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),                // Job Table with enhanced styling
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(40, 24, 40, 40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 25,
                          offset: const Offset(0, 12),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: _buildJobContent(printingJobProvider, jobs),
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

  Widget _buildJobContent(PrintingJobProvider provider, List<PrintingJob> jobs) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Error loading printing jobs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
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
    if (jobs.isEmpty) {
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
    return PrintingJobTable(jobs: jobs);
  }
}

// Add a new widget for the top bar
class PrintingTopBar extends StatelessWidget {
  const PrintingTopBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: [
          const Spacer(),
          // User/logout section
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                },
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              const CircleAvatar(
                backgroundColor: Color(0xFF232B3E),
                child: Text('J', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('John Doe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF232B3E))),
                  Text('Admin', style: TextStyle(fontSize: 12, color: Color(0xFF888FA6))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
