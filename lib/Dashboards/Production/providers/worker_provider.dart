import 'package:flutter/foundation.dart';
import '../models/worker.dart';
import '../services/production_service.dart';

class WorkerProvider with ChangeNotifier {
  final ProductionService _productionService;
  List<Worker> _workers = [];
  bool _isLoading = false;
  String? _errorMessage;

  WorkerProvider(this._productionService) {
    fetchWorkers();
  }

  List<Worker> get workers => _workers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchWorkers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();    try {
      final response = await _productionService.getProductionWorkers();      _workers = response
          .where((workerData) => 
            workerData['id'] != null && 
            workerData['full_name'] != null && 
            workerData['phone'] != null &&
            workerData['role'] == 'prod_labour'
          )
          .map((workerData) => Worker.fromJson({
            'id': workerData['id'].toString(),
            'full_name': workerData['full_name'].toString(),
            'phone': workerData['phone'].toString(),
            'role': 'prod_labour',
            'branch_id': workerData['branch_id'],
            'image': 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(workerData['full_name'].toString())}&background=random',
            'is_available': workerData['is_available'],
            'assigned_job': workerData['assigned_job'],
          })).toList();

      // Debug print to see the processed workers
      if (kDebugMode) {
        print('Processed workers in provider:');
        for (var worker in _workers) {
          print('  ${worker.name} - Available: ${worker.isAvailable}, Assigned: ${worker.assigned}, AssignedJob: ${worker.assignedJob}');
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('Error fetching workers: $_errorMessage');
      }
      _workers = [];
    }

    _isLoading = false;
    notifyListeners();
  }  Future<void> assignWorker(String workerId, String jobId) async {
    try {
      await _productionService.assignWorkerToJob(jobId, workerId);
      // Update the worker's assigned status locally
      final index = _workers.indexWhere((w) => w.id == workerId);
      if (index != -1) {
        _workers[index] = _workers[index].copyWith(
          assigned: true, 
          assignedJob: jobId,
          isAvailable: false // Worker is no longer available when assigned
        );
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error assigning worker: $e');
      }
      rethrow;
    }
  }
}
