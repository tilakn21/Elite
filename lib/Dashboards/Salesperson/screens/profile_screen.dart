import 'package:flutter/material.dart';
import '../widgets/salesperson_sidebar.dart';
import '../models/salesperson_profile.dart';

class SalespersonProfileScreen extends StatefulWidget {
  const SalespersonProfileScreen({Key? key}) : super(key: key);

  @override
  State<SalespersonProfileScreen> createState() =>
      _SalespersonProfileScreenState();
}

class _SalespersonProfileScreenState extends State<SalespersonProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final SalespersonProfile profile = SalespersonProfile(
    fullName: 'Brooklyn Simmons',
    phoneNumber: '(603) 555-0123',
    email: 'brooklyns@mail.com',
    age: 26,
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth >= 900;
        Widget sidebar = SalespersonSidebar(
          selectedRoute: 'profile',
          onItemSelected: (route) {
            if (route == 'home') {
              Navigator.of(context)
                  .pushReplacementNamed('/salesperson/dashboard');
            } else if (route == 'profile') {
              if (isLargeScreen) return;
              Navigator.of(context).pop();
            }
          },
        );
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white,
          drawer: isLargeScreen
              ? null
              : Drawer(
                  width: MediaQuery.of(context).size.width * 0.75,
                  child: sidebar,
                ),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: isLargeScreen
                ? Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Image.asset(
                      'assets/images/elite_logo.png',
                      height: 36,
                      fit: BoxFit.contain,
                    ),
                  )
                : Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: Image.asset(
                          'assets/images/elite_logo.png',
                          height: 36,
                          fit: BoxFit.contain,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.menu, color: Colors.black87),
                        onPressed: () =>
                            _scaffoldKey.currentState?.openDrawer(),
                      ),
                    ],
                  ),
            title: const Text('Profile',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w700)),
            centerTitle: true,
          ),
          body: Row(
            children: [
              if (isLargeScreen) ...[
                SizedBox(
                  width: 240,
                  child: sidebar,
                ),
              ],
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22.0, vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        Center(
                          child: CircleAvatar(
                            backgroundColor: Color(0xFFE7F6FB),
                            radius: 46,
                            child: Icon(Icons.person,
                                color: Color(0xFF5A6CEA), size: 56),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          profile.fullName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              color: Colors.black),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Sales person',
                          style: TextStyle(
                              color: Color(0xFFBDBDBD),
                              fontSize: 15,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 24),
                        _ProfileCard(
                          label: 'Full Name',
                          value: profile.fullName,
                          isBold: true,
                        ),
                        const SizedBox(height: 12),
                        _ProfileCard(
                          label: 'Phone no.',
                          value: profile.phoneNumber,
                        ),
                        const SizedBox(height: 12),
                        _ProfileCard(
                          label: 'Email Address',
                          value: profile.email,
                          isBold: true,
                        ),
                        const SizedBox(height: 12),
                        _ProfileCard(
                          label: 'Age',
                          value: '${profile.age} yr',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  const _ProfileCard(
      {required this.label, required this.value, this.isBold = false});

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
            color: Colors.black.withAlpha(15),
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
            style: const TextStyle(
                color: Color(0xFFBDBDBD),
                fontSize: 14,
                fontWeight: FontWeight.w500),
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
