import 'package:flutter/material.dart';
import '../models/employee_payment.dart';

class AccountsEmployeeTable extends StatelessWidget {
  final List<EmployeePayment>? payments;
  final String? selectedEmployeeId;
  final void Function(EmployeePayment payment)? onViewDetails;

  const AccountsEmployeeTable({
    Key? key, 
    this.payments,
    this.selectedEmployeeId,
    this.onViewDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<EmployeePayment> employeePayments = payments ?? [];

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEF1), width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: const BoxDecoration(
              color: Color(0xFFF6F4FF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                _HeaderCell('Employee ID', flex: 2),
                _HeaderCell('Name', flex: 3),
                _HeaderCell('Purpose', flex: 3),
                _HeaderCell('Amount', flex: 2, align: TextAlign.right),
                _HeaderCell('Date', flex: 2, align: TextAlign.center),
                _HeaderCell('Status', flex: 2, align: TextAlign.center),
                const SizedBox(width: 180), // Space for button + arrow
              ],
            ),
          ),
          if (employeePayments.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'No reimbursement requests found.',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 15,
                    fontWeight: FontWeight.w500
                  ),
                ),
              ),
            )
          else ...employeePayments.map((payment) => _EmployeeRow(
            payment: payment,
            selected: selectedEmployeeId == payment.empId,
            onViewDetails: () {
              if (onViewDetails != null) {
                onViewDetails!(payment);
              }
            },
          )),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final int flex;
  final TextAlign align;

  const _HeaderCell(
    this.label, {
    this.flex = 1,
    this.align = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        textAlign: align,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Color(0xFFB0B3C7),
          fontSize: 15,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _EmployeeRow extends StatelessWidget {
  final EmployeePayment payment;
  final bool selected;
  final VoidCallback onViewDetails;

  const _EmployeeRow({
    required this.payment,
    required this.selected,
    required this.onViewDetails,
  });

  Color _statusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return const Color(0xFFD0F8E6);
      case PaymentStatus.pending:
        return const Color(0xFFFFEAEA);
      case PaymentStatus.rejected:
        return const Color(0xFFF3EFFF);
      case PaymentStatus.approved:
        return const Color(0xFFFEF9C3); // yellow background for approved
    }
  }

  Color _statusTextColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return const Color(0xFF059669);
      case PaymentStatus.pending:
        return const Color(0xFFF96E6E);
      case PaymentStatus.rejected:
        return const Color(0xFF9B6FF7);
      case PaymentStatus.approved:
        return const Color(0xFFB45309); // dark yellow text for approved
    }
  }

  String _formatStatus(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.rejected:
        return 'Rejected';
      case PaymentStatus.approved:
        return 'Approved';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFF8F7FF) : Colors.transparent,
        border: Border(
          bottom: BorderSide(color: const Color(0xFFEEEEF1)),
        ),
      ),
      child: InkWell(
        onTap: onViewDetails,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  payment.empId,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  payment.empName,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  payment.purpose,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF374151),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '\£${payment.amount.toStringAsFixed(2)}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  _formatDate(payment.reimbursementDate),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(payment.status),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _formatStatus(payment.status),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: _statusTextColor(payment.status),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                height: 34,
                width: 120,
                child: ElevatedButton(
                  onPressed: onViewDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'View Details',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: Color(0xFFB0B3C7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
