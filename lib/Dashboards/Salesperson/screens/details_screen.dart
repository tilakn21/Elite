import 'package:flutter/material.dart';
import '../widgets/salesperson_sidebar.dart';
import '../widgets/salesperson_topbar.dart';
import '../models/salesperson_job_details.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SalespersonDetailsScreen extends StatefulWidget {
  final String jobId;
  final String date;
  final String customer;
  final String shopName;
  const SalespersonDetailsScreen({Key? key, required this.jobId, required this.date, required this.customer, required this.shopName}) : super(key: key);

  @override
  State<SalespersonDetailsScreen> createState() => _SalespersonDetailsScreenState();
}

class _SalespersonDetailsScreenState extends State<SalespersonDetailsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // Controllers for all fields
  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _jobNoController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _materialController = TextEditingController();
  final TextEditingController _toolsNailsController = TextEditingController();
  final TextEditingController _timeForProductionController =
      TextEditingController();
  final TextEditingController _timeForFittingController =
      TextEditingController();
  final TextEditingController _extraDetailsController = TextEditingController();
  final TextEditingController _signMeasurementsController =
      TextEditingController();
  final TextEditingController _windowVinylMeasurementsController =
      TextEditingController();
  String _stickSide = 'Inside';
  String _typeOfSign = 'design';
  List<XFile> _images = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Remove demo data, use widget values
    _customerController.text = widget.customer;
    _jobNoController.text = widget.jobId;
    _dateController.text = widget.date;
    _stickSide = 'Inside';
  }

  @override
  void dispose() {
    _customerController.dispose();
    _jobNoController.dispose();
    _dateController.dispose();
    _materialController.dispose();
    _toolsNailsController.dispose();
    _timeForProductionController.dispose();
    _timeForFittingController.dispose();
    _extraDetailsController.dispose();
    _signMeasurementsController.dispose();
    _windowVinylMeasurementsController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _images.add(image);
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final List<XFile> images = await _picker.pickMultiImage();
    setState(() {
      _images.addAll(images);
    });
  }

  void _removeImage(int idx) {
    setState(() {
      _images.removeAt(idx);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 600;
    final GlobalKey<ScaffoldState> scaffoldKey = _scaffoldKey;
    Widget sidebar = SalespersonSidebar(
      selectedRoute: 'home',
      onItemSelected: (route) {
        if (route == 'home') {
          Navigator.of(context).pushReplacementNamed('/salesperson/dashboard');
        } else if (route == 'profile') {
          Navigator.of(context).pushReplacementNamed('/salesperson/profile');
        }
      },
    );
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      drawer: isMobile
          ? Drawer(
              width: MediaQuery.of(context).size.width * 0.75,
              child: sidebar,
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            SizedBox(width: 240, child: sidebar),
          Expanded(
            child: Column(
              children: [
                SalespersonTopBar(
                  isDashboard: false,
                  showMenu: isMobile,
                  onMenuTap: () => scaffoldKey.currentState?.openDrawer(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Center(
                          child: Image.asset(
                            'assets/images/elite_logo.png',
                            height: 72,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Top row: Customer, Job No, Date, Shop Name
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Customer', style: TextStyle(fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text(widget.customer, style: const TextStyle(fontSize: 15, color: Colors.black87)),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Job No', style: TextStyle(fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text(widget.jobId, style: const TextStyle(fontSize: 15, color: Colors.black87)),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Date', style: TextStyle(fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text(widget.date, style: const TextStyle(fontSize: 15, color: Colors.black87)),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Shop Name', style: TextStyle(fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text(widget.shopName, style: const TextStyle(fontSize: 15, color: Colors.black87)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Replace type of sign text field with dropdown
                        DropdownButtonFormField<String>(
                          value: _typeOfSign,
                          items: const [
                            DropdownMenuItem(value: 'design', child: Text('Design')),
                            DropdownMenuItem(value: 'board', child: Text('Board')),
                            DropdownMenuItem(value: 'banner', child: Text('Banner')),
                            DropdownMenuItem(value: 'sticker', child: Text('Sticker')),
                          ],
                          onChanged: (val) {
                            setState(() {
                              _typeOfSign = val!;
                            });
                          },
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
                            labelText:
                                'Extra Details (Frame, bracket or additional requirements to complete this job)',
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
                        Text('Add Images', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              icon: Icon(Icons.camera_alt),
                              label: Text('Camera'),
                              onPressed: _pickImageFromCamera,
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              icon: Icon(Icons.photo_library),
                              label: Text('Gallery'),
                              onPressed: _pickImageFromGallery,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 80,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _images.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, idx) => Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(File(_images[idx].path), width: 80, height: 80, fit: BoxFit.cover),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(idx),
                                    child: Container(
                                      color: Colors.black54,
                                      child: const Icon(Icons.close, color: Colors.white, size: 18),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3EC1D3),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            onPressed: () async {
                              // Submit logic: update salesperson JSONB for this job
                              final now = DateTime.now();
                              final salespersonId = await getCurrentSalespersonId(); // implement this as needed
                              final paymentAmount = await showDialog<double>(
                                context: context,
                                builder: (context) {
                                  double? value;
                                  return AlertDialog(
                                    title: const Text('Enter Payment Amount'),
                                    content: TextField(
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(labelText: 'Payment Amount'),
                                      onChanged: (v) => value = double.tryParse(v),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, value),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                              if (paymentAmount == null) return;
                              // Prepare data
                              final details = {
                                'customer': _customerController.text,
                                'jobId': _jobNoController.text,
                                'date': _dateController.text,
                                'typeOfSign': _typeOfSign,
                                'material': _materialController.text,
                                'toolsNails': _toolsNailsController.text,
                                'timeForProduction': _timeForProductionController.text,
                                'timeForFitting': _timeForFittingController.text,
                                'extraDetails': _extraDetailsController.text,
                                'signMeasurements': _signMeasurementsController.text,
                                'windowVinylMeasurements': _windowVinylMeasurementsController.text,
                                'stickSide': _stickSide,
                                'images': _images.map((x) => x.path).toList(),
                                'timeOfSubmission': now.toIso8601String(),
                                'dateOfSubmission': now.toLocal().toString().split(' ')[0],
                                'salespersonId': salespersonId,
                                'paymentAmount': paymentAmount,
                              };
                              // TODO: Update Supabase jobs table for this jobId, set salesperson = details
                              await updateSalespersonJsonb(widget.jobId, details, paymentAmount); // implement this
                              await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Success'),
                                  content: const Text('Details submitted successfully!'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                              Navigator.of(context).pop();
                            },
                            child: const Text('Submit Details',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16)),
                          ),
                        ),
                      ], // <-- closes children of Column in SingleChildScrollView
                    ), // <-- closes Column in SingleChildScrollView
                  ), // <-- closes SingleChildScrollView
                ), // <-- closes Expanded
              ], // <-- closes children of main Column
            ), // <-- closes main Column
          ), // <-- closes Expanded
        ], // <-- closes children of Row
      ), // <-- closes Row
    ); // <-- closes Scaffold
  }

  Future<String> getCurrentSalespersonId() async {
    // TODO: Replace with actual logic to get logged-in salesperson id
    // For now, return a placeholder or fetch from your auth/session provider
    return 'salesperson_123';
  }

  Future<List<String>> uploadImagesToSupabaseStorage(List<XFile> images, String jobId) async {
    final supabase = Supabase.instance.client;
    final List<String> urls = [];
    for (int i = 0; i < images.length; i++) {
      final file = File(images[i].path);
      final fileName = 'salesperson_jobs/$jobId/${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
      final uploadResponse = await supabase.storage.from('eliteimage').upload(fileName, file);
      if (uploadResponse.isNotEmpty && !uploadResponse.contains('error')) {
        final publicUrl = supabase.storage.from('eliteimage').getPublicUrl(fileName);
        urls.add(publicUrl);
      } else {
        throw Exception('Image upload failed for $fileName');
      }
    }
    return urls;
  }

  Future<void> updateSalespersonJsonb(String jobId, Map<String, dynamic> details, double paymentAmount) async {
    final supabase = Supabase.instance.client;
    try {
      // Upload images and get URLs
      final imageUrls = await uploadImagesToSupabaseStorage(_images, jobId);
      final detailsWithUrls = Map<String, dynamic>.from(details);
      detailsWithUrls['images'] = imageUrls;
      // Update salesperson JSONB
      await supabase
          .from('jobs')
          .update({'salesperson': detailsWithUrls})
          .eq('id', jobId)
          .select();
      // Update accounts JSONB: set amount_salesperson
      final job = await supabase.from('jobs').select('accountant').eq('id', jobId).single();
      Map<String, dynamic> accountant = {};
      if (job['accountant'] != null) {
        accountant = Map<String, dynamic>.from(job['accountant']);
      }
      accountant['amount_salesperson'] = paymentAmount;
      await supabase
          .from('jobs')
          .update({'accountant': accountant})
          .eq('id', jobId)
          .select();
    } catch (e) {
      throw Exception('Failed to update job: $e');
    }
  }
}