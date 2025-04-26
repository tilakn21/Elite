import 'package:flutter/material.dart';
import '../widgets/accounts_sidebar.dart';
import '../widgets/accounts_top_bar.dart';
import '../widgets/accounts_employee_table.dart';

class AccountsEmployeeScreen extends StatefulWidget {
  const AccountsEmployeeScreen({Key? key}) : super(key: key);

  @override
  State<AccountsEmployeeScreen> createState() => _AccountsEmployeeScreenState();
}

class _AccountsEmployeeScreenState extends State<AccountsEmployeeScreen> {
  int selectedTab = 0;
  final List<String> tabs = ['Paid', 'Pending', 'Overdue'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FF),
      body: Row(
        children: [
          const AccountsSidebar(selectedIndex: 2),
          Expanded(
            child: Column(
              children: [
                const AccountsTopBar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Overview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
                        const SizedBox(height: 24),
                        Row(
                          children: List.generate(
                            tabs.length,
                            (index) => Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: selectedTab == index ? const Color(0xFF232B3E) : const Color(0xFFF6F4FF),
                                  foregroundColor: selectedTab == index ? Colors.white : const Color(0xFF888FA6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  minimumSize: const Size(110, 44),
                                ),
                                onPressed: () => setState(() => selectedTab = index),
                                child: Text(tabs[index], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        // Scrollable employee table
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                AccountsEmployeeTable(),
                              ],
                            ),
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
