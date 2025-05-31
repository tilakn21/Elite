import 'package:flutter/foundation.dart';
import '../models/production_job.dart';
import '../services/production_service.dart';

class ProductionJobProvider with ChangeNotifier {
  final ProductionService _productionService;

  ProductionJobProvider(this._productionService) {
    fetchProductionJobs();
  }

  List<ProductionJob> _jobs = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ProductionJob> get jobs => _jobs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProductionJobs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _jobs = await _productionService.fetchProductionJobs();
      
      // Print fetched data in a structured format
      print('\n=== Production Jobs Data ===');
      print('Total jobs found: ${_jobs.length}\n');
      
      for (var job in _jobs) {
        print('Job Details:');
        print('  ID: ${job.id}');
        print('  Job No: ${job.jobNo}');
        print('  Client: ${job.clientName}');
        print('  Due Date: ${job.dueDate.toString()}');
        print('  Description: ${job.description}');
        print('  Status: ${job.status.label}');
        print('  Action: ${job.action}');
        
        // Print JSONB data if available
        if (job.receptionistjsonb != null) {
          print('\n  Receptionist Data:');
          job.receptionistjsonb!.forEach((key, value) {
            print('    $key: $value');
          });
        }
        
        if (job.salespersonjsonb != null) {
          print('\n  Salesperson Data:');
          job.salespersonjsonb!.forEach((key, value) {
            print('    $key: $value');
          });
        }
        
        if (job.designjsonb != null) {
          print('\n  Design Data:');
          job.designjsonb!.forEach((key, value) {
            print('    $key: $value');
          });
        }
        
        print('\n' + '-' * 50 + '\n');
      }
      
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('Error fetching production jobs: $_errorMessage');
      }
    }
    _isLoading = false;
    notifyListeners();
  }
  Future<void> updateJobStatus(String jobId, JobStatus newStatus, {String? feedback}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _productionService.updateProductionJobStatus(jobId, newStatus, feedback: feedback);
      // Refresh the specific job or the whole list
      // For simplicity, let's refetch the specific job or update it locally
      final index = _jobs.indexWhere((job) => job.id == jobId);
      if (index != -1) {
        final updatedJob = await _productionService.getProductionJobDetails(jobId);
        _jobs[index] = updatedJob;
      } else {
        // If not found, maybe refetch all as a fallback, or handle error
        await fetchProductionJobs(); 
      }
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('Error updating job status for $jobId: $_errorMessage');
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> assignWorkerToJob(String jobId, String workerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _productionService.assignWorkerToJob(jobId, workerId);
      // Potentially update the job details if the assignment changes job state
      // For now, we can just log or refetch if necessary
      print('Provider: Worker $workerId assigned to job $jobId. Consider refreshing job details.');
      // Example: Refetch details for the specific job
      final index = _jobs.indexWhere((job) => job.id == jobId);
      if (index != -1) {
        final updatedJob = await _productionService.getProductionJobDetails(jobId);
        _jobs[index] = updatedJob; 
      }
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('Error assigning worker for job $jobId: $_errorMessage');
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  // Add other methods like addJob, deleteJob as needed
}
