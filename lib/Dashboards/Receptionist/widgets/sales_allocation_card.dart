import 'package:flutter/material.dart';
import '../models/salesperson.dart' as model;

class SalesAllocationCard extends StatelessWidget {
  final List<model.Salesperson> salesPeople;
  const SalesAllocationCard({super.key, required this.salesPeople});

  @override
  Widget build(BuildContext context) {
    if (salesPeople.isEmpty) {
      return Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 28, 32, 28),
          child: Center(
            child: Text(
              'No salespersons found.',
              style: TextStyle(
                color: Colors.red.shade400,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
        ),
      );
    }

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
                child: _StatusPill(isAvailable: person.status == model.SalespersonStatus.available),
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
  final bool isAvailable;
  const _StatusPill({required this.isAvailable});

  @override
  Widget build(BuildContext context) {
    final statusLabel = isAvailable ? 'Available' : 'Unavailable';
    final statusColor = isAvailable ? const Color(0xFF4CAF50) : const Color(0xFFE53935);
    final bgColor = isAvailable ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            statusLabel,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
