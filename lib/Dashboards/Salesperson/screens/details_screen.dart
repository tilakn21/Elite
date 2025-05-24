import 'package:flutter/material.dart';
import '../widgets/salesperson_sidebar.dart';

class SalespersonDetailsScreen extends StatefulWidget {
  const SalespersonDetailsScreen({Key? key}) : super(key: key);

  @override
  State<SalespersonDetailsScreen> createState() => _SalespersonDetailsScreenState();
}

class _SalespersonDetailsScreenState extends State<SalespersonDetailsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // Controllers for all fields
  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _jobNoController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _typeOfSignController = TextEditingController();
  final TextEditingController _materialController = TextEditingController();
  final TextEditingController _toolsNailsController = TextEditingController();
  final TextEditingController _timeForProductionController = TextEditingController();
  final TextEditingController _timeForFittingController = TextEditingController();
  final TextEditingController _extraDetailsController = TextEditingController();
  final TextEditingController _signMeasurementsController = TextEditingController();
  final TextEditingController _windowVinylMeasurementsController = TextEditingController();
  String _stickSide = 'Inside';

  @override
  void dispose() {
    _customerController.dispose();
    _jobNoController.dispose();
    _dateController.dispose();
    _typeOfSignController.dispose();
    _materialController.dispose();
    _toolsNailsController.dispose();
    _timeForProductionController.dispose();
    _timeForFittingController.dispose();
    _extraDetailsController.dispose();
    _signMeasurementsController.dispose();
    _windowVinylMeasurementsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth >= 900;
          return Drawer(
            width: isLargeScreen ? 320 : MediaQuery.of(context).size.width * 0.75,
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
          );
        },
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Row(
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Demo values for Customer, Job No, Date
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Customer', style: TextStyle(fontWeight: FontWeight.w600)),
                      SizedBox(height: 4),
                      Text('John Doe', style: TextStyle(fontSize: 15, color: Colors.black87)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Job No', style: TextStyle(fontWeight: FontWeight.w600)),
                      SizedBox(height: 4),
                      Text('J-12345', style: TextStyle(fontSize: 15, color: Colors.black87)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Date', style: TextStyle(fontWeight: FontWeight.w600)),
                      SizedBox(height: 4),
                      Text('10/05/2025', style: TextStyle(fontSize: 15, color: Colors.black87)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _typeOfSignController,
              decoration: const InputDecoration(
                labelText: 'Type of Sign',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _materialController,
                    decoration: const InputDecoration(
                      labelText: 'Material',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _toolsNailsController,
                    decoration: const InputDecoration(
                      labelText: 'Tools / Nails',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _timeForProductionController,
                    decoration: const InputDecoration(
                      labelText: 'Time for Production',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _timeForFittingController,
                    decoration: const InputDecoration(
                      labelText: 'Time for Fitting',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _extraDetailsController,
              decoration: const InputDecoration(
                labelText: 'Extra Details (Frame, bracket or additional requirements to complete this job)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black54),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SIGN MEASUREMENTS',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'PUT AN X TO MARK DRILL HOLES AND NAILS',
                    style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _signMeasurementsController,
                    decoration: const InputDecoration(
                      labelText: 'Sign Measurements',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black54),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Window Vinyls',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _windowVinylMeasurementsController,
                    decoration: const InputDecoration(
                      labelText: 'Measurements',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 400;
                      return isNarrow
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Which Side to Stick from:'),
                                Row(
                                  children: [
                                    Radio<String>(
                                      value: 'Inside',
                                      groupValue: _stickSide,
                                      onChanged: (value) {
                                        setState(() {
                                          _stickSide = value!;
                                        });
                                      },
                                    ),
                                    const Text('Inside'),
                                    Radio<String>(
                                      value: 'Outside',
                                      groupValue: _stickSide,
                                      onChanged: (value) {
                                        setState(() {
                                          _stickSide = value!;
                                        });
                                      },
                                    ),
                                    const Text('Outside'),
                                  ],
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                const Text('Which Side to Stick from:  '),
                                Row(
                                  children: [
                                    Radio<String>(
                                      value: 'Inside',
                                      groupValue: _stickSide,
                                      onChanged: (value) {
                                        setState(() {
                                          _stickSide = value!;
                                        });
                                      },
                                    ),
                                    const Text('Inside'),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Radio<String>(
                                      value: 'Outside',
                                      groupValue: _stickSide,
                                      onChanged: (value) {
                                        setState(() {
                                          _stickSide = value!;
                                        });
                                      },
                                    ),
                                    const Text('Outside'),
                                  ],
                                ),
                              ],
                            );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3EC1D3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                onPressed: () {
                  // Submit logic here
                },
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
