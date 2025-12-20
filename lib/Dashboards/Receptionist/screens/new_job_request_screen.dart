import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../widgets/sidebar.dart';
import '../widgets/topbar.dart';
import '../providers/job_request_provider.dart';

class NewJobRequestScreen extends StatefulWidget {
  final String? receptionistId;
  const NewJobRequestScreen({Key? key, this.receptionistId}) : super(key: key);

  @override
  State<NewJobRequestScreen> createState() => _NewJobRequestScreenState();
}

class _NewJobRequestScreenState extends State<NewJobRequestScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  String _receptionistName = '';
  String _branchName = '';
  String _receptionistId = ''; // Will be set from widget parameter

  @override
  void initState() {
    super.initState();
    // Set receptionistId from widget parameter or use empty string if null
    _receptionistId = widget.receptionistId ?? '';
    print('[NEW_JOB] Using receptionist ID: $_receptionistId');
    // Refresh job requests when screen is opened
    Future.microtask(() {
      Provider.of<JobRequestProvider>(context, listen: false).fetchJobRequests();
    });
    _fetchReceptionistAndBranch();
  }

  Future<void> _fetchReceptionistAndBranch() async {
    if (_receptionistId.isEmpty) {
      print('[NEW_JOB] Warning: Receptionist ID is empty');
      setState(() {
        _receptionistName = 'Unknown';
        _branchName = 'Unknown';
      });
      return;
    }
    
    final service = ReceptionistService();
    try {
      final details = await service.fetchReceptionistDetails(receptionistId: _receptionistId);
      String name = details?['full_name'] ?? '';
      String branchName = '';
      
      if (details != null && details['branch_id'] != null) {
        branchName = await service.fetchBranchName(int.parse(details['branch_id'].toString())) ?? '';
      }
      
      setState(() {
        _receptionistName = name;
        _branchName = branchName;
      });
      print('[NEW_JOB] Fetched details: name=$_receptionistName, branch=$_branchName');
    } catch (e) {
      print('[NEW_JOB] Error fetching receptionist details: $e');
      setState(() {
        _receptionistName = 'Error';
        _branchName = 'Error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 900;
    final double formWidth = isMobile ? double.infinity : (isTablet ? 500 : 800);
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFF6F3FE),
      drawer: isMobile
          ? Drawer(              child: Sidebar(
                selectedIndex: 1,
                isDrawer: true,
                onClose: () => Navigator.of(context).pop(),
                employeeId: _receptionistId.isNotEmpty ? _receptionistId : 'unknown',
              ),
            )
          : null,
      body: Row(
        children: [
          if (!isMobile) Sidebar(selectedIndex: 1, employeeId: _receptionistId.isNotEmpty ? _receptionistId : 'unknown'),
          Expanded(
            child: Column(
              children: [
                TopBar(
                  isDashboard: false,
                  showMenu: isMobile,
                  onMenuTap: () => scaffoldKey.currentState?.openDrawer(),
                  receptionistName: _receptionistName.isNotEmpty ? _receptionistName : 'Receptionist',
                  branchName: _branchName.isNotEmpty ? _branchName : 'Branch',
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        vertical: isMobile ? 8 : 24,
                        horizontal: isMobile ? 0 : 8,
                      ),
                      child: Container(
                        width: formWidth,
                        padding: EdgeInsets.symmetric(
                          vertical: isMobile ? 16 : 32,
                          horizontal: isMobile ? 8 : 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(isMobile ? 0 : 12),
                          boxShadow: [
                            if (!isMobile)
                              BoxShadow(
                                color: Colors.black.withAlpha(10),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                          ],
                        ),
                        child: _JobRequestForm(isMobile: isMobile, receptionistId: _receptionistId),
                      ),
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
    final jobProvider = Provider.of<JobRequestProvider>(context, listen: false);
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
  const _JobRequestFormDialog({required this.onJobAdded, Key? key})
      : super(key: key);
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
                child: Text('Add New Job Request',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
  final String receptionistId;
  const _JobRequestForm({this.isMobile = false, required this.receptionistId});
  @override
  State<_JobRequestForm> createState() => _JobRequestFormState();
}

class _JobRequestFormState extends State<_JobRequestForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController shopNameController = TextEditingController();
  final TextEditingController streetAddressController = TextEditingController();
  final TextEditingController streetNumberController = TextEditingController();
  final TextEditingController townController = TextEditingController();
  final TextEditingController postcodeController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController dateOfVisitController = TextEditingController();
  final TextEditingController dateOfAppointmentController = TextEditingController();
  final TextEditingController totalAmountController = TextEditingController(); // Added for total amount

  String? selectedSalespersonId;
  String? selectedSalespersonName;
  List<Map<String, String>> availableSalespersons = [];
  bool _isLoadingSalespersons = false;

  bool _isSubmitting = false;
  String? _submitMessage;
  final ReceptionistService _receptionistService = ReceptionistService();
  final _formKey = GlobalKey<FormState>();
  // Track invalid fields for highlighting
  Set<String> _invalidFields = {};
  @override
  void initState() {
    super.initState();
    // Debug print to check if we get the correct ID
    print('[JOB_FORM] Received receptionist ID: ${widget.receptionistId}');
    // Set date of appointment to today (read-only)
    final now = DateTime.now();
    dateOfAppointmentController.text = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
    _fetchSalespersons();
  }

  Future<void> _fetchSalespersons() async {
    try {
      final salespersonProvider =
          Provider.of<SalespersonProvider>(context, listen: false);
      await salespersonProvider.fetchSalespersons();
      setState(() {
        _salespersons
            .addAll(salespersonProvider.salespersons.map((s) => s.name));
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

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    shopNameController.dispose();
    streetAddressController.dispose();
    streetNumberController.dispose();
    townController.dispose();
    postcodeController.dispose();
    dateController.dispose();
    timeController.dispose();
    dateOfVisitController.dispose();
    dateOfAppointmentController.dispose();
    totalAmountController.dispose(); // Dispose total amount controller
    super.dispose();
  }

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
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
  }  Future<void> _submitJobRequest() async {
    setState(() {
      _invalidFields.clear();
    });
    if (!_validateForm()) {
      return;
    }
    setState(() {
      _isSubmitting = true;
      _submitMessage = null;
    });    try {
      // Get receptionistId directly from the widget
      final String receptionistId = widget.receptionistId;
      
      if (receptionistId.isEmpty) {
        throw Exception('Receptionist ID is missing. Please log in again.');
      }
      
      print('[JOB_REQUEST] Using receptionist ID for job creation: $receptionistId');
      
      // Prepare accountant JSONB
      final String totalAmountText = totalAmountController.text.trim();
      final double? totalAmount = double.tryParse(totalAmountText);
      final Map<String, dynamic> accountantJson = {
        'total_amount': totalAmount ?? 0,
        'amount_paid': 0,
        'amount_due': totalAmount ?? 0,
      };      // Upload job to Supabase
      await _receptionistService.addJobToSupabase(
        customerName: nameController.text.trim(),
        phone: phoneController.text.trim(),
        shopName: shopNameController.text.trim(),
        streetAddress: streetAddressController.text.trim(),
        streetNumber: streetNumberController.text.trim(),
        town: townController.text.trim(),
        postcode: postcodeController.text.trim(),
        dateOfAppointment: dateOfAppointmentController.text.trim(),
        dateOfVisit: dateOfVisitController.text.trim(),
        timeOfVisit: timeController.text.trim(),
        assignedSalesperson: selectedSalespersonId,
        createdBy: receptionistId, // Use authenticated receptionist ID
        accountant: accountantJson, // Pass accountant JSONB
        onJobAdded: () async {
          // Optionally refresh job requests after adding
          try {
            final jobRequestProvider = Provider.of<JobRequestProvider>(context, listen: false);
            await jobRequestProvider.fetchJobRequests();
          } catch (_) {}
        },
      );
      setState(() {
        _submitMessage = 'Job request submitted successfully!';
      });
      _clearForm();
      await _fetchSalespersons();
      try {
        final salespersonProvider =
            Provider.of<SalespersonProvider>(context, listen: false);
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

  bool _validateForm() {
    final phone = phoneController.text.trim();
    final postcode = postcodeController.text.trim();
    final phoneRegExp = RegExp(r'^[0-9]{8,}$');
    final postcodeRegExp = RegExp(r'^[0-9]{4,8}$');
    List<String> missingFields = [];
    _invalidFields.clear();
    if (nameController.text.trim().isEmpty) {
      missingFields.add('Name');
      _invalidFields.add('name');
    }
    if (phone.isEmpty) {
      missingFields.add('Phone number');
      _invalidFields.add('phone');
    } else if (!phoneRegExp.hasMatch(phone)) {
      missingFields.add('Valid phone number (8+ digits, numbers only)');
      _invalidFields.add('phone');
    }
    if (shopNameController.text.trim().isEmpty) {
      missingFields.add('Shop name');
      _invalidFields.add('shopName');
    }
    if (streetAddressController.text.trim().isEmpty) {
      missingFields.add('Street address');
      _invalidFields.add('streetAddress');
    }
    if (streetNumberController.text.trim().isEmpty) {
      missingFields.add('Street number');
      _invalidFields.add('streetNumber');
    }
    if (townController.text.trim().isEmpty) {
      missingFields.add('Town');
      _invalidFields.add('town');
    }
    if (postcode.isEmpty) {
      missingFields.add('Postcode');
      _invalidFields.add('postcode');
    } else if (!postcodeRegExp.hasMatch(postcode)) {
      missingFields.add('Valid postcode (4-8 digits, numbers only)');
      _invalidFields.add('postcode');
    }
    // Remove dateController (date of appointment) from validation
    if (dateOfVisitController.text.trim().isEmpty) {
      missingFields.add('Date of visit');
      _invalidFields.add('dateOfVisit');
    }
    if (timeController.text.trim().isEmpty) {
      missingFields.add('Time of visit');
      _invalidFields.add('timeOfVisit');
    }
    if (selectedSalespersonId == null) {
      missingFields.add('Salesperson');
      _invalidFields.add('salesperson');
    }
    // Validate total amount
    final totalAmountText = totalAmountController.text.trim();
    final totalAmount = double.tryParse(totalAmountText);
    if (totalAmountText.isEmpty) {
      missingFields.add('Total amount');
      _invalidFields.add('totalAmount');
    } else if (totalAmount == null || totalAmount < 0) {
      missingFields.add('Valid total amount (number >= 0)');
      _invalidFields.add('totalAmount');
    }
    if (missingFields.isNotEmpty) {
      setState(() {
        _submitMessage = 'Please fill/enter: ' + missingFields.join(', ');
      });
      return false;
    }
    setState(() {
      _submitMessage = null;
    });
    return true;
  }

  void _clearForm() {
    nameController.clear();
    phoneController.clear();
    shopNameController.clear();
    streetAddressController.clear();
    streetNumberController.clear();
    townController.clear();
    postcodeController.clear();
    // dateController.clear(); // No longer used
    timeController.clear();
    dateOfVisitController.clear();
    totalAmountController.clear(); // Clear total amount
    setState(() {
      selectedSalespersonId = null;
      selectedSalespersonName = null;
    });
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
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
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
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
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
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
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
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Submit'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildFormFields(bool isMobile) {
    return [
      ..._buildLeftFields(),
      const SizedBox(height: 20),
      ..._buildRightFields(),
      const SizedBox(height: 20),
      _Label('Total Amount', tooltip: 'Total job amount (required)'),
      _InputField(
        hint: 'Enter total amount',
        controller: totalAmountController,
        error: _invalidFields.contains('totalAmount'),
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        helperText: _invalidFields.contains('totalAmount') ? 'Enter a valid amount (number >= 0)' : null,
      ),
    ];
  }

  List<Widget> _buildLeftFields() {
    return [
      _Label('Name', tooltip: 'Customer full name'),
      _InputField(
        hint: 'Enter name',
        controller: nameController,
        error: _invalidFields.contains('name'),
      ),
      SizedBox(height: 20),
      _Label('Phone number', tooltip: 'At least 8 digits, numbers only'),
      _InputField(
        hint: 'Enter phone number',
        controller: phoneController,
        error: _invalidFields.contains('phone'),
        keyboardType: TextInputType.number,
        helperText: _invalidFields.contains('phone') ? 'Enter at least 8 digits, numbers only' : null,
      ),
      SizedBox(height: 20),
      _Label('Shop name', tooltip: 'Business/shop name'),
      _InputField(
        hint: 'Enter shop name',
        controller: shopNameController,
        error: _invalidFields.contains('shopName'),
      ),
      SizedBox(height: 20),
      _Label('Street address', tooltip: 'Street name (no number)'),
      _InputField(
        hint: 'Enter street address',
        controller: streetAddressController,
        error: _invalidFields.contains('streetAddress'),
      ),
      SizedBox(height: 20),
      _Label('Date of appointment', tooltip: 'Auto-filled as today'),
      _InputField(
        hint: '',
        controller: dateOfAppointmentController,
        readOnly: true,
        error: false,
      ),
      SizedBox(height: 20),
      _Label('Total Amount', tooltip: 'Total job amount (required)'),
      _InputField(
        hint: 'Enter total amount',
        controller: totalAmountController,
        error: _invalidFields.contains('totalAmount'),
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        helperText: _invalidFields.contains('totalAmount') ? 'Enter a valid amount (number >= 0)' : null,
      ),
    ];
  }

  List<Widget> _buildRightFields() {
    return [
      _Label('Street number', tooltip: 'Building/street number'),
      _InputField(
        hint: 'Enter street number',
        controller: streetNumberController,
        error: _invalidFields.contains('streetNumber'),
      ),
      SizedBox(height: 20),
      _Label('Town', tooltip: 'Town or city'),
      _InputField(
        hint: 'Enter town',
        controller: townController,
        error: _invalidFields.contains('town'),
      ),
      SizedBox(height: 20),
      _Label('Postcode', tooltip: '4-8 digits, numbers only'),
      _InputField(
        hint: 'Enter postcode',
        controller: postcodeController,
        error: _invalidFields.contains('postcode'),
        keyboardType: TextInputType.number,
        helperText: _invalidFields.contains('postcode') ? 'Enter 4-8 digits, numbers only' : null,
      ),
      SizedBox(height: 20),
      _Label('Date of visit', tooltip: 'Date the salesperson will visit'),
      _InputField(
        hint: 'Select date of visit',
        controller: dateOfVisitController,
        readOnly: true,
        onTap: () => _pickDateOfVisit(context),
        suffixIcon: Icon(Icons.calendar_today, size: 18, color: Color(0xFFBDBDBD)),
        error: _invalidFields.contains('dateOfVisit'),
      ),
      SizedBox(height: 20),
      _Label('Time of visit', tooltip: 'Time the salesperson will visit'),
      _InputField(
        hint: 'Select time',
        controller: timeController,
        readOnly: true,
        onTap: () => _pickTime(context),
        suffixIcon: Icon(Icons.access_time, size: 18, color: Color(0xFFBDBDBD)),
        error: _invalidFields.contains('timeOfVisit'),
      ),
    ];
  }
}

class _Label extends StatelessWidget {
  final String text;
  final String? tooltip;
  const _Label(this.text, {this.tooltip, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF7B7B7B),
            fontWeight: FontWeight.w500,
          ),
        ),
        if (tooltip != null)
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Tooltip(
              message: tooltip!,
              child: Icon(Icons.info_outline, size: 15, color: Color(0xFFBDBDBD)),
            ),
          ),
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  final String hint;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool error;
  final TextInputType? keyboardType;
  final String? helperText;
  const _InputField({
    required this.hint,
    this.suffixIcon,
    this.controller,
    this.readOnly = false,
    this.onTap,
    this.error = false,
    this.keyboardType,
    this.helperText,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        boxShadow: error
            ? [
                BoxShadow(
                  color: Colors.red.withOpacity(0.15),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 13, color: Color(0xFFBDBDBD)),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          filled: true,
          fillColor: Color(0xFFF8F8F8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide.none,
          ),
          suffixIcon: suffixIcon,
          errorText: error ? '' : null,
          errorBorder: error
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: Colors.red, width: 1.5),
                )
              : null,
          helperText: helperText,
          helperStyle: TextStyle(color: Colors.red, fontSize: 11),
        ),
      ),
    );
  }
}
