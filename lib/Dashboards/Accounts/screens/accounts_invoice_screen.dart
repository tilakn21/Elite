import 'package:flutter/material.dart';
import '../widgets/accounts_sidebar.dart';
import '../widgets/accounts_top_bar.dart';
import '../widgets/accounts_invoice_detail.dart';
import '../models/invoice.dart';
import 'package:provider/provider.dart';
import '../providers/invoice_provider.dart';
import 'package:intl/intl.dart';

class AccountsInvoiceScreen extends StatefulWidget {
  final String? accountantId;
  const AccountsInvoiceScreen({Key? key, this.accountantId}) : super(key: key);

  @override
  State<AccountsInvoiceScreen> createState() => _AccountsInvoiceScreenState();
}

class _AccountsInvoiceScreenState extends State<AccountsInvoiceScreen> {
  Future<void> _showPaymentDialog(BuildContext context, InvoiceProvider invoiceProvider, Invoice invoice) async {
    final TextEditingController amountController = TextEditingController(text: invoice.balanceDue.toStringAsFixed(2));
    String modeOfPayment = 'Cash';
    final List<String> paymentModes = ['Cash', 'Bank Transfer', 'UPI', 'Cheque', 'Card'];
    // Use a demo accountant name for now; replace with authenticated user name in future
    final String demoAccountantName = widget.accountantId ?? 'Demo Accountant'; // Use authenticated user name if available
    final TextEditingController receivedByController = TextEditingController(text: demoAccountantName);
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd – kk:mm').format(now);

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount to Pay',
                ),
                readOnly: true, // Make amount field uneditable
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: modeOfPayment,
                items: paymentModes.map((mode) => DropdownMenuItem(
                  value: mode,
                  child: Text(mode),
                )).toList(),
                onChanged: (val) {
                  if (val != null) modeOfPayment = val;
                },
                decoration: const InputDecoration(
                  labelText: 'Mode of Payment',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: receivedByController,
                decoration: const InputDecoration(
                  labelText: 'Received By',
                  hintText: 'Enter receiver name',
                ),
                readOnly: true, // Make received by field uneditable
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 18),
                  const SizedBox(width: 8),
                  Text(dateStr, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop({
                  'amountPaid': double.tryParse(amountController.text) ?? invoice.balanceDue,
                  'modeOfPayment': modeOfPayment,
                  'receivedBy': demoAccountantName, // Use demo name
                  'dateTime': now,
                });
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      final double paid = result['amountPaid'] ?? invoice.balanceDue;
      final String mode = result['modeOfPayment'] ?? 'Cash';
      final String receivedBy = result['receivedBy'] ?? '';
      final DateTime paidAt = result['dateTime'] ?? DateTime.now();
      final String paidDate = DateFormat('yyyy-MM-dd').format(paidAt);
      final String paidTime = DateFormat('HH:mm:ss').format(paidAt);

      // Only update accountant JSONB in jobs table (remove updateInvoice call)
      await invoiceProvider.appendAccountantPaymentDetail(
        jobId: invoice.id, // Use invoice.id as jobId
        paymentDetail: {
          'amount_paid': paid,
          'received_by': receivedBy,
          'mode_of_payment': mode,
          'date': paidDate,
          'time': paidTime,
          'status': 'completed', // Set status to completed in accountant JSONB
        },
      );

      // Auto-refresh invoice list and re-select the current invoice
      await invoiceProvider.fetchInvoices();
      await invoiceProvider.fetchInvoiceById(invoice.id);

      // If due is now 0, ensure status is set to completed
      final refreshedInvoice = invoiceProvider.selectedInvoice;
      final accountant = refreshedInvoice?.accountantJson;
      final double due = (accountant?['amount_due'] as num?)?.toDouble() ?? refreshedInvoice?.balanceDue ?? 0.0;
      if (due == 0 && (accountant?['status'] != 'completed')) {
        await invoiceProvider.appendAccountantPaymentDetail(
          jobId: invoice.id,
          paymentDetail: {
            'status': 'completed',
          },
        );
        await invoiceProvider.fetchInvoices();
        await invoiceProvider.fetchInvoiceById(invoice.id);
      }

      // --- NEW LOGIC: If job status is 'payment pending', set to 'out for delivery' ---
      await invoiceProvider.updateJobStatusOutForDeliveryIfPaymentPending(invoice.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment of ₹${paid.toStringAsFixed(2)} confirmed for ${invoice.clientName} (${invoice.invoiceNo})'),
            backgroundColor: const Color(0xFF059669),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InvoiceProvider>(context, listen: false).fetchInvoices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final invoiceProvider = Provider.of<InvoiceProvider>(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FF),
      body: Row(
        children: [
          AccountsSidebar(selectedIndex: 1, accountantId: widget.accountantId),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AccountsTopBar(accountantId: widget.accountantId),
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 1000),
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with back button
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.of(context).pushReplacementNamed('/accounts/dashboard'),
                                  icon: const Icon(Icons.arrow_back, color: Color(0xFF232B3E)),
                                  tooltip: 'Back to Dashboard',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  iconSize: 22,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Invoice Details',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28,
                                    color: Color(0xFF232B3E),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Show loading state
                            if (invoiceProvider.isLoading)
                              Container(
                                height: 400,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFEEEEF1)),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF232B3E)),
                                  ),
                                ),
                              )
                            // Show error state
                            else if (invoiceProvider.errorMessage != null)
                              Container(
                                height: 400,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFEEEEF1)),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.error_outline,
                                        color: Color(0xFFDC2626),
                                        size: 48,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Error loading invoice details',
                                        style: TextStyle(
                                          color: Colors.grey[800],
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        invoiceProvider.errorMessage!,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      TextButton.icon(
                                        onPressed: () => invoiceProvider.fetchInvoices(),
                                        icon: const Icon(Icons.refresh),
                                        label: const Text('Retry'),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            // Show invoice details
                            else
                              AccountsInvoiceDetail(
                                invoice: invoiceProvider.selectedInvoice,
                                onConfirmPayment: () async {
                                  final currentSelectedInvoice = invoiceProvider.selectedInvoice;
                                  if (currentSelectedInvoice != null) {
                                    await _showPaymentDialog(context, invoiceProvider, currentSelectedInvoice);
                                  }
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
