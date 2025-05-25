import 'package:flutter/foundation.dart';
import '../models/models.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminDashboardProvider extends ChangeNotifier {
  List<Branch> _branches = [];
  List<AdminJob> _jobs = [];
  late SalesData _salesData;
  int _selectedBranchIndex = 0;

  List<Branch> get branches => _branches;
  List<AdminJob> get jobs => _jobs;
  SalesData get salesData => _salesData;
  int get selectedBranchIndex => _selectedBranchIndex;
  Branch get selectedBranch => _branches[_selectedBranchIndex];

  AdminDashboardProvider() {
    _loadInitialData();
  }

  void _loadInitialData() {
    // Load sample data
    _branches = [
      Branch(name: 'Branch A', completedJobs: 281, revenue: 250000, delays: 2),
      Branch(name: 'Branch B', completedJobs: 281, revenue: 250000, delays: 4),
      Branch(name: 'Branch C', completedJobs: 281, revenue: 250000, delays: 3),
    ];

    final now = DateTime.now();
    _jobs = List.generate(5, (i) => AdminJob(
      jobNo: '#${1001 + i}',
      title: i % 2 == 0 ? 'Office renovation' : 'Window installation',
      clientName: 'Brooklyn Simmons',
      date: now.add(Duration(days: i)),
      status: 'Approved',
    ));

    _salesData = SalesData.fromPoints([
      FlSpot(0, 200),
      FlSpot(1, 350),
      FlSpot(2, 400),
      FlSpot(3, 500),
      FlSpot(4, 300),
      FlSpot(5, 600),
      FlSpot(6, 450),
      FlSpot(7, 500),
      FlSpot(8, 600),
    ]);
  }

  void setSelectedBranch(int index) {
    if (index >= 0 && index < _branches.length && index != _selectedBranchIndex) {
      _selectedBranchIndex = index;
      notifyListeners();
    }
  }

  Future<void> refreshData() async {
    // TODO: Implement API call to refresh data
    notifyListeners();
  }
}
