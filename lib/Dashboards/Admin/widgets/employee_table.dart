import 'package:flutter/material.dart';
import '../models/employee.dart';

class EmployeeTable extends StatelessWidget {
  final List<Employee> employees;
  final Function? onEmployeeUpdated;
  final Function? onEmployeeDeleted;

  const EmployeeTable({
    Key? key, 
    required this.employees,
    this.onEmployeeUpdated,
    this.onEmployeeDeleted,
  }) : super(key: key);

  // Helper method for detail row in dialog
  Widget _detailRow(IconData icon, String label, String value, {Color? iconColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor ?? Colors.grey[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 1200, // Adjusted width after removing a column
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
                  Expanded(flex: 1, child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF232B3E)))),
                  Expanded(flex: 1, child: Text('ID', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF232B3E)))),
                  Expanded(flex: 1, child: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF232B3E)))),
                  Expanded(flex: 1, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF232B3E)))),
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
                    onTap: () {                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Container(
                            width: 400,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Colors.grey[200],
                                      child: Icon(Icons.person, color: Colors.grey[600], size: 32),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            emp.fullName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold, 
                                              fontSize: 20,
                                              color: Color(0xFF232B3E),
                                            ),
                                          ),
                                          Text(
                                            emp.role,
                                            style: const TextStyle(
                                              fontSize: 16, 
                                              color: Color(0xFFB0B3C7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                const Divider(),
                                const SizedBox(height: 16),
                                _detailRow(Icons.badge, 'Employee ID', emp.id),
                                _detailRow(Icons.phone, 'Phone', emp.phone),
                                _detailRow(Icons.email, 'Email', emp.email),
                                _detailRow(Icons.business, 'Branch ID', emp.branchId.toString()),
                                _detailRow(
                                  Icons.calendar_today, 
                                  'Joined', 
                                  '${emp.createdAt.day}/${emp.createdAt.month}/${emp.createdAt.year}'
                                ),
                                if (emp.isAvailable != null)
                                  _detailRow(
                                    emp.isAvailable! ? Icons.check_circle : Icons.cancel,
                                    'Available',
                                    emp.isAvailable! ? 'Yes' : 'No',
                                    iconColor: emp.isAvailable! ? Colors.green : Colors.red,
                                  ),
                                if (emp.assignedJob != null && emp.assignedJob!.isNotEmpty)
                                  _detailRow(Icons.work, 'Assigned Job', emp.assignedJob!),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        if (onEmployeeUpdated != null) {
                                          onEmployeeUpdated!(emp);
                                        }
                                      },
                                      icon: const Icon(Icons.edit),
                                      label: const Text('Edit'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF9EE2EA),
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Close'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
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
                            flex: 1,
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
                            flex: 1,
                            child: Text(emp.phone, style: const TextStyle(fontSize: 15)),
                          ),
                          // Actions
                          Expanded(
                            flex: 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                  onPressed: () {
                                    if (onEmployeeUpdated != null) {
                                      onEmployeeUpdated!(emp);
                                    }
                                  },
                                  tooltip: 'Edit',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                  onPressed: () {
                                    if (onEmployeeDeleted != null) {
                                      onEmployeeDeleted!(emp);
                                    }
                                  },
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
