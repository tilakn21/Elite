// lib/Dashboards/Admin/services/admin_service.dart
import '../models/admin_job.dart';
import '../models/branch.dart';
import '../models/sales_data.dart';
// import 'package:http/http.dart' as http; // Placeholder for HTTP requests

class AdminService {
  // Mock base URL - replace with actual API endpoint
  // static const String _baseUrl = 'https://api.example.com/admin';

  Future<List<AdminJob>> getAdminJobs() async {
    print('AdminService: Fetching admin jobs (mocked)');
    await Future.delayed(const Duration(seconds: 1));
    return [
      AdminJob(no: 'JOB001', title: 'Website Redesign', client: 'Client A', date: '2024-05-20', status: 'In Progress'),
      AdminJob(no: 'JOB002', title: 'Mobile App Dev', client: 'Client B', date: '2024-05-22', status: 'Completed'),
    ];
  }

  Future<List<Branch>> getBranchStats() async {
    print('AdminService: Fetching branch stats (mocked)');
    await Future.delayed(const Duration(seconds: 1));
    return [
      Branch(name: 'Main Branch', completed: 150, revenue: '\$50,000', delays: 5),
      Branch(name: 'West Branch', completed: 90, revenue: '\$30,000', delays: 2),
    ];
  }

  Future<List<SalesData>> getSalesPerformance() async {
    print('AdminService: Fetching sales performance (mocked)');
    await Future.delayed(const Duration(seconds: 1));
    return [
      SalesData(1, 35), // Month 1, Sales 35k
      SalesData(2, 28), // Month 2, Sales 28k
      SalesData(3, 34), // Month 3, Sales 34k
      SalesData(4, 32), // Month 4, Sales 32k
      SalesData(5, 40), // Month 5, Sales 40k
    ];
  }

  // Placeholder for other methods like:
  // Future<AdminJob> createAdminJob(AdminJob job) async { ... }
  // Future<Branch> updateBranchDetails(String branchId, Branch branch) async { ... }
}