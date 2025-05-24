import 'package:flutter/material.dart';

class EmployeeFilterDropdown extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String>? onChanged;
  const EmployeeFilterDropdown({Key? key, this.initialValue = 'Receptionist', this.onChanged}) : super(key: key);

  @override
  State<EmployeeFilterDropdown> createState() => _EmployeeFilterDropdownState();
}

class _EmployeeFilterDropdownState extends State<EmployeeFilterDropdown> {
  late String selectedRole;
  final List<String> roles = ['Receptionist', 'Designer', 'Sales Person'];

  @override
  void initState() {
    super.initState();
    selectedRole = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: selectedRole,
        borderRadius: BorderRadius.circular(8),
        style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF232B3E)),
        items: roles.map((role) => DropdownMenuItem(value: role, child: Text(role))).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() => selectedRole = value);
            if (widget.onChanged != null) widget.onChanged!(value);
          }
        },
        isExpanded: true,
      ),
    );
  }
}

