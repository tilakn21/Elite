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

  // TODO: Implement other provider methods for updating, assigning, etc.
  // These would typically call corresponding methods in _printingService
  // and then update the state and notify listeners.
  // Example:
  // Future<void> updateJobStatus(String jobId, PrintingStatus newStatus) async {
  //   _isLoading = true;
  //   notifyListeners();
  //   try {
  //     final updatedJob = await _printingService.updatePrintingJobStatus(jobId, newStatus);
  //     final index = _printingJobs.indexWhere((job) => job.id == jobId);
  //     if (index != -1) {
  //       _printingJobs[index] = updatedJob;
  //     }
  //     _errorMessage = null;
  //   } catch (e) {
  //     _errorMessage = e.toString();
  //      if (kDebugMode) {
  //        print('Error updating job status: $_errorMessage');
  //      }
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }
}
