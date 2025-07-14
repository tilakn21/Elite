import '../models/job_request.dart';
import '../models/salesperson.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class ReceptionistService {
  final Uuid _uuid = const Uuid();

  // Mock data for JobRequests
  final List<JobRequest> _mockJobRequests = [
    JobRequest(
      id: 'jr1',
      name: 'Alice Wonderland',
      phone: '123-456-7890',
      email: 'alice@example.com',
      status: JobRequestStatus.pending,
      dateAdded: DateTime.now().subtract(const Duration(days: 1)),
      subtitle: 'New kitchen design inquiry',
      avatar: 'assets/images/avatars/default_avatar.png', // Placeholder path
      time: '10:30 AM',
      assigned: false,
    ),
    JobRequest(
      id: 'jr2',
      name: 'Bob The Builder',
      phone: '987-654-3210',
      email: 'bob@example.com',
      status: JobRequestStatus.approved,
      dateAdded: DateTime.now().subtract(const Duration(hours: 5)),
      subtitle: 'Approved for site visit',
      avatar: 'assets/images/avatars/default_avatar.png', // Placeholder path
      time: '02:15 PM',
      assigned: true,
    ),
    JobRequest(
      id: 'jr3',
      name: 'Charlie Brown',
      phone: '555-123-4567',
      email: 'charlie@example.com',
      status: JobRequestStatus.declined,
      dateAdded: DateTime.now().subtract(const Duration(days: 2)),
      subtitle: 'Not interested at this time',
      avatar: 'assets/images/avatars/default_avatar.png', // Placeholder path
      time: '09:00 AM',
      assigned: false,
    ),
  ];

  // Mock data for Salespersons
  final List<Salesperson> _mockSalespersons = [
    Salesperson(
      id: 'sp1',
      name: 'Sarah Connor',
      status: SalespersonStatus.available,
      avatar: 'assets/images/sales/sales1.png', // Placeholder path
      subtitle: 'Ready for new assignments',
    ),
    Salesperson(
      id: 'sp2',
      name: 'John Doe',
      status: SalespersonStatus.onVisit,
      avatar: 'assets/images/sales/sales2.png', // Placeholder path
      subtitle: 'Currently on a client visit',
    ),
    Salesperson(
      id: 'sp3',
      name: 'Jane Smith',
      status: SalespersonStatus.busy,
      avatar: 'assets/images/sales/sales3.png', // Placeholder path
      subtitle: 'Wrapping up previous task',
    ),
  ];

  // Fetch all job requests
  Future<List<JobRequest>> fetchJobRequests() async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    return List.from(_mockJobRequests);
  }

  // Fetch a single job request by ID
  Future<JobRequest?> getJobRequestDetails(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _mockJobRequests.firstWhere((job) => job.id == id);
    } catch (e) {
      return null;
    }
  }

  // Add a new job request
  Future<JobRequest> addJobRequest(JobRequest jobRequest) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newJobRequest = JobRequest(
      id: _uuid.v4(),
      name: jobRequest.name,
      phone: jobRequest.phone,
      email: jobRequest.email,
      status: jobRequest.status,
      dateAdded: jobRequest.dateAdded ?? DateTime.now(),
      subtitle: jobRequest.subtitle,
      avatar: jobRequest.avatar, // Ensure placeholder or actual path
      time: jobRequest.time,
      assigned: jobRequest.assigned,
    );
    _mockJobRequests.add(newJobRequest);
    return newJobRequest;
  }

  // Update an existing job request (e.g., status, assignment)
  Future<JobRequest?> updateJobRequest(String id, {JobRequestStatus? status, bool? assigned, String? salespersonId}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    int index = _mockJobRequests.indexWhere((job) => job.id == id);
    if (index != -1) {
      var currentJob = _mockJobRequests[index];
      _mockJobRequests[index] = JobRequest(
        id: currentJob.id,
        name: currentJob.name,
        phone: currentJob.phone,
        email: currentJob.email,
        status: status ?? currentJob.status,
        dateAdded: currentJob.dateAdded,
        subtitle: currentJob.subtitle, 
        avatar: currentJob.avatar,
        time: currentJob.time,
        assigned: assigned ?? currentJob.assigned,
      );
      // If assigning a salesperson, you might want to update the subtitle or link them.
      // For now, this is a basic update.
      return _mockJobRequests[index];
    }
    return null;
  }

  // Fetch all salespersons
  Future<List<Salesperson>> fetchSalespersons() async {
    await Future.delayed(const Duration(seconds: 1));
    return List.from(_mockSalespersons);
  }

  // Fetch a single salesperson by ID
  Future<Salesperson?> getSalespersonDetails(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _mockSalespersons.firstWhere((sp) => sp.id == id);
    } catch (e) {
      return null;
    }
  }

  // Update salesperson status
  Future<Salesperson?> updateSalespersonStatus(String id, SalespersonStatus status) async {
    await Future.delayed(const Duration(milliseconds: 500));
    int index = _mockSalespersons.indexWhere((sp) => sp.id == id);
    if (index != -1) {
      var currentSp = _mockSalespersons[index];
       _mockSalespersons[index] = Salesperson(
         id: currentSp.id,
         name: currentSp.name,
         status: status,
         avatar: currentSp.avatar,
         subtitle: currentSp.subtitle, // Subtitle could be updated based on new status
       );
      return _mockSalespersons[index];
    }
    return null;
  }

  // Add a new job to Supabase, now with branch_id logic
  Future<void> addJobToSupabase({
    required String customerName,
    required String phone,
    required String shopName,
    required String streetAddress,
    required String streetNumber,
    required String town,
    required String postcode,
    required String dateOfAppointment,
    required String dateOfVisit,
    required String timeOfVisit,
    required String? assignedSalesperson,
    required String createdBy, // receptionist user id
    Map<String, dynamic>? accountant, // <-- add this
    void Function()? onJobAdded, // callback after job is added
  }) async {
    print('[SUPABASE_JOB] Creating job with receptionist ID: $createdBy');
    final supabase = Supabase.instance.client;
    final now = DateTime.now().toUtc().toIso8601String();
    // --- Fetch branch_id for authenticated receptionist ---
    final branchResult = await supabase
        .from('employee')
        .select('branch_id')
        .eq('id', createdBy)
        .maybeSingle();
    print('[SUPABASE_JOB] Branch result: $branchResult for ID: $createdBy');
    
    final int? branchId = branchResult != null ? int.tryParse(branchResult['branch_id'].toString()) : null;
    print('[SUPABASE_JOB] Branch ID: $branchId');
    // --- END ---
    final receptionistJson = {
      'customerName': customerName,
      'phone': phone,
      'shopName': shopName,
      'streetAddress': streetAddress, // separate
      'streetNumber': streetNumber,   // separate
      'town': town,                   // separate
      'postcode': postcode,           // separate
      'dateOfAppointment': dateOfAppointment,
      'dateOfVisit': dateOfVisit,
      'timeOfVisit': timeOfVisit,
      'assignedSalesperson': assignedSalesperson,
      'createdBy': createdBy,
      'createdAt': now,
    };
    try {
      // Insert job and get the created job's id
      final insertData = {
        'status': 'salesperson assigned',
        'created_at': now,
        'receptionist': receptionistJson,
        if (accountant != null) 'accountant': accountant, // <-- include accountant if provided
        if (branchId != null) 'branch_id': branchId, // <-- include branch_id in jobs table
      };
      final insertedJob = await supabase
          .from('jobs')
          .insert(insertData)
          .select()
          .single();
      final jobId = insertedJob['id'];
      // Update assigned_jobs for the assigned salesperson (append to array safely)
      if (assignedSalesperson != null && jobId != null) {
        // Fetch current assigned_jobs array and number_of_jobs
        final employee = await supabase
            .from('employee')
            .select('assigned_job, number_of_jobs')
            .eq('id', assignedSalesperson)
            .single();
        List<dynamic> currentJobs = employee['assigned_job'] ?? [];
        int numberOfJobs = (employee['number_of_jobs'] ?? 0) as int;
        // Ensure no duplicates and append
        if (!currentJobs.contains(jobId)) {
          currentJobs.add(jobId);
          numberOfJobs += 1;
        }
        // If number_of_jobs >= 4, set is_available to false
        bool isAvailable = numberOfJobs < 4;
        await supabase
            .from('employee')
            .update({
              'assigned_job': currentJobs,
              'number_of_jobs': numberOfJobs,
              'is_available': isAvailable
            })
            .eq('id', assignedSalesperson);
      }
      if (onJobAdded != null) onJobAdded();
    } catch (e) {
      rethrow;
    }
  }

  // Fetch all employees with id starting with 'sal' from Supabase
  Future<List<Salesperson>> fetchSalespersonsFromSupabase() async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('employee')
        .select('id, full_name, is_available, number_of_jobs')
        .ilike('id', 'sal%');
    List<Map<String, dynamic>> employees = List<Map<String, dynamic>>.from(response);
    // Sort: available first (ascending number_of_jobs), then unavailable
    employees.sort((a, b) {
      final aAvailable = a['is_available'] == true ? 0 : 1;
      final bAvailable = b['is_available'] == true ? 0 : 1;
      if (aAvailable != bAvailable) {
        return aAvailable - bAvailable;
      }
      // If both have same availability, sort by number_of_jobs ascending
      final aJobs = (a['number_of_jobs'] ?? 0) as int;
      final bJobs = (b['number_of_jobs'] ?? 0) as int;
      return aJobs.compareTo(bJobs);
    });
    return employees
        .map<Salesperson>((e) => Salesperson(
              id: e['id']?.toString() ?? '',
              name: e['full_name'] ?? '',
              status: (e['is_available'] == true)
                  ? SalespersonStatus.available
                  : SalespersonStatus.busy,
            ))
        .toList();
  }
  

  // Fetch all jobs from Supabase (jobs table, receptionist field)
  Future<List<JobRequest>> fetchJobRequestsFromSupabase() async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('jobs')
        .select('id, job_code, status, created_at, receptionist, assigned_salesperson');
    final jobs = List<Map<String, dynamic>>.from(response);
    // Update salesperson availability in a detached microtask (never blocks UI)
    Future.microtask(() async {
      for (final job in jobs) {
        final status = job['status']?.toString();
        final assignedSalesperson = job['assigned_salesperson'];
        if (assignedSalesperson != null && status != null && status.toLowerCase() != 'salesperson assigned') {
          try {
            await setSalespersonAvailable(assignedSalesperson);
          } catch (_) {}
        }
      }
    });
    final jobRequests = jobs.map<JobRequest>((e) {
      final receptionist = e['receptionist'] as Map<String, dynamic>?;
      final receptionistStatus = receptionist?['status']?.toString().toLowerCase();
      final isAssigned = receptionistStatus == 'completed';
      final jobCode = e['job_code']?.toString() ?? e['id']?.toString() ?? '';
      return JobRequest(
        id: e['id']?.toString() ?? '',
        name: jobCode,
        phone: receptionist?['phone'] ?? '',
        email: receptionist?['createdBy'] ?? '',
        status: _parseJobStatus(e['status']),
        dateAdded: e['created_at'] != null ? DateTime.tryParse(e['created_at']) : null,
        subtitle: receptionist?['shopName'] ?? '',
        avatar: '',
        time: receptionist?['timeOfVisit'] ?? '',
        assigned: isAssigned,
        receptionistJson: receptionist,
      );
    }).toList();
    // Sort by dateAdded descending (most recent first)
    jobRequests.sort((a, b) {
      final aDate = a.dateAdded ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.dateAdded ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });
    return jobRequests;
  }

  // Helper to parse job status from string
  JobRequestStatus _parseJobStatus(dynamic status) {
    switch (status?.toString().toLowerCase()) {
      case 'approved':
        return JobRequestStatus.approved;
      case 'declined':
        return JobRequestStatus.declined;
      case 'pending':
        return JobRequestStatus.pending;
      default:
        return JobRequestStatus.pending;
    }
  }

  // Set is_available to false for a salesperson in Supabase
  Future<void> setSalespersonUnavailable(String salespersonId) async {
    final supabase = Supabase.instance.client;
    try {
      await supabase
          .from('employee')
          .update({'is_available': false})
          .eq('id', salespersonId);
    } on PostgrestException catch (e) {
      throw Exception('Failed to update salesperson availability: \\${e.message}');
    } catch (e) {
      throw Exception('Failed to update salesperson availability: $e');
    }
  }

  // Set is_available to true for a salesperson in Supabase
  Future<void> setSalespersonAvailable(String salespersonId) async {
    final supabase = Supabase.instance.client;
    try {
      await supabase
          .from('employee')
          .update({'is_available': true})
          .eq('id', salespersonId);
    } on PostgrestException catch (e) {
      throw Exception('Failed to update salesperson availability: \\${e.message}');
    } catch (e) {
      throw Exception('Failed to update salesperson availability: $e');
    }
  }

  /// Fetch receptionist's name, role, and branch_id from employee table
  Future<Map<String, dynamic>?> fetchReceptionistDetails({required String receptionistId}) async {
    final supabase = Supabase.instance.client;
    final String id = receptionistId;
    final result = await supabase
        .from('employee')
        .select('full_name, role, branch_id')
        .eq('id', id)
        .maybeSingle();
    return result;
  }

  /// Fetch branch name from branches table using branch_id
  Future<String?> fetchBranchName(int branchId) async {
    final supabase = Supabase.instance.client;
    final result = await supabase
        .from('branches')
        .select('name')
        .eq('id', branchId)
        .maybeSingle();
    return result != null ? result['name'] as String? : null;
  }

  /// Authenticate employee by ID and password (hashed)
  static Future<Map<String, dynamic>?> loginWithIdAndPassword(String empId, String password) async {
    final supabase = Supabase.instance.client;
    // Hash the password (assuming SHA256, update if you use a different hash)
    final hashedPassword = sha256.convert(utf8.encode(password)).toString();
    final result = await supabase
        .from('employee')
        .select('id, full_name, role, branch_id')
        .eq('id', empId)
        .eq('password', hashedPassword)
        .maybeSingle();
    return result;
  }
}
