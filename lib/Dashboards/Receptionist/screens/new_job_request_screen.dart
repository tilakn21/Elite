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
          const Sidebar(),
          Expanded(
            child: Column(
              children: [
                const TopBar(isDashboard: false),
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
                                    _Label('Email address'),
                                    _InputField(hint: 'Your email address'),
                                    SizedBox(height: 20),
                                    _Label('Date'),
                                    _InputField(
                                      hint: 'Select date',
                                      suffixIcon: Icon(Icons.calendar_today,
                                          size: 18, color: Color(0xFFBDBDBD)),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 32),
                              // Right column
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _Label('Phone no.'),
                                    _InputField(hint: 'Enter phone number'),
                                    SizedBox(height: 20),
                                    _Label('Shop name'),
                                    _InputField(hint: 'Enter shop name'),
                                    SizedBox(height: 20),
                                    _Label('Shop address'),
                                    _InputField(hint: 'Enter shop address'),
                                  ],
                                ),
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
  const _InputField({required this.hint, this.suffixIcon, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
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
