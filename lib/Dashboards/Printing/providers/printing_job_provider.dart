import 'package:flutter/foundation.dart';
import '../models/printing_job.dart';
import '../services/printing_service.dart';

class PrintingJobProvider with ChangeNotifier {
  final PrintingService _printingService;

  PrintingJobProvider(this._printingService) {
    _fetchPrintingJobs();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<PrintingJob> _printingJobs = [];
  List<PrintingJob> get printingJobs => List.unmodifiable(_printingJobs);

  Future<void> _fetchPrintingJobs() async {
    _isLoading = true;
    _errorMessage = null;
    // Notify listeners at the beginning of the fetch operation if you want to show immediate loading
    // For this initial setup, we'll notify after the try-catch to batch notifications.
    // notifyListeners(); 

    try {
      _printingJobs = await _printingService.getPrintingJobs();
    } catch (e) {
      _errorMessage = e.toString();
      _printingJobs = []; // Clear or load sample/error state data if desired
      // Consider logging the error for debugging
      if (kDebugMode) {
        print('Error fetching printing jobs: $_errorMessage');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  // Method to allow manual refresh if needed
  Future<void> refreshPrintingJobs() async {
    await _fetchPrintingJobs();
  }

  // Update printing job status
  Future<void> updateJobStatus(String jobId, PrintingStatus newStatus, {String? feedback}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedJob = await _printingService.updatePrintingJobStatus(jobId, newStatus, feedback: feedback);
      final index = _printingJobs.indexWhere((job) => job.id == jobId);
      if (index != -1) {
        _printingJobs[index] = updatedJob;
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('Error updating printing job status: $_errorMessage');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  // Start printing job and update the job in the list
  Future<PrintingJob> startPrintingJob(String jobId, String designImageUrl) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedJob = await _printingService.startPrintingJob(jobId, designImageUrl);
      final index = _printingJobs.indexWhere((job) => job.id == jobId);
      if (index != -1) {
        _printingJobs[index] = updatedJob;
      }
      _errorMessage = null;
      return updatedJob;
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('Error starting printing job: $_errorMessage');
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  // Complete a printing job
  Future<PrintingJob> completePrintingJob(String jobId, {String? feedback}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedJob = await _printingService.completePrintingJob(jobId, feedback: feedback);
      final index = _printingJobs.indexWhere((job) => job.id == jobId);
      if (index != -1) {
        _printingJobs[index] = updatedJob;
      }
      _errorMessage = null;
      return updatedJob;
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('Error completing printing job: $_errorMessage');
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Reprint a job
  Future<PrintingJob> reprintJob(String jobId, String designImageUrl, {String? feedback}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedJob = await _printingService.reprintJob(jobId, designImageUrl, feedback: feedback);
      final index = _printingJobs.indexWhere((job) => job.id == jobId);
      if (index != -1) {
        _printingJobs[index] = updatedJob;
      }
      _errorMessage = null;
      return updatedJob;
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('Error reprinting job: $_errorMessage');
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Submit job for review
  Future<PrintingJob> submitJobForReview(String jobId, {String? feedback}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedJob = await _printingService.submitJobForReview(jobId, feedback: feedback);
      final index = _printingJobs.indexWhere((job) => job.id == jobId);
      if (index != -1) {
        _printingJobs[index] = updatedJob;
      }
      _errorMessage = null;
      return updatedJob;
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('Error submitting job: $_errorMessage');
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
