import 'package:flutter/material.dart';
import '../widgets/employee_table.dart';
import '../widgets/employee_filter_dropdown.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/admin_top_bar.dart';

class EmployeeManagementScreen extends StatelessWidget {
  const EmployeeManagementScreen({Key? key}) : super(key: key);

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
                                        child: EmployeeFilterDropdown(
                                          // TODO: Pass onChanged callback to filter the table by role
                                          onChanged: (role) {
                                            // Implement table filtering by role here if needed
                                          },
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {},
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
                                  EmployeeTable(),
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
