import 'package:flutter/material.dart';
import '../models/invoice.dart';

// Helper extension to format date
// ignore: camel_case_extensions
extension DateFormat on DateTime {
  String formatDate() {
    return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';
  }
}

class AccountsInvoiceTable extends StatelessWidget {
  final Function(Invoice) onSelectInvoice;
  final String? selectedInvoiceNo;
  final List<Invoice> invoices;
  
  const AccountsInvoiceTable({
    super.key, 
    required this.onSelectInvoice, 
    this.selectedInvoiceNo,
    List<Invoice>? invoices,
  }) : invoices = invoices ?? const [];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFF6F4FF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: const [
                _HeaderCell('Invoice no.', flex: 2),
                _HeaderCell('Client Name', flex: 3),
                _HeaderCell('Approved Date', flex: 3),
                _HeaderCell('Amount', flex: 2),
                _HeaderCell('STATUS', flex: 2),
              ],
            ),
          ),
          ...invoices.map((invoice) => _InvoiceRow(
            invoice: invoice,
            selected: selectedInvoiceNo == invoice.invoiceNo,
            onTap: () => onSelectInvoice(invoice),
          )),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final int flex;
  const _HeaderCell(this.label, {this.flex = 1});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFB0B3C7), fontSize: 15)),
    );
  }
}

class _InvoiceRow extends StatelessWidget {
  final Invoice invoice;
  final bool selected;
  final VoidCallback onTap;
  const _InvoiceRow({required this.invoice, required this.selected, required this.onTap});

  Color _statusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.paid:
        return const Color(0xFFD0F8E6);
      case InvoiceStatus.pending:
        return const Color(0xFFFFEAEA);
      case InvoiceStatus.overdue:
        return const Color(0xFFF3EFFF);
      default:
        return Colors.grey.shade200;
    }
  }

  Color _statusTextColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.paid:
        return const Color(0xFF5AD09A);
      case InvoiceStatus.pending:
        return const Color(0xFFF96E6E);
      case InvoiceStatus.overdue:
        return const Color(0xFF9B6FF7);
      default:
        return Colors.black;
    }
  }
  
  String _formatStatus(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return 'Draft';
      case InvoiceStatus.sent:
        return 'Sent';
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.overdue:
        return 'Overdue';
      case InvoiceStatus.partial:
        return 'Partial';
      case InvoiceStatus.cancelled:
        return 'Cancelled';
      default:
        return status.toString().split('.').last[0].toUpperCase() + 
               status.toString().split('.').last.substring(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF1F0FF) : Colors.transparent,
          border: const Border(
            bottom: BorderSide(color: Color(0xFFF1F0FF)),
          ),
        ),
        child: Row(
          children: [
            Expanded(flex: 2, child: Text(invoice.invoiceNo, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15))),
            Expanded(flex: 3, child: Text(invoice.clientName, style: const TextStyle(fontSize: 15))),
            Expanded(flex: 3, child: Text(invoice.issueDate.formatDate(), style: const TextStyle(fontSize: 15))),
            Expanded(flex: 2, child: Text('£${invoice.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(invoice.status),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _formatStatus(invoice.status),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: _statusTextColor(invoice.status),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
