import '../models/production_job.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductionService {
  final _supabase = Supabase.instance.client;
  // Fetch jobs that are ready for production (have all required department approvals)
  Future<List<ProductionJob>> fetchProductionJobs() async {
    try {
      final response = await _supabase
          .from('jobs')
          .select('*, receptionist, salesperson, design, accountant, production')
          .not('receptionist', 'is', null)
          .not('salesperson', 'is', null)
          .not('design', 'is', null)
          .not('accountant', 'is', null);

      // Print raw response data
      print('\n=== Raw Database Response ===');
      print('Number of records: ${response.length}\n');
      
      for (var record in response) {
        print('Raw Job Record:');
        print('Base Job Fields:');
        print('  id: ${record['id']}');
        print('  status: ${record['status']}');
        print('  created_at: ${record['created_at']}');
        print('  production_workers: ${record['production_workers']}');
        
        // Handle receptionist data
        final receptionistData = record['receptionist'];
        if (receptionistData != null) {
          print('\nReceptionist Data:');
          if (receptionistData is Map<String, dynamic>) {
            receptionistData.forEach((key, value) => print('  $key: $value'));
          }
        }
        
        // Handle salesperson data
        final salespersonData = record['salesperson'];
        if (salespersonData != null) {
          print('\nSalesperson Data:');
          if (salespersonData is Map<String, dynamic>) {
            salespersonData.forEach((key, value) => print('  $key: $value'));
          }
        }
        
        // Handle design data
        final designData = record['design'];
        if (designData != null) {
          print('\nDesign Data:');
          if (designData is List) {
            // If it's a list, process accordingly
            print('  Design submissions: ${designData.length}');
            for (var design in designData) {
              if (design is Map<String, dynamic>) {
                print('  Submission:');
                design.forEach((key, value) => print('    $key: $value'));
              }
            }
          } else if (designData is Map<String, dynamic>) {
            designData.forEach((key, value) => print('  $key: $value'));
          }
        }
        
        // Handle accountant data
        final accountantData = record['accountant'];
        if (accountantData != null) {
          print('\nAccountant Data:');
          if (accountantData is Map<String, dynamic>) {
            accountantData.forEach((key, value) => print('  $key: $value'));
          }
        }
        
        print('\n' + '=' * 50 + '\n');
      }

      // Convert the records to ProductionJob objects
      final jobs = await Future.wait(response.map<Future<ProductionJob>>((record) async {
        // Convert design data to the expected format
        Map<String, dynamic> designData = {};
        if (record['design'] is List && (record['design'] as List).isNotEmpty) {
          // Take the latest design submission if it's a list
          designData = (record['design'] as List).last as Map<String, dynamic>;
        } else if (record['design'] is Map<String, dynamic>) {
          designData = record['design'] as Map<String, dynamic>;
        }

        // Handle production data
        final productionData = (record['production'] as Map<String, dynamic>?) ?? {};
        String computedStatus = '';
        // 1. If design is completed and production is null/empty/null current_status
        final designCompleted = designData['status']?.toString().toLowerCase() == 'completed';
        // Use both current_status and status from production jsonb for status logic
        final prodStatus = (productionData['current_status'] ?? productionData['status'])?.toString().toLowerCase();

        // Check for printing JSONB status
        String? printingStatus;
        if (record['printing'] is List && (record['printing'] as List).isNotEmpty) {
          final latestPrinting = (record['printing'] as List).last;
          if (latestPrinting is Map<String, dynamic> && latestPrinting['status'] != null) {
            printingStatus = latestPrinting['status'].toString().toLowerCase();
          }
        } else if (record['printing'] is Map<String, dynamic> && record['printing']['status'] != null) {
          printingStatus = record['printing']['status'].toString().toLowerCase();
        }

        // --- NEW LOGIC: If printing is completed, update DB if needed ---
        if (printingStatus == 'print_completed') {
          // Only set to printing_completed if not already completed
          if (productionData['current_status'] != 'printing_completed' && productionData['current_status'] != 'completed') {
            computedStatus = 'printing_completed';
            productionData['current_status'] = 'printing_completed';
            await _supabase
              .from('jobs')
              .update({'production': productionData})
              .eq('id', record['id']);
          } else if (productionData['current_status'] == 'completed') {
            computedStatus = 'completed';
          } else {
            computedStatus = 'printing_completed';
          }
        } else if (productionData['current_status'] == 'printing_completed') {
          computedStatus = 'printing_completed';
        } else if (designCompleted && (record['production'] == null || productionData.isEmpty || prodStatus == null)) {
          computedStatus = 'received';
        } else if (prodStatus == 'labour_assigned' || prodStatus == 'assigned_labour') {
          computedStatus = 'assigned_labour';
        } else if (prodStatus == 'in_progress' || prodStatus == 'printing' || prodStatus == 'forwarded for printing') {
          computedStatus = 'in_progress';
        } else if (prodStatus == 'processed_for_printing' || prodStatus == 'forwarded for printing') {
          computedStatus = 'processed_for_printing';
        } else if (prodStatus == 'completed' || prodStatus == 'production_complete') {
          computedStatus = 'completed';
        } else {
          // fallback to DB status
          computedStatus = (record['status'] as String?) ?? 'pending';
        }

        // Create a modified record with the processed design data and computed status
        final processedRecord = Map<String, dynamic>.from(record);
        processedRecord['designjsonb'] = designData;
        processedRecord['productionjsonb'] = productionData;
        processedRecord['status'] = computedStatus;

        return ProductionJob.fromJson(processedRecord);
      }).toList());

      // Print mapped jobs for verification
      print('\n=== Mapped Production Jobs ===\n');
      for (var job in jobs) {
        print('Mapped Job:');
        print('  Job No: ${job.jobNo}');
        print('  Client Name: ${job.clientName}');
        print('  Due Date: ${job.dueDate}');
        print('  Description: ${job.description}');
        print('  Status: ${job.status}');
        print('  Action: ${job.action}');
        print('\n' + '-' * 50 + '\n');
      }

      return jobs;
    } catch (e) {
      print('Error fetching production jobs: $e');
      rethrow;
    }
  }
  Future<ProductionJob> getProductionJobDetails(String jobId) async {
    try {
      final response = await _supabase
          .from('jobs')
          .select('*, receptionist, salesperson, design, accountant, production')
          .eq('id', jobId)
          .single();
      
      return ProductionJob.fromJson(response);
    } catch (e) {
      print('Error fetching job details: $e');
      throw Exception('Job not found: $jobId');
    }
  }  Future<void> updateProductionJobStatus(String jobId, JobStatus newStatus, {String? feedback}) async {
    try {
      // Get current job data to preserve existing production information
      final jobResponse = await _supabase
          .from('jobs')
          .select('production, status')
          .eq('id', jobId)
          .single();
      
      // Get or initialize production data
      Map<String, dynamic> productionData = jobResponse['production'] != null ? 
          Map<String, dynamic>.from(jobResponse['production']) : {};
      
      // Add status update to production history
      List<Map<String, dynamic>> statusHistory = [];
      if (productionData.containsKey('status_history') && productionData['status_history'] is List) {
        statusHistory = List<Map<String, dynamic>>.from(productionData['status_history']);
      }
      
      // Create status history entry
      Map<String, dynamic> statusEntry = {
        'status': _getStatusString(newStatus),
        'updated_at': DateTime.now().toIso8601String(),
        'previous_status': jobResponse['status']
      };
      
      // Add feedback to status history if provided
      if (feedback != null && feedback.trim().isNotEmpty) {
        statusEntry['feedback'] = feedback.trim();
      }
      
      // Add new status update
      statusHistory.add(statusEntry);
      
      // Update production data
      productionData['current_status'] = _getStatusString(newStatus);
      productionData['status_history'] = statusHistory;
      productionData['last_updated'] = DateTime.now().toIso8601String();
      
      // Prepare update data
      Map<String, dynamic> updateData = {
        'production': productionData,
      };
      
      // Only run worker update logic if production.current_status is actually 'completed'
      final currentStatus = productionData['current_status'] != null ? productionData['current_status'].toString().toLowerCase() : null;
      if (newStatus == JobStatus.completed && currentStatus == 'completed') {
        updateData['status'] = 'production_complete';
        productionData['completed_at'] = DateTime.now().toIso8601String();

        // --- Decrement number_of_jobs and update assigned_job for each worker in productionData['workers'] ---
        if (productionData.containsKey('workers') && productionData['workers'] is List) {
          List workers = productionData['workers'];
          for (var worker in workers) {
            final workerId = worker['worker_id'];
            if (workerId != null) {
              // Fetch current number_of_jobs and assigned_job array
              final workerRow = await _supabase
                .from('employee')
                .select('number_of_jobs, assigned_job')
                .eq('id', workerId)
                .maybeSingle();
              if (workerRow != null) {
                int jobs = 0;
                try {
                  jobs = int.parse(workerRow['number_of_jobs'].toString());
                } catch (_) {}
                List<dynamic> assignedJobs = [];
                if (workerRow['assigned_job'] is List) {
                  assignedJobs = List<dynamic>.from(workerRow['assigned_job']);
                } else if (workerRow['assigned_job'] != null) {
                  assignedJobs = [workerRow['assigned_job']];
                }
                // Remove this jobId from assignedJobs
                assignedJobs.remove(jobId);
                final newJobs = jobs > 0 ? jobs - 1 : 0;
                final newIsAvailable = newJobs < 4 ? true : false;
                await _supabase
                  .from('employee')
                  .update({
                    'number_of_jobs': newJobs,
                    'assigned_job': assignedJobs,
                    'is_available': newIsAvailable
                  })
                  .eq('id', workerId);
              }
            }
          }
        }
      }
      
      // Update the job
      await _supabase
          .from('jobs')
          .update(updateData)
          .eq('id', jobId);
      
      print('ProductionService: Updated job $jobId production status to $newStatus');
      if (newStatus == JobStatus.completed) {
        print('ProductionService: Job $jobId marked as production_complete');
      }
    } catch (e) {
      print('Error updating job status: $e');
      rethrow;
    }
  }// Fetch production workers from employee table
  Future<List<Map<String, dynamic>>> getProductionWorkers() async {
    try {
      // Fetch available prod_labour first, sorted by number_of_jobs ascending
      final availableResponse = await _supabase
          .from('employee')
          .select()
          .or('role.eq.prod_labour,role.eq.Production Worker')
          .eq('is_available', true)
          .order('number_of_jobs', ascending: true)
          .order('full_name');

      // Fetch unavailable prod_labour, sorted by full_name
      final unavailableResponse = await _supabase
          .from('employee')
          .select()
          .or('role.eq.prod_labour,role.eq.Production Worker')
          .eq('is_available', false)
          .order('full_name');

      // Combine available and unavailable lists
      final combined = [
        ...List<Map<String, dynamic>>.from(availableResponse),
        ...List<Map<String, dynamic>>.from(unavailableResponse),
      ];

      print('Raw worker response from database:');
      for (var worker in combined) {
        print('Worker: [32m${worker['full_name']}[0m - Available: ${worker['is_available']} - Assigned Job: ${worker['assigned_job']} - Jobs: ${worker['number_of_jobs']}');
      }

      final workers = combined.map((worker) {
        return {
          'id': worker['id']?.toString(),
          'full_name': worker['full_name'] ?? worker['name'] ?? 'Unknown',
          'phone': worker['phone']?.toString() ?? '',
          'role': 'prod_labour',
          'branch_id': worker['branch_id']?.toString(),
          'image': worker['image']?.toString() ?? '',
          'is_available': worker['is_available'] is bool ? worker['is_available'] : worker['is_available']?.toString().toLowerCase() == 'true',
          'assigned_job': worker['assigned_job']?.toString(),
          'number_of_jobs': worker['number_of_jobs'],
        };
      }).toList();

      return workers;
    } catch (e) {
      rethrow;
    }
  }
  Future<void> assignWorkerToJob(String jobId, String workerId) async {
    try {
      print('Attempting to assign worker $workerId to job $jobId');
      // Fetch worker
      final workerResponse = await _supabase
          .from('employee')
          .select()
          .eq('id', workerId)
          .maybeSingle();
      print('Worker response: $workerResponse');
      if (workerResponse == null) {
        print('No worker found with ID: $workerId');
        throw Exception('Worker not found');
      }
      // Check number_of_jobs and is_available
      int numberOfJobs = 0;
      try {
        numberOfJobs = int.parse(workerResponse['number_of_jobs'].toString());
      } catch (_) {}
      bool isAvailable = workerResponse['is_available'] == true;
      // assigned_job is now an array
      List<dynamic> assignedJobs = [];
      if (workerResponse['assigned_job'] is List) {
        assignedJobs = List<dynamic>.from(workerResponse['assigned_job']);
      } else if (workerResponse['assigned_job'] != null) {
        // If it's a single value, convert to array
        assignedJobs = [workerResponse['assigned_job']];
      }
      // Only allow assignment if number_of_jobs < 4 and is_available is true
      if (!isAvailable || numberOfJobs >= 4) {
        throw Exception('Worker is not available for assignment (number_of_jobs: $numberOfJobs, is_available: $isAvailable)');
      }
      // Prevent duplicate assignment
      if (assignedJobs.contains(jobId)) {
        throw Exception('Worker is already assigned to this job');
      }
      // Add jobId to assigned_job array
      assignedJobs.add(jobId);
      final newNumberOfJobs = numberOfJobs + 1;
      final newIsAvailable = newNumberOfJobs >= 4 ? false : true;
      // Get current job data
      final jobResponse = await _supabase
          .from('jobs')
          .select()
          .eq('id', jobId)
          .maybeSingle();
      if (jobResponse == null) {
        throw Exception('Job not found');
      }
      Map<String, dynamic> productionData = jobResponse['production'] != null ? 
          Map<String, dynamic>.from(jobResponse['production']) : {};
      List<Map<String, dynamic>> workers = [];
      if (productionData.containsKey('workers') && productionData['workers'] is List) {
        workers = List<Map<String, dynamic>>.from(productionData['workers']);
      }
      if (workers.any((w) => w['worker_id'] == workerId)) {
        throw Exception('Worker is already assigned to this job');
      }
      workers.add({
        'worker_id': workerId,
        'status': 'assigned',
        'assigned_at': DateTime.now().toIso8601String()
      });
      productionData['workers'] = workers;
      productionData['status'] = 'labour_assigned';
      productionData['last_updated'] = DateTime.now().toIso8601String();
      print('Production data: $productionData');
      // Begin transaction
      try {
        // Update the job
        final updatedJob = await _supabase.from('jobs').update({
          'status': 'labour_assigned',
          'production': productionData,
        }).eq('id', jobId)
        .select()
        .single();
        print('Job updated successfully: $updatedJob');
        // Update the worker: increment number_of_jobs, update assigned_job array, set is_available if needed
        final updatedWorker = await _supabase.from('employee').update({
          'is_available': newIsAvailable,
          'number_of_jobs': newNumberOfJobs,
          'assigned_job': assignedJobs
        }).eq('id', workerId)
        .select()
        .single();
        print('Worker updated successfully: $updatedWorker');
        print('Successfully assigned worker $workerId to job $jobId');
      } catch (transactionError) {
        print('Error during transaction: $transactionError');
        // Rollback: remove jobId from assigned_job, decrement number_of_jobs, set is_available back
        try {
          assignedJobs.remove(jobId);
          final rollbackNumberOfJobs = numberOfJobs;
          final rollbackIsAvailable = numberOfJobs < 4;
          await _supabase.from('employee').update({
            'is_available': rollbackIsAvailable,
            'number_of_jobs': rollbackNumberOfJobs,
            'assigned_job': assignedJobs
          }).eq('id', workerId);
        } catch (rollbackError) {
          print('Error during rollback: $rollbackError');
        }
        throw Exception('Failed to assign worker to job: $transactionError');
      }
    } catch (e) {
      print('Error assigning worker to job: $e');
      rethrow;
    }
  }  String _getStatusString(JobStatus status) {
    switch (status) {
      case JobStatus.received:
        return 'received';
      case JobStatus.assignedLabour:
        return 'assigned_labour';
      case JobStatus.inProgress:
        return 'forwarded for printing';
      case JobStatus.processedForPrinting:
        return 'forwarded for printing';
      case JobStatus.completed:
        return 'completed';
      case JobStatus.onHold:
        return 'on_hold';
      case JobStatus.pending:
        return 'pending';
      case JobStatus.printingCompleted:
        return 'printing_completed';
    }
  }

  // When reading from DB, treat 'printing' as 'forwarded for printing'
  static JobStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'received':
        return JobStatus.received;
      case 'assigned_labour':
        return JobStatus.assignedLabour;
      case 'in_progress':
      case 'printing':
      case 'forwarded for printing':
      case 'processed_for_printing':
        return JobStatus.inProgress;
      case 'completed':
      case 'production_complete':
        return JobStatus.completed;
      case 'on_hold':
        return JobStatus.onHold;
      case 'pending':
      default:
        return JobStatus.pending;
    }
  }
}
