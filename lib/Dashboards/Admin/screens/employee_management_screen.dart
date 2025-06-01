import 'package:flutter/material.dart';
import '../widgets/employee_table.dart';
import '../widgets/employee_filter_dropdown.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/admin_top_bar.dart';
import '../services/admin_service.dart';
import '../models/employee.dart';
import 'add_employee_screen.dart';

class EmployeeManagementScreen extends StatefulWidget {
  const EmployeeManagementScreen({Key? key}) : super(key: key);

  @override
  State<EmployeeManagementScreen> createState() => _EmployeeManagementScreenState();
}

class _EmployeeManagementScreenState extends State<EmployeeManagementScreen> {
  String selectedRole = 'All';
  String searchQuery = '';
  late Future<List<Employee>> _employeesFuture;
  final AdminService _adminService = AdminService();

  @override
  void initState() {
    super.initState();
    _refreshEmployees();
  }

  void _refreshEmployees() {
    setState(() {
      _employeesFuture = _adminService.getAllEmployees();
    });
  }

  void _navigateToAddEmployee() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEmployeeScreen(
          onEmployeeAdded: _refreshEmployees,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FF),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminSidebar(
              selectedIndex: 1,
              onItemTapped: (index) {
                if (index == 0) {
                  Navigator.pushReplacementNamed(context, '/admin/dashboard');
                } else if (index == 1) {
                  Navigator.pushReplacementNamed(context, '/admin/employees');
                } else if (index == 2) {
                  Navigator.pushReplacementNamed(context, '/admin/assign-salesperson');
                } else if (index == 3) {
                  Navigator.pushReplacementNamed(context, '/admin/job-progress');
                } else if (index == 4) {
                  Navigator.pushReplacementNamed(context, '/admin/calendar');
                }
              },
            ),
            Expanded(
              child: Column(
                children: [
                  const AdminTopBar(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 28.0, right: 28.0, top: 20.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'User Management',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                                color: Color(0xFF232B3E),
                              ),
                            ),
                            const SizedBox(height: 22),
                            // --- Search Bar Start ---
                            Container(
                              margin: const EdgeInsets.only(bottom: 18),
                              padding: const EdgeInsets.symmetric(horizontal: 0),
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Search employees by name, email, or role...',
                                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    searchQuery = value.trim();
                                  });
                                },
                              ),
                            ),
                            // --- Search Bar End ---
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 200,
                                        child: FutureBuilder<List<Employee>>(
                                          future: _employeesFuture,
                                          builder: (context, snapshot) {
                                            final employees = snapshot.data ?? [];
                                            final roles = ['All', ...{...employees.map((e) => e.role)}.toList()..sort()];
                                            return EmployeeFilterDropdown(
                                              roles: roles,
                                              selectedRole: selectedRole,
                                              onChanged: (role) {
                                                setState(() {
                                                  selectedRole = role;
                                                });
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: _navigateToAddEmployee,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF9EE2EA),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        child: const Text('+Add New'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  FutureBuilder<List<Employee>>(
                                    future: _employeesFuture,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const Center(child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return Center(child: Text('Error: \\${snapshot.error}'));
                                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                        return const Center(child: Text('No employees found.'));
                                      }
                                      // --- Filter by role and search query ---
                                      List<Employee> employees = snapshot.data!;
                                      if (selectedRole != 'All') {
                                        employees = employees.where((e) => e.role == selectedRole).toList();
                                      }
                                      if (searchQuery.isNotEmpty) {
                                        employees = employees.where((e) =>
                                          e.fullName.toLowerCase().contains(searchQuery.toLowerCase()) ||
                                          e.phone.toLowerCase().contains(searchQuery.toLowerCase()) ||
                                          e.role.toLowerCase().contains(searchQuery.toLowerCase())
                                        ).toList();
                                      }
                                      return EmployeeTable(employees: employees);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
