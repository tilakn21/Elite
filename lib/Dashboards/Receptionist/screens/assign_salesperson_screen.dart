import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/topbar.dart';

class AssignSalespersonScreen extends StatelessWidget {
  final bool showAppBars;
  const AssignSalespersonScreen({Key? key, this.showAppBars = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double cardWidth = 420;
    Widget content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 56, top: 8),
            child: Text(
              'Assign salesperson',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 24,
                color: Color(0xFF1B2330),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 56),
              // Job list card
              Container(
                width: cardWidth,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Job list',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Color(0xFF7B7B7B))),
                    const SizedBox(height: 16),
                    _JobListItem(
                      avatar: 'assets/images/avatar1.png',
                      name: 'Brooklyn Simmons',
                      subtitle: 'Dermatologists',
                      jobId: '87364523',
                      location: 'Chicago',
                    ),
                    _JobListItem(
                      avatar: 'assets/images/avatar2.png',
                      name: 'Jacob Jones',
                      subtitle: 'Ophthalmologists',
                      jobId: '23847569',
                      location: 'Newyork',
                    ),
                    _JobListItem(
                      avatar: 'assets/images/avatar3.png',
                      name: 'Kristin Watson',
                      subtitle: 'Infectious disease',
                      jobId: '93874563',
                      location: 'Chicago',
                    ),
                  ],
                ),
              ),
              SizedBox(width: 40),
              // Salesperson availability card
              Container(
                width: cardWidth,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Salesperson availability',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Color(0xFF7B7B7B))),
                    const SizedBox(height: 16),
                    _SalespersonDropdown(),
                    const SizedBox(height: 8),
                    _SalespersonItem(name: 'James smith'),
                    _SalespersonItem(name: 'Loura wisdom'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          Padding(
            padding: const EdgeInsets.only(left: 56),
            child: Container(
              width: 900,
              padding: const EdgeInsets.symmetric(
                  vertical: 24, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: 'Assign Job ',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1B2330),
                            fontSize: 16),
                        children: [
                          TextSpan(
                              text: '#87364523',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF36A1C5))),
                          TextSpan(text: ' to '),
                          TextSpan(
                              text: 'Richard Davis',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF36A1C5))),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    height: 32,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF36A1C5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {},
                      child: const Text(
                        'Assign',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    if (!showAppBars) return content;
    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FE),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Sidebar(selectedIndex: 2),
          Expanded(
            child: Column(
              children: [
                const TopBar(),
                Expanded(child: content),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _JobListItem extends StatelessWidget {
  final String avatar;
  final String name;
  final String subtitle;
  final String jobId;
  final String location;
  const _JobListItem(
      {required this.avatar,
      required this.name,
      required this.subtitle,
      required this.jobId,
      required this.location,
      Key? key})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(backgroundImage: AssetImage(avatar), radius: 18),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              Text(subtitle,
                  style: TextStyle(fontSize: 11, color: Color(0xFFBDBDBD))),
            ],
          ),
          Spacer(),
          Text(jobId,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          SizedBox(width: 32),
          Text(location,
              style: TextStyle(fontSize: 13, color: Color(0xFF7B7B7B))),
        ],
      ),
    );
  }
}

class _SalespersonDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: 'Richard Davis',
      items: [
        DropdownMenuItem(value: 'Richard Davis', child: Text('Richard Davis')),
        DropdownMenuItem(value: 'James smith', child: Text('James smith')),
        DropdownMenuItem(value: 'Loura wisdom', child: Text('Loura wisdom')),
      ],
      onChanged: (value) {},
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        filled: true,
        fillColor: Color(0xFFF8F8F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _SalespersonItem extends StatelessWidget {
  final String name;
  const _SalespersonItem({required this.name, Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(name,
            style: TextStyle(fontSize: 13, color: Color(0xFF1B2330))),
      ),
    );
  }
}
