import 'package:flutter/material.dart';

class SummaryCards extends StatelessWidget {
  final int pending;
  final int inProcess;
  final int completed;
  const SummaryCards({Key? key, required this.pending, required this.inProcess, required this.completed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SummaryCard(title: 'Total pending', value: pending, color: Colors.black),
        const SizedBox(width: 18),
        _SummaryCard(title: 'In process', value: inProcess, color: Color(0xFF1673FF)),
        const SizedBox(width: 18),
        _SummaryCard(title: 'Completed', value: completed, color: Color(0xFF101C2C)),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final int value;
  final Color color;
  const _SummaryCard({Key? key, required this.title, required this.value, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: color)),
          const SizedBox(height: 10),
          Text(value.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
        ],
      ),
    );
  }
}
