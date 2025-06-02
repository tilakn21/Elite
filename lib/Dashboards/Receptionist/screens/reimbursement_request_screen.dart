import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../widgets/sidebar.dart';
import '../widgets/topbar.dart';
import '../models/employee_reimbursement.dart';
import '../providers/reimbursement_provider.dart';

class ReimbursementRequestScreen extends StatefulWidget {
  const ReimbursementRequestScreen({Key? key}) : super(key: key);

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
  
  @override
  void initState() {
    super.initState();
    // Pre-fill employee name (in real app, get from auth/session)
    _empNameController.text = 'John Doe'; // TODO: Replace with actual logged-in user
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
              child: Sidebar(
                selectedIndex: 3, // Reimbursement screen index
                isDrawer: true,
                onClose: () => Navigator.of(context).pop(),
              ),
            )
          : null,
      body: Row(
        children: [
          if (!isMobile) Sidebar(selectedIndex: 3),
          Expanded(
            child: Column(
              children: [
                TopBar(
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
              // Header
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
              
              // Form fields
              isMobile 
                ? _buildMobileLayout()
                : _buildDesktopLayout(),
              
              SizedBox(height: 24),
              
              // Receipt upload section
              _buildReceiptUploadSection(isMobile),
              
              SizedBox(height: 32),
              
              // Submit button
              _buildSubmitButton(provider, isMobile),
              
              // Status messages
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
        readOnly: true, // Pre-filled from auth
      ),
      SizedBox(height: 20),
      
      _Label('Amount (\$)', tooltip: 'Total amount to be reimbursed'),
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
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F7FD),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE1E4E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attach_file, size: 18, color: const Color(0xFF1B2330)),
              SizedBox(width: 8),
              Text(
                'Receipt Upload',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1B2330),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          
          if (_receiptImage == null) ...[
            InkWell(
              onTap: _isUploading ? null : _pickReceiptImage,
              child: Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFBDBDBD),
                    style: BorderStyle.solid,
                  ),
                ),
                child: _isUploading
                    ? Center(child: CircularProgressIndicator(strokeWidth: 2))
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload, size: 32, color: const Color(0xFFBDBDBD)),
                          SizedBox(height: 8),
                          Text(
                            'Tap to upload receipt',
                            style: TextStyle(
                              color: const Color(0xFF7B7B7B),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ] else ...[
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE1E4E8)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    Image.file(
                      _receiptImage!,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: InkWell(
                        onTap: () => setState(() => _receiptImage = null),
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 16),
                SizedBox(width: 8),
                Text(
                  'Receipt uploaded successfully',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubmitButton(ReimbursementProvider provider, bool isMobile) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: provider.isSubmitting ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1B2330),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
        child: provider.isSubmitting
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Submitting...', style: TextStyle(fontSize: 16)),
                ],
              )
            : Text(
                'Submit Reimbursement Request',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildStatusMessage(ReimbursementProvider provider, bool isMobile) {
    return Padding(
      padding: EdgeInsets.only(top: 16),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: provider.submitMessage?.contains('success') == true
              ? Colors.green.withOpacity(0.1)
              : Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: provider.submitMessage?.contains('success') == true
                ? Colors.green
                : Colors.red,
          ),
        ),
        child: Row(
          children: [
            Icon(
              provider.submitMessage?.contains('success') == true
                  ? Icons.check_circle
                  : Icons.error,
              color: provider.submitMessage?.contains('success') == true
                  ? Colors.green
                  : Colors.red,
              size: 20,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                provider.submitMessage ?? provider.errorMessage ?? '',
                style: TextStyle(
                  color: provider.submitMessage?.contains('success') == true
                      ? Colors.green[700]
                      : Colors.red[700],
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF1B2330),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: const Color(0xFF1B2330),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
        _invalidFields.remove('date');
      });
    }
  }

  Future<void> _pickReceiptImage() async {
    setState(() => _isUploading = true);
    
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _receiptImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _submitForm() async {
    final provider = Provider.of<ReimbursementProvider>(context, listen: false);
    provider.clearMessages();

    // Log: Start form submission
    debugPrint('[Reimbursement] Submitting form...');
    // Validate form
    _invalidFields.clear();

    if (_empNameController.text.trim().isEmpty) {
      _invalidFields.add('empName');
      debugPrint('[Reimbursement] Validation failed: empName is empty');
    }

    if (_amountController.text.trim().isEmpty) {
      _invalidFields.add('amount');
      debugPrint('[Reimbursement] Validation failed: amount is empty');
    } else {
      final amount = double.tryParse(_amountController.text.trim());
      if (amount == null || amount <= 0) {
        _invalidFields.add('amount');
        debugPrint('[Reimbursement] Validation failed: amount is invalid');
      }
    }

    if (_purposeController.text.trim().isEmpty) {
      _invalidFields.add('purpose');
      debugPrint('[Reimbursement] Validation failed: purpose is empty');
    }

    if (_selectedDate == null) {
      _invalidFields.add('date');
      debugPrint('[Reimbursement] Validation failed: date is not selected');
    }
    if (_receiptImage == null) {
      debugPrint('[Reimbursement] Validation failed: receipt image not uploaded');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please upload a receipt image.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Log: All validations passed
    debugPrint('[Reimbursement] All validations passed. Creating reimbursement object...');
    // Create reimbursement request
    final reimbursement = EmployeeReimbursement(
      empId: 'sal2001', // TODO: Get from actual auth/session
      empName: _empNameController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      reimbursementDate: _selectedDate!,
      purpose: _purposeController.text.trim(),
      remarks: _remarksController.text.trim().isEmpty ? null : _remarksController.text.trim(),
      receiptUrl: _receiptImage != null ? 'uploaded' : null, // Will be replaced with actual URL
    );

    debugPrint('[Reimbursement] Calling provider.addReimbursementRequest...');
    await provider.addReimbursementRequest(reimbursement, receiptImage: _receiptImage);
    debugPrint('[Reimbursement] Provider submitMessage: "+(provider.submitMessage ?? '')+"');
    debugPrint('[Reimbursement] Provider errorMessage: "+(provider.errorMessage ?? '')+"');

    // Clear form if successful
    if (provider.submitMessage?.contains('success') == true) {
      debugPrint('[Reimbursement] Submission successful. Clearing form.');
      _clearForm();
      // Refresh reimbursements list after submit
      await provider.fetchReimbursements();
      setState(() {}); // Force UI refresh if needed
    } else {
      debugPrint('[Reimbursement] Submission failed.');
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
    // Pre-fill employee name again
    _empNameController.text = 'John Doe';
  }
}

// Reusable label widget
class _Label extends StatelessWidget {
  final String text;
  final String? tooltip;
  const _Label(this.text, {this.tooltip, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF7B7B7B),
              fontWeight: FontWeight.w500,
            ),
          ),
          if (tooltip != null)
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Tooltip(
                message: tooltip!,
                child: Icon(Icons.info_outline, size: 15, color: Color(0xFFBDBDBD)),
              ),
            ),
        ],
      ),
    );
  }
}

// Reusable input field widget
class _InputField extends StatelessWidget {
  final String hint;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool error;
  final TextInputType? keyboardType;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;

  const _InputField({
    required this.hint,
    this.suffixIcon,
    this.controller,
    this.readOnly = false,
    this.onTap,
    this.error = false,
    this.keyboardType,
    this.maxLines = 1,
    this.inputFormatters,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        boxShadow: error
            ? [
                BoxShadow(
                  color: Colors.red.withOpacity(0.15),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
        maxLines: maxLines,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 13, color: Color(0xFFBDBDBD)),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          filled: true,
          fillColor: readOnly ? Color(0xFFF0F0F0) : Color(0xFFF8F8F8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide.none,
          ),
          suffixIcon: suffixIcon,
          errorBorder: error
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: Colors.red, width: 1.5),
                )
              : null,
          focusedErrorBorder: error
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: Colors.red, width: 1.5),
                )
              : null,
        ),
      ),
    );
  }
}
