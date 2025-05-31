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
      final jobs = response.map<ProductionJob>((record) {
        // Convert design data to the expected format
        Map<String, dynamic> designData = {};
        if (record['design'] is List && (record['design'] as List).isNotEmpty) {
          // Take the latest design submission if it's a list
          designData = (record['design'] as List).last as Map<String, dynamic>;
        } else if (record['design'] is Map<String, dynamic>) {
          designData = record['design'] as Map<String, dynamic>;
        }

        // Create a modified record with the processed design data
        final processedRecord = Map<String, dynamic>.from(record);
        processedRecord['designjsonb'] = designData;

        return ProductionJob.fromJson(processedRecord);
      }).toList();

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
      
      // If status is completed, update the main status column to production_complete
      if (newStatus == JobStatus.completed) {
        updateData['status'] = 'production_complete';
        productionData['completed_at'] = DateTime.now().toIso8601String();
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
      final response = await _supabase
          .from('employee')
          .select()
          .or('role.eq.prod_labour,role.eq.Production Worker')
          .order('full_name');
      
      print('Raw worker response from database:');
      for (var worker in response) {
        print('Worker: ${worker['full_name']} - Available: ${worker['is_available']} - Assigned Job: ${worker['assigned_job']}');
      }

      final workers = List<Map<String, dynamic>>.from(response).map((worker) {
        return {
          'id': worker['id']?.toString(),
          'full_name': worker['full_name'] ?? worker['name'] ?? 'Unknown',
          'phone': worker['phone']?.toString() ?? '',
          'role': 'prod_labour',
          'branch_id': worker['branch_id']?.toString(),
          'image': worker['image']?.toString() ?? '',
          'is_available': worker['is_available'] is bool ? worker['is_available'] : worker['is_available']?.toString().toLowerCase() == 'true',
          'assigned_job': worker['assigned_job']?.toString(),
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
      
      // First, verify that the worker exists and check availability
      final workerResponse = await _supabase
          .from('employee')
          .select()  // Select all fields for debugging
          .eq('id', workerId)
          .maybeSingle();
      
      print('Worker response: $workerResponse');
      
      if (workerResponse == null) {
        print('No worker found with ID: $workerId');
        throw Exception('Worker not found');
      }

      // Print all fields for debugging
      print('Worker fields: ${workerResponse.keys.join(', ')}');

      // Check role - handle both possible values
      String workerRole = workerResponse['role']?.toString() ?? '';
      if (workerRole != 'prod_labour' && workerRole != 'Production Worker') {
        print('Invalid role: $workerRole');
        throw Exception('Invalid worker role: Worker must be a production worker (got: $workerRole)');
      }

      // Check worker availability - they must both be marked as available AND not assigned to a job
      bool isAvailable = false;
      if ((workerResponse['is_available'] is bool && workerResponse['is_available']) ||
          (workerResponse['is_available']?.toString().toLowerCase() == 'true')) {
        isAvailable = workerResponse['assigned_job'] == null;
      }
      
      print('Worker availability: $isAvailable');

      if (!isAvailable) {
        final String workerName = workerResponse['full_name'] ?? workerResponse['name'] ?? 'Worker';
        String errorMsg = '$workerName is not available for assignment';
        if (workerResponse['assigned_job'] != null) {
          errorMsg += ' (currently assigned to job ${workerResponse['assigned_job']})';
        } else {
          errorMsg += ' (marked as unavailable)';
        }
        throw Exception(errorMsg);
      }

      // Get current job data
      final jobResponse = await _supabase
          .from('jobs')
          .select()  // Select all fields for debugging
          .eq('id', jobId)
          .maybeSingle();
      
      print('Job response: $jobResponse');
      
      if (jobResponse == null) {
        throw Exception('Job not found');
      }

      // Get or initialize production data
      Map<String, dynamic> productionData = jobResponse['production'] != null ? 
          Map<String, dynamic>.from(jobResponse['production']) : {};
      
      // Initialize workers list if it doesn't exist
      List<Map<String, dynamic>> workers = [];
      if (productionData.containsKey('workers') && productionData['workers'] is List) {
        workers = List<Map<String, dynamic>>.from(productionData['workers']);
      }
      
      print('Current production workers: $workers');
      
      // Check if worker is already assigned
      if (workers.any((w) => w['worker_id'] == workerId)) {
        final String workerName = workerResponse['full_name'] ?? workerResponse['name'] ?? 'Worker';
        throw Exception('$workerName is already assigned to this job');
      }
      
      // Add new worker to the list
      workers.add({
        'worker_id': workerId,  // Changed from 'id' to 'worker_id' to be more explicit
        'status': 'assigned',
        'assigned_at': DateTime.now().toIso8601String()
      });

      // Update production data
      productionData['workers'] = workers;
      productionData['status'] = 'labour_assigned';
      productionData['last_updated'] = DateTime.now().toIso8601String();

      print('Production data: $productionData');

      // Begin transaction
      try {
        // Update the job first - send as Map for JSONB
        final updatedJob = await _supabase.from('jobs').update({
          'status': 'labour_assigned',
          'production': productionData,  // Send as Map for JSONB column
        }).eq('id', jobId)
        .select()
        .single();
        
        print('Job updated successfully: $updatedJob');
        
        // Then update the worker's availability and assigned job
        final updatedWorker = await _supabase.from('employee').update({
          'is_available': false,
          'assigned_job': jobId  // Store the job ID directly
        }).eq('id', workerId)
        .select()
        .single();
        
        print('Worker updated successfully: $updatedWorker');
        print('Successfully assigned worker $workerId to job $jobId');

      } catch (transactionError) {
        print('Error during transaction: $transactionError');
        // If either update fails, try to rollback worker availability
        try {
          // Rollback worker status and assignment
          await _supabase.from('employee').update({
            'is_available': true,
            'assigned_job': null  // Clear the job assignment
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
      case JobStatus.receiver:
        return 'receiver';
      case JobStatus.assignedLabour:
        return 'assigned_labour';
      case JobStatus.inProgress:
        return 'in_progress';
      case JobStatus.processedForPrinting:
        return 'processed_for_printing';
      case JobStatus.completed:
        return 'completed';
      case JobStatus.onHold:
        return 'on_hold';
      case JobStatus.pending:
        return 'pending';
    }
  }
}
