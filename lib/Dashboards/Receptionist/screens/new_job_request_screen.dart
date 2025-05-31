import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../widgets/sidebar.dart';
import '../widgets/topbar.dart';
import '../providers/job_request_provider.dart';
import '../models/job_request.dart';

class NewJobRequestScreen extends StatelessWidget {
  const NewJobRequestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 900;
    final double formWidth =
        isMobile ? double.infinity : (isTablet ? 500 : 800);
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFF6F3FE),
      drawer: isMobile
          ? Drawer(
              child: Sidebar(
                selectedIndex: 1,
                isDrawer: true,
                onClose: () => Navigator.of(context).pop(),
              ),
            )
          : null,
      body: Row(
        children: [
          if (!isMobile) Sidebar(selectedIndex: 1),
          Expanded(
            child: Column(
              children: [
                TopBar(
                  isDashboard: false,
                  showMenu: isMobile,
                  onMenuTap: () => scaffoldKey.currentState?.openDrawer(),
                ),
                Expanded(
                  child: JobRequestContent(
                      isMobile: isMobile, formWidth: formWidth),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class JobRequestContent extends StatefulWidget {
  final bool isMobile;
  final double formWidth;

  const JobRequestContent({
    Key? key,
    required this.isMobile,
    required this.formWidth,
  }) : super(key: key);

  @override
  State<JobRequestContent> createState() => _JobRequestContentState();
}

class _JobRequestContentState extends State<JobRequestContent> {
  final TextEditingController _searchController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedStatus;
  String? _selectedPriority;
  List<JobRequest> _filteredJobs = [];

  final List<String> _statuses = [
    'New',
    'In Progress',
    'Completed',
    'Cancelled'
  ];
  final List<String> _priorities = ['High', 'Medium', 'Low'];

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadJobs() async {
    final jobProvider =
        Provider.of<JobRequestProvider>(context, listen: false);
    await jobProvider.fetchJobRequests();
    _filterJobs();
  }

  void _filterJobs() {
    final allJobs =
        Provider.of<JobRequestProvider>(context, listen: false).jobRequests;
    var filteredList = List<JobRequest>.from(allJobs);

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      filteredList = filteredList.where((job) {
        return job.name.toLowerCase().contains(searchTerm) ||
            job.phone.toLowerCase().contains(searchTerm) ||
            job.email.toLowerCase().contains(searchTerm) ||
            (job.subtitle?.toLowerCase().contains(searchTerm) ?? false);
      }).toList();
    }

    // Apply date filter
    if (_startDate != null && _endDate != null) {
      filteredList = filteredList.where((job) {
        final jobDate = job.dateAdded;
        if (jobDate == null) return false;
        return jobDate.isAfter(_startDate!) &&
            jobDate.isBefore(_endDate!.add(const Duration(days: 1)));
      }).toList();
    }

    // Apply status filter
    if (_selectedStatus != null) {
      filteredList = filteredList
          .where((job) => job.status.name == _selectedStatus)
          .toList();
    }

    // Apply priority filter
    if (_selectedPriority != null) {
      filteredList = filteredList
          .where((job) => job.priority == _selectedPriority)
          .toList();
    }

    setState(() => _filteredJobs = filteredList);
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _startDate = null;
      _endDate = null;
      _selectedStatus = null;
      _selectedPriority = null;
    });
    _filterJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'New job request',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1B2330),
                    ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder: (context) => _AddJobDialog(onJobAdded: _loadJobs),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Add New job'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7DE2D1),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Prominent Search Bar
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, email, or ID...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF7DE2D1)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterJobs();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              onChanged: (value) => _filterJobs(),
            ),
          ),
          Expanded(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filter section without the search bar
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedStatus,
                              onChanged: (value) {
                                setState(() {
                                  _selectedStatus = value;
                                });
                                _filterJobs();
                              },
                              items: _statuses
                                  .map((status) => DropdownMenuItem<String>(
                                        value: status,
                                        child: Text(status),
                                      ))
                                  .toList(),
                              decoration: InputDecoration(
                                labelText: 'Status',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade300),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedPriority,
                              onChanged: (value) {
                                setState(() {
                                  _selectedPriority = value;
                                });
                                _filterJobs();
                              },
                              items: _priorities
                                  .map((priority) => DropdownMenuItem<String>(
                                        value: priority,
                                        child: Text(priority),
                                      ))
                                  .toList(),
                              decoration: InputDecoration(
                                labelText: 'Priority',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade300),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: _clearFilters,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEF5350),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Clear Filters'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Table headers
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 18),
                      child: Row(
                        children: const [
                          Expanded(
                              child: Text('Name',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFBDBDBD),
                                      fontSize: 15))),
                          Expanded(
                              child: Text('ID',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFBDBDBD),
                                      fontSize: 15))),
                          Expanded(
                              child: Text('Email',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFBDBDBD),
                                      fontSize: 15))),
                          Expanded(
                              child: Text('Phone number',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFBDBDBD),
                                      fontSize: 15))),
                          Expanded(
                              child: Text('Date added',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFBDBDBD),
                                      fontSize: 15))),
                          Expanded(
                              child: Text('STATUS',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFBDBDBD),
                                      fontSize: 15))),
                          SizedBox(width: 28),
                        ],
                      ),
                    ),
                    const Divider(
                        height: 1, thickness: 1, color: Color(0xFFF2F2F2)),
                    // Job list
                    _buildJobList(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobList() {
    final jobProvider = Provider.of<JobRequestProvider>(context);
    final jobs = _filteredJobs.isEmpty && _searchController.text.isEmpty
        ? jobProvider.jobRequests
        : _filteredJobs;

    if (jobProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (jobs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            'No requests for today',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    return Column(
      children: jobs.map((job) => _buildJobRow(job)).toList(),
    );
  }

  Widget _buildJobRow(JobRequest job) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF2F2F2), width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage:
                      AssetImage(job.avatar ?? 'assets/images/elite_logo.png'),
                  radius: 18,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    Text(
                      job.subtitle ?? '',
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFFBDBDBD)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              job.id,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              job.email,
              style: const TextStyle(fontSize: 13, color: Color(0xFF7B7B7B)),
            ),
          ),
          Expanded(
            child: Text(
              job.phone,
              style: const TextStyle(fontSize: 13, color: Color(0xFF7B7B7B)),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.dateAdded != null
                      ? DateFormat('dd/MM/yyyy').format(job.dateAdded!)
                      : '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF1B2330),
                  ),
                ),
                Text(
                  job.time ?? '',
                  style:
                      const TextStyle(fontSize: 11, color: Color(0xFFBDBDBD)),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: job.assigned == true
                    ? const Color(0xFF7DE2D1)
                    : const Color(0xFFFFAFAF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                job.assigned == true ? 'Assigned' : 'Unassigned',
                style: TextStyle(
                  color: job.assigned == true
                      ? const Color(0xFF1B2330)
                      : const Color(0xFFD32F2F),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios,
                size: 18, color: Color(0xFFBDBDBD)),
            onPressed: () => _showJobDetails(job),
          ),
        ],
      ),
    );
  }

  void _showJobDetails(JobRequest job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Job Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${job.name}'),
            Text('ID: ${job.id}'),
            Text('Email: ${job.email}'),
            Text('Phone: ${job.phone}'),
            Text('Status: ${job.assigned == true ? "Assigned" : "Unassigned"}'),
            if (job.dateAdded != null)
              Text(
                  'Date Added: ${DateFormat('dd/MM/yyyy').format(job.dateAdded!)}'),
            if (job.time != null) Text('Time: ${job.time}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _AddJobDialog extends StatefulWidget {
  final VoidCallback onJobAdded;
  const _AddJobDialog({required this.onJobAdded});

  @override
  State<_AddJobDialog> createState() => _AddJobDialogState();
}

class _AddJobDialogState extends State<_AddJobDialog> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String phone = '';
  String email = '';
  String subtitle = '';
  String priority = 'Medium';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Job Request'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Customer Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                onSaved: (v) => name = v ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                onSaved: (v) => phone = v ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                onSaved: (v) => email = v ?? '',
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Subtitle (Shop/Note)'),
                onSaved: (v) => subtitle = v ?? '',
              ),
              DropdownButtonFormField<String>(
                value: priority,
                items: ['High', 'Medium', 'Low']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => setState(() => priority = v ?? 'Medium'),
                decoration: const InputDecoration(labelText: 'Priority'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isLoading
              ? null
              : () async {
                  if (!_formKey.currentState!.validate()) return;
                  _formKey.currentState!.save();
                  setState(() => isLoading = true);
                  final provider =
                      Provider.of<JobRequestProvider>(context, listen: false);
                  await provider.addJobRequest(
                    JobRequest(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: name,
                      phone: phone,
                      email: email,
                      status: JobRequestStatus.pending,
                      dateAdded: DateTime.now(),
                      subtitle: subtitle,
                      avatar: '',
                      time: '',
                      assigned: false,
                      priority: priority,
                    ),
                  );
                  setState(() => isLoading = false);
                  widget.onJobAdded();
                  Navigator.pop(context);
                },
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Add'),
        ),
      ],
    );
  }
}
