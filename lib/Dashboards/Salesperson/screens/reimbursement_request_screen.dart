// Copied and adapted from Receptionist/screens/reimbursement_request_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../widgets/salesperson_sidebar.dart';
import '../widgets/salesperson_topbar.dart';
import '../../Receptionist/models/employee_reimbursement.dart';
import '../../Receptionist/providers/reimbursement_provider.dart';
import '../../Receptionist/services/reimbursement_service.dart';
import '../services/salesperson_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReimbursementRequestScreen extends StatefulWidget {
  final String? salespersonId;
  const ReimbursementRequestScreen({Key? key, this.salespersonId}) : super(key: key);

  @override
  State<ReimbursementRequestScreen> createState() => _ReimbursementRequestScreenState();
}

class _ReimbursementRequestScreenState extends State<ReimbursementRequestScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  // Form controllers
  final TextEditingController _empNameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  DateTime? _selectedDate;
  File? _receiptImage;
  final ImagePicker _imagePicker = ImagePicker();
  final Set<String> _invalidFields = {};
  bool _isUploading = false;
  final SalespersonService _salespersonService = SalespersonService();
  String? _salespersonId;

  @override
  void initState() {
    super.initState();
    // Extract ID from widget or route arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map && args['receptionistId'] != null) {
        setState(() {
          _salespersonId = args['receptionistId'] as String?;
        });
      } else if (widget.salespersonId != null) {
        _salespersonId = widget.salespersonId;
      }
      _fetchAndSetEmployeeName();
    });
  }

  Future<void> _fetchAndSetEmployeeName() async {
    // Only use the passed-in _salespersonId, never fallback
    final userId = _salespersonId;
    if (userId == null) return;
    final name = await _salespersonService.fetchSalespersonNameById(userId);
    setState(() {
      _empNameController.text = name ?? '';
    });
  }

  @override
  void dispose() {
    _empNameController.dispose();
    _amountController.dispose();
    _purposeController.dispose();
    _remarksController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 900;
    final double formWidth = isMobile ? double.infinity : (isTablet ? 500 : 800);
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFF6F3FE),
      drawer: isMobile
          ? Drawer(
              child: SalespersonSidebar(
                selectedRoute: 'reimbursement',
                salespersonId: _salespersonId,
                onItemSelected: (route) {
                  if (route == 'home') {
                    Navigator.of(context).pushReplacementNamed('/salesperson/dashboard', arguments: {'receptionistId': _salespersonId});
                  } else if (route == 'profile') {
                    Navigator.of(context).pushReplacementNamed('/salesperson/profile', arguments: {'receptionistId': _salespersonId});
                  } else if (route == 'reimbursement') {
                    Navigator.of(context).pop();
                  }
                },
              ),
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            SizedBox(width: 240, child: SalespersonSidebar(
              selectedRoute: 'reimbursement',
              salespersonId: _salespersonId,
              onItemSelected: (route) {
                if (route == 'home') {
                  Navigator.of(context).pushReplacementNamed('/salesperson/dashboard', arguments: {'receptionistId': _salespersonId});
                } else if (route == 'profile') {
                  Navigator.of(context).pushReplacementNamed('/salesperson/profile', arguments: {'receptionistId': _salespersonId});
                } else if (route == 'reimbursement') {
                  // Already here
                }
              },
            )),
          Expanded(
            child: Column(
              children: [
                SalespersonTopBar(
                  isDashboard: false,
                  showMenu: isMobile,
                  onMenuTap: () => scaffoldKey.currentState?.openDrawer(),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        vertical: isMobile ? 8 : 24,
                        horizontal: isMobile ? 0 : 8,
                      ),
                      child: Container(
                        width: formWidth,
                        constraints: BoxConstraints(
                          maxWidth: isMobile ? double.infinity : 800,
                        ),
                        margin: EdgeInsets.symmetric(
                          horizontal: isMobile ? 16 : 24,
                        ),
                        padding: EdgeInsets.all(isMobile ? 20 : 32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: _buildForm(isMobile),
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

  Widget _buildForm(bool isMobile) {
    return Consumer<ReimbursementProvider>(
      builder: (context, provider, child) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.receipt_long,
                    color: const Color(0xFF1B2330),
                    size: isMobile ? 20 : 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'New Reimbursement Request',
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1B2330),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 20 : 32),
              isMobile 
                ? _buildMobileLayout()
                : _buildDesktopLayout(),
              SizedBox(height: 24),
              _buildReceiptUploadSection(isMobile),
              SizedBox(height: 32),
              _buildSubmitButton(provider, isMobile),
              if (provider.submitMessage != null || provider.errorMessage != null)
                _buildStatusMessage(provider, isMobile),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: _buildAllFormFields(),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildLeftFormFields(),
          ),
        ),
        SizedBox(width: 32),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildRightFormFields(),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildAllFormFields() {
    return [
      ..._buildLeftFormFields(),
      SizedBox(height: 20),
      ..._buildRightFormFields(),
    ];
  }

  List<Widget> _buildLeftFormFields() {
    return [
      _Label('Employee Name', tooltip: 'Name of the employee requesting reimbursement'),
      _InputField(
        hint: 'Enter employee name',
        controller: _empNameController,
        error: _invalidFields.contains('empName'),
        readOnly: true,
      ),
      SizedBox(height: 20),
      _Label('Amount ( 24)', tooltip: 'Total amount to be reimbursed'),
      _InputField(
        hint: 'Enter amount (e.g., 125.50)',
        controller: _amountController,
        error: _invalidFields.contains('amount'),
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        ],
      ),
      SizedBox(height: 20),
      _Label('Purpose', tooltip: 'Reason for the expense'),
      _InputField(
        hint: 'Enter purpose of expense',
        controller: _purposeController,
        error: _invalidFields.contains('purpose'),
        maxLines: 2,
      ),
    ];
  }

  List<Widget> _buildRightFormFields() {
    return [
      _Label('Date of Expense', tooltip: 'Date when the expense was incurred'),
      _InputField(
        hint: 'Select date',
        controller: _dateController,
        error: _invalidFields.contains('date'),
        readOnly: true,
        onTap: () => _pickDate(),
        suffixIcon: Icon(Icons.calendar_today, size: 18, color: Color(0xFFBDBDBD)),
      ),
      SizedBox(height: 20),
      _Label('Remarks (Optional)', tooltip: 'Additional notes or comments'),
      _InputField(
        hint: 'Enter any additional remarks',
        controller: _remarksController,
        maxLines: 3,
      ),
    ];
  }

  Widget _buildReceiptUploadSection(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Receipt',
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1B2330),
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: _pickReceiptImage,
          child: Container(
            height: isMobile ? 150 : 200,
            decoration: BoxDecoration(
              color: const Color(0xFFEDEFF1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _invalidFields.contains('receipt') ? Colors.red : const Color(0xFFE0E0E0),
                width: 1.5,
              ),
            ),
            child: _receiptImage == null
                ? Center(
                    child: Text(
                      'Tap to upload receipt',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        color: const Color(0xFFBDBDBD),
                      ),
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _receiptImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
        ),
        if (_invalidFields.contains('receipt'))
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Receipt image is required.',
              style: TextStyle(
                color: Colors.red,
                fontSize: isMobile ? 12 : 14,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSubmitButton(ReimbursementProvider provider, bool isMobile) {
    return ElevatedButton(
      onPressed: _isUploading ? null : () => _submitForm(),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 56),
        backgroundColor: const Color(0xFF5C67F2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _isUploading
          ? CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )
          : Text(
              'Submit Request',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
    );
  }

  Widget _buildStatusMessage(ReimbursementProvider provider, bool isMobile) {
    final isSuccess = provider.submitMessage != null;
    final message = isSuccess ? provider.submitMessage : provider.errorMessage;
    final color = isSuccess ? Colors.green : Colors.red;

    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.error,
            color: color,
            size: 20,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              message!,
              style: TextStyle(
                color: color,
                fontSize: isMobile ? 14 : 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF5C67F2),
            hintColor: const Color(0xFF5C67F2),
            colorScheme: ColorScheme.light(primary: const Color(0xFF5C67F2)),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
        _invalidFields.remove('date');
      });
    }
  }

  Future<void> _pickReceiptImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _receiptImage = File(pickedFile.path);
        _invalidFields.remove('receipt');
      });
    }
  }

  // Add logging to _submitForm
  Future<void> _submitForm() async {
    debugPrint('[Form] Submit button pressed');
    if (_formKey.currentState!.validate() && _receiptImage != null) {
      setState(() {
        _isUploading = true;
      });
      try {
        debugPrint('[Form] Attempting to access ReimbursementProvider');
        final provider = Provider.of<ReimbursementProvider>(context, listen: false);
        debugPrint('[Form] Provider accessed successfully');
        final empId = _salespersonId;
        if (empId == null) {
          setState(() {
            _isUploading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No salesperson ID provided.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        final empName = _empNameController.text.trim();
        final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
        final purpose = _purposeController.text.trim();
        final remarks = _remarksController.text.trim();
        final reimbursementDate = _selectedDate ?? DateTime.now();
        final reimbursement = EmployeeReimbursement(
          id: '',
          empId: empId,
          empName: empName,
          amount: amount,
          reimbursementDate: reimbursementDate,
          purpose: purpose,
          remarks: remarks,
          status: ReimbursementStatus.pending,
        );
        await provider.addReimbursementRequest(reimbursement, receiptImage: _receiptImage);
        debugPrint('[Form] Reimbursement request submitted for $empId');
        setState(() {
          _isUploading = false;
          _clearForm();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reimbursement request submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        debugPrint('[Error] Failed to submit request: ' + e.toString());
        setState(() {
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit request: ' + e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      debugPrint('[Form] Validation failed or receipt image missing');
      setState(() {
        if (_empNameController.text.isEmpty) _invalidFields.add('empName');
        if (_amountController.text.isEmpty) _invalidFields.add('amount');
        if (_purposeController.text.isEmpty) _invalidFields.add('purpose');
        if (_dateController.text.isEmpty) _invalidFields.add('date');
        if (_receiptImage == null) _invalidFields.add('receipt');
      });
    }
  }

  void _clearForm() {
    _empNameController.clear();
    _amountController.clear();
    _purposeController.clear();
    _remarksController.clear();
    _dateController.clear();
    setState(() {
      _selectedDate = null;
      _receiptImage = null;
      _invalidFields.clear();
    });
  }
}

class _Label extends StatelessWidget {
  final String text;
  final String? tooltip;

  const _Label(this.text, {this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1B2330),
            ),
          ),
        ),
        if (tooltip != null)
          IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            iconSize: 16,
            icon: Icon(Icons.info_outline, color: const Color(0xFFBDBDBD)),
            onPressed: () {
              // Show tooltip or info dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  content: Text(
                    tooltip!,
                    style: TextStyle(fontSize: 14),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final bool error;
  final bool readOnly;
  final int maxLines;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _InputField({
    required this.hint,
    required this.controller,
    this.error = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.onTap,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: const Color(0xFFBDBDBD),
          fontSize: 14,
        ),
        filled: true,
        fillColor: const Color(0xFFF7F7F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: error ? Colors.red : const Color(0xFFE0E0E0),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFF5C67F2),
            width: 1.5,
          ),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
