import 'package:flutter/material.dart';
import '../models/invoice.dart';
import 'package:provider/provider.dart';
import '../providers/invoice_provider.dart';

class AccountsJobTable extends StatelessWidget {
  final void Function(Invoice invoice)? onViewInvoice;
  final List<Invoice>? invoices;
  final String? selectedJobId;

  const AccountsJobTable({Key? key, this.onViewInvoice, this.invoices, this.selectedJobId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final invoiceProvider = Provider.of<InvoiceProvider>(context);
    final List<Invoice> jobs = invoices != null ? invoices! : invoiceProvider.invoices;
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
                _HeaderCell('Job ID', flex: 2),
                _HeaderCell('Client Name', flex: 3),
                _HeaderCell('Total', flex: 2, align: TextAlign.right),
                _HeaderCell('Paid', flex: 2, align: TextAlign.right),
                _HeaderCell('Due', flex: 2, align: TextAlign.right),
                _HeaderCell('Status', flex: 2, align: TextAlign.center),
                const SizedBox(width: 180), // Space for button + arrow
              ],
            ),
          ),
          if (jobs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'No jobs found.',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 15,
                    fontWeight: FontWeight.w500
                  ),
                ),
              ),
            )
          else ...jobs.map((invoice) => _JobRow(
            invoice: invoice,
            selected: selectedJobId == invoice.id,
            onViewInvoice: () {
              if (onViewInvoice != null) {
                onViewInvoice!(invoice);
              } else {
                invoiceProvider.selectInvoice(invoice);
                Navigator.of(context).pushNamed('/accounts/invoice');
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
  const _HeaderCell(this.label, {this.flex = 1, this.align = TextAlign.left});
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

class _JobRow extends StatelessWidget {
  final Invoice invoice;
  final bool selected;
  final VoidCallback onViewInvoice;
  const _JobRow({required this.invoice, required this.selected, required this.onViewInvoice});

  @override
  Widget build(BuildContext context) {
    final accountant = invoice.accountantJson ?? {};
    final double total = (accountant['total_amount'] as num?)?.toDouble() ?? invoice.totalAmount;
    final double paid = (accountant['amount_paid'] as num?)?.toDouble() ?? invoice.amountPaid;
    final double due = (accountant['amount_due'] as num?)?.toDouble() ?? invoice.balanceDue;
    final String clientName = invoice.clientName;
    
    return Container(
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFF8F7FF) : Colors.transparent,
        border: Border(
          bottom: BorderSide(color: const Color(0xFFEEEEF1)),
        ),
      ),
      child: InkWell(
        onTap: onViewInvoice,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  invoice.invoiceNo, // Removed '#' from job number display
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
                  clientName,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '£${total.toStringAsFixed(2)}', // Changed to pound
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
                  '£${paid.toStringAsFixed(2)}', // Changed to pound
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: paid > 0 ? const Color(0xFF059669) : const Color(0xFF374151),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '£${due.toStringAsFixed(2)}', // Changed to pound
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: due > 0 ? const Color(0xFFDC2626) : const Color(0xFF059669),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Builder(
                    builder: (context) {
                      // Use status from accountantJson if present, else 'pending'
                      final String statusStr = (accountant['status'] as String?)?.toLowerCase() ?? 'pending';
                      Color bgColor;
                      Color textColor;
                      String label;
                      switch (statusStr) {
                        case 'paid':
                        case 'completed':
                          bgColor = const Color(0xFFD0F8E6);
                          textColor = const Color(0xFF059669);
                          label = 'Completed';
                          break;
                        case 'overdue':
                          bgColor = const Color(0xFFF3EFFF);
                          textColor = const Color(0xFF9B6FF7);
                          label = 'Overdue';
                          break;
                        case 'cancelled':
                          bgColor = Colors.grey.shade200;
                          textColor = Colors.grey.shade700;
                          label = 'Cancelled';
                          break;
                        case 'partial':
                          bgColor = const Color(0xFFFFF7E0);
                          textColor = const Color(0xFFF59E42);
                          label = 'Partial';
                          break;
                        case 'sent':
                          bgColor = Colors.grey.shade200;
                          textColor = Colors.grey.shade700;
                          label = 'Sent';
                          break;
                        case 'pending':
                        default:
                          bgColor = const Color(0xFFFFEAEA);
                          textColor = const Color(0xFFF96E6E);
                          label = 'Pending';
                      }
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: textColor,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                height: 34,
                width: 120,
                child: ElevatedButton(
                  onPressed: onViewInvoice,
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
                    'View Invoice',
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
