import 'package:flutter/material.dart';
import '../widgets/accounts_sidebar.dart';
import '../widgets/accounts_top_bar.dart';
import '../widgets/accounts_invoice_table.dart';
import '../widgets/accounts_invoice_detail.dart';
import '../models/invoice.dart';
import 'package:provider/provider.dart';
import '../providers/invoice_provider.dart';

class AccountsInvoiceScreen extends StatefulWidget {
  const AccountsInvoiceScreen({super.key});

  @override
  State<AccountsInvoiceScreen> createState() => _AccountsInvoiceScreenState();
}

class _AccountsInvoiceScreenState extends State<AccountsInvoiceScreen> {
  // selectedInvoice is now managed by InvoiceProvider
  // sampleInvoices list is removed as data is fetched by InvoiceProvider

  @override
  void initState() {
    super.initState();
    // Fetch initial data when the screen loads
    // Use WidgetsBinding.instance.addPostFrameCallback to ensure BuildContext is available
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
          const AccountsSidebar(selectedIndex: 1),
          Expanded(
            child: Column(
              children: [
                const AccountsTopBar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Table
                        Expanded(
                          flex: 7,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Invoice Managment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
                              const SizedBox(height: 24),
                              Expanded(
                                child: invoiceProvider.isLoading
                                    ? const Center(child: CircularProgressIndicator())
                                    : invoiceProvider.errorMessage != null
                                        ? Center(child: Text('Error: ${invoiceProvider.errorMessage}'))
                                        : invoiceProvider.invoices.isEmpty
                                            ? const Center(child: Text('No invoices found.'))
                                            : SingleChildScrollView(
                                                child: AccountsInvoiceTable(
                                                  onSelectInvoice: (invoice) {
                                                    invoiceProvider.selectInvoice(invoice);
                                                  },
                                                  invoices: invoiceProvider.invoices,
                                                  selectedInvoiceNo: invoiceProvider.selectedInvoice?.invoiceNo ?? '',
                                                ),
                                              ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 32),
                        // Payment Detail
                        Expanded(
                          flex: 5,
                          child: AccountsInvoiceDetail(
                            invoice: invoiceProvider.selectedInvoice, // Use selected invoice from provider
                            onConfirmPayment: () {
                              final currentSelectedInvoice = invoiceProvider.selectedInvoice;
                              if (currentSelectedInvoice != null) {
                                // Placeholder for actual payment confirmation logic via provider
                                // e.g., invoiceProvider.confirmPayment(currentSelectedInvoice.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Payment confirmed for ${currentSelectedInvoice.clientName} (${currentSelectedInvoice.invoiceNo})')),
                                );
                                // Potentially update status and refresh
                                invoiceProvider.updateInvoice(currentSelectedInvoice.id, currentSelectedInvoice.copyWith(status: InvoiceStatus.paid, paidDate: DateTime.now(), balanceDue: 0, amountPaid: currentSelectedInvoice.totalAmount));
                              }
                            },
                          ),
                        ),
                      ],
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
