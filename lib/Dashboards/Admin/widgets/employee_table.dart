import 'package:flutter/material.dart';

class EmployeeTable extends StatelessWidget {
  const EmployeeTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy data for now
    final employees = [
      {
        'avatar': 'assets/avatars/avatar1.png',
        'name': 'Brooklyn Simmons',
        'role': 'Receptionist',
        'id': '87364523',
        'email': 'brooklyn@smail.com',
        'phone': '(603) 555-0123',
        'date': '21/12/2022',
        'time': '10:40 PM',
        'status': 'Active',
      },
      {
        'avatar': 'assets/avatars/avatar2.png',
        'name': 'Kristin Watson',
        'role': 'Designer',
        'id': '93874563',
        'email': 'kristin@smail.com',
        'phone': '(219) 555-0114',
        'date': '22/12/2022',
        'time': '05:20 PM',
        'status': 'Inactive',
      },
      // ... add more dummy rows as needed
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 1100, // Ensures enough width for all columns
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
                  Expanded(flex: 2, child: Text('Email', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF232B3E)))),
                  Expanded(flex: 2, child: Text('Phone number', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF232B3E)))),
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
                              backgroundImage: AssetImage(emp['avatar'] ?? 'assets/avatars/default.png'),
                              radius: 20,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(emp['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                Text(emp['role'] ?? '', style: const TextStyle(fontSize: 13, color: Color(0xFFB0B3C7))),
                              ],
                            )
                          ],
                        ),
                      ),
                      // ID
                      Expanded(
                        flex: 1,
                        child: Text(emp['id'] ?? '', style: const TextStyle(fontSize: 15)),
                      ),
                      // Email
                      Expanded(
                        flex: 2,
                        child: Text(emp['email'] ?? '', style: const TextStyle(fontSize: 15)),
                      ),
                      // Phone
                      Expanded(
                        flex: 2,
                        child: Text(emp['phone'] ?? '', style: const TextStyle(fontSize: 15)),
                      ),
                      // Date Added
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(emp['date'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            Text(emp['time'] ?? '', style: const TextStyle(fontSize: 12, color: Color(0xFFB0B3C7))),
                          ],
                        ),
                      ),
                      // Status
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: emp['status'] == 'Active' ? const Color(0xFFE8FFF3) : const Color(0xFFFFE8E8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Status: \'${emp['status']}\'')),
                              );
                            },
                            child: Text(
                              emp['status'] ?? '',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: emp['status'] == 'Active' ? Colors.green : Colors.redAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
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
                              icon: Icon(Icons.edit, color: Colors.blue.shade300, size: 20),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Edit ${emp['name']}')),
                                );
                              },
                              tooltip: 'Edit',
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline, color: Colors.red.shade300, size: 20),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Delete ${emp['name']}')),
                                );
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
