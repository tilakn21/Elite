import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/salesperson_sidebar.dart';
import '../widgets/salesperson_topbar.dart';
import '../models/salesperson_profile.dart';

class SalespersonProfileScreen extends StatefulWidget {
  const SalespersonProfileScreen({Key? key}) : super(key: key);

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
      final supabase = Supabase.instance.client;
      // Use authenticated user's id from Supabase
      final user = Supabase.instance.client.auth.currentUser;
      final userId = user?.id ?? 'sal2001';
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

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 600;
    final GlobalKey<ScaffoldState> scaffoldKey = _scaffoldKey;
    Widget sidebar = SalespersonSidebar(
      selectedRoute: 'profile',
      onItemSelected: (route) {
        if (route == 'home') {
          Navigator.of(context).pushReplacementNamed('/salesperson/dashboard');
        } else if (route == 'profile') {
          if (isMobile) Navigator.of(context).pop();
        } else if (route == 'reimbursement') {
          Navigator.of(context).pushReplacementNamed('/salesperson/reimbursement');
        }
      },
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
