import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/printing_job.dart';
import '../models/printing_specification.dart';

class PrintingService {
  // Helper method to safely cast data to Map<String, dynamic>
  Map<String, dynamic>? _safeMapCast(dynamic data) {
    if (data == null) return null;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      try {
        return Map<String, dynamic>.from(data);
      } catch (e) {
        print('Warning: Could not convert map data: $e');
        return null;
      }
    }
    print('Warning: Expected Map but got ${data.runtimeType}: $data');
    return null;
  }

  // Fetch printing jobs from Supabase where design is not null
  Future<List<PrintingJob>> getPrintingJobs() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('jobs')
          .select('id, job_code, created_at, receptionist, salesperson, design, production, printing')
          .not('design', 'is', null);

      print('Printing jobs query response: ${response.length} jobs found');
      
      // Map Supabase data to PrintingJob model
      final jobs = <PrintingJob>[];
      for (final json in List<Map<String, dynamic>>.from(response)) {
        try {
          final job = _mapSupabaseJobToPrintingJob(json);
          jobs.add(job);
        } catch (e) {
          print('Error mapping job ${json['id']}: $e');
          print('Job data: $json');
        }
      }
      
      // Sort jobs by created_at descending (latest first)
      jobs.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
      print('Successfully mapped \\${jobs.length} printing jobs');
      return jobs;
    } catch (e) {
      print('Error fetching printing jobs: $e');
      // Return empty list if there's an error
      return [];    }
  }    // Helper method to map Supabase job data to PrintingJob model
  PrintingJob _mapSupabaseJobToPrintingJob(Map<String, dynamic> json) {    // Extract data from JSONB fields with proper type checking
    final receptionist = _safeMapCast(json['receptionist']);
    final salesperson = _safeMapCast(json['salesperson']);
    
    // Handle printing field which is a List<dynamic> of printing entries
    List<dynamic>? printingList;
    Map<String, dynamic>? latestPrinting;
    
    if (json['printing'] != null) {
      if (json['printing'] is List) {
        printingList = json['printing'] as List<dynamic>;
        // Get the latest printing entry (last in array)
        if (printingList.isNotEmpty) {
          final lastPrintingData = printingList.last;
          latestPrinting = _safeMapCast(lastPrintingData);
        }
      } else {
        // In case it's a single object (backward compatibility)
        latestPrinting = _safeMapCast(json['printing']);
      }
    }
    
    // Handle design field which is a List<dynamic> of design submissions
    List<dynamic>? designList;
    Map<String, dynamic>? latestDesign;
    
    if (json['design'] != null) {
      if (json['design'] is List) {
        designList = json['design'] as List<dynamic>;
        // Get the latest design submission (last in array)
        if (designList.isNotEmpty) {
          final lastDesignData = designList.last;
          latestDesign = _safeMapCast(lastDesignData);
        }
      } else {
        // In case it's a single object (backward compatibility)
        latestDesign = _safeMapCast(json['design']);
      }
    } // Use job_code as job number, fallback to id if missing
    final jobNo = (json['job_code'] != null && json['job_code'].toString().trim().isNotEmpty && json['job_code'].toString().toLowerCase() != 'null')
        ? json['job_code'].toString()
        : json['id'].toString();    // Extract client info from receptionist data
    final clientName = receptionist?['customerName'] ?? 'Unknown Client';
    final clientPhone = receptionist?['phone'] ?? '';
    final clientAddress = receptionist?['address'] ?? '';
    final shopName = receptionist?['shopName'] ?? '';
    final title = shopName.isNotEmpty ? shopName : 'Printing Job';

    // Parse creation date
    final submittedAt = DateTime.parse(json['created_at'] as String);    // Extract salesperson info
    final assignedSalesperson = receptionist?['assignedSalesperson'] ?? 'Unassigned';
    
    // Get design information from latest design submission
    final designStatus = latestDesign?['status'] ?? 'unknown';
    final designComments = latestDesign?['comments'] ?? '';
    final designSubmissionDate = latestDesign?['submission_date'] != null
        ? DateTime.tryParse(latestDesign!['submission_date'])
        : null;
      // Extract design image URL
    String? designImageUrl;
    if (latestDesign?['images'] != null) {
      final images = latestDesign!['images'];
      if (images is List && images.isNotEmpty) {
        designImageUrl = images.first.toString();
      } else if (images is String && images.isNotEmpty) {
        designImageUrl = images;
      }
    }
    
    // Debug print to see extracted data
    print('Job [1m${json['job_code'] ?? json['id']}[0m data extraction:');
    print('  clientName: $clientName');
    print('  clientPhone: $clientPhone');
    print('  clientAddress: $clientAddress');
    print('  shopName: $shopName');
    print('  assignedSalesperson: $assignedSalesperson');
    print('  designImageUrl: $designImageUrl');
    print('  receptionist data: $receptionist');
    print('  design data: $latestDesign');    // Calculate due date (could be from salesperson or default to 7 days from submission)
    final dueDate = salesperson?['dateOfSubmission'] != null
        ? DateTime.tryParse(salesperson!['dateOfSubmission'])
        : submittedAt.add(const Duration(days: 7));    // Determine status based on printing JSONB data instead of production
    PrintingStatus status = PrintingStatus.queued; // Default to 'queued' if no printing data
    DateTime? startedAt;
    DateTime? completedAt;
    double progress = 0.0;

    // Check printing JSONB for status
    if (latestPrinting != null && latestPrinting['status'] != null) {
      final printingStatusStr = latestPrinting['status'] as String?;      if (printingStatusStr != null) {
        switch (printingStatusStr.toLowerCase()) {
          case 'printing':
          case 'inprogress': // Handle both formats
            status = PrintingStatus.inProgress;
            progress = 0.7;
            if (latestPrinting['started_at'] != null) {
              startedAt = DateTime.tryParse(latestPrinting['started_at']);
            }
            break;
          case 'completed':
            status = PrintingStatus.completed;
            progress = 1.0;
            if (latestPrinting['started_at'] != null) {
              startedAt = DateTime.tryParse(latestPrinting['started_at']);
            }
            if (latestPrinting['completed_at'] != null) {
              completedAt = DateTime.tryParse(latestPrinting['completed_at']);
            }
            break;
          case 'queued':
            status = PrintingStatus.queued;
            progress = 0.2;
            break;
          case 'failed':
            status = PrintingStatus.failed;
            progress = 0.0;
            break;
          case 'reprint':
            status = PrintingStatus.inProgress; // Map reprint to inProgress for UI
            progress = 0.3; // Lower progress to indicate restarted process
            if (latestPrinting['started_at'] != null) {
              startedAt = DateTime.tryParse(latestPrinting['started_at']);
            }
            break;
          case 'print_completed':
            status = PrintingStatus.printed; // Map print_completed to printed for UI
            progress = 1.0;
            if (latestPrinting['submitted_at'] != null) {
              completedAt = DateTime.tryParse(latestPrinting['submitted_at']);
            }
            break;
          case 'onhold':
          case 'on_hold': // Handle both formats
            status = PrintingStatus.onHold;
            progress = 0.5;
            break;
          case 'review':
          case 'under_review':
            status = PrintingStatus.review;
            progress = 0.8;
            break;
          case 'printed':
            status = PrintingStatus.printed;
            progress = 1.0;
            break;
          default:
            // If printing status exists but is unrecognized, default to queued
            status = PrintingStatus.queued;
            print('Unrecognized printing status: $printingStatusStr, defaulting to queued');
        }
      }
    }
    
    // Print debug information about the status assignment
    print('Job [1m${json['job_code'] ?? json['id']}[0m status assigned: [1m${status.name}[0m from printing status: ${latestPrinting?['status']}');// Create default specifications
    final specifications = [
      PrintingSpecification(
        id: 'spec_${json['job_code'] ?? json['id']}_1',
        paperType: PaperType.uncoated,
        paperSize: PaperSize.a4,
        isDoubleSided: true,
        isColorPrint: true,
        quality: PrintQuality.standard,
        dpi: 300,
      ),
    ];

    final combinedNotes = [
      if (designComments.isNotEmpty && designComments != 'none for now') 'Design: $designComments',
      'Design Status: $designStatus',
      if (designSubmissionDate != null) 'Design Date: ${designSubmissionDate.toLocal()}',
      'Salesperson: $assignedSalesperson',
    ].join(' | ');    return PrintingJob(
      id: json['id'].toString(),
      jobNo: jobNo,
      title: title,
      clientName: clientName,
      submittedAt: submittedAt,
      startedAt: startedAt,
      completedAt: completedAt,
      status: status,
      specifications: specifications,
      assignedPrinter: 'Auto-Assigned',
      copies: 100, // Default value, can be enhanced later
      progress: progress,
      notes: combinedNotes,
      clientPhone: clientPhone.isNotEmpty ? clientPhone : null,
      clientAddress: clientAddress.isNotEmpty ? clientAddress : null,
      shopName: shopName.isNotEmpty ? shopName : null,
      assignedSalesperson: assignedSalesperson,
      designImageUrl: designImageUrl,
      designStatus: designStatus,
      designComments: designComments.isNotEmpty ? designComments : null,
      designSubmissionDate: designSubmissionDate,
      dueDate: dueDate,
    );
  }

  // Keep original sample data method for fallback/testing
  Future<List<PrintingJob>> getSamplePrintingJobs() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Sample data - for testing purposes
    return [
      PrintingJob(
        id: 'pj_001',
        jobNo: 'P0001',
        title: 'Marketing Brochures Batch 1',
        clientName: 'Client X Corp',
        submittedAt: DateTime.now().subtract(const Duration(days: 2)),
        status: PrintingStatus.queued,
        specifications: [
          PrintingSpecification(
            id: 'spec_001a',
            paperType: PaperType.gloss,
            paperSize: PaperSize.a4,
            isDoubleSided: true,
            isColorPrint: true,
            quality: PrintQuality.high,
            dpi: 300,
          ),
        ],
        assignedPrinter: 'Printer A1',
        copies: 500,
        progress: 0.0,
      ),
      PrintingJob(
        id: 'pj_002',
        jobNo: 'P0002',
        title: 'Event Posters - Urgent',
        clientName: 'Client Y Ltd',
        submittedAt: DateTime.now().subtract(const Duration(days: 1)),
        startedAt: DateTime.now().subtract(const Duration(hours: 4)),
        status: PrintingStatus.inProgress,
        specifications: [
          PrintingSpecification(
            id: 'spec_002a',
            paperType: PaperType.vinyl,
            paperSize: PaperSize.a1,
            isDoubleSided: false,
            isColorPrint: true,
            quality: PrintQuality.ultra,
            dpi: 600,
            finishingOptions: {'lamination': 'matte'},
          ),
        ],
        assignedPrinter: 'Printer B2',
        copies: 50,
        progress: 0.65,
      ),
      PrintingJob(
        id: 'pj_003',
        jobNo: 'P0003',
        title: 'Internal Training Manuals',
        clientName: 'Internal Dept',
        submittedAt: DateTime.now().subtract(const Duration(days: 5)),
        startedAt: DateTime.now().subtract(const Duration(days: 3)),
        completedAt: DateTime.now().subtract(const Duration(days: 1)),
        status: PrintingStatus.completed,
        specifications: [
          PrintingSpecification(
            id: 'spec_003a',
            paperType: PaperType.uncoated,
            paperSize: PaperSize.letter,
            isDoubleSided: true,
            isColorPrint: false,
            quality: PrintQuality.standard,
            dpi: 300,
            finishingOptions: {'binding': 'spiral'},
          ),
        ],
        assignedPrinter: 'Printer C3',
        copies: 200,
        progress: 1.0,
      ),
    ];  }
  // Start printing job - updates printing JSONB field
  Future<PrintingJob> startPrintingJob(String jobId, String designImageUrl) async {
    try {
      final supabase = Supabase.instance.client;
      
      // Get current job data
      final currentResponse = await supabase
          .from('jobs')
          .select('printing')
          .eq('id', jobId)
          .single();

      List<dynamic> printing = [];
      if (currentResponse['printing'] != null) {
        printing = List<dynamic>.from(currentResponse['printing']);
      }

      // Create new printing entry with inProgress status
      final printingEntry = {
        'status': 'inProgress', // Set status to match PrintingStatus enum
        'timestamp': DateTime.now().toUtc().toIso8601String(),
        'started_by': 'printing_dashboard',
        'design_image_url': designImageUrl,
        'started_at': DateTime.now().toUtc().toIso8601String(),
      };

      // Add to printing array
      printing.add(printingEntry);

      // Update in Supabase
      await supabase
          .from('jobs')
          .update({'printing': printing})
          .eq('id', jobId);

      print('Successfully started printing for job $jobId with status: inProgress');

      // Return updated job
      final updatedResponse = await supabase
          .from('jobs')
          .select('id, created_at, receptionist, salesperson, design, production, printing')
          .eq('id', jobId)
          .single();

      return _mapSupabaseJobToPrintingJob(updatedResponse);
    } catch (e) {
      print('Error starting printing job: $e');
      throw Exception('Failed to start printing job: $e');
    }
  }

  // Update printing job status in Supabase
  Future<PrintingJob> updatePrintingJobStatus(String jobId, PrintingStatus newStatus, {String? feedback}) async {
    try {
      final supabase = Supabase.instance.client;
      
      // Get current job data
      final currentResponse = await supabase
          .from('jobs')
          .select('production')
          .eq('id', jobId)
          .single();

      Map<String, dynamic> production = {};
      if (currentResponse['production'] != null) {
        production = Map<String, dynamic>.from(currentResponse['production']);
      }

      // Create new status entry
      final statusUpdate = {
        'status': newStatus.name,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
        'updated_by': 'printing_dashboard',
        if (feedback != null) 'feedback': feedback,
      };

      // Update production JSONB with new status
      production['current_status'] = statusUpdate;
      
      // Update status history
      if (production['status_history'] == null) {
        production['status_history'] = [];
      }
      (production['status_history'] as List).add(statusUpdate);

      // Update in Supabase
      await supabase
          .from('jobs')
          .update({'production': production})
          .eq('id', jobId);

      // Return updated job
      final updatedResponse = await supabase
          .from('jobs')
          .select('id, created_at, receptionist, salesperson, design, production')
          .eq('id', jobId)
          .single();

      return _mapSupabaseJobToPrintingJob(updatedResponse);
    } catch (e) {
      print('Error updating printing job status: $e');
      throw Exception('Failed to update printing job status: $e');
    }
  }

  // Complete a printing job - updates 'printing' JSONB field
  Future<PrintingJob> completePrintingJob(String jobId, {String? feedback}) async {
    try {
      final supabase = Supabase.instance.client;
      
      // Get current job data
      final currentResponse = await supabase
          .from('jobs')
          .select('printing')
          .eq('id', jobId)
          .single();

      List<dynamic> printing = [];
      if (currentResponse['printing'] != null) {
        printing = List<dynamic>.from(currentResponse['printing']);
      }

      // Get the last printing entry or create a new one if none exists
      Map<String, dynamic> lastPrinting = {};
      if (printing.isNotEmpty && printing.last is Map) {
        lastPrinting = Map<String, dynamic>.from(printing.last);
      }

      // Create new printing entry with completed status
      final printingEntry = {
        'status': 'completed', // Set status to completed
        'timestamp': DateTime.now().toUtc().toIso8601String(),
        'completed_by': 'printing_dashboard',
        'completed_at': DateTime.now().toUtc().toIso8601String(),
        'started_at': lastPrinting['started_at'] ?? DateTime.now().subtract(const Duration(hours: 1)).toUtc().toIso8601String(),
        if (feedback != null && feedback.isNotEmpty) 'feedback': feedback,
      };

      // Add to printing array
      printing.add(printingEntry);

      // Update in Supabase
      await supabase
          .from('jobs')
          .update({'printing': printing})
          .eq('id', jobId);

      print('Successfully completed printing for job $jobId');

      // Return updated job
      final updatedResponse = await supabase
          .from('jobs')
          .select('id, created_at, receptionist, salesperson, design, production, printing')
          .eq('id', jobId)
          .single();

      return _mapSupabaseJobToPrintingJob(updatedResponse);
    } catch (e) {
      print('Error completing printing job: $e');
      throw Exception('Failed to complete printing job: $e');
    }
  }

  // Reprint a job - updates 'printing' JSONB field to start printing again
  Future<PrintingJob> reprintJob(String jobId, String designImageUrl, {String? feedback}) async {
    try {
      final supabase = Supabase.instance.client;
      
      // Get current job data
      final currentResponse = await supabase
          .from('jobs')
          .select('printing')
          .eq('id', jobId)
          .single();

      List<dynamic> printing = [];
      if (currentResponse['printing'] != null) {
        printing = List<dynamic>.from(currentResponse['printing']);
      }      // Create new printing entry for reprint
      final printingEntry = {
        'status': 'reprint', // Set status to reprint instead of inProgress
        'timestamp': DateTime.now().toUtc().toIso8601String(),
        'started_by': 'printing_dashboard',
        'design_image_url': designImageUrl,
        'started_at': DateTime.now().toUtc().toIso8601String(),
        'is_reprint': true,
        if (feedback != null && feedback.isNotEmpty) 'reprint_reason': feedback,
      };

      // Add to printing array
      printing.add(printingEntry);

      // Update in Supabase
      await supabase
          .from('jobs')
          .update({'printing': printing})
          .eq('id', jobId);

      print('Successfully started reprinting job $jobId');

      // Return updated job
      final updatedResponse = await supabase
          .from('jobs')
          .select('id, created_at, receptionist, salesperson, design, production, printing')
          .eq('id', jobId)
          .single();

      return _mapSupabaseJobToPrintingJob(updatedResponse);
    } catch (e) {
      print('Error reprinting job: $e');
      throw Exception('Failed to reprint job: $e');
    }
  }
  // Submit a completed job
  Future<PrintingJob> submitJobForReview(String jobId, {String? feedback}) async {
    try {
      final supabase = Supabase.instance.client;
      
      // Get current job data
      final currentResponse = await supabase
          .from('jobs')
          .select('printing')
          .eq('id', jobId)
          .single();

      List<dynamic> printing = [];
      if (currentResponse['printing'] != null) {
        printing = List<dynamic>.from(currentResponse['printing']);
      }      // Create new printing entry for job submission
      final printingEntry = {
        'status': 'print_completed', // Set status to print_completed as requested
        'timestamp': DateTime.now().toUtc().toIso8601String(),
        'submitted_by': 'printing_dashboard',
        'submitted_at': DateTime.now().toUtc().toIso8601String(),
        if (feedback != null && feedback.isNotEmpty) 'notes': feedback,
      };

      // Add to printing array
      printing.add(printingEntry);

      // Update in Supabase
      await supabase
          .from('jobs')
          .update({'printing': printing})
          .eq('id', jobId);

      print('Successfully submitted job $jobId as printed');

      // Return updated job
      final updatedResponse = await supabase
          .from('jobs')
          .select('id, created_at, receptionist, salesperson, design, production, printing')
          .eq('id', jobId)
          .single();

      return _mapSupabaseJobToPrintingJob(updatedResponse);
    } catch (e) {
      print('Error submitting job as printed: $e');
      throw Exception('Failed to submit job as printed: $e');
    }
  }
}
