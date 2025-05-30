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
  String selectedStatus = 'All';
  late Future<List<AdminJob>> _jobsFuture;
  final AdminService _adminService = AdminService();
  
  // Search and filter controllers
  final TextEditingController _searchController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FF),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminSidebar(
              selectedIndex: 0, // Highlight dashboard since this is job-related
              onItemTapped: (index) {
                if (index == 0) {
                  Navigator.pushReplacementNamed(context, '/admin/dashboard');
                } else if (index == 1) {
                  Navigator.pushReplacementNamed(context, '/admin/employees');
                } else if (index == 2) {
                  Navigator.pushReplacementNamed(context, '/admin/assign-salesperson');
                } else if (index == 3) {
                  Navigator.pushReplacementNamed(context, '/admin/job-progress');
                } else if (index == 4) {
                  Navigator.pushReplacementNamed(context, '/admin/calendar');
                }
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
      ),
    );
  }
}

class JobListTable extends StatelessWidget {
  final List<AdminJob> jobs;

  const JobListTable({Key? key, required this.jobs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        headingRowHeight: 50,
        dataRowHeight: 60,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(8),
        ),
        headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
        columns: const [
          DataColumn(
            label: Expanded(
              child: Text(
                'Job ID',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
          DataColumn(
            label: Expanded(
              child: Text(
                'Title & Client',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
          DataColumn(
            label: Expanded(
              child: Text(
                'Date Created',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
          DataColumn(
            label: Expanded(
              child: Text(
                'Status',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
          DataColumn(
            label: Expanded(
              child: Text(
                'Progress',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
          DataColumn(
            label: Expanded(
              child: Text(
                'Actions',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ],
        rows: jobs.map((job) {
          return DataRow(
            cells: [
              DataCell(
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    job.no,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        job.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        job.client,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    job.date,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(job.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _getStatusColor(job.status).withOpacity(0.3)),
                    ),
                    child: Text(
                      job.status,
                      style: TextStyle(
                        color: _getStatusColor(job.status),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.all(8),
                  child: JobProgressIndicator(job: job),
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility, size: 18),
                        onPressed: () {
                          _showJobDetails(context, job);
                        },
                        tooltip: 'View Details',
                        color: Colors.blue[600],
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        onPressed: () {
                          // TODO: Navigate to edit job
                        },
                        tooltip: 'Edit Job',
                        color: Colors.orange[600],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }).toList(),
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

  void _showJobDetails(BuildContext context, AdminJob job) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return JobDetailsDialog(job: job);
      },
    );
  }
}

class JobProgressIndicator extends StatelessWidget {
  final AdminJob job;

  const JobProgressIndicator({Key? key, required this.job}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate progress based on truly completed stages
    int completedStages = 0;
    int totalStages = 6; // receptionist, salesperson, design, accountant, production, printing

    if (_isStageCompleted('receptionist', job.receptionist)) completedStages++;
    if (_isStageCompleted('salesperson', job.salesperson)) completedStages++;
    if (_isStageCompleted('design', job.design)) completedStages++;
    if (_isStageCompleted('accountant', job.accountant)) completedStages++;
    if (_isStageCompleted('production', job.production)) completedStages++;
    if (_isStageCompleted('printing', job.printing)) completedStages++;

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

  // Helper method to check if a stage is truly completed
  bool _isStageCompleted(String stageName, Map<String, dynamic>? stageData) {
    if (stageData == null) return false;
    
    // For design and printing stages, check if it's an array and look at status of first submission
    if ((stageName == 'design' || stageName == 'printing') && stageData.containsKey('0')) {
      final firstSubmission = stageData['0'] as Map<String, dynamic>?;
      final s = firstSubmission?['status']?.toString().toLowerCase();
      return s == 'approved' || s == 'completed' || s == 'done';
    }
    
    // For other stages, check common completion indicators
    final status = stageData['status']?.toString().toLowerCase();
    return status == 'completed' || status == 'approved' || status == 'done';
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

    if (_isStageCompleted('receptionist', job.receptionist)) completedStages++;
    if (_isStageCompleted('salesperson', job.salesperson)) completedStages++;
    if (_isStageCompleted('design', job.design)) completedStages++;
    if (_isStageCompleted('accountant', job.accountant)) completedStages++;
    if (_isStageCompleted('production', job.production)) completedStages++;
    if (_isStageCompleted('printing', job.printing)) completedStages++;

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
    String stageStatus = locked ? 'Pending' : _getStageStatus(stageName.toLowerCase(), stageData);
    Color statusColor = _getStageStatusColor(stageStatus);
    
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
                        (stageStatus == 'Pending' ? Icons.pending : Icons.schedule),
                        size: 14,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        stageStatus,
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
      ),
    );
  }

  Widget _buildStageDetails(String stageName, Map<String, dynamic> stageData) {
    // Enhanced: Handle design array structure with multiple submissions
    if (stageName == 'design') {
      if (stageData.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'No design submissions yet.',
            style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
          ),
        );
      }
      // If keys are numeric (as strings), sort and display all submissions
      final keys = stageData.keys.where((k) => int.tryParse(k) != null).toList();
      if (keys.isNotEmpty) {
        keys.sort((a, b) => int.parse(a).compareTo(int.parse(b)));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final key in keys) ...[
              Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: Colors.grey[50],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Submission #${int.parse(key) + 1}',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pink[700])),
                      const SizedBox(height: 6),
                      if (stageData[key]['submission_date'] != null)
                        _buildDetailRow('Submission Date', stageData[key]['submission_date']),
                      if (stageData[key]['submission_time'] != null)
                        _buildDetailRow('Submission Time', stageData[key]['submission_time']),
                      if (stageData[key]['comments'] != null)
                        _buildDetailRow('Comments', stageData[key]['comments']),
                      if (stageData[key]['images'] != null)
                        _buildDetailRow('Images',
                            '${(stageData[key]['images'] as List).length} file(s)'),
                      if (stageData[key]['status'] != null)
                        _buildDetailRow('Status', _formatStatus(stageData[key]['status'])),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      }
    }
    // Handle other stage structures
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: stageData.entries.map((entry) {
          return _buildDetailRow(entry.key, entry.value?.toString() ?? 'N/A');
        }).toList(),
      ),
    );
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
  }

  // Helper method to check if a stage is truly completed
  bool _isStageCompleted(String stageName, Map<String, dynamic>? stageData) {
    if (stageData == null) return false;
    
    // For design and printing stages, check if it's an array and look at status of first submission
    if ((stageName == 'design' || stageName == 'printing') && stageData.containsKey('0')) {
      final firstSubmission = stageData['0'] as Map<String, dynamic>?;
      final s = firstSubmission?['status']?.toString().toLowerCase();
      return s == 'approved' || s == 'completed' || s == 'done';
    }
    
    // For other stages, check common completion indicators
    final status = stageData['status']?.toString().toLowerCase();
    return status == 'completed' || status == 'approved' || status == 'done';
  }

  // Get stage status for display
  String _getStageStatus(String stageName, Map<String, dynamic>? stageData) {
    // If stage is locked, always return 'Pending'
    if (_isStageLocked(stageName, job)) return 'Pending';
    // If stageData is null, always return 'Pending'
    if (stageData == null) return 'Pending';
    
    // For design and printing stages with array structure
    if ((stageName == 'design' || stageName == 'printing') && stageData.containsKey('0')) {
      final firstSubmission = stageData['0'] as Map<String, dynamic>?;
      final status = firstSubmission?['status']?.toString() ?? 'pending';
      return _formatStatus(status);
    }
    
    // For other stages
    final status = stageData['status']?.toString();
    if (status == null || status.isEmpty) return 'Pending';
    return _formatStatus(status);
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
