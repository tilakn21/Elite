import '../models/job_request.dart';
import '../models/salesperson.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      avatar: 'assets/images/avatars/avatar1.png', // Placeholder path
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
      avatar: 'assets/images/avatars/avatar2.png', // Placeholder path
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
      avatar: 'assets/images/avatars/avatar3.png', // Placeholder path
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

  // Add a new job to Supabase (jobs table)
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
    void Function()? onJobAdded, // callback after job is added
  }) async {
    final supabase = Supabase.instance.client;
    final now = DateTime.now().toUtc().toIso8601String();
    final address = '$streetAddress, $streetNumber, $town, $postcode';
    final receptionistJson = {
      'customerName': customerName,
      'phone': phone,
      'shopName': shopName,
      'address': address,
      'dateOfAppointment': dateOfAppointment,
      'dateOfVisit': dateOfVisit,
      'timeOfVisit': timeOfVisit,
      'assignedSalesperson': assignedSalesperson,
      'createdBy': createdBy,
      'createdAt': now,
    };
    try {
      await supabase
          .from('jobs')
          .insert({
            'status': 'reception',
            'created_at': now,
            'receptionist': receptionistJson,
          })
          .select()
          .single();
      if (onJobAdded != null) {
        onJobAdded();
      }
      // Fetch jobs again after adding
      await fetchJobRequestsFromSupabase();
    } on PostgrestException catch (e) {
      throw Exception('Failed to add job: ${e.message}');
    } catch (e) {
      throw Exception('Failed to add job: $e');
    }
  }

  // Fetch all employees with id starting with 'sal' from Supabase
  Future<List<Salesperson>> fetchSalespersonsFromSupabase() async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('employee')
        .select('id, full_name, is_available')
        .ilike('id', 'sal%');
    return List<Map<String, dynamic>>.from(response)
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
        .select('id, status, created_at, receptionist');
    return List<Map<String, dynamic>>.from(response).map<JobRequest>((e) {
      final receptionist = e['receptionist'] as Map<String, dynamic>?;
      return JobRequest(
        id: e['id']?.toString() ?? '',
        name: receptionist?['customerName'] ?? '',
        phone: receptionist?['phone'] ?? '',
        email: receptionist?['createdBy'] ?? '',
        status: _parseJobStatus(e['status']),
        dateAdded: e['created_at'] != null ? DateTime.tryParse(e['created_at']) : null,
        subtitle: receptionist?['shopName'] ?? '',
        avatar: '',
        time: receptionist?['timeOfVisit'] ?? '',
        assigned: receptionist?['assignedSalesperson'] != null,
      );
    }).toList();
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
}
