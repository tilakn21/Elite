import 'package:flutter_test/flutter_test.dart';
import '../lib/Dashboards/Production/models/worker.dart';

void main() {
  group('Worker Model Tests', () {
    test('should correctly identify available worker', () {
      final workerData = {
        'id': '1',
        'full_name': 'John Doe',
        'phone': '1234567890',
        'role': 'prod_labour',
        'is_available': true,
        'assigned_job': null,
      };
      
      final worker = Worker.fromJson(workerData);
      
      expect(worker.isAvailable, true);
      expect(worker.assigned, false);
      expect(worker.assignedJob, null);
    });

    test('should correctly identify assigned worker', () {
      final workerData = {
        'id': '2',
        'full_name': 'Jane Smith',
        'phone': '1234567890',
        'role': 'prod_labour',
        'is_available': true,
        'assigned_job': 'job-123',
      };
      
      final worker = Worker.fromJson(workerData);
      
      expect(worker.isAvailable, false); // Should be false because assigned
      expect(worker.assigned, true);
      expect(worker.assignedJob, 'job-123');
    });

    test('should correctly identify unavailable worker', () {
      final workerData = {
        'id': '3',
        'full_name': 'Bob Johnson',
        'phone': '1234567890',
        'role': 'prod_labour',
        'is_available': false,
        'assigned_job': null,
      };
      
      final worker = Worker.fromJson(workerData);
      
      expect(worker.isAvailable, false);
      expect(worker.assigned, false);
      expect(worker.assignedJob, null);
    });

    test('should handle string booleans correctly', () {
      final workerData = {
        'id': '4',
        'full_name': 'Alice Brown',
        'phone': '1234567890',
        'role': 'prod_labour',
        'is_available': 'true',
        'assigned_job': null,
      };
      
      final worker = Worker.fromJson(workerData);
      
      expect(worker.isAvailable, true);
      expect(worker.assigned, false);
    });
  });
}
