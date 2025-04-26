import 'package:flutter/material.dart';
import '../widgets/accounts_sidebar.dart';
import '../widgets/accounts_top_bar.dart';
import '../widgets/accounts_invoice_table.dart';
import '../widgets/accounts_invoice_detail.dart';

class AccountsInvoiceScreen extends StatefulWidget {
  const AccountsInvoiceScreen({Key? key}) : super(key: key);

  @override
  State<AccountsInvoiceScreen> createState() => _AccountsInvoiceScreenState();
}

class _AccountsInvoiceScreenState extends State<AccountsInvoiceScreen> {
  Map<String, String>? selectedInvoice;

  @override
  Widget build(BuildContext context) {
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
                                child: SingleChildScrollView(
                                  child: AccountsInvoiceTable(
                                    onSelectInvoice: (invoice) {
                                      setState(() {
                                        selectedInvoice = invoice;
                                      });
                                    },
                                    selectedInvoiceNo: selectedInvoice?['invoiceNo'],
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
                            invoice: selectedInvoice,
                            onConfirmPayment: () {
                              if (selectedInvoice != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Payment confirmed for ${selectedInvoice!['invoiceNo']}')),
                                );
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
