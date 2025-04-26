import 'package:flutter/material.dart';

class AssignLabourItem extends StatelessWidget {
  final String name;
  final String role;
  final String image;
  final bool assigned;
  const AssignLabourItem({required this.name, required this.role, required this.image, this.assigned = false, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _AssignLabourItem(
      name: name,
      role: role,
      image: image,
      assigned: assigned,
    );
  }
}

class _AssignLabourItem extends StatelessWidget {
  final String name;
  final String role;
  final String image;
  final bool assigned;

  const _AssignLabourItem({required this.name, required this.role, required this.image, required this.assigned, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool narrow = constraints.maxWidth < 250;
        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFFB2DFDB)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: narrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$name – $role', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text('Address     - $image', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF26A6A2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        child: const Text('+Assign', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$name – $role', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 2),
                        Text('Address     - $image', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF26A6A2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: const Text('+Assign', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
