import 'package:flutter/foundation.dart';
import '../models/job.dart';
import '../services/design_service.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // No longer used directly
// import 'dart:convert'; // No longer used directly

class JobProvider with ChangeNotifier {
  final DesignService _designService;
  List<Job> _jobs = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Job> get jobs => _jobs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Job> get approvedJobs => _jobs.where((job) => job.status == JobStatus.approved).toList();
  List<Job> get pendingJobs => _jobs.where((job) => job.status == JobStatus.pending).toList();
  List<Job> get inProgressJobs => _jobs.where((job) => job.status == JobStatus.inProgress).toList();

  JobProvider(this._designService) {
    _fetchJobs(); // Renamed from _loadJobs for clarity
  }

  Future<void> _fetchJobs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();    try {
      _jobs = await _designService.getJobs();
      if (_jobs.isEmpty) {
        _errorMessage = 'No jobs found';
      }
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('Error fetching jobs from service: $e');
      }
      // Don't fallback to sample data in production
      _jobs = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _loadSampleJobs() {
    final now = DateTime.now();
    
    _jobs = [
      Job(
        jobNo: '#1001',
        clientName: 'Jim Gorge',
        email: 'jim@example.com',
        phoneNumber: '(603) 555-0123',
        address: 'House no. 12, Chicago',
        dateAdded: now,
        status: JobStatus.approved,
      ),
      Job(
        jobNo: '#1002',
        clientName: 'Jane Smith',
        email: 'jane@example.com',
        phoneNumber: '(219) 555-0114',
        address: '45 Park Avenue, New York',
        dateAdded: now.subtract(const Duration(days: 1)),
        status: JobStatus.pending,
      ),
      Job(
        jobNo: '#1003',
        clientName: 'Ace Corp',
        email: 'info@acecorp.com',
        phoneNumber: '(319) 555-0115',
        address: '789 Business Park, Boston',
        dateAdded: now.subtract(const Duration(days: 2)),
        status: JobStatus.inProgress,
      ),
      Job(
        jobNo: '#1004',
        clientName: 'Bob Johnson',
        email: 'bob@example.com',
        phoneNumber: '(229) 555-0109',
        address: '123 Main St, Seattle',
        dateAdded: now.subtract(const Duration(days: 3)),
        status: JobStatus.inProgress,
      ),
      Job(
        jobNo: '#1005',
        clientName: 'Brooklyn Simmons',
        email: 'brooklyn@example.com',
        phoneNumber: '(603) 555-0123',
        address: '456 Elm St, Chicago',
        dateAdded: now,
        status: JobStatus.inProgress,
      ),
      Job(
        jobNo: '#1006',
        clientName: 'John Doe',
        email: 'john@example.com',
        phoneNumber: '(219) 555-0114',
        address: '789 Oak St, New York',
        dateAdded: now.subtract(const Duration(days: 1)),
        status: JobStatus.pending,
      ),
      Job(
        jobNo: '#1007',
        clientName: 'Sana Jin',
        email: 'sana@example.com',
        phoneNumber: '(319) 555-0115',
        address: '101 Pine St, Boston',
        dateAdded: now.subtract(const Duration(days: 2)),
        status: JobStatus.inProgress,
      ),
      Job(
        jobNo: '#1008',
        clientName: 'Fin Ota',
        email: 'fin@example.com',
        phoneNumber: '(229) 555-0109',
        address: '202 Maple St, Seattle',
        dateAdded: now.subtract(const Duration(days: 3)),
        status: JobStatus.inProgress,
      ),
    ];
  }

  Future<void> addJob(Job job) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final newJob = await _designService.createJob(job);
      _jobs.add(newJob); // Assuming service returns the created job with potential updates (e.g., ID)
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('Error adding job via service: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateJob(Job updatedJob) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final returnedJob = await _designService.updateJob(updatedJob);
      final index = _jobs.indexWhere((job) => job.id == returnedJob.id);
      if (index != -1) {
        _jobs[index] = returnedJob;
      } else {
        // If the job wasn't in the list, perhaps add it or log an error
        print('JobProvider: Updated job ID ${returnedJob.id} not found in local list.');
      }
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('Error updating job via service: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteJob(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _designService.deleteJob(id);
      _jobs.removeWhere((job) => job.id == id);
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('Error deleting job via service: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Job? getJobById(String id) {
    try {
      return _jobs.firstWhere((job) => job.id == id);
    } catch (e) {
      return null;
    }
  }

  Job? getJobByNumber(String jobNo) {
    try {
      return _jobs.firstWhere((job) => job.jobNo == jobNo);
    } catch (e) {
      return null;
    }
  }
}