import '../models/printing_job.dart';
import '../models/printing_specification.dart';

class PrintingService {
  // Simulates fetching all printing jobs from a backend
  Future<List<PrintingJob>> getPrintingJobs() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Sample data - replace with actual API call
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
    ];
  }

  // TODO: Implement other service methods as needed:
  // Future<PrintingJob> getPrintingJobDetails(String jobId) async { ... }
  // Future<PrintingJob> updatePrintingJobStatus(String jobId, PrintingStatus newStatus) async { ... }
  // Future<PrintingJob> assignLabotomPrintingJob(String jobId, String labourId, String role) async { ... }
  // Future<PrintingJob> completeQualityCheck(String jobId, bool passed, List<String> issues) async { ... }
  // etc.
}
