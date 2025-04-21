import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/job.dart';

class JobProvider with ChangeNotifier {
  List<Job> _jobs = [];
  
  List<Job> get jobs => _jobs;
  
  List<Job> get approvedJobs => _jobs.where((job) => job.status == JobStatus.approved).toList();
  
  List<Job> get pendingJobs => _jobs.where((job) => job.status == JobStatus.pending).toList();
  
  List<Job> get inProgressJobs => _jobs.where((job) => job.status == JobStatus.inProgress).toList();

  JobProvider() {
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jobsJson = prefs.getString('jobs');
      
      if (jobsJson != null) {
        final List<dynamic> decodedJobs = json.decode(jobsJson);
        _jobs = decodedJobs.map((job) => Job.fromJson(job)).toList();
      } else {
        // Load sample data if no jobs are found
        _loadSampleJobs();
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading jobs: $e');
      }
      // Load sample data if there's an error
      _loadSampleJobs();
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

  Future<void> _saveJobs() async {
    final prefs = await SharedPreferences.getInstance();
    final jobsJson = json.encode(_jobs.map((job) => job.toJson()).toList());
    await prefs.setString('jobs', jobsJson);
  }

  Future<void> addJob(Job job) async {
    _jobs.add(job);
    await _saveJobs();
    notifyListeners();
  }

  Future<void> updateJob(Job updatedJob) async {
    final index = _jobs.indexWhere((job) => job.id == updatedJob.id);
    if (index != -1) {
      _jobs[index] = updatedJob;
      await _saveJobs();
      notifyListeners();
    }
  }

  Future<void> deleteJob(String id) async {
    _jobs.removeWhere((job) => job.id == id);
    await _saveJobs();
    notifyListeners();
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
