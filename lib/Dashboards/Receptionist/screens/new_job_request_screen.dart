import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/topbar.dart';
import '../services/receptionist_service.dart';

class NewJobRequestScreen extends StatelessWidget {
  const NewJobRequestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double formWidth = MediaQuery.of(context).size.width < 900 ? double.infinity : 800;
    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FE),
      body: Row(
        children: [
          Sidebar(selectedIndex: 1),
          Expanded(
            child: Column(
              children: [
                const TopBar(isDashboard: false),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
                      child: Container(
                        width: formWidth,
                        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
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
                        child: _JobRequestForm(),
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

class _JobRequestForm extends StatefulWidget {
  @override
  State<_JobRequestForm> createState() => _JobRequestFormState();
}

class _JobRequestFormState extends State<_JobRequestForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController shopNameController = TextEditingController();
  final TextEditingController streetAddressController = TextEditingController();
  final TextEditingController streetNumberController = TextEditingController();
  final TextEditingController townController = TextEditingController();
  final TextEditingController postcodeController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController dateOfVisitController = TextEditingController();
  final TextEditingController dateOfAppointmentController = TextEditingController();

  String? selectedSalesperson;
  List<String> availableSalespersons = [];
  bool _isLoadingSalespersons = false;

  bool _isSubmitting = false;
  String? _submitMessage;
  final ReceptionistService _receptionistService = ReceptionistService();
  final _formKey = GlobalKey<FormState>();
  String? _validationError;
  // Track invalid fields for highlighting
  Set<String> _invalidFields = {};

  @override
  void initState() {
    super.initState();
    // Set date of appointment to today (read-only)
    final now = DateTime.now();
    dateOfAppointmentController.text = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
    _fetchSalespersons();
  }

  Future<void> _fetchSalespersons() async {
    setState(() { _isLoadingSalespersons = true; });
    final ids = await _receptionistService.fetchSalespersonIdsFromSupabase();
    setState(() {
      availableSalespersons = ids;
      _isLoadingSalespersons = false;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    shopNameController.dispose();
    streetAddressController.dispose();
    streetNumberController.dispose();
    townController.dispose();
    postcodeController.dispose();
    dateController.dispose();
    timeController.dispose();
    dateOfVisitController.dispose();
    dateOfAppointmentController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        dateController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _pickDateOfVisit(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        dateOfVisitController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  Future<void> _submitJobRequest() async {
    setState(() {
      _validationError = null;
      _invalidFields.clear();
    });
    if (!_validateForm()) {
      return;
    }
    setState(() {
      _isSubmitting = true;
      _submitMessage = null;
    });
    try {
      // TODO: Replace with actual logged-in user id
      const String createdBy = 'receptionist-uid';
      await _receptionistService.addJobToSupabase(
        customerName: nameController.text.trim(),
        phone: phoneController.text.trim(),
        shopName: shopNameController.text.trim(),
        streetAddress: streetAddressController.text.trim(),
        streetNumber: streetNumberController.text.trim(),
        town: townController.text.trim(),
        postcode: postcodeController.text.trim(),
        dateOfAppointment: DateTime.now().toIso8601String(), // Use current date
        dateOfVisit: dateOfVisitController.text.trim(),
        timeOfVisit: timeController.text.trim(),
        assignedSalesperson: selectedSalesperson,
        createdBy: createdBy,
      );
      setState(() {
        _submitMessage = 'Job request submitted successfully!';
      });
      _clearForm();
    } catch (e) {
      setState(() {
        _submitMessage = 'Failed to submit job request: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  bool _validateForm() {
    final phone = phoneController.text.trim();
    final postcode = postcodeController.text.trim();
    final phoneRegExp = RegExp(r'^[0-9]{8,}$');
    final postcodeRegExp = RegExp(r'^[0-9]{4,8}$');
    List<String> missingFields = [];
    _invalidFields.clear();
    if (nameController.text.trim().isEmpty) {
      missingFields.add('Name');
      _invalidFields.add('name');
    }
    if (phone.isEmpty) {
      missingFields.add('Phone number');
      _invalidFields.add('phone');
    } else if (!phoneRegExp.hasMatch(phone)) {
      missingFields.add('Valid phone number (8+ digits, numbers only)');
      _invalidFields.add('phone');
    }
    if (shopNameController.text.trim().isEmpty) {
      missingFields.add('Shop name');
      _invalidFields.add('shopName');
    }
    if (streetAddressController.text.trim().isEmpty) {
      missingFields.add('Street address');
      _invalidFields.add('streetAddress');
    }
    if (streetNumberController.text.trim().isEmpty) {
      missingFields.add('Street number');
      _invalidFields.add('streetNumber');
    }
    if (townController.text.trim().isEmpty) {
      missingFields.add('Town');
      _invalidFields.add('town');
    }
    if (postcode.isEmpty) {
      missingFields.add('Postcode');
      _invalidFields.add('postcode');
    } else if (!postcodeRegExp.hasMatch(postcode)) {
      missingFields.add('Valid postcode (4-8 digits, numbers only)');
      _invalidFields.add('postcode');
    }
    // Remove dateController (date of appointment) from validation
    if (dateOfVisitController.text.trim().isEmpty) {
      missingFields.add('Date of visit');
      _invalidFields.add('dateOfVisit');
    }
    if (timeController.text.trim().isEmpty) {
      missingFields.add('Time of visit');
      _invalidFields.add('timeOfVisit');
    }
    if (selectedSalesperson == null) {
      missingFields.add('Salesperson');
      _invalidFields.add('salesperson');
    }
    if (missingFields.isNotEmpty) {
      setState(() {
        _validationError = 'Please fill/enter: ' + missingFields.join(', ');
      });
      return false;
    }
    setState(() {
      _validationError = null;
    });
    return true;
  }

  void _clearForm() {
    nameController.clear();
    phoneController.clear();
    shopNameController.clear();
    streetAddressController.clear();
    streetNumberController.clear();
    townController.clear();
    postcodeController.clear();
    // dateController.clear(); // No longer used
    timeController.clear();
    dateOfVisitController.clear();
    setState(() {
      selectedSalesperson = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Basic information',
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
          isMobile
              ? Column(
                  children: _buildFormFields(isMobile),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildLeftFields(),
                      ),
                    ),
                    SizedBox(width: 32),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildRightFields(),
                      ),
                    ),
                  ],
                ),
          const SizedBox(height: 32),
          // Salesperson dropdown
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: _isLoadingSalespersons
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Assign Salesperson',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      errorText: _invalidFields.contains('salesperson') ? 'Please select a salesperson' : null,
                    ),
                    value: selectedSalesperson,
                    items: availableSalespersons
                        .map((sp) => DropdownMenuItem<String>(
                              value: sp,
                              child: Text(sp),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSalesperson = value;
                      });
                    },
                  ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF36A1C5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _isSubmitting ? null : _submitJobRequest,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            'Submit',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
          if (_submitMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              _submitMessage!,
              style: TextStyle(
                color: _submitMessage!.contains('success') ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildFormFields(bool isMobile) {
    return [
      ..._buildLeftFields(),
      const SizedBox(height: 20),
      ..._buildRightFields(),
    ];
  }

  List<Widget> _buildLeftFields() {
    return [
      _Label('Name'),
      _InputField(
        hint: 'Enter name',
        controller: nameController,
        error: _invalidFields.contains('name'),
      ),
      SizedBox(height: 20),
      _Label('Phone number'),
      _InputField(
        hint: 'Enter phone number',
        controller: phoneController,
        error: _invalidFields.contains('phone'),
        keyboardType: TextInputType.number,
        helperText: _invalidFields.contains('phone') ? 'Enter at least 8 digits, numbers only' : null,
      ),
      SizedBox(height: 20),
      _Label('Shop name'),
      _InputField(
        hint: 'Enter shop name',
        controller: shopNameController,
        error: _invalidFields.contains('shopName'),
      ),
      SizedBox(height: 20),
      _Label('Street address'),
      _InputField(
        hint: 'Enter street address',
        controller: streetAddressController,
        error: _invalidFields.contains('streetAddress'),
      ),
      SizedBox(height: 20),
      _Label('Date of appointment'),
      _InputField(
        hint: '',
        controller: dateOfAppointmentController,
        readOnly: true,
        error: false,
      ),
    ];
  }

  List<Widget> _buildRightFields() {
    return [
      _Label('Street number'),
      _InputField(
        hint: 'Enter street number',
        controller: streetNumberController,
        error: _invalidFields.contains('streetNumber'),
      ),
      SizedBox(height: 20),
      _Label('Town'),
      _InputField(
        hint: 'Enter town',
        controller: townController,
        error: _invalidFields.contains('town'),
      ),
      SizedBox(height: 20),
      _Label('Postcode'),
      _InputField(
        hint: 'Enter postcode',
        controller: postcodeController,
        error: _invalidFields.contains('postcode'),
        keyboardType: TextInputType.number,
        helperText: _invalidFields.contains('postcode') ? 'Enter 4-8 digits, numbers only' : null,
      ),
      SizedBox(height: 20),
      _Label('Date of visit'),
      _InputField(
        hint: 'Select date of visit',
        controller: dateOfVisitController,
        readOnly: true,
        onTap: () => _pickDateOfVisit(context),
        suffixIcon: Icon(Icons.calendar_today, size: 18, color: Color(0xFFBDBDBD)),
        error: _invalidFields.contains('dateOfVisit'),
      ),
      SizedBox(height: 20),
      _Label('Time of visit'),
      _InputField(
        hint: 'Select time',
        controller: timeController,
        readOnly: true,
        onTap: () => _pickTime(context),
        suffixIcon: Icon(Icons.access_time, size: 18, color: Color(0xFFBDBDBD)),
        error: _invalidFields.contains('timeOfVisit'),
      ),
    ];
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
  final TextEditingController? controller;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool error;
  final TextInputType? keyboardType;
  final String? helperText;
  const _InputField({
    required this.hint,
    this.suffixIcon,
    this.controller,
    this.readOnly = false,
    this.onTap,
    this.error = false,
    this.keyboardType,
    this.helperText,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13, color: Color(0xFFBDBDBD)),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        filled: true,
        fillColor: Color(0xFFF8F8F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide.none,
        ),
        suffixIcon: suffixIcon,
        errorText: error ? '' : null,
        errorBorder: error
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.red, width: 1.5),
              )
            : null,
        helperText: helperText,
        helperStyle: TextStyle(color: Colors.red, fontSize: 11),
      ),
    );
  }
}

// Right column fields as a separate widget for clarity
class _RightFormFields extends StatefulWidget {
  const _RightFormFields({Key? key}) : super(key: key);
  @override
  State<_RightFormFields> createState() => _RightFormFieldsState();
}

class _RightFormFieldsState extends State<_RightFormFields> {
  final TextEditingController streetNumberController = TextEditingController();
  final TextEditingController townController = TextEditingController();
  final TextEditingController postcodeController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  @override
  void dispose() {
    streetNumberController.dispose();
    townController.dispose();
    postcodeController.dispose();
    dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        dateController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label('Street number'),
        _InputField(hint: 'Enter street number', controller: streetNumberController),
        SizedBox(height: 20),
        _Label('Town'),
        _InputField(hint: 'Enter town', controller: townController),
        SizedBox(height: 20),
        _Label('Postcode'),
        _InputField(hint: 'Enter postcode', controller: postcodeController),
        SizedBox(height: 20),
        _Label('Date of appointment'),
        _InputField(
          hint: 'Select date',
          controller: dateController,
          readOnly: true,
          onTap: () => _pickDate(context),
          suffixIcon: Icon(Icons.calendar_today, size: 18, color: Color(0xFFBDBDBD)),
        ),
      ],
    );
  }
}
