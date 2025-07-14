import 'package:flutter/material.dart';
import '../services/accounts_service.dart';

class AccountsTopBar extends StatefulWidget {
  final String? accountantId;
  const AccountsTopBar({Key? key, this.accountantId}) : super(key: key);

  @override
  State<AccountsTopBar> createState() => _AccountsTopBarState();
}

class _AccountsTopBarState extends State<AccountsTopBar> {
  String _accountantName = '';
  String _accountantRole = '';
  String _branchName = '';

  @override
  void initState() {
    super.initState();
    _fetchAccountantAndBranch();
  }

  Future<void> _fetchAccountantAndBranch() async {
    final service = AccountsService();
    if (widget.accountantId == null || widget.accountantId!.isEmpty) return;
    final details = await service.fetchAccountantDetails(accountantId: widget.accountantId);
    String name = details?['full_name'] ?? '';
    String role = details?['role'] ?? '';
    String branchName = '';
    if (details != null && details['branch_id'] != null) {
      branchName = await service.fetchBranchName(int.parse(details['branch_id'].toString())) ?? '';
    }
    setState(() {
      _accountantName = name;
      _accountantRole = role;
      _branchName = branchName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF232B3E),
                child: Text(
                  _accountantName.isNotEmpty ? _accountantName[0] : '',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _accountantName.isNotEmpty ? _accountantName : 'Accountant',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF232B3E), fontSize: 14),
                  ),
                  Text(
                    _accountantRole.isNotEmpty ? _accountantRole : 'Accountant',
                    style: const TextStyle(color: Color(0xFF888FA6), fontSize: 12),
                  ),
                  if (_branchName.isNotEmpty)
                    Text(
                      'Branch: $_branchName',
                      style: const TextStyle(color: Color(0xFF7DE2D1), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
