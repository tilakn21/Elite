import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/reimbursement_model.dart';
import '../providers/reimbursement_provider.dart';

class ReimbursementRequestForm extends StatefulWidget {
  final String empId;
  final String empName;
  final Widget? header;
  final Widget? footer;
  final double? maxWidth;
  final Color? primaryColor;
  final bool showTitle;

  const ReimbursementRequestForm({
    Key? key,
    required this.empId,
    required this.empName,
    this.header,
    this.footer,
    this.maxWidth,
    this.primaryColor = const Color(0xFF5C67F2),
    this.showTitle = true,
  }) : super(key: key);

  @override
  State<ReimbursementRequestForm> createState() => _ReimbursementRequestFormState();
}

class _ReimbursementRequestFormState extends State<ReimbursementRequestForm> {
  final _formKey = GlobalKey<FormState>();
  
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
  void dispose() {
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
    final formWidth = widget.maxWidth ?? (isMobile ? double.infinity : 700);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 24, horizontal: isMobile ? 0 : 8),
      child: Container(
        width: formWidth,
        margin: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.header != null) ...[
                widget.header!,
                SizedBox(height: 24),
              ],
              if (widget.showTitle) ...[
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
              ],
              _buildFormFields(isMobile),
              SizedBox(height: 24),
              _buildReceiptUploadSection(isMobile),
              SizedBox(height: 32),
              _buildSubmitButton(context, isMobile),
              Consumer<ReimbursementProvider>(
                builder: (context, provider, child) {
                  if (provider.submitMessage != null || provider.errorMessage != null) {
                    return _buildStatusMessage(provider, isMobile);
                  }
                  return SizedBox.shrink();
                },
              ),
              if (widget.footer != null) ...[
                SizedBox(height: 24),
                widget.footer!,
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormFields(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputField('Amount (\$)', _amountController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          error: _invalidFields.contains('amount'),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
          tooltip: 'Total amount to be reimbursed',
        ),
        SizedBox(height: 20),
        _buildInputField('Purpose', _purposeController,
          error: _invalidFields.contains('purpose'),
          maxLines: 2,
          tooltip: 'Reason for the expense',
        ),
        SizedBox(height: 20),
        _buildInputField('Date of Expense', _dateController,
          error: _invalidFields.contains('date'),
          readOnly: true,
          onTap: () => _pickDate(),
          suffixIcon: Icon(Icons.calendar_today, size: 18, color: Color(0xFFBDBDBD)),
          tooltip: 'Date when the expense was incurred',
        ),
        SizedBox(height: 20),
        _buildInputField('Remarks (Optional)', _remarksController,
          maxLines: 3,
          tooltip: 'Additional notes or comments',
        ),
      ],
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller, {
    bool error = false,
    bool readOnly = false,
    int maxLines = 1,
    VoidCallback? onTap,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? tooltip,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF7B7B7B),
              ),
            ),
            if (tooltip != null) ...[
              SizedBox(width: 4),
              Tooltip(
                message: tooltip,
                child: Icon(Icons.info_outline, size: 15, color: Color(0xFFBDBDBD)),
              ),
            ],
          ],
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          maxLines: maxLines,
          keyboardType: keyboardType,
          onTap: onTap,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            filled: true,
            fillColor: readOnly ? Color(0xFFF0F0F0) : Color(0xFFF8F8F8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: error ? Colors.red : Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: widget.primaryColor!, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red),
            ),
            suffixIcon: suffixIcon,
          ),
        ),
        if (error)
          Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'This field is required',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload, size: 40, color: Color(0xFFBDBDBD)),
                        SizedBox(height: 8),
                        Text(
                          'Tap to upload receipt',
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            color: const Color(0xFFBDBDBD),
                          ),
                        ),
                      ],
                    ),
                  )
                : Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _receiptImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
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
        if (_invalidFields.contains('receipt'))
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Receipt image is required',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context, bool isMobile) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isUploading ? null : () => _submitForm(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
        child: _isUploading
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
    final isSuccess = provider.submitMessage != null;
    final message = isSuccess ? provider.submitMessage : provider.errorMessage;
    final color = isSuccess ? Colors.green : Colors.red;

    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
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
              message ?? '',
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
            colorScheme: ColorScheme.light(primary: widget.primaryColor!),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
        _invalidFields.remove('date');
      });
    }
  }

  Future<void> _pickReceiptImage() async {
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
          _invalidFields.remove('receipt');
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitForm(BuildContext context) async {
    final provider = Provider.of<ReimbursementProvider>(context, listen: false);
    provider.clearMessages();
    _invalidFields.clear();

    // Validate all fields
    if (_amountController.text.trim().isEmpty) {
      _invalidFields.add('amount');
    } else {
      final amount = double.tryParse(_amountController.text.trim());
      if (amount == null || amount <= 0) {
        _invalidFields.add('amount');
      }
    }

    if (_purposeController.text.trim().isEmpty) {
      _invalidFields.add('purpose');
    }

    if (_selectedDate == null) {
      _invalidFields.add('date');
    }

    if (_receiptImage == null) {
      _invalidFields.add('receipt');
    }

    if (_invalidFields.isNotEmpty) {
      setState(() {}); // Trigger rebuild to show validation errors
      return;
    }

    setState(() => _isUploading = true);

    try {
      final reimbursement = EmployeeReimbursement(
        empId: widget.empId,
        empName: widget.empName,
        amount: double.parse(_amountController.text.trim()),
        reimbursementDate: _selectedDate!,
        purpose: _purposeController.text.trim(),
        remarks: _remarksController.text.trim().isEmpty ? null : _remarksController.text.trim(),
      );

      await provider.addReimbursementRequest(reimbursement, receiptImage: _receiptImage);

      if (provider.submitMessage?.contains('success') == true) {
        _clearForm();
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _clearForm() {
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
