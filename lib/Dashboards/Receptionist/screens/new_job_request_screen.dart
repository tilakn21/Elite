import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/topbar.dart';
import '../../Design/providers/job_provider.dart';
import '../../Design/models/job.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class NewJobRequestScreen extends StatefulWidget {
  final bool showAppBars;
  final bool showBackButton;
  final Map<String, dynamic>? jobDetails;
  
  const NewJobRequestScreen({
    Key? key, 
    this.showAppBars = true, 
    this.showBackButton = false,
    this.jobDetails,
  }) : super(key: key);

  @override
  State<NewJobRequestScreen> createState() => _NewJobRequestScreenState();
}

class _NewJobRequestScreenState extends State<NewJobRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final shopNameController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.jobDetails != null) {
      nameController.text = widget.jobDetails!['name'] ?? '';
      phoneController.text = widget.jobDetails!['phone'] ?? '';
      shopNameController.text = widget.jobDetails!['shopName'] ?? '';
      emailController.text = widget.jobDetails!['email'] ?? '';
      addressController.text = widget.jobDetails!['address'] ?? '';
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    shopNameController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final rightFormFieldsState = _rightFormFieldsKey.currentState;
    if (rightFormFieldsState == null || !rightFormFieldsState.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final jobProvider = Provider.of<JobProvider>(context, listen: false);

      final job = Job(
        jobNo: '#${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        clientName: nameController.text,
        email: emailController.text,
        phoneNumber: phoneController.text,
        address: '${rightFormFieldsState.streetNumberController.text}, ${rightFormFieldsState.townController.text}, ${rightFormFieldsState.postcodeController.text}',
        dateAdded: DateTime.now(),
        status: JobStatus.pending,
        notes: 'Shop Name: ${shopNameController.text}\nAppointment Date: ${rightFormFieldsState.dateController.text}',
      );

      await jobProvider.addJob(job);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job request submitted successfully')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to submit job request. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  final _rightFormFieldsKey = GlobalKey<_RightFormFieldsState>();

  @override
  Widget build(BuildContext context) {
    final double formWidth = 800;
    final bool isViewMode = widget.jobDetails != null;
    
    Widget content = Center(
      child: Container(
        width: formWidth,
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.showBackButton)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF101C2C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                    ),
                  ),
                ),
              Row(
                children: [
                  Text(
                    isViewMode ? 'Job Request Details' : 'Basic information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B2330),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: Color(0xFF1B2330).withAlpha(20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Label('Name'),
                        _InputField(
                          controller: nameController,
                          hint: 'Enter name',
                          readOnly: isViewMode,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Name is required';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        _Label('Phone number'),
                        _InputField(
                          controller: phoneController,
                          hint: 'Enter phone number',
                          readOnly: isViewMode,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Phone number is required';
                            }
                            if (!RegExp(r'^\(\d{3}\) \d{3}-\d{4}$').hasMatch(value)) {
                              return 'Enter phone number in format (123) 456-7890';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        _Label('Shop name'),
                        _InputField(
                          controller: shopNameController,
                          hint: 'Enter shop name',
                          readOnly: isViewMode,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Shop name is required';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        _Label('Email'),
                        _InputField(
                          controller: emailController,
                          hint: 'Enter email address',
                          readOnly: isViewMode,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email is required';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        _Label('Street address'),
                        _InputField(
                          controller: addressController,
                          hint: 'Enter street address',
                          readOnly: isViewMode,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Street address is required';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 32),
                  Expanded(
                    child: _RightFormFields(
                      key: _rightFormFieldsKey,
                      jobDetails: widget.jobDetails,
                      readOnly: isViewMode,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              if (!isViewMode)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 32,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF36A1C5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _isLoading ? null : _submitForm,
                        child: _isLoading
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Submit',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );

    if (!widget.showAppBars) return content;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FE),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Sidebar(selectedIndex: 1),
          Expanded(
            child: Column(
              children: [
                const TopBar(),
                Expanded(child: content),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        color: Color(0xFF7B7B7B),
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String hint;
  final Widget? suffixIcon;
  final TextEditingController controller;
  final bool readOnly;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  
  const _InputField({
    Key? key,
    required this.hint,
    required this.controller,
    this.suffixIcon,
    this.readOnly = false,
    this.onTap,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13, color: Color(0xFFBDBDBD)),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        filled: true,
        fillColor: readOnly ? Color(0xFFF8F8F8).withOpacity(0.5) : Color(0xFFF8F8F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide.none,
        ),
        suffixIcon: suffixIcon,
        errorStyle: TextStyle(color: Colors.red.shade700),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
      ),
    );
  }
}

class _RightFormFields extends StatefulWidget {
  final Map<String, dynamic>? jobDetails;
  final bool readOnly;
  
  const _RightFormFields({
    Key? key,
    this.jobDetails,
    this.readOnly = false,
  }) : super(key: key);
  
  @override
  State<_RightFormFields> createState() => _RightFormFieldsState();
}

class _RightFormFieldsState extends State<_RightFormFields> {
  final TextEditingController streetNumberController = TextEditingController();
  final TextEditingController townController = TextEditingController();
  final TextEditingController postcodeController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.jobDetails != null) {
      streetNumberController.text = widget.jobDetails!['streetNumber'] ?? '';
      townController.text = widget.jobDetails!['town'] ?? '';
      postcodeController.text = widget.jobDetails!['postcode'] ?? '';
      dateController.text = widget.jobDetails!['appointmentDate'] ?? '';
    }
  }

  @override
  void dispose() {
    streetNumberController.dispose();
    townController.dispose();
    postcodeController.dispose();
    dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    if (widget.readOnly) return;
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        dateController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  bool validate() {
    bool isValid = true;
    if (streetNumberController.text.isEmpty) {
      isValid = false;
    }
    if (townController.text.isEmpty) {
      isValid = false;
    }
    if (postcodeController.text.isEmpty) {
      isValid = false;
    }
    if (dateController.text.isEmpty) {
      isValid = false;
    }
    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label('Street number'),
        _InputField(
          hint: 'Enter street number',
          controller: streetNumberController,
          readOnly: widget.readOnly,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Street number is required';
            }
            return null;
          },
        ),
        SizedBox(height: 20),
        _Label('Town'),
        _InputField(
          hint: 'Enter town',
          controller: townController,
          readOnly: widget.readOnly,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Town is required';
            }
            return null;
          },
        ),
        SizedBox(height: 20),
        _Label('Postcode'),
        _InputField(
          hint: 'Enter postcode',
          controller: postcodeController,
          readOnly: widget.readOnly,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Postcode is required';
            }
            if (!RegExp(r'^[A-Z]{1,2}[0-9][A-Z0-9]? ?[0-9][A-Z]{2}$', caseSensitive: false).hasMatch(value)) {
              return 'Enter a valid UK postcode';
            }
            return null;
          },
        ),
        SizedBox(height: 20),
        _Label('Date of appointment'),
        _InputField(
          hint: 'Select date',
          controller: dateController,
          readOnly: true,
          onTap: () => _pickDate(context),
          suffixIcon: Icon(Icons.calendar_today, size: 18, color: Color(0xFFBDBDBD)),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Appointment date is required';
            }
            return null;
          },
        ),
      ],
    );
  }
}
