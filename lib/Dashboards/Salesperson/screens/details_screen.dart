import 'package:flutter/material.dart';
import '../widgets/salesperson_sidebar.dart';

class SalespersonDetailsScreen extends StatefulWidget {
  const SalespersonDetailsScreen({Key? key}) : super(key: key);

  @override
  State<SalespersonDetailsScreen> createState() => _SalespersonDetailsScreenState();
}

class _SalespersonDetailsScreenState extends State<SalespersonDetailsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.75,
        child: SalespersonSidebar(
          selectedRoute: 'home',
          onItemSelected: (route) {
            if (route == 'home') {
              Navigator.of(context).pushReplacementNamed('/salesperson/dashboard');
            } else if (route == 'profile') {
              Navigator.of(context).pushReplacementNamed('/salesperson/profile');
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
        title: const Text('Details', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text('Client Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black)),
            const SizedBox(height: 2),
            const Text('Jim Gorge', style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14)),
            const SizedBox(height: 18),
            const Text('Job Description', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black)),
            const SizedBox(height: 2),
            const Text('Renovation of Living Room & Bedroom', style: TextStyle(color: Color(0xFFBDBDBD), fontSize: 14)),
            const SizedBox(height: 18),
            const Text('Date', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black)),
            const SizedBox(height: 2),
            const Text('DD/MM/YY', style: TextStyle(color: Color(0xFFBDBDBD), fontSize: 14)),
            const SizedBox(height: 22),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black87),
                borderRadius: BorderRadius.circular(6),
              ),
              child: TextField(
                controller: _notesController,
                minLines: 5,
                maxLines: 6,
                style: const TextStyle(fontSize: 15),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  hintText: 'Enter text..',
                  hintStyle: TextStyle(color: Color(0xFFBDBDBD)),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black87),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                  ),
                  onPressed: () {},
                  child: const Text('Upload Image', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 15)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: 180,
              height: 42,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3EC1D3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                onPressed: () {},
                child: const Text('Submit Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
              ),
            ),
          ],
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
