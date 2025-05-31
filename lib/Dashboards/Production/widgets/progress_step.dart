import 'package:flutter/material.dart';

class ProgressStep extends StatelessWidget {
  final String label;
  final bool filled;
  const ProgressStep({required this.label, required this.filled, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: filled ? Colors.blue[800] : Colors.grey[300],
        ),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }
}
