import 'package:flutter/material.dart';
import '../utils/platform_utils.dart';
import '../Dashboards/Receptionist/services/receptionist_service.dart';
import 'login_screen_left_image.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final empId = _employeeIdController.text.trim();
    final password = _passwordController.text;
    if (empId.isEmpty || password.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please enter both Employee ID and Password.';
      });
      return;
    }
    try {
      // Example: Use ReceptionistService for all roles, or switch by prefix if needed
      final user = await ReceptionistService.loginWithIdAndPassword(empId, password);
      if (user != null) {
        // Route based on ID prefix
        if (empId.toLowerCase().startsWith('adm')) {
          Navigator.of(context).pushReplacementNamed('/admin/dashboard', arguments: {'admindashboardId': empId});
        } else if (empId.toLowerCase().startsWith('rec')) {
          Navigator.of(context).pushReplacementNamed('/receptionist/dashboard', arguments: {'receptionistId': empId});
        } else if (empId.toLowerCase().startsWith('prod')) {
          Navigator.of(context).pushReplacementNamed('/production/dashboard', arguments: {'productiondashboardId': empId});
        } else if (empId.toLowerCase().startsWith('pri')) {
          Navigator.of(context).pushReplacementNamed('/printing/dashboard', arguments: {'printingdashboardId': empId});
        } else if (empId.toLowerCase().startsWith('des')) {
          Navigator.of(context).pushReplacementNamed('/design/dashboard', arguments: {'designdashboardId': empId});
        } else if (empId.toLowerCase().startsWith('acc')) {
          Navigator.of(context).pushReplacementNamed('/accounts/dashboard', arguments: {'accountsdashboardId': empId});
        } else if (empId.toLowerCase().startsWith('sal')) {
          Navigator.of(context).pushReplacementNamed('/salesperson/dashboard', arguments: {'receptionistId': empId});
        } else {
          setState(() {
            _errorMessage = 'Unknown role for this Employee ID.';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Invalid Employee ID or Password.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Login failed. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                            hintText: 'Employee ID',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE6007A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
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
