import 'package:flutter/foundation.dart';
import '../models/job_request.dart';
import '../services/receptionist_service.dart';

class JobRequestProvider with ChangeNotifier {
  final ReceptionistService _receptionistService;

  JobRequestProvider(this._receptionistService) {
    fetchJobRequests();
  }

  List<JobRequest> _jobRequests = [];
  List<JobRequest> get jobRequests => _jobRequests;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchJobRequests() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _jobRequests = await _receptionistService.fetchJobRequestsFromSupabase();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addJobRequest(JobRequest jobRequest) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _receptionistService.addJobRequest(jobRequest);
      // Refresh the list after adding
      await fetchJobRequests();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateJobRequestStatus(
      String jobRequestId, JobRequestStatus status,
      {bool? assigned, String? salespersonId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _receptionistService.updateJobRequest(
        jobRequestId,
        status: status,
        assigned: assigned,
        salespersonId: salespersonId,
      );
      await fetchJobRequests();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateJobRequestPriority(
      String jobRequestId, String priority) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final updatedJob = await _receptionistService
          .updateJobRequest(jobRequestId, priority: priority);
      if (updatedJob != null) {
        final index = _jobRequests.indexWhere((job) => job.id == jobRequestId);
        if (index != -1) {
          _jobRequests[index] = updatedJob;
        }
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
