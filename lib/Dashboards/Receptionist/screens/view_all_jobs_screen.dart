import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_request_provider.dart';
import '../models/job_request.dart';
import '../widgets/sidebar.dart';
import '../widgets/topbar.dart';
import '../services/receptionist_service.dart';

class ViewAllJobsScreen extends StatefulWidget {
  final String? receptionistId;
  const ViewAllJobsScreen({Key? key, this.receptionistId}) : super(key: key);

  @override
  State<ViewAllJobsScreen> createState() => _ViewAllJobsScreenState();
}

class _ViewAllJobsScreenState extends State<ViewAllJobsScreen> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  String selectedStatus = 'All';

  String _receptionistName = '';
  String _branchName = '';
  String _receptionistId = ''; // Will be set from widget parameter

  @override
  void initState() {
    super.initState();
    // Set receptionistId from widget parameter or use empty string if null
    _receptionistId = widget.receptionistId ?? '';
    print('[VIEW_JOBS] Using receptionist ID: $_receptionistId');
    
    WidgetsBinding.instance.addObserver(this);
    // Refresh job requests when screen is opened
    Future.microtask(() {
      Provider.of<JobRequestProvider>(context, listen: false).fetchJobRequests();
    });
    _fetchReceptionistAndBranch();
  }

  Future<void> _fetchReceptionistAndBranch() async {
    if (_receptionistId.isEmpty) {
      print('[VIEW_JOBS] Warning: Receptionist ID is empty');
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
      print('[VIEW_JOBS] Fetched details: name=$_receptionistName, branch=$_branchName');
    } catch (e) {
      print('[VIEW_JOBS] Error fetching receptionist details: $e');
      setState(() {
        _receptionistName = 'Error';
        _branchName = 'Error';
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh job requests when app resumes
      Provider.of<JobRequestProvider>(context, listen: false).fetchJobRequests();
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobRequestProvider = Provider.of<JobRequestProvider>(context);
    final List<JobRequest> jobRequests = jobRequestProvider.jobRequests;
    final bool isLoading = jobRequestProvider.isLoading;
    final double width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 600;
    // Filtered jobs based on search and status
    List<JobRequest> filteredJobs = jobRequests.where((job) {
      final matchesSearch = searchQuery.isEmpty ||
          job.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          job.phone.toLowerCase().contains(searchQuery.toLowerCase()) ||
          job.id.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesStatus = selectedStatus == 'All' ||
          (selectedStatus == 'Assigned' && job.assigned == true) ||
          (selectedStatus == 'Unassigned' && job.assigned != true);
      return matchesSearch && matchesStatus;
    }).toList();
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFF6F3FE),
      drawer: isMobile
          ? Drawer(
              child: Sidebar(
                selectedIndex: 2,
                isDrawer: true,
                onClose: () => Navigator.of(context).pop(),
                employeeId: _receptionistId,
              ),
            )
          : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMobile) Sidebar(selectedIndex: 2, employeeId: _receptionistId),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TopBar(
                  isDashboard: false,
                  showMenu: isMobile,
                  onMenuTap: () => scaffoldKey.currentState?.openDrawer(),
                  receptionistName: _receptionistName.isNotEmpty ? _receptionistName : 'Receptionist',
                  branchName: _branchName.isNotEmpty ? _branchName : 'Branch',
                ),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Add label above search bar
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 12.0),
                                  child: Text(
                                    'Jobs Screen',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1B2330),
                                    ),
                                  ),
                                ),
                                // --- Search and Filter Row ---
                                Row(
                                  children: [
                                    // Search bar
                                    Expanded(
                                      flex: 2,
                                      child: TextField(
                                        controller: searchController,
                                        decoration: InputDecoration(
                                          hintText: 'Search by name, phone, or ID...',
                                          prefixIcon: Icon(Icons.search, size: 20),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: BorderSide(color: Colors.grey[300]!),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            searchQuery = value;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Status filter dropdown
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey[300]!),
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.white,
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: selectedStatus,
                                          icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                                          isExpanded: false,
                                          style: const TextStyle(color: Colors.black87, fontSize: 14),
                                          onChanged: (String? newValue) {
                                            if (newValue != null) {
                                              setState(() {
                                                selectedStatus = newValue;
                                              });
                                            }
                                          },
                                          items: ['All', 'Assigned', 'Unassigned']
                                              .map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                const SizedBox(height: 36),
                                _JobRequestsTable(jobRequests: filteredJobs),
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
    );
  }
}

class _JobRequestsTable extends StatelessWidget {
  final List<JobRequest> jobRequests;
  const _JobRequestsTable({Key? key, required this.jobRequests}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            decoration: const BoxDecoration(
              color: Color(0xFFF9F7FD),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: const [
                Expanded(child: Text('Name', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFBDBDBD), fontSize: 15))),
                Expanded(child: Text('Job Number', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFBDBDBD), fontSize: 15))),
                Expanded(child: Text('Phone number', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFBDBDBD), fontSize: 15))),
                Expanded(child: Text('Date added', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFBDBDBD), fontSize: 15))),
                Expanded(child: Text('STATUS', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFBDBDBD), fontSize: 15))),
                SizedBox(width: 28),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF2F2F2)),
          ...jobRequests.map((row) => _TableRowWidget(row)).toList(),
        ],
      ),
    );
  }
}

class _TableRowWidget extends StatelessWidget {
  final JobRequest row;
  const _TableRowWidget(this.row);
  @override
  Widget build(BuildContext context) {
    return InkWell(      onTap: () {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              width: 600,
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8F6FF),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.person, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                row.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937),
                                ),
                              ),                              Text(
                                'Job Number: ${row.receptionistJson?['jobNo'] ?? row.id}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: row.assigned == true ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            row.assigned == true ? 'Assigned' : 'Unassigned',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
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
                          // Contact Information Card
                          _buildInfoCard(
                            'Contact Information',
                            Icons.contact_phone,
                            [
                              _buildDetailItem('Phone', row.phone, Icons.phone),
                              _buildDetailItem('Email', row.email, Icons.email),
                              _buildDetailItem('Date Added', row.dateAdded != null 
                                ? "${row.dateAdded!.day.toString().padLeft(2, '0')}/${row.dateAdded!.month.toString().padLeft(2, '0')}/${row.dateAdded!.year}"
                                : 'Not specified', Icons.calendar_today),
                              _buildDetailItem('Time', row.time ?? 'Not specified', Icons.access_time),
                            ],
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Job Status Card
                          _buildInfoCard(
                            'Job Status',
                            Icons.work,
                            [
                              _buildDetailItem('Status', row.status.toString().split('.').last, Icons.info),
                              _buildDetailItem('Subtitle', row.subtitle ?? 'Not specified', Icons.description),
                            ],
                          ),
                          
                          // Receptionist Details Card (if available)
                          if (row.receptionistJson != null) ...[
                            const SizedBox(height: 20),
                            _buildReceptionistCard(row.receptionistJson!),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF2F2F2), width: 1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  CircleAvatar(backgroundImage: AssetImage('assets/images/elite_logo.png'), radius: 18),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(row.subtitle ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      Text(row.phone, style: const TextStyle(fontSize: 11, color: Color(0xFFBDBDBD))),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(child: Text(row.name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
            Expanded(child: Text(row.phone, style: const TextStyle(fontSize: 13, color: Color(0xFF7B7B7B)))),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(row.dateAdded != null ? "${row.dateAdded!.day.toString().padLeft(2, '0')}/${row.dateAdded!.month.toString().padLeft(2, '0')}/${row.dateAdded!.year}" : '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1B2330))),
                  Text(row.time ?? '', style: const TextStyle(fontSize: 11, color: Color(0xFFBDBDBD))),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: row.assigned == true ? const Color(0xFF7DE2D1) : const Color(0xFFFFAFAF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      row.assigned == true ? 'Assigned' : 'Unassigned',
                      style: TextStyle(
                        color: row.assigned == true ? const Color(0xFF1B2330) : const Color(0xFFD32F2F),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios, size: 18, color: Color(0xFFBDBDBD)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildInfoCard(String title, IconData icon, List<Widget> children) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE5E7EB)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xFFF9FAFB),
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF8B5CF6), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: children,
          ),
        ),
      ],
    ),
  );
}

Widget _buildDetailItem(String label, String value, IconData icon) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Icon(icon, color: const Color(0xFF6B7280), size: 16),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildReceptionistCard(Map<String, dynamic> receptionistData) {
  // Organize the data into logical sections
  final contactInfo = <String, dynamic>{};
  final locationInfo = <String, dynamic>{};
  final appointmentInfo = <String, dynamic>{};
  final businessInfo = <String, dynamic>{};
  final systemInfo = <String, dynamic>{};

  // Categorize the data
  receptionistData.forEach((key, value) {
    switch (key.toLowerCase()) {
      case 'phone':
      case 'customername':
        contactInfo[key] = value;
        break;
      case 'streetaddress':
      case 'streetnumber':
      case 'town':
      case 'postcode':
        locationInfo[key] = value;
        break;
      case 'dateofvisit':
      case 'timeofvisit':
      case 'dateofappointment':
      case 'assignedsalesperson':
        appointmentInfo[key] = value;
        break;
      case 'shopname':
        businessInfo[key] = value;
        break;
      case 'status':
      case 'createdat':
      case 'createdby':
        systemInfo[key] = value;
        break;
      default:
        systemInfo[key] = value;
    }
  });

  return Column(
    children: [
      // Contact Information
      if (contactInfo.isNotEmpty) ...[
        _buildInfoCard(
          'Customer Contact',
          Icons.person_outline,
          contactInfo.entries.map((e) => 
            _buildDetailItem(_formatFieldName(e.key), e.value?.toString() ?? 'Not specified', _getIconForField(e.key))
          ).toList(),
        ),
        const SizedBox(height: 20),
      ],

      // Location Information
      if (locationInfo.isNotEmpty) ...[
        _buildInfoCard(
          'Location Details',
          Icons.location_on_outlined,
          [
            _buildDetailItem(
              'Full Address',
              _buildFullAddress(locationInfo),
              Icons.home,
            ),
            ...locationInfo.entries.map((e) => 
              _buildDetailItem(_formatFieldName(e.key), e.value?.toString() ?? 'Not specified', _getIconForField(e.key))
            ).toList(),
          ],
        ),
        const SizedBox(height: 20),
      ],

      // Appointment Information
      if (appointmentInfo.isNotEmpty) ...[
        _buildInfoCard(
          'Appointment Details',
          Icons.schedule,
          appointmentInfo.entries.map((e) => 
            _buildDetailItem(_formatFieldName(e.key), _formatFieldValue(e.key, e.value), _getIconForField(e.key))
          ).toList(),
        ),
        const SizedBox(height: 20),
      ],

      // Business Information
      if (businessInfo.isNotEmpty) ...[
        _buildInfoCard(
          'Business Information',
          Icons.store,
          businessInfo.entries.map((e) => 
            _buildDetailItem(_formatFieldName(e.key), e.value?.toString() ?? 'Not specified', _getIconForField(e.key))
          ).toList(),
        ),
        const SizedBox(height: 20),
      ],

      // System Information
      if (systemInfo.isNotEmpty) ...[
        _buildInfoCard(
          'System Information',
          Icons.info_outline,
          systemInfo.entries.map((e) => 
            _buildDetailItem(_formatFieldName(e.key), _formatFieldValue(e.key, e.value), _getIconForField(e.key))
          ).toList(),
        ),
      ],
    ],
  );
}

String _formatFieldName(String fieldName) {
  // Convert camelCase and snake_case to proper titles
  return fieldName
      .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
      .replaceAll('_', ' ')
      .split(' ')
      .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1).toLowerCase())
      .join(' ')
      .trim();
}

String _formatFieldValue(String fieldName, dynamic value) {
  if (value == null) return 'Not specified';
  
  String stringValue = value.toString();
  
  // Special formatting for date fields
  if (fieldName.toLowerCase().contains('date') || fieldName.toLowerCase().contains('createdat')) {
    try {
      DateTime date = DateTime.parse(stringValue);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    } catch (e) {
      return stringValue;
    }
  }
  
  return stringValue;
}

IconData _getIconForField(String fieldName) {
  switch (fieldName.toLowerCase()) {
    case 'phone':
      return Icons.phone;
    case 'customername':
      return Icons.person;
    case 'streetaddress':
    case 'streetnumber':
      return Icons.home;
    case 'town':
    case 'postcode':
      return Icons.location_city;
    case 'dateofvisit':
    case 'dateofappointment':
      return Icons.calendar_today;
    case 'timeofvisit':
      return Icons.access_time;
    case 'assignedsalesperson':
      return Icons.person_pin;
    case 'shopname':
      return Icons.store;
    case 'status':
      return Icons.info;
    case 'createdat':
      return Icons.schedule;
    case 'createdby':
      return Icons.person_outline;
    default:
      return Icons.info_outline;
  }
}

String _buildFullAddress(Map<String, dynamic> locationInfo) {
  final parts = <String>[];
  
  if (locationInfo['streetnumber'] != null && locationInfo['streetnumber'].toString().isNotEmpty) {
    parts.add(locationInfo['streetnumber'].toString());
  }
  if (locationInfo['streetaddress'] != null && locationInfo['streetaddress'].toString().isNotEmpty) {
    parts.add(locationInfo['streetaddress'].toString());
  }
  if (locationInfo['town'] != null && locationInfo['town'].toString().isNotEmpty) {
    parts.add(locationInfo['town'].toString());
  }
  if (locationInfo['postcode'] != null && locationInfo['postcode'].toString().isNotEmpty) {
    parts.add(locationInfo['postcode'].toString());
  }
  
  return parts.isNotEmpty ? parts.join(', ') : 'Not specified';
}


