import 'package:flutter/material.dart';
import '../utils/platform_utils.dart';
import 'login_screen_left_image.dart';
import '../Dashboards/Admin/screens/admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _selectedRole;

  final List<Map<String, String>> _roles = [
    {'label': 'Receptionist', 'route': '/receptionist/dashboard'},
    {'label': 'Salesperson', 'route': '/salesperson/dashboard'},
    {'label': 'Design Team', 'route': '/design/dashboard'},
    {'label': 'Accounts', 'route': '/accounts/dashboard'},
    {'label': 'Production Team', 'route': '/production/dashboard'},
    {'label': 'Printing', 'route': '/printing/dashboard'},
    {'label': 'Admin', 'route': '/admin/dashboard'},
  ];

  void navigateBasedOnRoleAndPlatform(String role) {
    if (role == 'Salesperson' && (isMobile() || isDesktop())) {
      Navigator.of(context).pushReplacementNamed('/salesperson/dashboard');
    } else if (role == 'Admin' && isDesktop()) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
      );
    } else if (role == 'Receptionist' && isDesktop()) {
      Navigator.of(context).pushReplacementNamed('/receptionist/dashboard');
    } else if (role == 'Design Team' && isDesktop()) {
      Navigator.of(context).pushReplacementNamed('/design/dashboard');
    } else if (role == 'Accounts' && isDesktop()) {
      Navigator.of(context).pushReplacementNamed('/accounts/dashboard');
    } else if (role == 'Production Team' && isDesktop()) {
      Navigator.of(context).pushReplacementNamed('/production/dashboard');
    } else if (role == 'Printing' && isDesktop()) {
      Navigator.of(context).pushReplacementNamed('/printing/dashboard');
    } else if (role == 'Printing' && isMobile()) {
      Navigator.of(context).pushReplacementNamed('/printing/dashboard');
    } else if (role == 'Accounts' && isMobile()) {
      Navigator.of(context).pushReplacementNamed('/accounts/dashboard');
    } else {
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text('Unsupported'),
          content: Text('This dashboard is not available on this device.'),
        ),
      );
    }
  }

  void _login() {
    if (_selectedRole != null) {
      navigateBasedOnRoleAndPlatform(_selectedRole!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 900;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FF),
      body: Row(
        children: [
          if (isWide)
            const LoginScreenLeftImage(),
          Expanded(
            child: Center(
              child: SizedBox(
                width: 400,
                child: Card(
                  color: const Color(0xFFF9F7FA),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1B2330),
                            letterSpacing: 0.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Enter your employee ID and password to Sign In',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF7B7B93),
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        TextField(
                          controller: _employeeIdController,
                          decoration: InputDecoration(
                            hintText: 'employee ID',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedRole,
                          decoration: InputDecoration(
                            hintText: 'Role',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          items: _roles
                              .map((role) => DropdownMenuItem<String>(
                                    value: role['label'],
                                    child: Text(role['label']!),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedRole = value;
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            StatefulBuilder(
                              builder: (context, setSwitchState) {
                                bool rememberMe = false;
                                return Row(
                                  children: [
                                    Switch(
                                      value: rememberMe,
                                      onChanged: (value) {
                                        setSwitchState(() {
                                          rememberMe = value;
                                        });
                                      },
                                      activeColor: const Color(0xFFE6007A),
                                    ),
                                    const Text(
                                      'Remember me',
                                      style: TextStyle(
                                        color: Color(0xFF7B7B93),
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE6007A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'SIGN IN',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
