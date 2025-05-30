import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/admin_service.dart';

class AddEmployeeScreen extends StatefulWidget {
  final VoidCallback? onEmployeeAdded;

  const AddEmployeeScreen({super.key, this.onEmployeeAdded});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _adminService = AdminService();
  
  // Form controllers
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _assignedJobController = TextEditingController();
  
  // Form values
  String? _selectedRole;
  int? _selectedBranchId;
  bool _isAvailable = true;
  
  // Data lists
  List<String> _roles = [];
  List<Map<String, dynamic>> _branches = [];
  
  // Loading states
  bool _isLoading = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadFormData();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _assignedJobController.dispose();
    super.dispose();
  }

  Future<void> _loadFormData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await Future.wait([
        _adminService.getEmployeeRoles(),
        _adminService.getBranches(),
      ]);

      setState(() {
        _roles = results[0] as List<String>;
        _branches = results[1] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading form data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _adminService.addEmployee(
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        role: _selectedRole!,
        branchId: _selectedBranchId!,
        isAvailable: _isAvailable,
        assignedJob: _assignedJobController.text.trim().isEmpty 
            ? null 
            : _assignedJobController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Employee added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Call the callback to refresh the employee list
        widget.onEmployeeAdded?.call();
        
        // Go back to the previous screen
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding employee: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  String? _validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Full name must be at least 2 characters';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? _validateRole(String? value) {
    if (value == null || value.isEmpty) {
      return 'Role is required';
    }
    return null;
  }

  String? _validateBranch(int? value) {
    if (value == null) {
      return 'Branch is required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Employee'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Employee Information',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 32),
                            
                            // Full Name Field
                            TextFormField(
                              controller: _fullNameController,
                              decoration: InputDecoration(
                                labelText: 'Full Name',
                                hintText: 'Enter employee full name',
                                prefixIcon: const Icon(Icons.person),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: _validateFullName,
                              textCapitalization: TextCapitalization.words,
                            ),
                            const SizedBox(height: 20),
                            
                            // Phone Field
                            TextFormField(
                              controller: _phoneController,
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                hintText: 'Enter phone number',
                                prefixIcon: const Icon(Icons.phone),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: _validatePhone,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 20),
                            
                            // Role Dropdown
                            DropdownButtonFormField<String>(
                              value: _selectedRole,
                              decoration: InputDecoration(
                                labelText: 'Role',
                                prefixIcon: const Icon(Icons.work),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              items: _roles.map((role) => DropdownMenuItem(
                                value: role,
                                child: Text(role),
                              )).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedRole = value;
                                });
                              },
                              validator: _validateRole,
                            ),
                            const SizedBox(height: 20),
                            
                            // Branch Dropdown
                            DropdownButtonFormField<int>(
                              value: _selectedBranchId,
                              decoration: InputDecoration(
                                labelText: 'Branch',
                                prefixIcon: const Icon(Icons.location_on),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              items: _branches.map((branch) => DropdownMenuItem<int>(
                                value: branch['id'] as int,
                                child: Text('${branch['name']} - ${branch['location']}'),
                              )).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedBranchId = value;
                                });
                              },
                              validator: _validateBranch,
                            ),
                            const SizedBox(height: 20),
                            
                            // Assigned Job Field (Optional)
                            TextFormField(
                              controller: _assignedJobController,
                              decoration: InputDecoration(
                                labelText: 'Assigned Job (Optional)',
                                hintText: 'Enter current assigned job ID',
                                prefixIcon: const Icon(Icons.assignment),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Availability Switch
                            Card(
                              color: Colors.grey[50],
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.accessibility,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Available for Assignment',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                    ),
                                    Switch(
                                      value: _isAvailable,
                                      onChanged: (value) {
                                        setState(() {
                                          _isAvailable = value;
                                        });
                                      },
                                      activeColor: Colors.green,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            
                            // Submit Button
                            SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isSubmitting ? null : _submitForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[600],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: _isSubmitting
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Text(
                                        'Add Employee',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Cancel Button
                            SizedBox(
                              height: 50,
                              child: TextButton(
                                onPressed: _isSubmitting 
                                    ? null 
                                    : () => Navigator.of(context).pop(),
                                style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
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
            ),
    );
  }
}
