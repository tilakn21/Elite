// lib/Dashboards/Admin/services/admin_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/admin_job.dart';
import '../models/branch.dart';
import '../models/sales_data.dart';
import '../models/employee.dart'; // <-- Missing import added
import 'dart:convert';
import 'package:crypto/crypto.dart';

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
            no: (job['job_code']?.toString() ?? '').isNotEmpty ? job['job_code'].toString() : job['id'].toString(), // Use job_code as job number
            title: receptionist?['shopName']?.toString() ?? 'Job ${job['job_code'] ?? job['id']}',
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
          .not('branch_id', 'is', null);      // Fetch all jobs with amount and branch information
      final jobsResponse = await _supabase
          .from('jobs')
          .select('id, branch_id, status, amount, printing')
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
          // Add revenue from job amount if available
          final amount = (job['amount'] as num?)?.toDouble() ?? 0.0;
          revenue += amount;
          
          // Check if job is completed (has printing data or completed status)
          if (job['printing'] != null || job['status']?.toString().toLowerCase() == 'completed') {
            completed++;
            
            // Check for delays if printing data exists
            dynamic printingRaw = job['printing'];
            Map<String, dynamic>? printing;
            if (printingRaw is Map<String, dynamic>) {
              printing = printingRaw;
            } else if (printingRaw is List && printingRaw.isNotEmpty && printingRaw.first is Map<String, dynamic>) {
              printing = printingRaw.first as Map<String, dynamic>;
            } else {
              printing = null;
            }
            
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
                  print('Error parsing dates for job \\${job['id']}: $e');
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
        print('Error fetching branch stats: $e');      }
      throw Exception('Failed to load branch statistics: $e');
    }
  }

  Future<List<SalesData>> getSalesPerformance() async {
    try {
      print('AdminService: Fetching sales performance from Supabase');
      
      // Get the current date
      final now = DateTime.now();
      
      // Calculate the date 9 months ago to get enough data for the chart
      final nineMonthsAgo = DateTime(now.year, now.month - 8, 1);
      final startDateStr = nineMonthsAgo.toIso8601String();
      
      // Fetch jobs with amounts from the last 9 months
      final jobsWithAmounts = await _supabase
          .from('jobs')
          .select('id, created_at, amount, status')
          .not('amount', 'is', null)
          .gte('created_at', startDateStr)
          .order('created_at');
      
      // Initialize monthly sales data for last 9 months
      Map<int, double> monthlySales = {};
      List<String> monthNames = [];
      
      for (int i = 8; i >= 0; i--) {
        final monthDate = DateTime(now.year, now.month - i, 1);
        final monthKey = i; // Use index as key for chart x-axis
        monthlySales[monthKey] = 0.0;
        
        // Store month names for reference
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        monthNames.add(months[monthDate.month - 1]);
      }
      
      print('AdminService: Processing ${jobsWithAmounts.length} jobs for sales data');
      
      // Process jobs and aggregate by month
      for (final job in jobsWithAmounts) {
        try {
          final createdAt = DateTime.parse(job['created_at']);
          final amount = (job['amount'] as num?)?.toDouble() ?? 0.0;
          
          // Calculate which month this job belongs to (0-8 index)
          final monthsFromStart = (createdAt.year - nineMonthsAgo.year) * 12 + 
                                 (createdAt.month - nineMonthsAgo.month);
          
          // Only include jobs from the target 9-month range
          if (monthsFromStart >= 0 && monthsFromStart < 9) {
            monthlySales[monthsFromStart] = (monthlySales[monthsFromStart] ?? 0.0) + amount;
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error processing job ${job['id']} for sales data: $e');
          }
        }
      }
        // Convert to SalesData objects for the chart
      List<SalesData> salesData = [];
      double maxAmount = 0.0;
      
      monthlySales.forEach((monthIndex, totalAmount) {
        // Convert to thousands for better chart display
        final amountInThousands = totalAmount / 1000;
        salesData.add(SalesData(monthIndex.toDouble(), amountInThousands));
        
        // Track maximum amount for scaling
        if (amountInThousands > maxAmount) {
          maxAmount = amountInThousands;
        }
      });
      
      // Sort by month index
      salesData.sort((a, b) => a.x.compareTo(b.x));
      
      // Calculate appropriate maxY for chart (add 20% padding and round up to nearest 50k)
      final paddedMax = maxAmount * 1.2;
      final roundedMax = ((paddedMax / 50).ceil() * 50).toDouble();
      final chartMaxY = roundedMax < 100 ? 100 : roundedMax; // Minimum 100k scale
      
      print('AdminService: Generated sales data for ${salesData.length} months');
      print('AdminService: Max amount: £${(maxAmount * 1000).toStringAsFixed(2)}, Chart maxY: ${chartMaxY}k');
      for (final data in salesData) {
        print('Month ${data.x.toInt()}: £${(data.y * 1000).toStringAsFixed(2)}');
      }
      
      // Store maxY in the first data point's metadata (we'll handle this differently)
      // For now, we'll pass maxY through a different method
      
      return salesData;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching sales performance: $e');
      }
        // Return fallback data in case of error
      return [
        SalesData(0, 35), // Month 0, Sales £35k
        SalesData(1, 28), // Month 1, Sales £28k
        SalesData(2, 34), // Month 2, Sales £34k
        SalesData(3, 42), // Month 3, Sales £42k
        SalesData(4, 38), // Month 4, Sales £38k
        SalesData(5, 45), // Month 5, Sales £45k
        SalesData(6, 52), // Month 6, Sales £52k
        SalesData(7, 48), // Month 7, Sales £48k
        SalesData(8, 55), // Month 8, Sales £55k
      ];
    }
  }

  // Get the appropriate maxY value for the sales chart based on data
  double getSalesChartMaxY(List<SalesData> salesData) {
    if (salesData.isEmpty) return 100.0;
    
    // Find the maximum value in the data
    double maxAmount = salesData.map((e) => e.y).reduce((a, b) => a > b ? a : b);
      // Calculate appropriate maxY (add 20% padding and round up to nearest 50k)
    final paddedMax = maxAmount * 1.2;
    final roundedMax = ((paddedMax / 50).ceil() * 50).toDouble();
    final chartMaxY = roundedMax < 100 ? 100.0 : roundedMax; // Minimum 100k scale
    
    return chartMaxY;
  }

  // Fetch all employees from Supabase
  Future<List<Employee>> getAllEmployees() async {
    try {
      print('AdminService: Starting to fetch employees from Supabase');
      final response = await _supabase
          .from('employee')
          .select('id, full_name, phone, email, role, branch_id, created_at, is_available, assigned_job');
      
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
    required String email,
    required String role,
    required int branchId,
    bool? isAvailable = true,
    String? assignedJob,
  }) async {
    // Check if email exists
    final existing = await _supabase
        .from('employee')
        .select('id')
        .eq('email', email)
        .maybeSingle();
    if (existing != null) {
      throw Exception('An employee with this email already exists.');
    }
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
        final match = RegExp(r'^(?:[a-zA-Z]+)(\d+)\u0000? ?$').firstMatch(lastId);
        if (match != null) {
          final numberPart = match.group(1);
          if (numberPart != null) {
            nextNumber = int.parse(numberPart) + 1;
          }
        }
      }
      final newId = '$rolePrefix$nextNumber';
      // --- Password logic ---
      String last4 = phone.length >= 4 ? phone.substring(phone.length - 4) : phone;
      String rawPassword = '$newId@$last4';
      String hashedPassword = sha256.convert(utf8.encode(rawPassword)).toString();
      // 3. Insert new employee with generated ID and hashed password
      final response = await _supabase
          .from('employee')
          .insert({
            'id': newId,
            'full_name': fullName,
            'phone': phone,
            'email': email,
            'role': role,
            'branch_id': branchId,
            'is_available': isAvailable,
            'assigned_job': assignedJob,
            'password': hashedPassword,
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

  // Update an existing employee
  Future<Employee> updateEmployee({
    required String id,
    String? fullName,
    String? phone,
    String? email,
    String? role,
    int? branchId,
    bool? isAvailable,
    String? assignedJob,
  }) async {
    try {
      // Check if email exists and belongs to another employee
      if (email != null) {
        final existing = await _supabase
            .from('employee')
            .select('id')
            .eq('email', email)
            .neq('id', id) // Ensure it's not the current employee
            .maybeSingle();
        
        if (existing != null) {
          throw Exception('Another employee with this email already exists.');
        }
      }
      
      // Build update map with only provided fields
      final Map<String, dynamic> updateData = {};
      if (fullName != null) updateData['full_name'] = fullName;
      if (phone != null) updateData['phone'] = phone;
      if (email != null) updateData['email'] = email;
      if (role != null) updateData['role'] = role;
      if (branchId != null) updateData['branch_id'] = branchId;
      if (isAvailable != null) updateData['is_available'] = isAvailable;
      if (assignedJob != null) updateData['assigned_job'] = assignedJob;
      
      // Update the employee
      final response = await _supabase
          .from('employee')
          .update(updateData)
          .eq('id', id)
          .select()
          .single();
      
      return Employee.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating employee: $e');
      }
      throw Exception('Failed to update employee: $e');
    }
  }
  
  // Delete an employee
  Future<void> deleteEmployee(String id) async {
    try {
      await _supabase
          .from('employee')
          .delete()
          .eq('id', id);
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting employee: $e');
      }
      throw Exception('Failed to delete employee: $e');
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

  // Fetch jobs for a specific branch
  Future<List<AdminJob>> getAdminJobsByBranch(int branchId) async {
    try {
      final response = await _supabase
          .from('jobs')
          .select()
          .eq('branch_id', branchId)
          .order('created_at', ascending: false);
      // ...existing job parsing logic...
      // (You can reuse the parsing logic from getAdminJobs)
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
            no: (job['job_code']?.toString() ?? '').isNotEmpty ? job['job_code'].toString() : job['id'].toString(), // Use job_code as job number
            title: receptionist?['shopName']?.toString() ?? 'Job ${job['job_code'] ?? job['id']}',
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
        print('Error fetching jobs for branch $branchId: $e');
      }
      throw Exception('Failed to load jobs for branch $branchId: $e');
    }
  }

  // Fetch employees for a specific branch
  Future<List<Employee>> getEmployeesByBranch(int branchId) async {
    try {
      final response = await _supabase
          .from('employee')
          .select()
          .eq('branch_id', branchId);
      return response.map<Employee>((e) => Employee.fromJson(e)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching employees for branch $branchId: $e');
      }
      throw Exception('Failed to load employees for branch $branchId: $e');
    }
  }

  // Fetch sales performance for a specific branch
  Future<List<SalesData>> getSalesPerformanceByBranch(int branchId) async {
    try {
      final now = DateTime.now();
      final nineMonthsAgo = DateTime(now.year, now.month - 8, 1);
      final startDateStr = nineMonthsAgo.toIso8601String();
      final jobsWithAmounts = await _supabase
          .from('jobs')
          .select('id, created_at, amount, status, branch_id')
          .eq('branch_id', branchId)
          .not('amount', 'is', null)
          .gte('created_at', startDateStr)
          .order('created_at');
      Map<int, double> monthlySales = {};
      for (int i = 8; i >= 0; i--) {
        monthlySales[i] = 0.0;
      }
      for (final job in jobsWithAmounts) {
        try {
          final createdAt = DateTime.parse(job['created_at']);
          final amount = (job['amount'] as num?)?.toDouble() ?? 0.0;
          final monthsFromStart = (createdAt.year - nineMonthsAgo.year) * 12 + (createdAt.month - nineMonthsAgo.month);
          if (monthsFromStart >= 0 && monthsFromStart < 9) {
            monthlySales[monthsFromStart] = (monthlySales[monthsFromStart] ?? 0.0) + amount;
          }
        } catch (_) {}
      }
      List<SalesData> salesData = [];
      monthlySales.forEach((monthIndex, totalAmount) {
        final amountInThousands = totalAmount / 1000;
        salesData.add(SalesData(monthIndex.toDouble(), amountInThousands));
      });
      salesData.sort((a, b) => a.x.compareTo(b.x));
      return salesData;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching sales performance for branch $branchId: $e');
      }
      return [];
    }
  }

  // Fetch employee by id or email
  Future<Employee?> getEmployeeByIdOrEmail({String? id, String? email}) async {
    // Build filter
    String filter = '';
    if (id != null && id.isNotEmpty) {
      filter = "id.eq.$id";
    }
    if (email != null && email.isNotEmpty) {
      if (filter.isNotEmpty) {
        filter += ',';
      }
      filter += "email.eq.$email";
    }
    final result = await _supabase
        .from('employee')
        .select()
        .or(filter)
        .limit(1);
    if (result.isNotEmpty) {
      final emp = result[0];
      String parseString(dynamic v) {
        if (v is String) return v;
        if (v is List && v.isNotEmpty) return v.first.toString();
        if (v != null) return v.toString();
        return '';
      }
      return Employee(
        id: parseString(emp['id']),
        fullName: parseString(emp['full_name']),
        phone: parseString(emp['phone']),
        email: parseString(emp['email']),
        role: parseString(emp['role']),
        branchId: int.parse(emp['branch_id'].toString()),
        createdAt: DateTime.parse(emp['created_at'] as String),
        isAvailable: emp['is_available'] == null ? null : emp['is_available'] is bool 
            ? emp['is_available'] as bool 
            : emp['is_available'].toString().toLowerCase() == 'true',
        assignedJob: parseString(emp['assigned_job']),
        password: parseString(emp['password']),
      );
    }
    return null;
  }
}