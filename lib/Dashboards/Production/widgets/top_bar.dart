import 'package:flutter/material.dart';
import '../services/production_service.dart';

class ProductionTopBar extends StatefulWidget {
  const ProductionTopBar({Key? key}) : super(key: key);

  @override
  State<ProductionTopBar> createState() => _ProductionTopBarState();
}

class _ProductionTopBarState extends State<ProductionTopBar> {
  String _employeeName = '';
  String _employeeRole = '';
  String _branchName = '';

  @override
  void initState() {
    super.initState();
    _fetchProductionEmployeeAndBranch();
  }

  Future<void> _fetchProductionEmployeeAndBranch() async {
    final service = ProductionService();
    final details = await service.fetchProductionDetails();
    String name = details?['full_name'] ?? '';
    String role = details?['role'] ?? '';
    String branchName = '';
    if (details != null && details['branch_id'] != null) {
      branchName = await service.fetchBranchName(int.parse(details['branch_id'].toString())) ?? '';
    }
    if (!mounted) return;
    setState(() {
      _employeeName = name;
      _employeeRole = role;
      _branchName = branchName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(width: 32),
          Icon(Icons.notifications_none, color: Color(0xFF232B3E), size: 26),
          const SizedBox(width: 18),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(
                  _employeeName.isNotEmpty ? _employeeName : 'Employee',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF232B3E)),
                ),
                const SizedBox(width: 4),
                Text(
                  _employeeRole.isNotEmpty ? _employeeRole : 'Production',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (_branchName.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    'Branch: $_branchName',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF7DE2D1), fontWeight: FontWeight.w600),
                  ),
                ],
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 14,
                  backgroundColor: const Color(0xFF232B3E),
                  child: Text(
                    _employeeName.isNotEmpty ? _employeeName[0] : 'E',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
