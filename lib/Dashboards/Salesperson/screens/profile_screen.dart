import 'package:flutter/material.dart';
import '../widgets/salesperson_sidebar.dart';

class SalespersonProfileScreen extends StatefulWidget {
  const SalespersonProfileScreen({Key? key}) : super(key: key);

  @override
  State<SalespersonProfileScreen> createState() => _SalespersonProfileScreenState();
}

class _SalespersonProfileScreenState extends State<SalespersonProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.75,
        child: SalespersonSidebar(
          selectedRoute: 'profile',
          onItemSelected: (route) {
            if (route == 'home') {
              Navigator.of(context).pushReplacementNamed('/salesperson/dashboard');
            } else if (route == 'profile') {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Profile', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Color(0xFFE7F6FB),
              radius: 18,
              child: Icon(Icons.person, color: Color(0xFF5A6CEA)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Center(
                child: CircleAvatar(
                  backgroundColor: Color(0xFFE7F6FB),
                  radius: 46,
                  child: Icon(Icons.person, color: Color(0xFF5A6CEA), size: 56),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Brooklyn Simmons',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: Colors.black),
              ),
              const SizedBox(height: 2),
              const Text(
                'Sales person',
                style: TextStyle(color: Color(0xFFBDBDBD), fontSize: 15, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 24),
              _ProfileCard(
                label: 'Full Name',
                value: 'Brooklyn Simmons',
                isBold: true,
              ),
              const SizedBox(height: 12),
              _ProfileCard(
                label: 'Phone no.',
                value: '(603) 555-0123',
              ),
              const SizedBox(height: 12),
              _ProfileCard(
                label: 'Email Address',
                value: 'brooklyns@mail.com',
                isBold: true,
              ),
              const SizedBox(height: 12),
              _ProfileCard(
                label: 'Age',
                value: '26 yr',
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0D223F),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Icon(Icons.apps, color: Colors.white, size: 28),
            Icon(Icons.settings, color: Colors.white, size: 28),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  const _ProfileCard({required this.label, required this.value, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
