// lib/Dashboards/Admin/providers/admin_provider.dart
import 'package:flutter/material.dart';
import '../models/admin_job.dart';
import '../models/branch.dart';
import '../models/sales_data.dart';
import '../services/admin_service.dart';

class AdminProvider with ChangeNotifier {
  final AdminService _adminService;

  AdminProvider(this._adminService);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<AdminJob> _adminJobs = [];
  List<AdminJob> get adminJobs => _adminJobs;

  List<Branch> _branchStats = [];
  List<Branch> get branchStats => _branchStats;

  List<SalesData> _salesPerformance = [];
  List<SalesData> get salesPerformance => _salesPerformance;

  double _salesChartMaxY = 100.0;
  double get salesChartMaxY => _salesChartMaxY;

  Future<void> fetchAdminData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch all data concurrently
      final results = await Future.wait([
        _adminService.getAdminJobs(),
        _adminService.getBranchStats(),
        _adminService.getSalesPerformance(),
      ]);
        _adminJobs = results[0] as List<AdminJob>;
      _branchStats = results[1] as List<Branch>;
      _salesPerformance = results[2] as List<SalesData>;
      
      // Calculate the appropriate maxY for the sales chart
      _salesChartMaxY = _adminService.getSalesChartMaxY(_salesPerformance);

    } catch (e) {
      _errorMessage = e.toString();
      print('AdminProvider Error: Failed to fetch admin data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Placeholder for methods to add/update/delete admin jobs or other data
  // Example:
  // Future<void> addAdminJob(AdminJob job) async {
  //   try {
  //     final newJob = await _adminService.createAdminJob(job);
  //     _adminJobs.add(newJob);
  //     notifyListeners();
  //   } catch (e) {
  //     _errorMessage = e.toString();
  //     notifyListeners();
  //   }
  // }
}
