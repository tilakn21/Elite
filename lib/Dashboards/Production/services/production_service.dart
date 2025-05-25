import '../models/production_job.dart';

class ProductionService {
  // Mock delay to simulate network latency
  Future<void> _mockDelay() => Future.delayed(const Duration(seconds: 1));

  // Mock list of production jobs
  final List<ProductionJob> _mockJobs = [
    ProductionJob(
      id: 'prod_job_1',
      jobNo: 'P001',
      clientName: 'Alpha Corp',
      dueDate: DateTime.now().add(const Duration(days: 7)),
      description: 'Assemble 1000 units of Product X',
      status: JobStatus.pending,
      action: 'Assign Workers',
    ),
    ProductionJob(
      id: 'prod_job_2',
      jobNo: 'P002',
      clientName: 'Beta LLC',
      dueDate: DateTime.now().add(const Duration(days: 10)),
      description: 'Quality check for Batch Y',
      status: JobStatus.inProgress,
      action: 'Update Progress',
    ),
    ProductionJob(
      id: 'prod_job_3',
      jobNo: 'P003',
      clientName: 'Gamma Inc',
      dueDate: DateTime.now().subtract(const Duration(days: 2)),
      description: 'Package and ship Order Z',
      status: JobStatus.completed,
      action: 'View Report',
    ),
    ProductionJob(
      id: 'prod_job_4',
      jobNo: 'P004',
      clientName: 'Delta Co.',
      dueDate: DateTime.now().add(const Duration(days: 5)),
      description: 'Urgent: Rework 50 units of Product A',
      status: JobStatus.onHold,
      action: 'Resolve Issue',
    ),
  ];

  Future<List<ProductionJob>> fetchProductionJobs() async {
    await _mockDelay();
    // In a real scenario, this would be an API call
    // For now, return a copy of the mock list to prevent direct modification
    return List<ProductionJob>.from(_mockJobs);
  }

  Future<ProductionJob> getProductionJobDetails(String jobId) async {
    await _mockDelay();
    return _mockJobs.firstWhere((job) => job.id == jobId,
        orElse: () => throw Exception('Job not found: $jobId'));
  }

  Future<void> updateProductionJobStatus(String jobId, JobStatus newStatus) async {
    await _mockDelay();
    try {
      final jobIndex = _mockJobs.indexWhere((job) => job.id == jobId);
      if (jobIndex != -1) {
        _mockJobs[jobIndex] = _mockJobs[jobIndex].copyWith(status: newStatus);
        print('ProductionService: Updated job $jobId status to $newStatus');
      } else {
        throw Exception('Job not found for status update: $jobId');
      }
    } catch (e) {
      print('Error updating job status: $e');
      rethrow;
    }
  }

  // Mock method to assign a worker to a job - can be expanded later
  Future<void> assignWorkerToJob(String jobId, String workerId) async {
    await _mockDelay();
    // Here you might update the job with an assigned worker or list of workers
    // For now, just a print statement
    print('ProductionService: Assigned worker $workerId to job $jobId (mock)');
  }

  // Add other methods as needed, e.g.:
  // Future<ProductionJob> createProductionJob(ProductionJob newJob) async { ... }
  // Future<void> deleteProductionJob(String jobId) async { ... }
}
