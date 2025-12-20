import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../services/admin_service.dart';

class EditEmployeeScreen extends StatefulWidget {
  final Employee employee;
  final Function onEmployeeUpdated;

  const EditEmployeeScreen({
    Key? key,
    required this.employee,
    required this.onEmployeeUpdated,
  }) : super(key: key);

  @override
  _EditEmployeeScreenState createState() => _EditEmployeeScreenState();
}

class _EditEmployeeScreenState extends State<EditEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  String _selectedRole = '';
  int _selectedBranchId = 0;
  bool _isAvailable = true;
  
  final AdminService _adminService = AdminService();
  late Future<List<Map<String, dynamic>>> _branchesFuture;
  late Future<List<String>> _rolesFuture;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with employee data
    _nameController.text = widget.employee.fullName;
    _phoneController.text = widget.employee.phone;
    _emailController.text = widget.employee.email;
    _selectedRole = widget.employee.role;
    _selectedBranchId = widget.employee.branchId;
    _isAvailable = widget.employee.isAvailable ?? true;
    
    // Load branches and roles
    _branchesFuture = _adminService.getBranches();
    _rolesFuture = _adminService.getEmployeeRoles();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        await _adminService.updateEmployee(
          id: widget.employee.id,
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          role: _selectedRole,
          branchId: _selectedBranchId,
          isAvailable: _isAvailable,
        );
        
        widget.onEmployeeUpdated();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Employee updated successfully')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Employee'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF232B3E),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit Employee: ${widget.employee.fullName}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF232B3E),
                        ),
                      ),
                      Text(
                        'ID: ${widget.employee.id}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Full Name
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter the employee\'s full name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Phone Number
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter the employee\'s phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Email
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter the employee\'s email';
                          }
                          
                          final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegExp.hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Role
                      FutureBuilder<List<String>>(
                        future: _rolesFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }
                          
                          final roles = snapshot.data ?? [];
                          
                          return DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Role',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            value: roles.contains(_selectedRole) ? _selectedRole : (roles.isNotEmpty ? roles.first : null),
                            items: roles.map((role) {
                              return DropdownMenuItem<String>(
                                value: role,
                                child: Text(role),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedRole = value!;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a role';
                              }
                              return null;
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Branch
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: _branchesFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }
                          
                          final branches = snapshot.data ?? [];
                          
                          // Find if employee's branch exists in the list
                          final branchExists = branches.any((branch) => branch['id'] == _selectedBranchId);
                          final initialBranchId = branchExists ? _selectedBranchId : (branches.isNotEmpty ? branches.first['id'] : null);
                          
                          return DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              labelText: 'Branch',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            value: initialBranchId,
                            isExpanded: true,
                            items: branches.map((branch) {
                              // Use branch name and location
                              return DropdownMenuItem<int>(
                                value: branch['id'],
                                child: Tooltip(
                                  message: '${branch['name']} - ${branch['location']}',
                                  child: Text(
                                    '${branch['name']} - ${branch['location']}',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedBranchId = value!;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a branch';
                              }
                              return null;
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Availability
                      SwitchListTile(
                        title: const Text('Available for Assignment'),
                        value: _isAvailable,
                        onChanged: (value) {
                          setState(() {
                            _isAvailable = value;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: _submitForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF9EE2EA),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Update Employee',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
