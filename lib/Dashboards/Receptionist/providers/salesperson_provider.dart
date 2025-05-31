import 'package:flutter/foundation.dart';
import '../models/salesperson.dart';
import '../services/receptionist_service.dart';

class SalespersonProvider with ChangeNotifier {
  final ReceptionistService _receptionistService;

  SalespersonProvider(this._receptionistService) {
    fetchSalespersons();
  }

  List<Salesperson> _salespersons = [];
  List<Salesperson> get salespersons => _salespersons; // Master list

  List<Salesperson> _filteredSalespersons = [];
  List<Salesperson> get filteredSalespersons => _filteredSalespersons;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchSalespersons() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final fetchedSalespersons = await _receptionistService.fetchSalespersonsFromSupabase();
      if (fetchedSalespersons.isEmpty) {
        _errorMessage = 'No salespersons found.';
        debugPrint('DEBUG: No salespersons found.');
        _salespersons = [];
        _filteredSalespersons = [];
      } else {
        debugPrint('DEBUG: Fetched \${fetchedSalespersons.length} salespersons.');
        _salespersons = fetchedSalespersons;
        _filteredSalespersons = List.from(_salespersons); // Initialize filtered list
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('DEBUG: Error fetching salespersons: ${e.toString()}');
      _salespersons = [];
      _filteredSalespersons = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchAndFilterSalespersons({
    String searchTerm = '',
    List<SalespersonStatus>? selectedStatuses,
    List<String>? selectedExpertise,
    // Potentially add other filters like department, availability (workload based) here
  }) {
    _isLoading = true;
    notifyListeners();

    List<Salesperson> tempFilteredList = List.from(_salespersons);

    // Filter by search term (name, department, skills)
    if (searchTerm.isNotEmpty) {
      String lowerSearchTerm = searchTerm.toLowerCase();
      tempFilteredList = tempFilteredList.where((sp) {
        return sp.name.toLowerCase().contains(lowerSearchTerm) ||
               sp.department.toLowerCase().contains(lowerSearchTerm) ||
               sp.skills.any((skill) => skill.toLowerCase().contains(lowerSearchTerm)) ||
               sp.expertise.any((exp) => exp.toLowerCase().contains(lowerSearchTerm)) ||
               sp.currentWorkload.toString().contains(lowerSearchTerm);
      }).toList();
    }

    // Filter by status
    if (selectedStatuses != null && selectedStatuses.isNotEmpty) {
      tempFilteredList = tempFilteredList.where((sp) => selectedStatuses.contains(sp.status)).toList();
    }

    // Filter by expertise
    if (selectedExpertise != null && selectedExpertise.isNotEmpty) {
      tempFilteredList = tempFilteredList.where((sp) {
        return selectedExpertise.any((exp) => sp.expertise.map((e) => e.toLowerCase()).contains(exp.toLowerCase()));
      }).toList();
    }

    // TODO: Implement filtering by current workload if needed
    // Example: filter by workload (e.g., sp.currentWorkload < 5 for 'Available Now' if workload represents tasks)

    _filteredSalespersons = tempFilteredList;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateSalespersonStatus(String salespersonId, SalespersonStatus status) async {
    _isLoading = true;
    _errorMessage = null;
    // No need to notifyListeners() here as the UI might not need to show loading for this specific action immediately,
    // or it can be handled by a local loading state in the widget triggering it.
    // However, if a global loading state for this action is desired, uncomment the next line.
    // notifyListeners(); 
    try {
      final updatedSalesperson = await _receptionistService.updateSalespersonStatus(salespersonId, status);
      if (updatedSalesperson != null) {
        // Update the local list
        int index = _salespersons.indexWhere((sp) => sp.id == salespersonId);
        if (index != -1) {
          _salespersons[index] = updatedSalesperson;
          // Also update in filtered list if present
          int filteredIndex = _filteredSalespersons.indexWhere((sp) => sp.id == salespersonId);
          if (filteredIndex != -1) {
            _filteredSalespersons[filteredIndex] = updatedSalesperson;
          }
        }
      } else {
        _errorMessage = 'Failed to update salesperson status or salesperson not found.';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false; // Assuming we want to turn off global loading if it was on
      notifyListeners(); // Notify listeners about the change in data or error state
    }
  }
}
