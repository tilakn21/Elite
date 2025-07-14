import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/salesperson_sidebar.dart';
import '../widgets/salesperson_topbar.dart';

class SalespersonProfileScreen extends StatefulWidget {
  final String? salespersonId;
  const SalespersonProfileScreen({Key? key, this.salespersonId}) : super(key: key);

  @override
  State<SalespersonProfileScreen> createState() =>
      _SalespersonProfileScreenState();
}

class _SalespersonProfileScreenState extends State<SalespersonProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, dynamic>? employee;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchEmployee();
  }

  Future<void> _fetchEmployee() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      String? userId = widget.salespersonId;
      if (userId == null) {
        final user = Supabase.instance.client.auth.currentUser;
        userId = user?.id;
      }
      if (userId == null) {
        setState(() {
          _error = 'No authenticated user found and no ID passed.';
          _isLoading = false;
        });
        print('[SALESPERSON_PROFILE] No authenticated user or ID passed.');
        return;
      }
      print('[SALESPERSON_PROFILE] Using salesperson ID: ' + userId);
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('employee')
          .select()
          .eq('id', userId)
          .single();
      setState(() {
        employee = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load profile: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final TextEditingController _currentPasswordController = TextEditingController();
    final TextEditingController _newPasswordController = TextEditingController();
    final TextEditingController _confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _currentPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Current Password'),
                ),
                TextField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'New Password'),
                ),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Confirm New Password'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final String currentPassword = _currentPasswordController.text.trim();
                final String newPassword = _newPasswordController.text.trim();
                final String confirmPassword = _confirmPasswordController.text.trim();

                if (newPassword != confirmPassword) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('New password and confirmation do not match.')),
                  );
                  return;
                }

                try {
                  final supabase = Supabase.instance.client;
                  final userId = widget.salespersonId;
                  if (userId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User ID missing.')),
                    );
                    return;
                  }
                  // Fetch current hashed password
                  final response = await supabase
                      .from('employee')
                      .select('password')
                      .eq('id', userId)
                      .single();
                  final String storedHash = response['password'] ?? '';
                  final String currentHash = sha256.convert(utf8.encode(currentPassword)).toString();
                  if (storedHash != currentHash) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Current password is incorrect.')),
                    );
                    return;
                  }
                  // Update password
                  final String newHash = sha256.convert(utf8.encode(newPassword)).toString();
                  await supabase
                      .from('employee')
                      .update({'password': newHash})
                      .eq('id', userId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password changed successfully.')),
                  );
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text('Change Password'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 600;
    final GlobalKey<ScaffoldState> scaffoldKey = _scaffoldKey;
    Widget sidebar = SalespersonSidebar(
      selectedRoute: 'profile',
      onItemSelected: (route) {
        if (route == 'home') {
          Navigator.of(context).pushReplacementNamed('/salesperson/dashboard', arguments: {'receptionistId': widget.salespersonId});
        } else if (route == 'profile') {
          if (isMobile) Navigator.of(context).pop();
        } else if (route == 'reimbursement') {
          String employeeId = widget.salespersonId ?? 'sal2003';
          Navigator.of(context).pushReplacementNamed(
            '/salesperson/reimbursement',
            arguments: {'employeeId': employeeId},
          );
        }
      },
      salespersonId: widget.salespersonId,
    );
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      drawer: isMobile
          ? Drawer(
              width: MediaQuery.of(context).size.width * 0.75,
              child: sidebar,
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            SizedBox(width: 240, child: sidebar),
          Expanded(
            child: Column(
              children: [
                SalespersonTopBar(
                  isDashboard: false,
                  showMenu: isMobile,
                  onMenuTap: () => scaffoldKey.currentState?.openDrawer(),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                          ? Center(child: Text(_error!, style: TextStyle(color: Colors.red)))
                          : employee == null
                              ? Center(child: Text('No profile found.', style: TextStyle(color: Colors.grey)))
                              : SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(height: 20),
                                        Center(
                                          child: Image.asset(
                                            'assets/images/elite_logo.png',
                                            height: 92,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        const SizedBox(height: 18),
                                        Text(
                                          employee!['full_name'] ?? '',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 20,
                                              color: Colors.black),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          (employee!['role'] ?? '').toString().replaceAll('_', ' ').replaceFirst(RegExp(r'^.'), (employee!['role'] ?? '').isNotEmpty ? (employee!['role'] ?? '').substring(0, 1).toUpperCase() : ''),
                                          style: const TextStyle(
                                              color: Color(0xFFBDBDBD),
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(height: 24),
                                        _ProfileCard(
                                          label: 'Full Name',
                                          value: employee!['full_name'] ?? '',
                                          isBold: true,
                                        ),
                                        const SizedBox(height: 12),
                                        _ProfileCard(
                                          label: 'Phone no.',
                                          value: employee!['phone'] ?? '',
                                        ),
                                        const SizedBox(height: 12),
                                        _ProfileCard(
                                          label: 'Role',
                                          value: employee!['role'] ?? '',
                                          isBold: true,
                                        ),
                                        const SizedBox(height: 12),
                                        _ProfileCard(
                                          label: 'Branch ID',
                                          value: employee!['branch_id']?.toString() ?? '-',
                                        ),
                                        const SizedBox(height: 12),
                                        _ProfileCard(
                                          label: 'Created At',
                                          value: (employee!['created_at'] ?? '').toString().split('T').first,
                                        ),
                                        const SizedBox(height: 24),
                                        ElevatedButton.icon(
                                          icon: const Icon(Icons.lock, color: Colors.white),
                                          label: const Text('Change Password', style: TextStyle(color: Colors.white)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blueAccent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                          ),
                                          onPressed: () async {
                                            await _showChangePasswordDialog(context);
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        ElevatedButton.icon(
                                          icon: const Icon(Icons.logout, color: Colors.white),
                                          label: const Text('Log Out', style: TextStyle(color: Colors.white)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.redAccent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                          ),
                                          onPressed: () async {
                                            await Supabase.instance.client.auth.signOut();
                                            if (!mounted) return;
                                            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                                          },
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
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  const _ProfileCard(
      {required this.label, required this.value, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
                color: Color(0xFFBDBDBD),
                fontSize: 14,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
