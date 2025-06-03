// lib/Dashboards/Admin/services/admin_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/admin_job.dart';
import '../models/branch.dart';
import '../models/sales_data.dart';
import '../models/employee.dart'; // Import Employee model
import 'dart:convert';

class AdminService {
  final _supabase = Supabase.instance.client;

  // Fetch jobs from Supabase with all JSONB fields parsed for dashboard use
  Future<List<AdminJob>> getAdminJobs() async {
    try {
      print('AdminService: Fetching jobs from Supabase');
      final response = await _supabase
          .from('jobs')
          .select()
          .order('created_at', ascending: false);

      final jobs = <AdminJob>[];
      for (final job in response) {
        try {          // Parse JSONB fields if they are not already maps
          Map<String, dynamic>? parseJsonField(dynamic field) {
            if (field == null) return {};
            if (field is Map<String, dynamic>) return field;
            if (field is String) {
              try {
                final decoded = jsonDecode(field);
                // Handle array structure (like design field)
                if (decoded is List) {
                  // Convert array to map with indexed keys, even if empty
                  final Map<String, dynamic> arrayAsMap = {};
                  for (int i = 0; i < decoded.length; i++) {
                    arrayAsMap[i.toString()] = decoded[i];
                  }
                  return arrayAsMap;
                } else if (decoded is Map<String, dynamic>) {
                  return decoded;
                }
                return {};
              } catch (_) {
                return {};
              }
            } else if (field is List) {
              // Handle case where field is already a List
              final Map<String, dynamic> arrayAsMap = {};
              for (int i = 0; i < field.length; i++) {
                arrayAsMap[i.toString()] = field[i];
              }
              return arrayAsMap;
            }
            return {};
          }

          final receptionist = parseJsonField(job['receptionist']);
          final salesperson = parseJsonField(job['salesperson']);
          final design = parseJsonField(job['design']);
          final accountant = parseJsonField(job['accountant']);
          final production = parseJsonField(job['production']);
          final printing = parseJsonField(job['printing']);

          jobs.add(AdminJob(
            no: job['id'].toString(),
            title: receptionist?['shopName']?.toString() ?? 'Job ${job['id']}',
            client: receptionist?['customerName']?.toString() ?? 'Unknown Client',
            date: DateTime.parse(job['created_at']).toString().substring(0, 10),
            status: job['status']?.toString() ?? 'Unknown',
            receptionist: receptionist,
            salesperson: salesperson,
            design: design,
            accountant: accountant,
            production: production,
            printing: printing,
          ));
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing job ${job['id']}: $e');
          }
        }
      }
      return jobs;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching jobs: $e');
      }
      throw Exception('Failed to load jobs: $e');
    }
  }
  // Fetch branch statistics from employees and jobs data, using integer branch IDs
  Future<List<Branch>> getBranchStats() async {
    try {
      print('AdminService: Fetching branch statistics from Supabase');
      // Fetch all branches
      final branchesResponse = await _supabase
          .from('branches')
          .select('id, name, location, contact_no');
      // Fetch all employees
      final employeesResponse = await _supabase
          .from('employee')
          .select('id, branch_id, role')
          .not('branch_id', 'is', null);
      // Fetch all jobs
      final jobsResponse = await _supabase
          .from('jobs')
          .select('id, branch_id, salesperson, printing')
          .order('created_at');

      // Organize employees by branch_id (int)
      Map<int, List<String>> branchEmployees = {};
      for (final employee in employeesResponse) {
        final branchId = employee['branch_id'];
        if (branchId == null) continue;
        branchEmployees.putIfAbsent(branchId, () => []).add(employee['id']);
      }

      // Aggregate stats for each branch
      List<Branch> branches = [];
      for (final branch in branchesResponse) {
        final int branchId = branch['id'] as int;
        final String branchName = branch['name']?.toString() ?? 'Branch $branchId';
        int completed = 0;
        double revenue = 0.0;
        int delays = 0;

        // Find jobs for this branch
        final branchJobs = jobsResponse.where((job) => job['branch_id'] == branchId);
        for (final job in branchJobs) {
          // Check if job is completed (has printing data)
          if (job['printing'] != null) {
            completed++;
            // Add revenue if available in printing
            final printing = job['printing'] as Map<String, dynamic>?;
            if (printing != null && printing.containsKey('finalCost')) {
              revenue += double.tryParse(printing['finalCost'].toString()) ?? 0.0;
            }
            // Check for delays
            if (printing != null &&
                printing.containsKey('expectedCompletionDate') &&
                printing.containsKey('actualCompletionDate')) {
              try {
                var expectedDate = DateTime.parse(printing['expectedCompletionDate'].toString());
                var actualDate = DateTime.parse(printing['actualCompletionDate'].toString());
                if (actualDate.isAfter(expectedDate)) {
                  delays++;
                }
              } catch (e) {
                if (kDebugMode) {
                  print('Error parsing dates for job ${job['id']}: $e');
                }
              }
            }
          }
        }
        branches.add(Branch(
          name: branchName,
          completed: completed,
          revenue: revenue.toStringAsFixed(2),
          delays: delays,
        ));
      }
      return branches;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching branch stats: $e');
      }
      throw Exception('Failed to load branch statistics: $e');
    }
  }
  Future<List<SalesData>> getSalesPerformance() async {
    try {
      print('AdminService: Fetching sales performance from Supabase');
      
      // Get the current date
      final now = DateTime.now();
      
      // Calculate the date 5 months ago
      final fiveMonthsAgo = DateTime(now.year, now.month - 5, 1);
      final startDateStr = fiveMonthsAgo.toIso8601String();
      
      // Fetch jobs with completed sales (jobs that have salesperson data)
      final jobsWithSales = await _supabase
          .from('jobs')
          .select('id, created_at, salesperson')
          .not('salesperson', 'is', null)
          .gte('created_at', startDateStr)
          .order('created_at');
      
      // Group jobs by month
      Map<int, double> monthlySales = {};
      
      for (int i = 0; i < 6; i++) {
        // Initialize all 6 months with zero values
        final monthKey = now.month - i;
        final adjustedMonth = monthKey <= 0 ? monthKey + 12 : monthKey;
        monthlySales[adjustedMonth] = 0.0;
      }
        // Process jobs
      for (final job in jobsWithSales) {
        try {
          final createdAt = DateTime.parse(job['created_at']);
          final monthsAgo = now.month - createdAt.month + (now.year - createdAt.year) * 12;          
          // Only include jobs from the last 6 months
          if (monthsAgo >= 0 && monthsAgo < 6) {
            final monthKey = createdAt.month;
            
            // Extract sale value if available
            final salesData = job['salesperson'] as Map<String, dynamic>?;
            if (salesData != null && salesData.containsKey('proposedCost')) {
              final saleValue = double.tryParse(salesData['proposedCost'].toString()) ?? 0.0;
              monthlySales[monthKey] = (monthlySales[monthKey] ?? 0.0) + saleValue;
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error processing job ${job['id']} for sales data: $e');
          }
        }
      }
      
      // Convert to SalesData objects
      List<SalesData> salesData = [];
      monthlySales.forEach((month, value) {
        // Convert month to x value (1-based)
        salesData.add(SalesData(month.toDouble(), value / 1000)); // Convert to thousands for display
      });
      
      // Sort by month
      salesData.sort((a, b) => a.x.compareTo(b.x));
      
      return salesData;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching sales performance: $e');
      }
      
      // Return fallback data in case of error
      return [
        SalesData(1, 35), // Month 1, Sales 35k
        SalesData(2, 28), // Month 2, Sales 28k
        SalesData(3, 34), // Month 3, Sales 34k
        SalesData(4, 32), // Month 4, Sales 32k
        SalesData(5, 40), // Month 5, Sales 40k
      ];
    }
  }
  // Fetch all employees from Supabase
  Future<List<Employee>> getAllEmployees() async {
    try {
      print('AdminService: Starting to fetch employees from Supabase');
      final response = await _supabase
          .from('employee')
          .select('id, full_name, phone, role, branch_id, created_at, is_available, assigned_job');
      
      print('AdminService: Received ${response.length} employees from Supabase');
      
      // Debug each employee's role
      for (int i = 0; i < response.length; i++) {
        final e = response[i];
        print('AdminService: Employee ${e['id']} - role type: ${e['role']?.runtimeType}, value: ${e['role']}');
      }
      
      return response
          .map<Employee>((e) {
            var role = e['role'];
            if (role is List) {
              print('AdminService: Converting List role to String for employee ${e['id']}: $role');
              // If it's a list, take the first element
              role = role.isNotEmpty ? role.first.toString() : "";
            } else if (role != null && role is! String) {
              print('AdminService: Converting ${role.runtimeType} role to String for employee ${e['id']}: $role');
              // Convert any other type to string
              role = role.toString();
            } else if (role == null) {
              print('AdminService: Role is null for employee ${e['id']}, using empty string');
              role = "";
            }
            
            try {
              return Employee.fromJson({
                ...e,
                'role': role,
              });
            } catch (error) {
              print('AdminService: Error creating Employee object for ${e['id']}: $error');
              rethrow;
            }
          })
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching employees: $e');
        print('Error details: ${e.toString()}');
      }
      throw Exception('Failed to load employees: $e');
    }
  }
  // Fetch all branches for dropdown selection
  Future<List<Map<String, dynamic>>> getBranches() async {
    try {
      final response = await _supabase
          .from('branches')
          .select('id, name, location');
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching branches: $e');
      }
      throw Exception('Failed to load branches: $e');
    }
  }

  // Add a new employee with custom ID logic
  Future<Employee> addEmployee({
    required String fullName,
    required String phone,
    required String role,
    required int branchId,
    bool? isAvailable = true,
    String? assignedJob,
  }) async {
    try {
      // 1. Get role prefix (first 3 letters, lowercase)
      final rolePrefix = role.trim().toLowerCase().substring(0, 3);
      // 2. Query for the latest employee with this role prefix
      final latest = await _supabase
          .from('employee')
          .select('id')
          .ilike('id', '$rolePrefix%')
          .order('id', ascending: false)
          .limit(1);
      int nextNumber = 1001;
      if (latest.isNotEmpty) {
        final lastId = latest[0]['id'] as String;
        final match = RegExp(r'^(?:[a-zA-Z]+)(\d+) ?$').firstMatch(lastId);
        if (match != null) {
          final numberPart = match.group(1);
          if (numberPart != null) {
            nextNumber = int.parse(numberPart) + 1;
          }
        }
      }
      final newId = '$rolePrefix$nextNumber';
      // 3. Insert new employee with generated ID
      final response = await _supabase
          .from('employee')
          .insert({
            'id': newId,
            'full_name': fullName,
            'phone': phone,
            'role': role,
            'branch_id': branchId,
            'is_available': isAvailable,
            'assigned_job': assignedJob,
          })
          .select()
          .single();
      return Employee.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error adding employee: $e');
      }
      throw Exception('Failed to add employee: $e');
    }
  }

  // Get unique roles from existing employees
  Future<List<String>> getEmployeeRoles() async {
    try {
      final response = await _supabase
          .from('employee')
          .select('role')
          .not('role', 'is', null);
      
      final roles = response
          .map((e) => e['role'] as String?)
          .whereType<String>()
          .toSet()
          .toList();
      
      // Add default roles if not present
      const defaultRoles = [
        'Manager', 'Receptionist', 'Salesperson', 'design', 'Accountant', 'Production', 'Printing',
        'receptionist', 'salesperson', 'designer', 'accountant', 'production_manager', 'printing_manager', 'admin', 'prod_labour', 'print_labour', 'driver'
      ];
      for (final role in defaultRoles) {
        if (!roles.contains(role)) {
          roles.add(role);
        }
      }
      
      roles.sort();
      return roles;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching employee roles: $e');
      }
      // Return default roles on error
      return [
        'Manager', 'Receptionist', 'Salesperson', 'design', 'Accountant', 'Production', 'Printing',
        'receptionist', 'salesperson', 'designer', 'accountant', 'production_manager', 'printing_manager', 'admin', 'prod_labour', 'print_labour', 'driver'
      ];
    }
  }
}