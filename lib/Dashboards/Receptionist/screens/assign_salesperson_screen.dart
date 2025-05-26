import 'package:flutter/material.dart';
import '../models/job_request.dart';
import '../models/salesperson.dart' as model;
import '../widgets/sidebar.dart';
import '../widgets/topbar.dart';

class AssignSalespersonScreen extends StatelessWidget {
  const AssignSalespersonScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double cardWidth = 420;
    final jobs = [
      ReceptionistJob(
        id: '87364523',
        name: 'Brooklyn Simmons',
        subtitle: 'Dermatologists',
        avatar: 'assets/images/avatar1.png',
        location: 'Chicago',
      ),
      ReceptionistJob(
        id: '23847569',
        name: 'Jacob Jones',
        subtitle: 'Ophthalmologists',
        avatar: 'assets/images/avatar2.png',
        location: 'Newyork',
      ),
      ReceptionistJob(
        id: '93874563',
        name: 'Kristin Watson',
        subtitle: 'Infectious disease',
        avatar: 'assets/images/avatar3.png',
        location: 'Chicago',
      ),
    ];
    final salesPeople = [
      model.Salesperson(
          name: 'James smith', status: model.SalespersonStatus.available),
      model.Salesperson(
          name: 'Loura wisdom', status: model.SalespersonStatus.busy),
    ];
    final double width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 600;
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFF6F3FE),
      drawer: isMobile
          ? Drawer(
              child: Sidebar(
                selectedIndex: 2,
                isDrawer: true,
                onClose: () => Navigator.of(context).pop(),
              ),
            )
          : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMobile) Sidebar(selectedIndex: 2),
          Expanded(
            child: Column(
              children: [
                TopBar(
                  isDashboard: false,
                  showMenu: isMobile,
                  onMenuTap: () => scaffoldKey.currentState?.openDrawer(),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 32.0, horizontal: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 56, top: 8),
                          child: Text(
                            'Assign salesperson',
                            style: const TextStyle(
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
                            const SizedBox(width: 56),
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
                                  const Text('Job list',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                          color: Color(0xFF7B7B7B))),
                                  const SizedBox(height: 16),
                                  ...jobs
                                      .map((job) => _JobListItem(job: job))
                                      .toList(),
                                ],
                              ),
                            ),
                            const SizedBox(width: 40),
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
                                  const Text('Salesperson availability',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                          color: Color(0xFF7B7B7B))),
                                  const SizedBox(height: 16),
                                  _SalespersonDropdown(
                                      salesPeople: salesPeople),
                                  const SizedBox(height: 8),
                                  ...salesPeople
                                      .map((sp) =>
                                          _SalespersonItem(name: sp.name))
                                      .toList(),
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

class _JobListItem extends StatelessWidget {
  final ReceptionistJob job;
  const _JobListItem({required this.job, Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(backgroundImage: AssetImage(job.avatar), radius: 18),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(job.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              Text(job.subtitle,
                  style:
                      const TextStyle(fontSize: 11, color: Color(0xFFBDBDBD))),
            ],
          ),
          const Spacer(),
          Text(job.id,
              style:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          const SizedBox(width: 32),
          Text(job.location,
              style: const TextStyle(fontSize: 13, color: Color(0xFF7B7B7B))),
        ],
      ),
    );
  }
}

class _SalespersonDropdown extends StatelessWidget {
  final List<model.Salesperson> salesPeople;
  const _SalespersonDropdown({required this.salesPeople, Key? key})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: salesPeople.isNotEmpty ? salesPeople.first.name : null,
      items: salesPeople
          .map((sp) => DropdownMenuItem(value: sp.name, child: Text(sp.name)))
          .toList(),
      onChanged: (value) {},
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        filled: true,
        fillColor: const Color(0xFFF8F8F8),
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
