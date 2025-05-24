import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/topbar.dart';

class NewJobRequestScreen extends StatelessWidget {
  const NewJobRequestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double formWidth = 800;
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
                Expanded(
                  child: Center(
                    child: Container(
                      width: formWidth,
                      padding: const EdgeInsets.symmetric(
                          vertical: 48, horizontal: 40),
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
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
                          // Updated Form Fields
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left column
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _Label('Name'),
                                    _InputField(hint: 'Enter name'),
                                    SizedBox(height: 20),
                                    _Label('Phone number'),
                                    _InputField(hint: 'Enter phone number'),
                                    SizedBox(height: 20),
                                    _Label('Shop name'),
                                    _InputField(hint: 'Enter shop name'),
                                    SizedBox(height: 20),
                                    _Label('Street address'),
                                    _InputField(hint: 'Enter street address'),
                                  ],
                                ),
                              ),
                              SizedBox(width: 32),
                              // Right column
                              Expanded(
                                child: _RightFormFields(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 48),
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
                                  onPressed: () {},
                                  child: const Text(
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
                ),
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
  final TextEditingController? controller;
  final bool readOnly;
  final VoidCallback? onTap;
  const _InputField({required this.hint, this.suffixIcon, this.controller, this.readOnly = false, this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
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
