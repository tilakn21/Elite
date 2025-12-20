import 'package:flutter/material.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/admin_top_bar.dart';
import '../services/admin_service.dart';
import '../models/admin_job.dart';

class JobListingScreen extends StatefulWidget {
  const JobListingScreen({Key? key}) : super(key: key);

  @override
  State<JobListingScreen> createState() => _JobListingScreenState();
}

class _JobListingScreenState extends State<JobListingScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String selectedStatus = 'All';
  late Future<List<AdminJob>> _jobsFuture;
  final AdminService _adminService = AdminService();
  
  // Search and filter controllers
  final TextEditingController _searchController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';
  
  // Keep track of the sidebar index as a class property
  int sidebarIndex = 3; // Jobs is index 3 in the sidebar

  @override
  void initState() {
    super.initState();
    _refreshJobs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refreshJobs() {
    setState(() {
      _jobsFuture = _adminService.getAdminJobs();
    });
  }

  List<AdminJob> _filterJobs(List<AdminJob> jobs) {
    return jobs.where((job) {
      // Status filter
      bool statusMatch = selectedStatus == 'All' || job.status == selectedStatus;
      
      // Search filter
      bool searchMatch = _searchQuery.isEmpty ||
          job.no.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          job.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          job.client.toLowerCase().contains(_searchQuery.toLowerCase());
      
      // Date filter
      bool dateMatch = true;
      if (_startDate != null || _endDate != null) {
        try {
          DateTime jobDate = DateTime.parse(job.date);
          if (_startDate != null && jobDate.isBefore(_startDate!)) {
            dateMatch = false;
          }
          if (_endDate != null && jobDate.isAfter(_endDate!.add(Duration(days: 1)))) {
            dateMatch = false;
          }
        } catch (e) {
          dateMatch = true; // If date parsing fails, include the job
        }
      }
      
      return statusMatch && searchMatch && dateMatch;
    }).toList();
  }

  void _showDateRangePicker() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 365)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }
  void _clearDateFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
  }
  
  // Handle navigation based on the sidebar index
  void _handleNavigation(int index) {
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/admin/dashboard');
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/admin/employees');
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/admin/assign-salesperson');
    } else if (index == 3) {
      // We're already on the Jobs screen, no need to navigate
      // Navigator.pushReplacementNamed(context, '/admin/jobs');
    } else if (index == 4) {
      Navigator.pushReplacementNamed(context, '/admin/calendar');    } else if (index == 5) {
      Navigator.pushReplacementNamed(context, '/admin/reimbursements');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;
    
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFF7F5FF),
      drawer: isMobile
          ? Drawer(
              child: AdminSidebar(
                selectedIndex: sidebarIndex,
                onItemTapped: (idx) {
                  setState(() {
                    sidebarIndex = idx;
                  });
                  Navigator.of(context).pop(); // Close the drawer
                  
                  // Handle navigation here
                  _handleNavigation(idx);
                },
              ),
            )
          : null,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMobile)
              AdminSidebar(
                selectedIndex: sidebarIndex,
                onItemTapped: (index) {
                  setState(() {
                    sidebarIndex = index;
                  });
                  
                  // Handle navigation
                  _handleNavigation(index);
                },
              ),
            Expanded(
              child: Column(
                children: [
                  const AdminTopBar(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 28.0, right: 28.0, top: 20.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const Icon(Icons.arrow_back, color: Color(0xFF232B3E)),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Job Management',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28,
                                    color: Color(0xFF232B3E),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 22),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Search and filters row
                                  Row(
                                    children: [
                                      // Search field
                                      Expanded(
                                        flex: 2,
                                        child: TextField(
                                          controller: _searchController,
                                          decoration: InputDecoration(
                                            hintText: 'Search jobs by ID, title, or client...',
                                            prefixIcon: const Icon(Icons.search, size: 20),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: BorderSide(color: Colors.grey[300]!),
                                            ),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              _searchQuery = value;
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Date range filter
                                      ElevatedButton.icon(
                                        onPressed: _showDateRangePicker,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _startDate != null ? Colors.blue[50] : Colors.grey[100],
                                          foregroundColor: _startDate != null ? Colors.blue[700] : Colors.grey[700],
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        icon: const Icon(Icons.date_range, size: 18),
                                        label: Text(_startDate != null 
                                            ? '${_startDate!.day}/${_startDate!.month} - ${_endDate!.day}/${_endDate!.month}'
                                            : 'Date Range'),
                                      ),
                                      if (_startDate != null) ...[
                                        const SizedBox(width: 8),
                                        IconButton(
                                          onPressed: _clearDateFilter,
                                          icon: const Icon(Icons.clear, size: 18),
                                          tooltip: 'Clear date filter',
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // Status filter and action buttons row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 200,
                                        child: FutureBuilder<List<AdminJob>>(
                                          future: _jobsFuture,
                                          builder: (context, snapshot) {
                                            final jobs = snapshot.data ?? [];
                                            final statuses = ['All', ...{...jobs.map((e) => e.status)}.toList()..sort()];
                                            return JobStatusFilterDropdown(
                                              statuses: statuses,
                                              selectedStatus: selectedStatus,
                                              onChanged: (status) {
                                                setState(() {
                                                  selectedStatus = status;
                                                });
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          ElevatedButton.icon(
                                            onPressed: _refreshJobs,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.grey[100],
                                              foregroundColor: Colors.grey[700],
                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                            icon: const Icon(Icons.refresh, size: 18),
                                            label: const Text('Refresh'),
                                          ),
                                          const SizedBox(width: 12),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              // TODO: Add export functionality
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF9EE2EA),
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            icon: const Icon(Icons.download, size: 18),
                                            label: const Text('Export'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  FutureBuilder<List<AdminJob>>(
                                    future: _jobsFuture,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(50.0),
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                      } else if (snapshot.hasError) {
                                        return Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(50.0),
                                            child: Column(
                                              children: [
                                                Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                                                const SizedBox(height: 16),
                                                Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red[600])),
                                                const SizedBox(height: 16),
                                                ElevatedButton(
                                                  onPressed: _refreshJobs,
                                                  child: const Text('Retry'),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                        return Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(50.0),
                                            child: Column(
                                              children: [
                                                Icon(Icons.work_off, size: 48, color: Colors.grey[400]),
                                                const SizedBox(height: 16),
                                                Text(
                                                  'No jobs found.',
                                                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                      final jobs = _filterJobs(snapshot.data!);
                                      if (jobs.isEmpty) {
                                        return Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(50.0),
                                            child: Column(
                                              children: [
                                                Icon(Icons.filter_list_off, size: 48, color: Colors.grey[400]),
                                                const SizedBox(height: 16),
                                                Text(
                                                  'No jobs match your filters.',
                                                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                                                ),
                                                const SizedBox(height: 8),
                                                TextButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      selectedStatus = 'All';
                                                      _searchQuery = '';
                                                      _searchController.clear();
                                                      _startDate = null;
                                                      _endDate = null;
                                                    });
                                                  },
                                                  child: const Text('Clear all filters'),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                      return JobListTable(jobs: jobs);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class JobStatusFilterDropdown extends StatelessWidget {
  final List<String> statuses;
  final String selectedStatus;
  final ValueChanged<String> onChanged;

  const JobStatusFilterDropdown({
    Key? key,
    required this.statuses,
    required this.selectedStatus,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('JobStatusFilterDropdown statuses: ' + statuses.toString());
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedStatus,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
          isExpanded: true,
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          onChanged: (String? newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
          items: statuses.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      )
      );
  }
}

class JobListTable extends StatelessWidget {
  final List<AdminJob> jobs;
  const JobListTable({Key? key, required this.jobs}) : super(key: key);  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;    // Calculate table width to fit exactly: Job ID(100) + Title&Client(200) + Date(120) + Status(150) + Progress(120) + Actions(120) + spacing
    final tableWidth = 100.0 + 200.0 + 120.0 + 150.0 + 120.0 + 120.0 + (8.0 * 5); // 810 + 40 = 850px
    final containerWidth = screenWidth > 600 ? screenWidth - 320.0 : screenWidth - 40.0;
    final finalTableWidth = tableWidth > containerWidth ? tableWidth : containerWidth;
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: finalTableWidth,            child: DataTable(
              columnSpacing: 8.0,
              headingRowHeight: 56,
              dataRowHeight: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              headingRowColor: MaterialStateProperty.all(const Color(0xFFF8FAFC)),
              dataRowColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                if (states.contains(MaterialState.hovered)) {
                  return const Color(0xFFF1F5F9);
                }
                return Colors.white;
              }),              columns: [
              DataColumn(
                label: SizedBox(
                  width: 100,
                  child: Text(
                    'Job ID',
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 15, 
                      color: Color(0xFF1E293B),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              DataColumn(
                label: SizedBox(
                  width: 200,
                  child: Text(
                    'Title & Client',
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 15, 
                      color: Color(0xFF1E293B),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              DataColumn(
                label: SizedBox(
                  width: 120,
                  child: Text(
                    'Date Created',
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 15, 
                      color: Color(0xFF1E293B),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              DataColumn(
                label: SizedBox(
                  width: 150,
                  child: Text(
                    'Status',
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 15, 
                      color: Color(0xFF1E293B),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              DataColumn(
                label: SizedBox(
                  width: 120,
                  child: Text(
                    'Progress',
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 15, 
                      color: Color(0xFF1E293B),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              DataColumn(
                label: SizedBox(
                  width: 120,
                  child: Text(
                    'Actions',
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 15, 
                      color: Color(0xFF1E293B),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
            rows: jobs.map((job) {
              return DataRow(                cells: [
                  DataCell(
                    SizedBox(
                      width: 100,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.2)),
                          ),
                          child: Text(
                            job.no,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: Color(0xFF3B82F6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 200,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              job.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              job.client,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 120,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text(
                          job.date,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF475569),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 150,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(job.status).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _getStatusColor(job.status).withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getStatusIcon(job.status),
                                size: 12,
                                color: _getStatusColor(job.status),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  job.status,
                                  style: TextStyle(
                                    color: _getStatusColor(job.status),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 120,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: JobProgressIndicator(job: job),
                      ),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 120,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.blue.shade100),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.visibility, size: 16),
                                onPressed: () {
                                  _showJobDetails(context, job);
                                },
                                tooltip: 'View Details',
                                color: Colors.blue[700],
                                padding: const EdgeInsets.all(6),
                                constraints: const BoxConstraints(minHeight: 32, minWidth: 32),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.orange.shade100),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.edit, size: 16),
                                onPressed: () {
                                  // TODO: Navigate to edit job
                                },
                                tooltip: 'Edit Job',
                                color: Colors.orange[700],
                                padding: const EdgeInsets.all(6),
                                constraints: const BoxConstraints(minHeight: 32, minWidth: 32),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'completed':
        return Colors.green;
      case 'pending':
      case 'in progress':
        return Colors.orange;
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'completed':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'in progress':
        return Icons.autorenew;
      case 'cancelled':
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  void _showJobDetails(BuildContext context, AdminJob job) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return JobDetailsDialog(job: job);
      },
    );
  }
}

// Utility class for consistent job stage logic
class JobStageUtils {
  static bool isStageCompleted(String stageName, dynamic stageData) {
    if (stageData == null) return false;
    String? status;
    if (stageName == 'printing') {
      status = getMostRecentStatus(stageData)?.toLowerCase();
      return status == 'completed' || status == 'print_completed' || status == 'print_complete';
    } else if (stageName == 'production') {
      if (stageData is Map<String, dynamic>) {
        // Prefer current_status, fallback to status
        status = (stageData['current_status'] ?? stageData['status'])?.toString().toLowerCase();
      }
      return ['completed', 'approved', 'done', 'production_complete'].contains(status);
    } else if (stageName == 'design' || stageName == 'designer') {
      status = getMostRecentStatus(stageData)?.toLowerCase();
      return ['completed', 'approved', 'done'].contains(status);
    } else if (stageData is Map<String, dynamic>) {
      status = stageData['status']?.toString().toLowerCase();
    }
    return ['completed', 'approved', 'done'].contains(status);
  }

  static String? getMostRecentStatus(dynamic stageData) {
    if (stageData == null) return null;
    if (stageData is List) {
      if (stageData.isEmpty) return null;
      Map<String, dynamic>? mostRecent;
      DateTime? mostRecentDateTime;
      for (final item in stageData) {
        if (item is Map<String, dynamic> && item['submission_date'] != null && item['submission_time'] != null) {
          try {
            final dt = DateTime.parse(item['submission_date'] + ' ' + item['submission_time']);
            if (mostRecentDateTime == null || dt.isAfter(mostRecentDateTime)) {
              mostRecentDateTime = dt;
              mostRecent = item;
            }
          } catch (_) {}
        }
      }
      mostRecent ??= stageData.isNotEmpty ? stageData.last as Map<String, dynamic>? : null;
      return mostRecent?['status']?.toString();
    } else if (stageData is Map<String, dynamic>) {
      final numericKeys = stageData.keys.where((k) => int.tryParse(k) != null).toList();
      if (numericKeys.isNotEmpty) {
        numericKeys.sort((a, b) => int.parse(a).compareTo(int.parse(b)));
        Map<String, dynamic>? mostRecent;
        DateTime? mostRecentDateTime;
        for (final key in numericKeys) {
          final submission = stageData[key] as Map<String, dynamic>?;
          if (submission != null) {
            if (submission['submission_date'] != null && submission['submission_time'] != null) {
              try {
                final dt = DateTime.parse(submission['submission_date'] + ' ' + submission['submission_time']);
                if (mostRecentDateTime == null || dt.isAfter(mostRecentDateTime)) {
                  mostRecentDateTime = dt;
                  mostRecent = submission;
                }
              } catch (_) {
                mostRecent = submission;
              }
            } else {
              mostRecent = submission;
            }
          }
        }
        return mostRecent?['status']?.toString();
      }
      return stageData['status']?.toString();
    }
    return null;
  }
}

// Update JobProgressIndicator to use JobStageUtils
class JobProgressIndicator extends StatelessWidget {
  final AdminJob job;

  const JobProgressIndicator({Key? key, required this.job}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int completedStages = 0;
    int totalStages = 6; // receptionist, salesperson, design, accountant, production, printing

    if (JobStageUtils.isStageCompleted('receptionist', job.receptionist)) completedStages++;
    if (JobStageUtils.isStageCompleted('salesperson', job.salesperson)) completedStages++;
    if (JobStageUtils.isStageCompleted('design', job.design)) completedStages++;
    if (JobStageUtils.isStageCompleted('accountant', job.accountant)) completedStages++;
    if (JobStageUtils.isStageCompleted('production', job.production)) completedStages++;
    if (JobStageUtils.isStageCompleted('printing', job.printing)) completedStages++;

    double progress = completedStages / totalStages;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            progress == 1.0 ? Colors.green : Colors.blue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$completedStages/$totalStages stages',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class JobDetailsDialog extends StatelessWidget {
  final AdminJob job;

  const JobDetailsDialog({Key? key, required this.job}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 900,
        constraints: const BoxConstraints(maxHeight: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.work, color: Colors.blue[700], size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Job Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                        Text(
                          'Job ID: ${job.no}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Information Card
                    _buildInfoCard(
                      'Basic Information',
                      Icons.info_outline,
                      Colors.green,
                      [
                        _buildInfoRow('Job Title', job.title),
                        _buildInfoRow('Client Name', job.client),
                        _buildInfoRow('Date Created', job.date),
                        _buildInfoRow('Current Status', job.status, isStatus: true),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Progress Overview
                    _buildProgressCard(),
                    const SizedBox(height: 20),
                    
                    // Stage Details
                    Text(
                      'Stage Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildStageSection('Receptionist', job.receptionist, Icons.person, Colors.purple),
                    _buildStageSection('Salesperson', job.salesperson, Icons.handshake, Colors.blue),
                    _buildStageSection('Designer', job.design, Icons.design_services, Colors.pink),
                    _buildStageSection('Accountant', job.accountant, Icons.account_balance, Colors.orange),
                    _buildStageSection('Production', job.production, Icons.precision_manufacturing, Colors.indigo),
                    _buildStageSection('Printing', job.printing, Icons.print, Colors.teal),
                  ],
                ),
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to edit job
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit Job'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, Color color, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    int completedStages = 0;
    int totalStages = 6;

    if (JobStageUtils.isStageCompleted('receptionist', job.receptionist)) completedStages++;
    if (JobStageUtils.isStageCompleted('salesperson', job.salesperson)) completedStages++;
    if (JobStageUtils.isStageCompleted('design', job.design)) completedStages++;
    if (JobStageUtils.isStageCompleted('accountant', job.accountant)) completedStages++;
    if (JobStageUtils.isStageCompleted('production', job.production)) completedStages++;
    if (JobStageUtils.isStageCompleted('printing', job.printing)) completedStages++;

    double progress = completedStages / totalStages;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.timeline, color: Colors.blue, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Progress Overview',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const Spacer(),
                Text(
                  '${(progress * 100).toInt()}% Complete',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: progress == 1.0 ? Colors.green : Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress == 1.0 ? Colors.green : Colors.blue,
              ),
              minHeight: 8,
            ),
            const SizedBox(height: 12),
            Text(
              '$completedStages of $totalStages stages completed',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: isStatus
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(value).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _getStatusColor(value).withOpacity(0.3)),
                    ),
                    child: Text(
                      value,
                      style: TextStyle(
                        color: _getStatusColor(value),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  )
                : Text(
                    value,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageSection(String stageName, Map<String, dynamic>? stageData, IconData icon, Color color) {
    final locked = _isStageLocked(stageName, job);
    bool isCompleted = !locked && _isStageCompleted(stageName.toLowerCase(), stageData);
    String fetchedStatus = locked ? 'Pending' : _getStageStatus(stageName.toLowerCase(), stageData, log: true);
    Color statusColor = _getStageStatusColor(fetchedStatus);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isCompleted ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCompleted ? color.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (stageData != null) ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: (stageData != null) ? color : Colors.grey,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    stageName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: (stageData != null) ? color : Colors.grey[600],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isCompleted ? Icons.check_circle : 
                        (fetchedStatus == 'Pending' ? Icons.pending : Icons.schedule),
                        size: 14,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        fetchedStatus,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (stageData != null && stageData.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildStageDetails(stageName.toLowerCase(), stageData),
            ],
          ],
        ),
      )
      );
  }
  Widget _buildStageDetails(String stageName, Map<String, dynamic> stageData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: _buildStageSpecificContent(stageName, stageData),
    );
  }

  Widget _buildStageSpecificContent(String stageName, Map<String, dynamic> stageData) {
    switch (stageName.toLowerCase()) {
      case 'receptionist':
        return _buildReceptionistDetails(stageData);
      case 'salesperson':
        return _buildSalespersonDetails(stageData);
      case 'design':
        return _buildDesignDetails(stageData);
      case 'accountant':
        return _buildAccountantDetails(stageData);
      case 'production':
        return _buildProductionDetails(stageData);
      case 'printing':
        return _buildPrintingDetails(stageData);
      default:
        return _buildGenericDetails(stageData);
    }
  }

  Widget _buildReceptionistDetails(Map<String, dynamic> data) {
    if (data.isEmpty) return _buildEmptyState('No receptionist information available');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Customer Information', Icons.person, Colors.purple),
        const SizedBox(height: 12),
        if (data['customerName'] != null)
          _buildInfoTile('Customer Name', data['customerName'], Icons.person_outline),
        if (data['phone'] != null)
          _buildInfoTile('Phone Number', data['phone'], Icons.phone),
        if (data['email'] != null)
          _buildInfoTile('Email', data['email'], Icons.email),
        if (data['shopName'] != null)
          _buildInfoTile('Shop Name', data['shopName'], Icons.store),
        if (data['streetAddress'] != null || data['town'] != null)
          _buildInfoTile('Address', _buildFullAddress(data), Icons.location_on),
        if (data['dateOfAppointment'] != null)
          _buildInfoTile('Appointment Date', data['dateOfAppointment'], Icons.calendar_today),
        if (data['assignedSalesperson'] != null)
          _buildInfoTile('Assigned Salesperson', data['assignedSalesperson'], Icons.person_pin),
        if (data['status'] != null)
          _buildStatusTile('Status', data['status']),
      ],
    );
  }

  Widget _buildSalespersonDetails(Map<String, dynamic> data) {
    if (data.isEmpty) return _buildEmptyState('No salesperson information available');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Site Visit Information', Icons.handshake, Colors.blue),
        const SizedBox(height: 12),
        if (data['typeOfSign'] != null)
          _buildInfoTile('Type of Sign', data['typeOfSign'], Icons.category),
        if (data['material'] != null)
          _buildInfoTile('Material', data['material'], Icons.construction),
        if (data['timeForProduction'] != null)
          _buildInfoTile('Production Time', data['timeForProduction'], Icons.access_time),
        if (data['timeForFitting'] != null)
          _buildInfoTile('Fitting Time', data['timeForFitting'], Icons.build),
        if (data['signMeasurements'] != null)
          _buildInfoTile('Sign Measurements', data['signMeasurements'], Icons.straighten),
        if (data['extraDetails'] != null)
          _buildInfoTile('Extra Details', data['extraDetails'], Icons.notes),
        if (data['paymentAmount'] != null)
          _buildInfoTile('Payment Amount', '£${data['paymentAmount']}', Icons.payment),
        if (data['modeOfPayment'] != null)
          _buildInfoTile('Payment Method', data['modeOfPayment'], Icons.credit_card),
        if (data['images'] != null)
          _buildInfoTile('Site Images', '${(data['images'] as List).length} file(s)', Icons.photo_library),
        if (data['status'] != null)
          _buildStatusTile('Status', data['status']),
      ],
    );
  }

  Widget _buildDesignDetails(Map<String, dynamic> data) {
    if (data.isEmpty) return _buildEmptyState('No design submissions yet');
    
    // Handle numeric keys (multiple submissions)
    final keys = data.keys.where((k) => int.tryParse(k) != null).toList();
    if (keys.isNotEmpty) {
      keys.sort((a, b) => int.parse(a).compareTo(int.parse(b)));
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Design Submissions', Icons.design_services, Colors.pink),
          const SizedBox(height: 12),
          for (final key in keys) ...[
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.brush, color: Colors.pink[600], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Draft #${int.parse(key) + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.pink[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    if (data[key]['submission_date'] != null)
                      _buildDetailRow('Submitted On', data[key]['submission_date']),
                    if (data[key]['submission_time'] != null)
                      _buildDetailRow('Time', data[key]['submission_time']),
                    if (data[key]['comments'] != null)
                      _buildDetailRow('Comments', data[key]['comments']),
                    if (data[key]['images'] != null)
                      _buildDetailRow('Design Files', '${(data[key]['images'] as List).length} file(s)'),
                    if (data[key]['status'] != null)
                      _buildStatusTile('Status', data[key]['status']),
                  ],
                ),
              ),
            ),
          ],
        ],
      );
    }
    
    return _buildGenericDetails(data);
  }

  Widget _buildAccountantDetails(Map<String, dynamic> data) {
    if (data.isEmpty) return _buildEmptyState('No accounting information available');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Financial Information', Icons.account_balance, Colors.orange),
        const SizedBox(height: 12),
        if (data['totalAmount'] != null)
          _buildInfoTile('Total Amount', '£${data['totalAmount']}', Icons.monetization_on),
        if (data['amountPaid'] != null)
          _buildInfoTile('Amount Paid', '£${data['amountPaid']}', Icons.payment),
        if (data['remainingAmount'] != null)
          _buildInfoTile('Remaining Amount', '£${data['remainingAmount']}', Icons.account_balance_wallet),
        if (data['paymentMethod'] != null)
          _buildInfoTile('Payment Method', data['paymentMethod'], Icons.credit_card),
        if (data['invoiceNumber'] != null)
          _buildInfoTile('Invoice Number', data['invoiceNumber'], Icons.receipt),
        if (data['paymentDate'] != null)
          _buildInfoTile('Payment Date', data['paymentDate'], Icons.date_range),
        if (data['status'] != null)
          _buildStatusTile('Status', data['status']),
      ],
    );
  }

  Widget _buildProductionDetails(Map<String, dynamic> data) {
    if (data.isEmpty) return _buildEmptyState('No production information available');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Production Information', Icons.precision_manufacturing, Colors.indigo),
        const SizedBox(height: 12),
        if (data['current_status'] != null || data['status'] != null)
          _buildStatusTile('Production Status', data['current_status'] ?? data['status']),        if (data['assignedWorker'] != null)
          _buildInfoTile('Assigned Worker', data['assignedWorker'], Icons.engineering),
        if (data['startDate'] != null)
          _buildInfoTile('Start Date', data['startDate'], Icons.play_arrow),
        if (data['estimatedCompletion'] != null)
          _buildInfoTile('Estimated Completion', data['estimatedCompletion'], Icons.schedule),
        if (data['actualCompletion'] != null)
          _buildInfoTile('Actual Completion', data['actualCompletion'], Icons.check_circle),
        if (data['productionNotes'] != null)
          _buildInfoTile('Production Notes', data['productionNotes'], Icons.note),
        if (data['materials'] != null)
          _buildInfoTile('Materials Used', data['materials'], Icons.inventory),
      ],
    );
  }

  Widget _buildPrintingDetails(Map<String, dynamic> data) {
    if (data.isEmpty) return _buildEmptyState('No printing information available');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Printing Information', Icons.print, Colors.teal),
        const SizedBox(height: 12),
        if (data['printStatus'] != null || data['status'] != null)
          _buildStatusTile('Printing Status', data['printStatus'] ?? data['status']),
        if (data['printType'] != null)
          _buildInfoTile('Print Type', data['printType'], Icons.category),
        if (data['printSize'] != null)
          _buildInfoTile('Print Size', data['printSize'], Icons.aspect_ratio),
        if (data['printQuantity'] != null)
          _buildInfoTile('Quantity', data['printQuantity'], Icons.format_list_numbered),
        if (data['printMaterial'] != null)
          _buildInfoTile('Print Material', data['printMaterial'], Icons.texture),
        if (data['printDate'] != null)
          _buildInfoTile('Print Date', data['printDate'], Icons.date_range),
        if (data['printNotes'] != null)
          _buildInfoTile('Print Notes', data['printNotes'], Icons.note),
      ],
    );
  }

  Widget _buildGenericDetails(Map<String, dynamic> data) {
    if (data.isEmpty) return _buildEmptyState('No information available');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.entries.map((entry) {
        if (entry.key == 'status') {
          return _buildStatusTile('Status', entry.value?.toString() ?? 'N/A');
        }
        return _buildDetailRow(_formatLabel(entry.key), entry.value?.toString() ?? 'N/A');
      }).toList(),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.grey[800], fontSize: 13),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTile(String label, String status) {
    final color = _getStageStatusColor(status);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
              fontSize: 13,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              _formatStatus(status),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.info_outline, color: Colors.grey[400], size: 32),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _buildFullAddress(Map<String, dynamic> data) {
    final parts = <String>[];
    if (data['streetNumber'] != null) parts.add(data['streetNumber']);
    if (data['streetAddress'] != null) parts.add(data['streetAddress']);
    if (data['town'] != null) parts.add(data['town']);
    if (data['postcode'] != null) parts.add(data['postcode']);
    return parts.join(', ').isNotEmpty ? parts.join(', ') : 'N/A';
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '${_formatLabel(label)}:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatLabel(String label) {
    return label.replaceAll('_', ' ').split(' ').map((word) => 
      word.isEmpty ? word : word[0].toUpperCase() + word.substring(1)).join(' ');
  } bool _isStageCompleted(String stageName, dynamic stageData) {
    return JobStageUtils.isStageCompleted(stageName, stageData);
  }

  String _getStageStatus(String stageName, dynamic stageData, {bool log = false}) {
    if (_isStageLocked(stageName, job)) {
      return 'Pending';
    }
    if (stageData == null) {
      if (stageName == 'printing') return 'Pending';
      return 'Pending';
    }
    if (stageName == 'printing') {
      String? status = _getMostRecentStatus(stageData);
      if (status == null) return 'Pending';
      final s = status.toLowerCase();
      if (s == 'completed' || s == 'print_completed' || s == 'print_complete') return 'Complete';
      return 'In Progress';
    }
    if (stageName == 'production') {
      String? status;
      if (stageData is Map<String, dynamic>) {
        // Prefer current_status, fallback to status
        status = (stageData['current_status'] ?? stageData['status'])?.toString();
      }
      return status?.isNotEmpty == true ? _formatStatus(status!) : 'Pending';
    }
    if (stageName == 'design' || stageName == 'designer') {
      String? status = _getMostRecentStatus(stageData);
      if (status?.isNotEmpty == true) return _formatStatus(status!);
      if (stageData is Map<String, dynamic> && (stageData.containsKey('images') || stageData.containsKey('comments') || stageData.containsKey('submission_date'))) {
        return 'Complete';
      }
      return 'Pending';
    }
    String? status;
    if (stageData is Map<String, dynamic>) {
      status = stageData['status']?.toString();
    }
    return status?.isNotEmpty == true ? _formatStatus(status!) : 'Pending';
  }

  String? _getMostRecentStatus(dynamic stageData) {
    return JobStageUtils.getMostRecentStatus(stageData);
  }

  // Format status for display
  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending_approval':
        return 'Pending Approval';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
      case 'approved':
        return 'Complete';
      case 'rejected':
        return 'Rejected';
      default:
        return status.replaceAll('_', ' ').split(' ').map((word) => 
          word.isEmpty ? word : word[0].toUpperCase() + word.substring(1)).join(' ');
    }
  }

  // Get color for stage status
  Color _getStageStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'complete':
      case 'approved':
        return Colors.green;
      case 'pending approval':
      case 'in progress':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Helper to determine if a stage is locked (pending) due to previous nulls
  bool _isStageLocked(String stageName, AdminJob job) {
    const sequence = [
      'receptionist',
      'salesperson',
      'design',
      'accountant',
      'production',
      'printing',
    ];
    final stageIndex = sequence.indexOf(stageName.toLowerCase());
    if (stageIndex == -1) return false;
    for (int i = 0; i < stageIndex; i++) {
      final prev = sequence[i];
      final data = _getStageData(prev, job);
      if (data == null) return true;
    }
    return false;
  }

  Map<String, dynamic>? _getStageData(String stageName, AdminJob job) {
    switch (stageName) {
      case 'receptionist':
        return job.receptionist;
      case 'salesperson':
        return job.salesperson;
      case 'design':
        return job.design;
      case 'accountant':
        return job.accountant;
      case 'production':
        return job.production;
      case 'printing':
        return job.printing;
      default:
        return null;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'completed':
        return Colors.green;
      case 'pending':
      case 'in progress':
        return Colors.orange;
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
