import 'package:flutter/material.dart';
import '../utils/platform_utils.dart';

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
    if (role == 'Salesperson' && isMobile()) {
      Navigator.of(context).pushReplacementNamed('/salesperson/dashboard');
    } else if (role == 'Admin' && isDesktop()) {
      Navigator.of(context).pushReplacementNamed('/admin/dashboard');
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
    // Use the same theme as other screens
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FF),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Elite Signboard Login',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B2330),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _employeeIdController,
                decoration: InputDecoration(
                  labelText: 'Employee ID',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.badge_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.people_outline),
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
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7DE2D1),
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
