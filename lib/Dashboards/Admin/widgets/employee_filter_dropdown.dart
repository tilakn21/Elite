import 'package:flutter/material.dart';

class EmployeeFilterDropdown extends StatefulWidget {
  final List<String> roles;
  final String selectedRole;
  final ValueChanged<String>? onChanged;
  const EmployeeFilterDropdown({Key? key, required this.roles, required this.selectedRole, this.onChanged}) : super(key: key);

  @override
  State<EmployeeFilterDropdown> createState() => _EmployeeFilterDropdownState();
}

class _EmployeeFilterDropdownState extends State<EmployeeFilterDropdown> {
  late String selectedRole;

  @override
  void initState() {
    super.initState();
    selectedRole = widget.selectedRole;
  }

  @override
  void didUpdateWidget(EmployeeFilterDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedRole != selectedRole) {
      selectedRole = widget.selectedRole;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: selectedRole,
        borderRadius: BorderRadius.circular(8),
        style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF232B3E)),
        items: widget.roles.map((role) => DropdownMenuItem(value: role, child: Text(role))).toList(),
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

