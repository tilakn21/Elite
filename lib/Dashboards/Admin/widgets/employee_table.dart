import 'package:flutter/material.dart';
import '../models/employee.dart';

class EmployeeTable extends StatelessWidget {
  final List<Employee> employees;
  const EmployeeTable({Key? key, required this.employees}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 1400, // Increased width for more columns
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Table header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F5FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: const [
                  Expanded(flex: 2, child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF232B3E)))),
                  Expanded(flex: 1, child: Text('ID', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF232B3E)))),
                  Expanded(flex: 2, child: Text('Phone number', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF232B3E)))),
                  Expanded(flex: 2, child: Text('Role', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF232B3E)))),
                  Expanded(flex: 2, child: Text('Date added', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF232B3E)))),
                  Expanded(flex: 1, child: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF232B3E)))),
                  SizedBox(width: 40), // For action buttons
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Table body
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: employees.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final emp = employees[index];
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {},
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                      child: Row(
                        children: [
                          // Name & Avatar
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.grey[200],
                                  child: Icon(Icons.person, color: Colors.grey[600]),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(emp.fullName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                    Text(emp.role, style: const TextStyle(fontSize: 13, color: Color(0xFFB0B3C7))),
                                  ],
                                )
                              ],
                            ),
                          ),
                          // ID
                          Expanded(
                            flex: 1,
                            child: Text(emp.id, style: const TextStyle(fontSize: 15)),
                          ),
                          // Phone
                          Expanded(
                            flex: 2,
                            child: Text(emp.phone, style: const TextStyle(fontSize: 15)),
                          ),
                          // Role
                          Expanded(
                            flex: 2,
                            child: Text(emp.role, style: const TextStyle(fontSize: 15)),
                          ),
                          // Date Added
                          Expanded(
                            flex: 2,
                            child: Text('${emp.createdAt.day}/${emp.createdAt.month}/${emp.createdAt.year}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ),
                          // Status (dummy for now)
                          Expanded(
                            flex: 1,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Active',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          // Actions
                          SizedBox(
                            width: 40,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue, size: 20),
                                  onPressed: () {},
                                  tooltip: 'Edit',
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                  onPressed: () {},
                                  tooltip: 'Delete',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
