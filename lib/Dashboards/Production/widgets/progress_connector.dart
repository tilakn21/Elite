import 'package:flutter/material.dart';

class ProgressConnector extends StatelessWidget {
  final bool filled;
  final bool short;
  const ProgressConnector({required this.filled, this.short = false, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: short ? 40 : 70,
      height: 8,
      decoration: BoxDecoration(
        color: filled ? Colors.blue : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
