import 'package:flutter/material.dart';
import '../widgets/salesperson_sidebar.dart';
import 'details_screen.dart';
import 'profile_screen.dart';

class SalespersonHomeScreen extends StatefulWidget {
  const SalespersonHomeScreen({Key? key}) : super(key: key);

  @override
  State<SalespersonHomeScreen> createState() => _SalespersonHomeScreenState();
}

class _SiteVisitItem {
  final String siteId;
  final String name;
  final String avatarPath;
  final String date;
  final bool submitted;
  _SiteVisitItem(this.siteId, this.name, this.avatarPath, this.date, this.submitted);
}

class _SalespersonHomeScreenState extends State<SalespersonHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _selectedSidebar = 'home';

  @override
  Widget build(BuildContext context) {
    final List<_SiteVisitItem> visits = [
      _SiteVisitItem('S001', 'Brooklyn Simmons', 'assets/images/avatar1.png', '21/12/2022', true),
      _SiteVisitItem('S002', 'Kristin Watson', 'assets/images/avatar2.png', '21/12/2022', false),
      _SiteVisitItem('S003', 'Brooklyn Simmons', 'assets/images/avatar3.png', '21/12/2022', false),
      _SiteVisitItem('S004', 'Cody Fisher', 'assets/images/avatar4.png', '21/12/2022', true),
      _SiteVisitItem('S005', 'Jacob Jones', 'assets/images/avatar5.png', '21/12/2022', false),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth >= 900;
        Widget sidebar = SalespersonSidebar(
          selectedRoute: _selectedSidebar,
          onItemSelected: (route) {
            setState(() {
              _selectedSidebar = route;
            });
            if (route == 'profile') {
              Navigator.of(context).pushReplacementNamed('/salesperson/profile');
            } else if (route == 'home') {
              Navigator.of(context).pushReplacementNamed('/salesperson/dashboard');
            }
          },
        );
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white,
          drawer: isLargeScreen ? null : Drawer(
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
                        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                      ),
                    ],
                  ),
            title: const Text('Home', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed('/salesperson/profile');
                  },
                  child: CircleAvatar(
                    backgroundColor: Color(0xFFE7F6FB),
                    radius: 18,
                    child: Icon(Icons.person, color: Color(0xFF5A6CEA)),
                  ),
                ),
              ),
            ],
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.separated(
                          itemCount: visits.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final item = visits[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const SalespersonDetailsScreen()),
                                );
                              },
                              child: _SiteVisitCard(item: item),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: isLargeScreen
              ? null
              : Container(
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
      },
    );
  }
}

class _SiteVisitCard extends StatelessWidget {
  final _SiteVisitItem item;
  const _SiteVisitCard({required this.item});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 400;
        if (isNarrow) {
          // Mobile: Use Column layout
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(backgroundImage: AssetImage(item.avatarPath), radius: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              Text(
                                'Site ID: ',
                                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                              ),
                              Flexible(
                                child: Text(
                                  item.siteId,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF5A6CEA)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            item.date,
                            style: const TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: item.submitted ? const Color(0xFFD2F6E7) : const Color(0xFFFFE3E3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.submitted ? 'Submitted' : 'Pending',
                        style: TextStyle(
                          color: item.submitted ? const Color(0xFF3BB77E) : const Color(0xFFD32F2F),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F3FB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.arrow_forward_ios, size: 22, color: Color(0xFFBDBDBD)),
                    ),
                  ],
                ),
              ],
            ),
          );
        } else {
          // Desktop/tablet: Use Row layout
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(backgroundImage: AssetImage(item.avatarPath), radius: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Text(
                            'Site ID: ',
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                          ),
                          Flexible(
                            child: Text(
                              item.siteId,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF5A6CEA)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            item.date,
                            style: const TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: item.submitted ? const Color(0xFFD2F6E7) : const Color(0xFFFFE3E3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.submitted ? 'Submitted' : 'Pending',
                    style: TextStyle(
                      color: item.submitted ? const Color(0xFF3BB77E) : const Color(0xFFD32F2F),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F3FB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.arrow_forward_ios, size: 22, color: Color(0xFFBDBDBD)),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
