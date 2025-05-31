import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../widgets/sidebar.dart';
import '../widgets/topbar.dart';
import '../providers/job_request_provider.dart';
import '../models/job_request.dart';
import '../providers/salesperson_provider.dart';

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
                onItemSelected: (index) {}, // Dummy callback
              ),
            )
          : null,
      body: Row(
        children: [
          if (!isMobile) Sidebar(selectedIndex: 1, onItemSelected: (index) {}), // Dummy callback
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
                    builder: (context) => Dialog(
                      insetPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 32),
                      backgroundColor: Colors.transparent,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Material(
                          borderRadius: BorderRadius.circular(12),
                          child: _JobRequestFormDialog(onJobAdded: _loadJobs),
                        ),
                      ),
                    ),
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

class _JobRequestFormDialog extends StatelessWidget {
  final VoidCallback onJobAdded;
  const _JobRequestFormDialog({required this.onJobAdded, Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Add New Job Request', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: _JobRequestForm(
              isMobile: MediaQuery.of(context).size.width < 600,
              onSuccess: () {
                Navigator.of(context).pop();
                onJobAdded();
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Update _JobRequestForm to accept onSuccess and call it after successful submission
class _JobRequestForm extends StatefulWidget {
  final bool isMobile;
  final VoidCallback? onSuccess;
  const _JobRequestForm({this.isMobile = false, this.onSuccess, Key? key}) : super(key: key);
  @override
  State<_JobRequestForm> createState() => _JobRequestFormState();
}

class _JobRequestFormState extends State<_JobRequestForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _selectedStatus;
  String? _selectedPriority;
  DateTime? _date;
  TimeOfDay? _time;
  bool _isSubmitting = false;
  String? _submitMessage;
  String? _validationError;
  final List<String> _statuses = ['New', 'In Progress', 'Completed', 'Cancelled'];
  final List<String> _priorities = ['High', 'Medium', 'Low'];
  final List<String> _salespersons = [];

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return TimeOfDay(hour: dt.hour, minute: dt.minute).format(context);
  }

  @override
  void initState() {
    super.initState();
    _fetchSalespersons();
  }

  Future<void> _fetchSalespersons() async {
    try {
      final salespersonProvider = Provider.of<SalespersonProvider>(context, listen: false);
      await salespersonProvider.fetchSalespersons();
      setState(() {
        _salespersons.addAll(salespersonProvider.salespersons.map((s) => s.name));
      });
    } catch (e) {
      // Handle error
    }
  }

  void _clearForm() {
    setState(() {
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _selectedStatus = null;
      _selectedPriority = null;
      _date = null;
      _time = null;
      _validationError = null;
      _submitMessage = null;
    });
  }

  bool _validateForm() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final date = _date;
    final time = _time;

    if (name.isEmpty || email.isEmpty || phone.isEmpty || date == null || time == null) {
      setState(() {
        _validationError = 'Please fill in all fields.';
      });
      return false;
    }

    if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(name)) {
      setState(() {
        _validationError = 'Name can only contain letters and spaces.';
      });
      return false;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
      setState(() {
        _validationError = 'Phone number can only contain digits.';
      });
      return false;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      setState(() {
        _validationError = 'Please enter a valid email address.';
      });
      return false;
    }

    return true;
  }

  Future<void> _submitJobRequest() async {
    setState(() {
      _validationError = null;
    });
    if (!_validateForm()) {
      return;
    }
    setState(() {
      _isSubmitting = true;
      _submitMessage = null;
    });
    try {
      final jobRequestProvider = Provider.of<JobRequestProvider>(context, listen: false);
      await jobRequestProvider.addJobRequest(
        JobRequest(
          id: '',
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          status: JobRequestStatus.pending,
          dateAdded: _date,
          subtitle: _nameController.text.trim(),
          avatar: null,
          time: _formatTimeOfDay(_time),
          assigned: false,
          priority: _selectedPriority,
        ),
      );
      setState(() {
        _submitMessage = 'Job request submitted successfully!';
      });
      _clearForm();
      await _fetchSalespersons();
      try {
        final salespersonProvider = Provider.of<SalespersonProvider>(context, listen: false);
        await salespersonProvider.fetchSalespersons();
      } catch (_) {}
      if (widget.onSuccess != null) widget.onSuccess!();
    } catch (e) {
      setState(() {
        _submitMessage = 'Failed to submit job request: \\${e.toString()}';
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Job Request Form',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1B2330),
                  ),
            ),
            const SizedBox(height: 16),
            if (_submitMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _submitMessage!,
                  style: const TextStyle(color: Colors.green, fontSize: 14),
                ),
              ),
            if (_validationError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _validationError!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
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
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: _date ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (selectedDate != null) {
                        setState(() {
                          _date = selectedDate;
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Date',
                          hintText: _date != null
                              ? DateFormat('dd/MM/yyyy').format(_date!)
                              : 'Select a date',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final selectedTime = await showTimePicker(
                        context: context,
                        initialTime: _time ?? TimeOfDay.now(),
                      );
                      if (selectedTime != null) {
                        setState(() {
                          _time = selectedTime;
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Time',
                          hintText: _formatTimeOfDay(_time).isNotEmpty
                              ? _formatTimeOfDay(_time)
                              : 'Select a time',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF5350),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitJobRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7DE2D1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Submit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
