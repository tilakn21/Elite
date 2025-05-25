import 'package:flutter/material.dart';
import '../models/salesperson.dart' as model;

class SalesAllocationCard extends StatelessWidget {
  final List<model.Salesperson> salesPeople;
  const SalesAllocationCard({super.key, required this.salesPeople});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 28, 32, 28),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sales Allocation Dashboard',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Color(0xFF1B2330),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: const [
                  Expanded(flex: 2, child: _Header('Name')),
                  Expanded(child: _Header('Status')),
                ],
              ),
              const Divider(height: 18, thickness: 1, color: Color(0xFFF2F2F2)),
              ...salesPeople.map((person) => _SalesRow(person)).toList(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  const _Header(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w500,
        color: Color(0xFF8A8D9F),
        fontSize: 14,
      ),
    );
  }
}

class _SalesRow extends StatelessWidget {
  final model.Salesperson person;
  const _SalesRow(this.person);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        person.name.isNotEmpty ? person.name[0] : '',
                        style: const TextStyle(
                          color: Color(0xFF1A237E),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      person.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _StatusPill(person.status.name),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill(this.status);

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: statusInfo.backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: statusInfo.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            status,
            style: TextStyle(
              color: statusInfo.color,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  ({Color color, Color backgroundColor}) _getStatusInfo(String status) {
    switch (status) {
      case 'Available':
        return (
          color: const Color(0xFF4CAF50),
          backgroundColor: const Color(0xFFE8F5E9),
        );
      case 'On Visit':
        return (
          color: const Color(0xFF2196F3),
          backgroundColor: const Color(0xFFE3F2FD),
        );
      case 'Busy':
        return (
          color: const Color(0xFFE53935),
          backgroundColor: const Color(0xFFFFEBEE),
        );
      case 'Away':
        return (
          color: const Color(0xFFFFA000),
          backgroundColor: const Color(0xFFFFF3E0),
        );
      default:
        return (
          color: Colors.grey,
          backgroundColor: Colors.grey.shade100,
        );
    }
  }
}
