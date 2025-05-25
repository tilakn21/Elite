import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:elite_signboard_app/Dashboards/Design/providers/job_provider.dart';
import 'package:elite_signboard_app/Dashboards/Design/models/job.dart';
import './mock_design_service.dart'; // Assuming mock_design_service.dart is in the same directory

// A simple mock class for ChangeNotifier's listener
class MockListener extends Mock {
  void call();
}

void main() {
  late JobProvider jobProvider;
  late MockDesignService mockDesignService;
  late MockListener mockListener;

  // Default setUp for tests that don't need to mock getJobs before instantiation
  setUp(() {
    mockDesignService = MockDesignService();
    // For most tests, we assume getJobs might be called, so a default successful empty list
    when(() => mockDesignService.getJobs()).thenAnswer((_) async => []);
    jobProvider = JobProvider(mockDesignService);
    mockListener = MockListener();
    jobProvider.addListener(mockListener.call);
  });

  tearDown(() {
    jobProvider.removeListener(mockListener.call);
    jobProvider.dispose();
  });

  // Helper to create a sample job
  Job createSampleJob(String id, {
    String jobNo = 'JOB001',
    String clientName = 'Test Client',
    String email = 'test@example.com',
    String phoneNumber = '1234567890',
    String address = '123 Test St',
    JobStatus status = JobStatus.pending,
  }) {
    return Job(
      id: id,
      jobNo: jobNo,
      clientName: clientName,
      email: email,
      phoneNumber: phoneNumber,
      address: address,
      dateAdded: DateTime.now(),
      status: status,
      // Optional fields from Job model
      assignedTo: 'designer_id_1',
      measurements: '10x20',
      uploadedImages: ['image1.png'],
      notes: 'Sample job notes',
    );
  }

  group('JobProvider Tests', () {
    test('Initial state is correct', () {
      expect(jobProvider.jobs, isEmpty);
      expect(jobProvider.isLoading, isFalse);
      expect(jobProvider.errorMessage, isNull);
    });

    group('Initialization (_fetchJobs behavior)', () {
      final mockJobs = [
        createSampleJob('1', jobNo: 'J001', clientName: 'Client A'),
        createSampleJob('2', jobNo: 'J002', clientName: 'Client B'),
      ];

      test('loads jobs successfully from service on initialization', () async {
        // Arrange: Setup mock BEFORE JobProvider is created for this specific test
        mockDesignService = MockDesignService();
        when(() => mockDesignService.getJobs()).thenAnswer((_) async => mockJobs);
        
        jobProvider = JobProvider(mockDesignService); // Instantiation triggers _fetchJobs
        jobProvider.addListener(mockListener.call);

        // Act: _fetchJobs is called in constructor. We need to wait for it to complete.
        // The provider sets isLoading to true, then false. Listeners are notified.
        // We can't directly await _fetchJobs, so we check the state after a short delay 
        // or rely on the isLoading flag and listener calls.

        // Assert: Check state after _fetchJobs has run (or is running)
        // Initial call to notifyListeners (isLoading = true)
        // Second call after jobs are fetched (isLoading = false)
        
        // Wait for the async operations within the provider to settle.
        // This is a common pattern when testing ChangeNotifier initialization logic.
        await Future.delayed(Duration.zero); // Allows microtasks to complete

        expect(jobProvider.jobs, mockJobs);
        expect(jobProvider.isLoading, isFalse); // Should be false after loading
        expect(jobProvider.errorMessage, isNull);
        // Listener is added after constructor starts. If quick enough, it catches both notifications from _fetchJobs.
        verify(() => mockListener.call()).called(2);
      });

      test('handles error and loads sample data on initialization if service fails', () async {
        // Arrange: Setup mock BEFORE JobProvider is created for this specific test
        final exception = Exception('Failed to load jobs');
        mockDesignService = MockDesignService();
        when(() => mockDesignService.getJobs()).thenThrow(exception);
        // DesignService.getJobs throws, so JobProvider._loadSampleJobs() should be called.
        // We don't mock _loadSampleJobs as it's internal to JobProvider.
        
        jobProvider = JobProvider(mockDesignService); // Instantiation triggers _fetchJobs
        // mockListener is already initialized by the main setUp and reset for each test.
        // We just need to add it to this new jobProvider instance.
        jobProvider.addListener(mockListener.call);

        // Act: _fetchJobs is called in constructor.
        await Future.delayed(Duration.zero); // Allows microtasks to complete

        // Assert: Check state after _fetchJobs has run and failed, then _loadSampleJobs ran
        expect(jobProvider.isLoading, isFalse); // Should be false after attempting to load
        expect(jobProvider.errorMessage, exception.toString());
        expect(jobProvider.jobs, isNotEmpty); // Sample jobs should be loaded
        expect(jobProvider.jobs.first.jobNo, '#1001'); // Check if sample data is loaded
        // Listener is added after constructor starts, so it likely only catches the second notifyListeners call.
        verify(() => mockListener.call()).called(1);
      });
    });
  });

  group('addJob', () {
    final newJob = createSampleJob('3', jobNo: 'J003', clientName: 'Client C');

    test('successfully adds a job and notifies listeners', () async {
      // Arrange
      // Ensure getJobs is mocked for initial load, if not already covered by a general setUp
      // For this specific test, we assume initial _fetchJobs was successful (e.g. empty list or other jobs)
      when(() => mockDesignService.getJobs()).thenAnswer((_) async => []); // Initial load
      jobProvider = JobProvider(mockDesignService); // Re-initialize for a clean state if needed, or ensure setup handles this
      jobProvider.addListener(mockListener.call); // Re-add listener if re-initialized

      when(() => mockDesignService.createJob(newJob)).thenAnswer((_) async => newJob); // Mock createJob

      // Clear interactions for the mockListener from setUp before the addJob action
      clearInteractions(mockListener);
      
      // Act
      final future = jobProvider.addJob(newJob);

      // Assert: loading state during add
      expect(jobProvider.isLoading, isTrue);
      verify(() => mockListener.call()).called(1); // For isLoading=true during add

      await future;

      // Assert: state after successful add
      expect(jobProvider.jobs, contains(newJob));
      expect(jobProvider.isLoading, isFalse);
      expect(jobProvider.errorMessage, isNull);
      verify(() => mockListener.call()).called(2); // 2nd call since clear: For isLoading=false after add
    });

    test('handles error when adding a job and notifies listeners', () async {
      // Arrange
      final exception = Exception('Failed to add job');
      when(() => mockDesignService.getJobs()).thenAnswer((_) async => []); // Initial load
      jobProvider = JobProvider(mockDesignService); // Re-initialize
      jobProvider.addListener(mockListener.call); // Re-add listener
      await Future.delayed(Duration.zero); // Allow _fetchJobs from re-init to complete its notifications

      when(() => mockDesignService.createJob(newJob)).thenThrow(exception);

      // Clear interactions for the mockListener from setUp before the addJob action
      clearInteractions(mockListener);

      // Act
      final future = jobProvider.addJob(newJob);
      await future;
      // Assertions will follow after future completes

      // Assert: state after failed add
      expect(jobProvider.jobs, isNot(contains(newJob)));
      expect(jobProvider.isLoading, isFalse);
      expect(jobProvider.errorMessage, exception.toString());
      verify(() => mockListener.call()).called(2); // 2nd call since clear: For isLoading=false after error
    });
  });

  group('updateJob', () {
    final initialJob = createSampleJob('1', jobNo: 'J001', clientName: 'Client A', status: JobStatus.pending);
    final updatedJobDetails = initialJob.copyWith(clientName: 'Client A Updated', status: JobStatus.inProgress);

    setUp(() {
      // Ensure JobProvider is reset and has the initialJob for these tests
      mockDesignService = MockDesignService();
      when(() => mockDesignService.getJobs()).thenAnswer((_) async => [initialJob]);
      jobProvider = JobProvider(mockDesignService);
      mockListener = MockListener(); // Create a new listener for this group to avoid interference
      jobProvider.addListener(mockListener.call);
      // Wait for initial _fetchJobs to complete
      return Future.delayed(Duration.zero);
    });

    test('successfully updates an existing job and notifies listeners', () async {
      // Arrange
      when(() => mockDesignService.updateJob(updatedJobDetails)).thenAnswer((_) async => updatedJobDetails);
      clearInteractions(mockListener); // Clear interactions from _fetchJobs

      // Act
      final future = jobProvider.updateJob(updatedJobDetails);
      await future;
      // Assertions for final state and listener calls will follow

      // Assert: state after successful update
      expect(jobProvider.jobs.first.clientName, 'Client A Updated');
      expect(jobProvider.jobs.first.status, JobStatus.inProgress);
      expect(jobProvider.isLoading, isFalse);
      expect(jobProvider.errorMessage, isNull);
      verify(() => mockListener.call()).called(2); // isLoading=true, then isLoading=false
    });

    test('handles attempt to update a non-existent job gracefully', () async {
      // Arrange
      final nonExistentJob = createSampleJob('non-existent-id', clientName: 'Ghost Client');
      // Mock service to return the non-existent job as if update was attempted (though service might error)
      // Or, more realistically, the service might throw an error if the job ID isn't found for an update.
      // For this test, let's assume the service call itself doesn't fail, but the provider handles it.
      when(() => mockDesignService.updateJob(nonExistentJob)).thenAnswer((_) async => nonExistentJob);
      clearInteractions(mockListener);

      // Act
      final future = jobProvider.updateJob(nonExistentJob);
      await future;
      // Assertions for final state and listener calls will follow

      // Assert: state after attempt to update non-existent job
      expect(jobProvider.jobs.length, 1); // Original job should still be there
      expect(jobProvider.jobs.first.id, initialJob.id);
      expect(jobProvider.isLoading, isFalse);
      // No error message should be set if the service didn't error, but the job wasn't found locally to update.
      // The JobProvider's current updateJob logic prints a message but doesn't set errorMessage for this case.
      expect(jobProvider.errorMessage, isNull);
      verify(() => mockListener.call()).called(2);
    });

    test('handles error from service when updating a job', () async {
      // Arrange
      final exception = Exception('Failed to update job');
      when(() => mockDesignService.updateJob(updatedJobDetails)).thenThrow(exception);
      clearInteractions(mockListener);

      // Act
      final future = jobProvider.updateJob(updatedJobDetails);
      await future;
      // Assertions will follow after future completes

      // Assert: state after failed update
      expect(jobProvider.jobs.first.clientName, 'Client A'); // Data should not have changed
      expect(jobProvider.isLoading, isFalse);
      expect(jobProvider.errorMessage, exception.toString());
      verify(() => mockListener.call()).called(2);
    });
  });

  group('deleteJob', () {
    final jobToDelete = createSampleJob('1', jobNo: 'J001');

    setUp(() {
      // Ensure JobProvider is reset and has the jobToDelete for these tests
      mockDesignService = MockDesignService();
      when(() => mockDesignService.getJobs()).thenAnswer((_) async => [jobToDelete]);
      jobProvider = JobProvider(mockDesignService);
      mockListener = MockListener(); // New listener for this group
      jobProvider.addListener(mockListener.call);
      return Future.delayed(Duration.zero); // Wait for _fetchJobs
    });

    test('successfully deletes an existing job and notifies listeners', () async {
      // Arrange
      when(() => mockDesignService.deleteJob(jobToDelete.id)).thenAnswer((_) async => Future.value());
      clearInteractions(mockListener); // Clear interactions from _fetchJobs

      // Act
      final future = jobProvider.deleteJob(jobToDelete.id);
      await future;
      // Assertions for final state and listener calls will follow

      // Assert: state after successful delete
      expect(jobProvider.jobs, isEmpty);
      expect(jobProvider.isLoading, isFalse);
      expect(jobProvider.errorMessage, isNull);
      verify(() => mockListener.call()).called(2);
    });

    test('handles attempt to delete a non-existent job id gracefully', () async {
      // Arrange
      const nonExistentId = 'non-existent-id';
      // Assume service delete might not error for a non-existent ID, or it might (depends on API design)
      // For this test, let's assume service call is fine, provider handles it.
      when(() => mockDesignService.deleteJob(nonExistentId)).thenAnswer((_) async => Future.value());
      clearInteractions(mockListener);

      // Act
      final future = jobProvider.deleteJob(nonExistentId);
      await future;
      // Assertions for final state and listener calls will follow

      // Assert: state after attempt to delete non-existent job
      expect(jobProvider.jobs.length, 1); // Original job should still be there
      expect(jobProvider.jobs.first.id, jobToDelete.id);
      expect(jobProvider.isLoading, isFalse);
      // JobProvider's deleteJob doesn't set errorMessage if service call is okay but ID not found locally.
      expect(jobProvider.errorMessage, isNull);
      verify(() => mockListener.call()).called(2);
    });

    test('handles error from service when deleting a job', () async {
      // Arrange
      final exception = Exception('Failed to delete job');
      when(() => mockDesignService.deleteJob(jobToDelete.id)).thenThrow(exception);
      clearInteractions(mockListener);

      // Act
      final future = jobProvider.deleteJob(jobToDelete.id);
      await future;
      // Assertions will follow after future completes

      // Assert: state after failed delete
      expect(jobProvider.jobs.length, 1); // Job should still be there
      expect(jobProvider.isLoading, isFalse);
      expect(jobProvider.errorMessage, exception.toString());
      verify(() => mockListener.call()).called(2);
    });
  });
}
